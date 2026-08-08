// ============================================================
// COLOR PRIMITIVES — GLSL 1:1 translation of shader-lab TSL
// source: shader-lab/packages/.../shaders/tsl/color/ + cosine-palette.ts
// ============================================================

// ---- cosine-palette.ts --------------------------------------
// cosinePalette(t, a, b, c, d, e) = a + b*cos(e*(c*t + d))
vec3 cosinePalette(float t, vec3 a, vec3 b, vec3 c, vec3 d, float e) {
  return a + b * cos(e * (c * t + d));
}

// ---- tonemapping.ts -----------------------------------------
vec3 reinhardTonemap(vec3 color) {
  return color / (color + 1.0);
}

// Uncharted2 / "totos" — lifted-shadow split-grade
vec3 totosTonemap(vec3 color) {
  vec3 compressed = color * vec3(1.18, 1.04, 0.94) /
    (color * vec3(0.82, 0.9, 0.98) + vec3(0.78, 0.68, 0.6));
  float lum = dot(compressed, vec3(0.2126, 0.7152, 0.0722));
  float shadowLift = smoothstep(0.0, 0.38, lum);
  float highlightRoll = smoothstep(0.42, 1.0, lum);
  float toneMix = smoothstep(0.16, 0.82, lum);

  vec3 cool = vec3(
    compressed.x * 0.82,
    compressed.y * 0.98 + shadowLift * 0.04,
    compressed.z * 1.24 + shadowLift * 0.08
  );
  vec3 warm = vec3(
    compressed.x * 1.14 + highlightRoll * 0.08,
    compressed.y * 1.03 + highlightRoll * 0.03,
    compressed.z * 0.84
  );
  vec3 splitToned = mix(cool, warm, toneMix);
  vec3 curved = vec3(
    pow(splitToned.x, 0.86),
    pow(splitToned.y, 0.95),
    pow(splitToned.z, 1.12)
  );
  vec3 bleach = mix(curved, vec3(lum), highlightRoll * 0.06);
  return clamp(bleach, 0.0, 1.0);
}

vec3 acesTonemap(vec3 color) {
  const float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
  return clamp(color * (color * a + b) / (color * (color * c + d) + e), 0.0, 1.0);
}

vec3 crossProcessTonemap(vec3 color) {
  vec3 r = vec3(
    pow(color.x, 0.8),
    pow(color.y, 1.2),
    pow(color.z, 1.5)
  );
  return clamp(r, 0.0, 1.0);
}

vec3 bleachBypassTonemap(vec3 color) {
  float lum = dot(color, vec3(0.2126, 0.7152, 0.0722));
  return clamp(mix(vec3(lum), color, 0.7) * 1.2, 0.0, 1.0);
}

vec3 technicolorTonemap(vec3 color) {
  return clamp(vec3(
    color.x * 1.5,
    color.y * 1.2,
    color.z * 0.8 + color.x * 0.2
  ), 0.0, 1.0);
}

vec3 cinematicTonemap(vec3 color) {
  return clamp(vec3(
    smoothstep(0.05, 0.95, color.x * 0.95 + 0.02),
    smoothstep(0.05, 0.95, color.y * 1.05),
    smoothstep(0.05, 0.95, color.z * 1.1)
  ), 0.0, 1.0);
}

float tanh(float x) {
  float tmp = exp(x);
  return (tmp - 1.0 / tmp) / (tmp + 1.0 / tmp);
}