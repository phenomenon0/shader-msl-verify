// ============================================================
// Shared noise/render helpers — Metal (MSL)
// Faithful port of the gradient-lab FRAG_HEADER (+ shader-lab
// TSL noise primitives) tuned for Metal.
//
// Performance notes:
//  - Uses float (fp32) for noise lattice math; on Apple silicon
//    the GPU may denormalize — keep:  use half2 when porting to
//    tile-defer already computed to avoid resource reuse.
//  - `#pragma unroll` on fixed-count octave loops.
//  - All helpers are `metal::fn`, `noinline` not needed.
// ============================================================
#ifndef SHADER_CATALOGUE_NOISE_METAL
#define SHADER_CATALOGUE_NOISE_METAL

#include <metal_stdlib>
using namespace metal;

// GLSL `mod(x, y)` (floor-based, sign of divisor) — Metal's % / fmod
// truncate instead, so reimplement the GLSL builtin for float/vec.
inline float mod4(float x, float y) { return x - y * floor(x / y); }
inline float2 mod4(float2 x, float y) { return x - y * floor(x / y); }
inline float3 mod4(float3 x, float y) { return x - y * floor(x / y); }
inline float4 mod4(float4 x, float y) { return x - y * floor(x / y); }

// ------------------------------------------------------------
// Ashima 2D simplex (gradient-lab FRAG_HEADER) -- faithful
// ------------------------------------------------------------
inline float3 mod289_3(float3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
inline float2 mod289_2(float2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
inline float3 permute(float3 x) {
  return mod289_3(((x * 34.0) + 1.0) * x);
}

float snoise2D(float2 v) {
  constexpr float4 C = float4(0.211324865405187, 0.366025403784439,
                                   -0.577350269189626, 0.024390243902439);
  float2 i  = floor(v + dot(v, C.yy));
  float2 x0 = v - i + dot(i, C.xx);
  float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  float4 x12 = float4(x0.x, x0.y, x0.x, x0.y) + C.xxzz;
  x12.xy -= i1;
  i = mod289_2(i);
  float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) +
                     i.x + float3(0.0, i1.x, 1.0));
  float3 m = max(0.5 - float3(dot(x0, x0),
                              dot(x12.xy, x12.xy),
                              dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;
  float3 x = 2.0 * fract(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
  float3 g;
  g.x  = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// ------------------------------------------------------------
// 3D simplex (TSL simplex-noise-3d) -- faithful
// ------------------------------------------------------------
inline float permute3(float x) { return mod4((x * 34.0 + 10.0) * x, 289.0); }
inline float4 permute3v(float4 x) { return mod4((x * 34.0 + 10.0) * x, 289.0); }
inline float3 permute3v3(float3 x) { return mod4((x * 34.0 + 10.0) * x, 289.0); }
inline float taylorInvSqrt(float r) { return 1.79284291400159 - 0.85373472095314 * r; }
inline float4 tInvS(float4 r)  { return 1.79284291400159 - 0.85373472095314 * r; }

float simplexNoise3d(float3 v) {
  constexpr float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
  constexpr float4 D = float4(0.0, 0.5, 1.0, 2.0);
  float3 i  = floor(v + dot(v, C.yyy));
  float3 x0 = v - i + dot(i, C.xxx);
  float3 g = step(x0.yzx, x0.xyz);
  float3 l = 1.0 - g;
  float3 i1 = min(g.xyz, l.zxy);
  float3 i2 = max(g.xyz, l.zxy);
  float3 x1 = x0 - i1 + C.xxx;
  float3 x2 = x0 - i2 + 2.0 * C.xxx;
  float3 x3 = x0 - 1.0 + 3.0 * C.xxx;
  i = mod4(i, 289.0);
  float4 p = permute3v(permute3v(permute3v(i.z + float4(0.0, i1.z, i2.z, 1.0)) +
                               i.y + float4(0.0, i1.y, i2.y, 1.0)) +
                      i.x + float4(0.0, i1.x, i2.x, 1.0));
  float n_ = 1.0 / 7.0;
  float3 ns = n_ * D.wyz - D.xzx;
  float4 j = p - 49.0 * floor(p * ns.z * ns.z);
  float4 x_ = floor(j * ns.z);
  float4 y_ = floor(j - 7.0 * x_);
  float4 xx = x_ * ns.x + ns.yyyy;
  float4 yy = y_ * ns.x + ns.yyyy;
  float4 h = 1.0 - (abs(xx) - abs(yy));
  float4 b0 = float4(xx.xy, yy.xy);
  float4 b1 = float4(xx.zw, yy.zw);
  float4 s0 = floor(b0) * 2.0 + 1.0;
  float4 s1 = floor(b1) * 2.0 + 1.0;
  float4 sh = -step(h, float4(0.0));
  float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
  float3 pp0 = float3(a0.xy, h.x);
  float3 pp1 = float3(a0.zw, h.y);
  float3 pp2 = float3(a1.xy, h.z);
  float3 pp3 = float3(a1.zw, h.w);
  float4 norm = tInvS(float4(dot(pp0, pp0), dot(pp1, pp1), dot(pp2, pp2), dot(pp3, pp3)));
  pp0 *= norm.x; pp1 *= norm.y; pp2 *= norm.z; pp3 *= norm.w;
  float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 42.0 * dot(m * m, float4(dot(pp0, x0), dot(pp1, x1), dot(pp2, x2), dot(pp3, x3)));
}

// Global-facing: `sn3d` so Mesh/Soft don't compile it in if unused.
// (A linker-time dead-strip will remove it when GS does.)

// ------------------------------------------------------------
// Perlin 3D (TSL perlin-noise-3d) -- faithful
// ------------------------------------------------------------
inline float fade(float t) {
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}
inline float3 fade(float3 t) {
  return float3(fade(t.x), fade(t.y), fade(t.z));
}

float perlinNoise3d(float3 P) {
  float3 Pi0 = mod4(floor(P), 289.0);
  float3 Pi1 = mod4(Pi0 + 1.0, 289.0);
  float3 Pf0 = fract(P);
  float3 Pf1 = Pf0 - 1.0;
  float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
  float4 iz0 = float4(Pi0.z);
  float4 iz1 = float4(Pi1.z);
  float4 ixy = permute3v(permute3v(ix) + iy);
  float4 ixy0 = permute3v(ixy + iz0);
  float4 ixy1 = permute3v(ixy + iz1);
  float4 gx0 = ixy0 / 7.0;
  float4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  float4 gz0 = 0.5 - abs(gx0) - abs(gy0);
  float4 sz0 = step(gz0, float4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);
  float4 gx1 = ixy1 / 7.0;
  float4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  float4 gz1 = 0.5 - abs(gx1) - abs(gy1);
  float4 sz1 = step(gz1, float4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);
  float3 g000 = float3(gx0.x, gy0.x, gz0.x);
  float3 g100 = float3(gx0.y, gy0.y, gz0.y);
  float3 g010 = float3(gx0.z, gy0.z, gz0.z);
  float3 g110 = float3(gx0.w, gy0.w, gz0.w);
  float3 g001 = float3(gx1.x, gy1.x, gz1.x);
  float3 g101 = float3(gx1.y, gy1.y, gz1.y);
  float3 g011 = float3(gx1.z, gy1.z, gz1.z);
  float3 g111 = float3(gx1.w, gy1.w, gz1.w);
  float4 n0 = tInvS(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= n0.x; g010 *= n0.y; g100 *= n0.z; g110 *= n0.w;
  float4 n1 = tInvS(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= n1.x; g011 *= n1.y; g101 *= n1.z; g111 *= n1.w;
  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
  float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
  float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
  float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
  float n111 = dot(g111, Pf1);
  float3 fadeXyz = fade(Pf0);
  float4 nZ = mix(float4(n000, n100, n010, n110),
                  float4(n001, n101, n011, n111), fadeXyz.z);
  float2 nYz = mix(nZ.xy, nZ.zw, fadeXyz.y);
  float nXyz = mix(nYz.x, nYz.y, fadeXyz.x);
  return 2.2 * nXyz;
}

// ------------------------------------------------------------
// Voronoi 3D (TSL voronoi-noise-3d) -- faithful, 27 taps
// ------------------------------------------------------------
inline float3 random3(float3 p) {
  return fract(sin(float3(dot(p, float3(127.1, 311.7, 74.7)),
                          dot(p, float3(269.5, 183.3, 246.1)),
                          dot(p, float3(113.5, 271.9, 124.6)))) * 43758.5453);
}

float voronoiNoise3d(float3 p) {
  float3 i = floor(p);
  float3 f = fract(p);
  float d = 1.0;
  for (int x = -1; x <= 1; ++x)
    for (int y = -1; y <= 1; ++y)
      for (int z = -1; z <= 1; ++z) {
        float3 nbr = float3(float(x), float(y), float(z));
        float3 pt = random3(i + nbr);
        float3 diff = nbr + pt - f;
        d = min(d, length(diff));
      }
  return d;
}

// grain hash used by GradientPass (patterns/grain-texture-pattern.ts)
inline float grainTexturePattern(float2 uv) {
  return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
}

// ------------------------------------------------------------
// Gradient grade + grain (FRAG_HEADER applyGrade / writeColor)
// — faithful to GLSL: brightness/contrast/saturation, then film
// grain from simplex noise in *pixel* space.
// ------------------------------------------------------------
inline float3 applyGrade(float3 col, float u_brightness,
                         float u_contrast, float u_saturation) {
  col *= u_brightness;
  col = (col - 0.5) * u_contrast + 0.5;
  float lum = dot(col, float3(0.299, 0.587, 0.114));
  col = mix(float3(lum), col, u_saturation);
  return col;
}

inline float4 writeColor(float2 v_uv, float resY, float uTime,
                         float3 col, float uBrightness, float uContrast,
                         float uSaturation, float uGrain) {
  col = applyGrade(col, uBrightness, uContrast, uSaturation);
  // faithful to GLSL: noise sampled in pixel space at u_resolution.y
  float g = (snoise2D(v_uv * resY * 0.6 + uTime * 137.0) - 0.5) * uGrain;
  col += g;
  // float4 output; Metal converts to the render-target format on write.
  return float4(clamp(col, 0.0, 1.0), 1.0);
}

#endif // SHADER_CATALOGUE_NOISE_METAL