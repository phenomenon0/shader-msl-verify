// ============================================================
// UTILITY PRIMITIVES — GLSL 1:1 translation of shader-lab TSL
// source: shader-lab/packages/.../shaders/tsl/utils/
// Requires: PI constant + UV varying (v_uv) for screenAspectUV
// ============================================================
#ifndef PI
#define PI 3.14159265359
#endif

// ---- atan2.ts -------------------------------------------------
float atan2(float y, float x) {
  float base = atan(y / x);
  float offset = sign(y) * PI;
  return x >= 0.0 ? base : base + offset;
}

// ---- rotate.ts -------------------------------------------------
vec2 rotate(vec2 uv, float angle) {
  float cosA = cos(angle);
  float sinA = sin(angle);
  return vec2(
    uv.x * cosA - uv.y * sinA,
    uv.x * sinA + uv.y * cosA
  );
}

// ---- screen-aspect-uv.ts ----------------------------------------
// Remaps a UV to aspect-corrected, centered on (0.5 - range) origin (TSL uv() => GLSL v_uv)
vec2 screenAspectUV(vec2 renderSize, float range, vec2 v_uv) {
  vec2 baseUv = v_uv - range;
  if (renderSize.x > renderSize.y) {
    return vec2(baseUv.x * (renderSize.x / renderSize.y), baseUv.y);
  } else {
    return vec2(baseUv.x, baseUv.y * (renderSize.y / renderSize.x));
  }
}

// ---- smin.ts / smax.ts -----------------------------------------
float smin(float left, float right, float factor) {
  float h = max(factor - abs(left - right), 0.0) / factor;
  return min(left, right) - h * h * factor * 0.25;
}

float smax(float left, float right, float factor) {
  float h = max(factor - abs(left - right), 0.0) / factor;
  return max(left, right) + h * h * factor * 0.25;
}

// ---- sd-box-2d.ts -------------------------------------------------
float sdBox2d(vec2 _uv, float size) {
  return max(abs(_uv.x), abs(_uv.y)) - size;
}

// ---- sd-box-3d.ts -------------------------------------------------
float sdBox3d(vec3 _p, vec3 size) {
  vec3 q = abs(_p) - size;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

// ---- sd-diamond.ts -------------------------------------------------
float sdDiamond(vec2 uvNode, float radius) {
  return abs(uvNode.x) + abs(uvNode.y) - radius;
}

// ---- sd-rhombus.ts -------------------------------------------------
float ndot(vec2 left, vec2 right) {
  return left.x * right.x - left.y * right.y;
}

float sdRhombus(vec2 pointNode, vec2 bounds) {
  vec2 point = abs(pointNode);
  float h = clamp(
    ndot(bounds - point * 2.0, bounds) / dot(bounds, bounds),
    -1.0, 1.0
  );
  float distance = length(
    point - bounds * 0.5 * vec2(1.0 - h, 1.0 + h)
  );
  return distance * sign(
    point.x * bounds.y +
    point.y * bounds.x -
    bounds.x * bounds.y
  );
}

// ---- sd-sphere.ts -------------------------------------------------
float sdSphere(vec2 _uv, float radius) {
  return length(_uv) - radius;
}

// ---- complex conj / mul / div ------------------------------------
vec2 complexConj(vec2 z) { return vec2(z.x, -z.y); }

vec2 complexMul(vec2 a, vec2 b) {
  return vec2(
    a.x * b.x - a.y * b.y,
    a.x * b.y + a.y * b.x
  );
}

vec2 complexDiv(vec2 a, vec2 b) {
  float denominator = dot(b, b);
  return vec2(
    (a.x * b.x + a.y * b.y) / denominator,
    (a.y * b.x - a.x * b.y) / denominator
  );
}

// ---- complex-pow.ts: z^n via polar form ---------------------------
vec2 complexPow(vec2 z, float n) {
  float angle = atan2(z.y, z.x);
  float r = length(z);
  float rn = pow(r, n);
  float nAngle = n * angle;
  return vec2(rn * cos(nAngle), rn * sin(nAngle));
}

// ---- complex-sqrt.ts ----------------------------------------------
vec2 complexSqrt(vec2 z) {
  float r = length(z);
  float rpart = sqrt((r + z.x) * 0.5);
  float ipart = sqrt((r - z.x) * 0.5);
  return z.y >= 0.0
    ? vec2(rpart, ipart)
    : vec2(rpart, -ipart);
}

// ---- complex-log.ts -----------------------------------------------
vec2 complexLog(vec2 z) {
  return vec2(log(length(z)), atan2(z.y, z.x));
}

// ---- complex-sin / complex-cos / complex-tan -----------------------
// Uses cosh/sinh (see hyperbolic.ts at bottom; forward-declared)
float cosh(float x);
float sinh(float x);
vec2 complexSin(vec2 z) { return vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y)); }
vec2 complexCos(vec2 z) { return vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y)); }
vec2 complexTan(vec2 z) { return complexDiv(complexSin(z), complexCos(z)); }

// ---- complex-mobius.ts: (z-1)/(z+1) -------------------------------
vec2 complexMobius(vec2 z) {
  vec2 one = vec2(1.0, 0.0);
  return complexDiv(z - one, z + one);
}

// ---- complex-to-polar.ts -------------------------------------------
vec2 complexToPolar(vec2 z) {
  return vec2(length(z), atan2(z.y, z.x));
}

// ---- hyperbolic.ts ---------------------------------------------------
float cosh(float x) {
  float tmp = exp(x);
  return (tmp + 1.0 / tmp) / 2.0;
}
float sinh(float x) {
  float tmp = exp(x);
  return (tmp - 1.0 / tmp) / 2.0;
}