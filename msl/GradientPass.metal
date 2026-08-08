// ============================================================
// GRADIENT PASS — Metal (MSL) port of shader-lab GradientPass
// Source: glsl/gradient-pass.frag.glsl (glsl/ primitives)
//
// The full mesh-gradient engine: 5 color points, domain warp
// (1..5 octaves, noise-mode selectable), vortex swirl, weighted
// blend, then tonemap + glow + grain + vignette.
//
// Perf notes:
//  - Noise mode & tonemap are compile-time constants → the
//    Metal driver can dead-strip unused primitives. swap patterns
//    via a macro to trade code size vs runtime.
//  - The 5-point blend and the octave warp loop are unrolled
//    when `WARP_ITERS` is a compile-time constant.
// ============================================================
#ifndef SHADER_CATALOGUE_GRADIENT_PASS_METAL
#define SHADER_CATALOGUE_GRADIENT_PASS_METAL

#include "Noise.metal"
#include <metal_stdlib>
using namespace metal;

// Which noise drives the domain warp (mirrors TSL noiseType enum)
#define NOISE_SIMPLEX   0
#define NOISE_PERLIN    1
#define NOISE_VALUE     2
#define NOISE_VORONOI   3
#define NOISE_RIDGE     4
#define NOISE_TURBULENCE 5
#ifndef NOISE_MODE
#define NOISE_MODE NOISE_SIMPLEX
#endif

// Which tonemap (mirrors TSL tonemap enum)
#define TM_ACES      0
#define TM_REINHARD  1
#define TM_TOTOS     2
#define TM_CINEMATIC 3
#define TM_NONE      4
#ifndef TONEMAP
#define TONEMAP TM_ACES
#endif

struct GradientPassUniforms {
  float     u_time;
  float     u_aspect;         // resolution.x / resolution.y
  float     u_activePoints;   // 2..5
  float     u_animate;
  float     u_warpAmount;
  float     u_warpBias;
  float     u_warpDecay;
  float     u_warpScale;
  int       u_warpIterations;   // 1..5
  float     u_noiseSeed;
  float     u_vortexAmount;
  float     u_motionAmount;
  float     u_motionSpeed;
  float     u_falloff;
  float     u_glowStrength;
  float     u_glowThreshold;
  float     u_grainAmount;
  float     u_vignetteStrength;
  float     u_vignetteRadius;
  float     u_vignetteSoftness;
  float3    u_pointColors[5];
  float2    u_pointPositions[5];
  float     u_pointWeights[5];
};
static_assert(sizeof(GradientPassUniforms) % 16 == 0,
              "MSL uniform buffer must be 16-byte aligned");

// ---- noise dispatch helper (compile-time selected) ----
inline float2 warpNoise(float2 warpInput, float timeOffsetX, float timeOffsetY) {
#if NOISE_MODE == NOISE_PERLIN
  float nx = perlinNoise3d(float3(warpInput, timeOffsetX));
  float ny = perlinNoise3d(float3(warpInput + float2(13.7, 7.1), timeOffsetY));
  return float2(nx, ny);
#elif NOISE_MODE == NOISE_VORONOI
  float nx = voronoiNoise3d(float3(warpInput, timeOffsetX)) * 2.0 - 1.0;
  float ny = voronoiNoise3d(float3(warpInput + float2(13.7, 7.1), timeOffsetY)) * 2.0 - 1.0;
  return float2(nx, ny);
#elif NOISE_MODE == NOISE_RIDGE
  float nx = ridgeWrap(float3(warpInput, timeOffsetX)) * 2.0 - 1.0;
  float ny = ridgeWrap(float3(warpInput + float2(13.7, 7.1), timeOffsetY)) * 2.0 - 1.0;
  return float2(nx, ny);
#elif NOISE_MODE == NOISE_TURBULENCE
  return turbField(warpInput, timeOffsetX * 20.0);
#else
  // default: simplex
  float nx = simplexNoise3d(float3(warpInput, timeOffsetX));
  float ny = simplexNoise3d(float3(warpInput + float2(13.7, 7.1), timeOffsetY));
  return float2(nx, ny);
#endif
}

// ridge variant wrapper (phe montecarlo: fixed 6 octaves)
float ridgeWrap(float3 warpInput, float timeOffsetX) {
  float value = 0.0;
  float amplitude = 0.5;
  float frequency = 1.0;
  float weight = 1.0;
  #pragma unroll
  for (int i = 0; i < 6; ++i) {
    float n = 1.0 - abs(simplexNoise3d(warpInput * frequency) * 2.0);
    float sig = n * n * weight;
    value += sig * amplitude;
    weight = clamp(sig, 0.0, 1.0);
    frequency *= 2.0;
    amplitude *= 0.5;
  }
  return (value * 2.0) - 1.0;
}

// turbulence — layered rotated sines (Xdigital)
float2 turbField(float2 pIn, float t) {
  const float HALF_PI = 1.5707963267948966;
  const float THETA   = 0.9272952180016122;
  float2 p = pIn;
  float freq = 2.0;
  float angle = 0.0;
  float iter = 0.0;
  #pragma unroll
  for (int i = 0; i < 10; ++i) {
    float c = sin(angle + HALF_PI);
    float s = sin(angle);
    float phase = freq * (p.x * s + p.y * c) + t + iter;
    float scale = 0.7 * sin(phase) / freq;
    p.x += scale * c;
    p.y += scale * -s;
    angle += THETA;
    freq *= 1.4;
    iter += 1.0;
  }
  return p - pIn;
}

