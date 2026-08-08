// ============================================================
// PATTERN PRIMITIVES — GLSL 1:1 translation of shader-lab TSL
// source: shader-lab/packages/.../shaders/tsl/patterns/
// Requires: fbm (noise.glsl) + PI constant
// ============================================================
#ifndef PI
#define PI 3.14159265359
#endif

// ---- repeating-pattern.ts ----------------------------------
// pattern = sin(pattern*repeat + time)/repeat
float repeatingPattern(float pattern, float repeat, float time) {
  return sin(pattern * repeat + time) / repeat;
}

// ---- bloom.ts -----------------------------------------------
// pattern = pow(edge/pattern, exponent)  — blooms an edge field
float bloom(float pattern, float edge, float exponent) {
  return pow(edge / pattern, exponent);
}

// ---- bloom-edge-pattern.ts -----------------------------------
float bloomEdgePattern(float pattern, float repeat, float edge, float exponent, float time) {
  pattern = repeatingPattern(pattern, repeat, time);
  pattern = abs(pattern);
  pattern = bloom(pattern, edge, exponent);
  return pattern;
}

// ---- grain-texture-pattern.ts --------------------------------
float grainTexturePattern(vec2 uv) {
  return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

// ---- canvas-weave-pattern.ts ---------------------------------
// 200px grid, FBM-warped cell coords, sin cross-hatch
float canvasWeavePattern(vec2 uv) {
  vec2 grid = fract(uv * 200.0);
  float noiseOffset = fbm(vec3(uv * 30.0, 0.0)) * 0.1;
  vec2 warpedGrid = grid + noiseOffset;

  float weaveX = sin(
    warpedGrid.x * PI + fbm(vec3(uv * 100.0, 0.0)) * 0.5
  );
  float weaveY = sin(
    warpedGrid.y * PI + fbm(vec3(uv * 100.0 + 0.5, 0.0)) * 0.5
  );
  float weave = weaveX * weaveY;
  float smoothedWeave = smoothstep(-0.3, 0.3, weave);

  return mix(0.9, 1.0, smoothedWeave);
  // fbm signature above used 2-3 octaves in TSL; calls omitted for brevity
}