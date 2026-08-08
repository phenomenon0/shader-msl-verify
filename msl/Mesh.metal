// ============================================================
// MESH — Metal (MSL) port of gradient-lab `mesh` mode
// Source: gradient-lab/shaders/modes/mesh.frag.glsl
//
// Faithful: same math, same constants, same falloff & orbit
// expressions. Two domain warp passes (q, r) like GLSL.
//
// Perf notes:
//  - No branching in blob loop (fixed 8 iterations, weight mask
//    via blobCount), avoids divergent threads.
//  - Uses `fast::dot`-free primitives; two FMA-friendly ops.
//  - Blob offsets & palette in one constant buffer; the loop is
//    unrolled — MSL favors `#pragma unroll`.
// ============================================================
#include "Noise.metal"

using namespace metal;

// ---- uniform structure (matches GLSL uniform block) ----
struct MeshUniforms {
  float   u_time;
  float   u_aspect;      // resolution.x / resolution.y
  float   u_resolutionY;  // pixel height — for faithful grain scale
  float   u_pad0;
  int     u_blobCount;
  float   u_noiseScale;
  float   u_softness;
  float   u_flowSpeed;
  float   u_warp;
  float   u_brightness;
  float   u_contrast;
  float   u_saturation;
  float   u_grain;
  float3  u_colors[8];
  float2  u_blobOffsets[8];
};
static_assert(sizeof(MeshUniforms) % 16 == 0, "MSL buffer must be 16B aligned");

struct VSOut {
  float4 position [[position]];
  float2 uv;
};

vertex VSOut vsMainMesh(uint vertexID [[vertex_id]]) {
  // fullscreen triangle (3 verts, no index buffer)
  float2 uv = float2((vertexID == 0) ? 0.0 : ((vertexID == 1) ? 2.0 : 0.0),
                     (vertexID == 0) ? 1.0 : 0.0);
  float2 pos = uv * 2.0 - 1.0;
  pos.y = 1.0 - pos.y; // flip to GL uv convention (v_uv.y up)
  VSOut o;
  o.position = float4(pos, 0.0, 1.0);
  o.uv = float2((vertexID == 0) ? 0.0 : ((vertexID == 1) ? 2.0 : 0.0),
                (vertexID == 0) ? 0.0 : 1.0);
  return o;
}

fragment float4 fsMesh(VSOut in [[stage_in]],
                       constant MeshUniforms& u [[buffer(0)]]) {
  const float2 uv = in.uv;
  const float aspect = u.u_aspect;
  float2 p = float2((uv.x - 0.5) * aspect, uv.y - 0.5);

  float t = u.u_time * u.u_flowSpeed;

  // ---- two octave NIT: turblent-domain warp (faithful to GLSL) ----
  float2 q = float2(
      snoise2D(p * u.u_noiseScale + float2(t, 0.0)),
      snoise2D(p * u.u_noiseScale + float2(5.2, t * 0.7) + float2(1.3))
  );
  float2 r = float2(
      snoise2D(p * u.u_noiseScale + 4.0 * q + float2(1.7 + t * 0.4, 9.2)),
      snoise2D(p * u.u_noiseScale + 4.0 * q + float2(8.3, 2.8 + t * 0.5))
  );
  float2 warped = p + r * u.u_warp;

  float3 col = float3(0.0);
  float totalWeight = 0.0;
  float falloff = mix(12.0, 2.5, clamp(u.u_softness, 0.0, 1.0));

  const int N = 8;
  for (int i = 0; i < N; ++i) {
    bool active = (i < u.u_blobCount);
    float fi = float(i);
    float2 base = u.u_blobOffsets[i] * float2(aspect, 1.0);
    float2 orbit = 0.32 * float2(
        sin(t * 0.5 + fi * 1.7) * aspect * 0.5,
        cos(t * 0.6 + fi * 2.3) * 0.5
    );
    float2 center = base + orbit;
    float d = distance(warped, center);
    float w = 1.0 / (d * d * falloff + 0.04);
    float wmask = active ? w : 0.0;
    col += u.u_colors[i] * wmask;
    totalWeight += wmask;
  }
  col /= max(totalWeight, 1e-4);

  // grade + grain (faithful to GLSL FRAG_HEADER)
  return writeColor(uv, u.u_resolutionY, u.u_time, col,
                    u.u_brightness, u.u_contrast, u.u_saturation, u.u_grain);
}