// ---- tonemaps (faithful to color.glsl) ----
float3 acesTonemap(float3 c) {
  const float a = 2.51, b = 0.03, cc = 2.43, d = 0.59, e = 0.14;
  return clamp(c * (c * a + b) / (c * (c * cc + d) + e), 0.0, 1.0);
}
float3 reinhardTonemap(float3 c) { return c / (c + 1.0); }
float3 cinematicTonemap(float3 c) {
  return clamp(float3(
      smoothstep(0.05, 0.95, c.x * 0.95 + 0.02),
      smoothstep(0.05, 0.95, c.y * 1.05),
      smoothstep(0.05, 0.95, c.z * 1.1)), 0.0, 1.0);
}

struct VSOut {
  float4 position [[position]];
  float2 uv;
};

vertex VSOut vsMainG(uint vertexID [[vertex_id]]) {
  float2 uv = float2((vertexID == 0) ? 0.0 : ((vertexID == 1) ? 2.0 : 0.0),
                     (vertexID == 0) ? 0.0 : 1.0);
  float2 pos = uv * 2.0 - 1.0;
  VSOut o;
  o.position = float4(pos.x, -pos.y, 0.0, 1.0);
  o.uv = uv;
  return o;
}

fragment float4 fsMain(VSOut in [[stage_in]],
                       constant GradientPassUniforms& u [[buffer(0)]]) {
  // ---- coordinate setup ----
  const float2 uv = in.uv;
  float2 baseUv = float2(
      (uv.x * 2.0 - 1.0) * u.u_aspect,
      (1.0 - uv.y) * 2.0 - 1.0
  );
  float2 vignetteUv = float2(uv.x * 2.0 - 1.0, (1.0 - uv.y) * 2.0 - 1.0);
  float time = u.u_time * u.u_motionSpeed;

  // ---- domain warp (iterations à TSL) ----
  float2 warpedUv = baseUv;
  float biasX = u.u_warpBias * 2.0;
  float biasY = (1.0 - u.u_warpBias) * 2.0;
  float warpIters = min(float(u.u_warpIterations), 5.0);
  for (float fi = 1.0; fi <= warpIters; fi += 1.0) {
    float strength = u.u_warpAmount / pow(fi, u.u_warpDecay);
    float2 warpInput = warpedUv * u.u_warpScale + u.u_noiseSeed * 73.7;
    float timeOffsetX = time * 0.1 + fi * 100.0;
    float timeOffsetY = time * 0.1 + fi * 200.0;
    float2 disp = warpNoise(warpInput, timeOffsetX, timeOffsetY);
    warpedUv.x += strength * disp.x * biasX;
    warpedUv.y += strength * disp.y * biasY;
  }

  // ---- vortex ----
  float distCenter = sqrt(max(dot(warpedUv, warpedUv), 1e-4));
  float vortexAngle = distCenter * u.u_vortexAmount;
  float cA = cos(vortexAngle), sA = sin(vortexAngle);
  float2 rotatedUv = float2(
      warpedUv.x * cA - warpedUv.y * sA,
      warpedUv.x * sA + warpedUv.y * cA
  );

  // ---- 5-point weighted blend ----
  float3 finalColor = float3(0.0);
  float totalWeight = 0.0;
  #pragma unroll
  for (int index = 0; index < 5; ++index) {
    float pointIndex = float(index + 1);
    float active = (u.u_activePoints >= pointIndex) ? 1.0 : 0.0;
    float2 pointPosition = float2(
        u.u_pointPositions[index].x +
            sin(time * (pointIndex * 0.73) + pointIndex) * u.u_motionAmount,
        u.u_pointPositions[index].y +
            cos(time * (pointIndex * 0.41) + pointIndex * 1.7) * u.u_motionAmount
    );
    float2 delta = rotatedUv - pointPosition;
    float dist = sqrt(max(dot(delta, delta), 1e-4));
    float baseWeight = 1.0 / max(pow(dist, u.u_falloff), 1e-4);
    float weighted = baseWeight * u.u_pointWeights[index] * active;
    finalColor += u.u_pointColors[index] * weighted;
    totalWeight += weighted;
  }
  finalColor /= max(totalWeight, 1e-4);

  // ---- grade / tonemap ----
#if TONEMAP == TM_REINHARD
  finalColor = reinhardTonemap(finalColor);
#elif TONEMAP == TM_CINEMATIC
  finalColor = cinematicTonemap(finalColor);
#elif TONEMAP == TM_NONE
  /* none */
#else
  finalColor = acesTonemap(finalColor);
#endif

  float luma = dot(finalColor, float3(0.2126, 0.7152, 0.0722));
  float glow = smoothstep(u.u_glowThreshold, 1.0, luma) * u.u_glowStrength;
  finalColor += float3(glow);

  float grain = (grainTexturePattern(uv) - 0.5) * u.u_grainAmount;
  finalColor += float3(grain);

  float vignetteD = sqrt(max(dot(vignetteUv, vignetteUv), 1e-4));
  float vignette = smoothstep(u.u_vignetteRadius,
                              u.u_vignetteRadius - u.u_vignetteSoftness,
                              vignetteD);
  finalColor *= mix(1.0, vignette, u.u_vignetteStrength);

  return float4(clamp(finalColor, 0.0, 1.0), 1.0);
}

#endif // SHADER_CATALOGUE_GRADIENT_PASS_METAL