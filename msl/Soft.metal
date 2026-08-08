// ============================================================
// SOFT — Metal (MSL) port of gradient-lab `soft` mode
// Source: gradient-lab/shaders/modes/soft.frag.glsl
//
// Faithful: same falloff, drift, blur/spread math. No domain
// warp — clean radial blending, which is cheap: pure ALU, no
// noise behaves besides the grain in writeColor.
//
// Perf notes:
//  - The 8-blob loop is branch-light; `weights[p]` strategy
//    identical to GLSL.
//  - Palettes via float3 in the uniform struct → read once.
// ============================================================
#include "Noise.metal"

using namespace metal;

struct SoftUniforms {
  float  u_time;
  float  u_aspect;        // resolution.x / resolution.y
  float  u_resolutionY;
  float  u_pad0;
  int    u_blobCount;
  float  u_blur;
  float  u_spread;
  float  u_speed;
  float  u_brightness;
  float  u_contrast;
  float  u_saturation;
  float  u_grain;
  float3 u_colors[8];
  float2 u_blobOffsets[8];
};
static_assert(sizeof(SoftUniforms) % 16 == 0, "MSL buffer must be 16B aligned");

struct VSOut {
  float4 position [[position]];
  float2 uv;
};

vertex VSOut vsMain(uint vertexID [[vertex_id]]) {
  float2 uv = float2((vertexID == 0) ? 0.0 : ((vertexID == 1) ? 2.0 : 0.0),
                     (vertexID == 0) ? 1.0 : 0.0);
  float2 pos = uv * 2.0 - 1.0;
  pos.y = 1.0 - pos.y; // GL uv convention: v_uv.y up
  VSOut o;
  o.position = float4(pos, 0.0, 1.0);
  o.uv = float2((vertexID == 0) ? 0.0 : ((vertexID == 1) ? 2.0 : 0.0),
                (vertexID == 0) ? 0.0 : 1.0);
  return o;
}

fragment float4 fsMain(VSOut in [[stage_in]],
                       constant SoftUniforms& u [[buffer(0)]]) {
  const float2 uv = in.uv;
  const float aspect = u.u_aspect;
  float2 p = float2((uv.x - 0.5) * aspect, uv.y - 0.5);

  float t = u.u_time * u.u_speed;

  // Larger blur = softer falloff (faithful from GLSL)
  float falloff = mix(8.0, 1.2, clamp(u.u_blur, 0.0, 1.0));

  float3 col = float3(0.0);
  float total = 0.0;
  const int N = 8;
  for (int i = 0; i < N; ++i) {
    bool active = (i < u.u_blobCount);
    float fi = float(i);
    float2 base = u.u_blobOffsets[i] * float2(aspect, 1.0) *
                  u.u_spread * 1.4;
    float2 drift = 0.04 * float2(
        sin(t + fi * 1.7),
        cos(t * 1.1 + fi * 2.3)
    );
    float2 center = base + drift;
    float d = distance(p, center);
    float w = 1.0 / (d * d * falloff + 0.012);
    float wm = active ? w : 0.0;
    col += u.u_colors[i] * wm;
    total += wm;
  }
  col /= max(total, 1e-4);

  // grade + grain
  return writeColor(uv, u.u_resolutionY, u.u_time, col,
                    u.u_brightness, u.u_contrast, u.u_saturation, u.u_grain);
}