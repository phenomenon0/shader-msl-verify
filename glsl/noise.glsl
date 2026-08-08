// ============================================================
// NOISE PRIMITIVES — GLSL 1:1 translation of shader-lab TSL
// source: shader-lab/packages/.../shaders/tsl/noise/
// All bodies match the TSL (three.js) source exactly.
// Metal note: port to MSL by replacing vecN -> floatN, and
// calling this with float3/float4 args. No other changes needed.
// ============================================================

// ---- common.ts ----------------------------------------------
float permute(float x){ return mod((x*34.0+10.0)*x, 289.0); }
float taylorInvSqrt(float r){ return 1.79284291400159 - 0.85373472095314 * r; }
float mod289(float x){ return mod((x*34.0+10.0)*x, 289.0); }
float fade(float t){ return t*t*t*(t*(t*6.0-15.0)+10.0); }
vec3 fade(vec3 t){ return vec3(fade(t.x), fade(t.y), fade(t.z)); }

// grad4: gradient generator for 4D simplex (Ashima/Gustavson)
vec4 grad4(float j, vec4 ip){
  vec4 ones = vec4(1.0,1.0,1.0,-1.0);
  vec4 p, s;
  p.xyz = floor(fract(vec3(j)*ip.xyz)*7.0)*ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = step(p, vec4(0.0));
  p.xyz += s.xyz*(2.0*s.www-1.0);
  return p;
}

// ---- simplex-noise-3d.ts ------------------------------------
float simplexNoise3d(vec3 v) {
  const vec2 C = vec2(1.0/6.0, 1.0/3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

  vec3 i  = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);

  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + 2.0*C.xxx;
  vec3 x3 = x0 - 1.0 + 3.0*C.xxx;

  i = mod(i, 289.0);

  vec4 p = permute(permute(permute(
            i.z + vec4(0.0, i1.z, i2.z, 1.0))
          + i.y + vec4(0.0, i1.y, i2.y, 1.0))
          + i.x + vec4(0.0, i1.x, i2.x, 1.0));

  float n_ = 1.0/7.0;
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_);

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;

  // NOTE: TSL is `1.0 - (abs(x) - abs(y))` == 1 - |x| + |y| (sign variant)
  vec4 h = 1.0 - (abs(x) - abs(y));

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
}

// ---- simplex-noise-4d.ts ------------------------------------
float simplexNoise4d(vec4 v) {
  const vec2 C = vec2(0.1381966011250105, 0.30901699437494745);
  vec4 i  = floor(v + dot(v, C.yyyy));
  vec4 x0 = v - i + dot(i, C.xxxx);

  vec4 i0 = vec4(0.0);
  vec3 isX = step(x0.yzw, x0.xxx);
  vec3 isYZ = step(x0.zww, x0.yyz);

  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  vec4 i3 = clamp(i0, 0.0, 1.0);
  vec4 i2 = clamp(i0 - 1.0, 0.0, 1.0);
  vec4 i1 = clamp(i0 - 2.0, 0.0, 1.0);

  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + 2.0*C.xxxx;
  vec4 x3 = x0 - i3 + 3.0*C.xxxx;
  vec4 x4 = x0 - 1.0 + 4.0*C.xxxx;

  i = mod(i, 289.0);

  float j0 = permute(permute(permute(permute(i.w)+i.z)+i.y)+i.x);
  vec4 j1 = permute(permute(permute(permute(
            i.w + vec4(i1.w, i2.w, i3.w, 1.0))
          + i.z + vec4(i1.z, i2.z, i3.z, 1.0))
          + i.y + vec4(i1.y, i2.y, i3.y, 1.0))
          + i.x + vec4(i1.x, i2.x, i3.x, 1.0));

  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0);

  vec4 p0 = grad4(j0, ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)), 0.0);
  m0 = m0*m0;
  m1 = m1*m1;

  return 49.0 * (
    dot(m0*m0, vec3(dot(p0,x0), dot(p1,x1), dot(p2,x2))) +
    dot(m1*m1, vec2(dot(p3,x3), dot(p4,x4)))
  );
}

// ---- perlin-noise-3d.ts -------------------------------------
float perlinNoise3d(vec3 P) {
  vec3 Pi0 = mod(floor(P), 289.0);
  vec3 Pi1 = mod(Pi0 + 1.0, 289.0);
  vec3 Pf0 = fract(P);
  vec3 Pf1 = Pf0 - 1.0;

  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
  vec4 iz0 = vec4(Pi0.z);
  vec4 iz1 = vec4(Pi1.z);

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = 0.5 - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = 0.5 - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x, gy0.x, gz0.x);
  vec3 g100 = vec3(gx0.y, gy0.y, gz0.y);
  vec3 g010 = vec3(gx0.z, gy0.z, gz0.z);
  vec3 g110 = vec3(gx0.w, gy0.w, gz0.w);
  vec3 g001 = vec3(gx1.x, gy1.x, gz1.x);
  vec3 g101 = vec3(gx1.y, gy1.y, gz1.y);
  vec3 g011 = vec3(gx1.z, gy1.z, gz1.z);
  vec3 g111 = vec3(gx1.w, gy1.w, gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000,g000), dot(g010,g010), dot(g100,g100), dot(g110,g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;

  vec4 norm1 = taylorInvSqrt(vec4(dot(g001,g001), dot(g011,g011), dot(g101,g101), dot(g111,g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.y, Pf0.z));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.x, Pf1.y, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.x, Pf0.y, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.y, Pf1.z));
  float n111 = dot(g111, Pf1);

  vec3 fadeXyz = fade(Pf0);
  vec4 nZ = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fadeXyz.z);
  vec2 nYz = mix(nZ.xy, nZ.zw, fadeXyz.y);
  float nXyz = mix(nYz.x, nYz.y, fadeXyz.x);

  return 2.2 * nXyz;
}

// ---- value-noise-3d.ts --------------------------------------
float hash31(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

float valueNoise3d(vec3 p) {
  vec3 cell = floor(p);
  vec3 local = fract(p);
  vec3 eased = fade(local);

  float n000 = hash31(cell);
  float n100 = hash31(cell + vec3(1, 0, 0));
  float n010 = hash31(cell + vec3(0, 1, 0));
  float n110 = hash31(cell + vec3(1, 1, 0));
  float n001 = hash31(cell + vec3(0, 0, 1));
  float n101 = hash31(cell + vec3(1, 0, 1));
  float n011 = hash31(cell + vec3(0, 1, 1));
  float n111 = hash31(cell + vec3(1, 1, 1));

  float nx00 = mix(n000, n100, eased.x);
  float nx10 = mix(n010, n110, eased.x);
  float nx01 = mix(n001, n101, eased.x);
  float nx11 = mix(n011, n111, eased.x);
  float nxy0 = mix(nx00, nx10, eased.y);
  float nxy1 = mix(nx01, nx11, eased.y);

  return mix(nxy0, nxy1, eased.z) * 2.0 - 1.0;
}

// ---- voronoi-noise-3d.ts ------------------------------------
vec3 random3(vec3 p) {
  return fract(sin(
    vec3(
      dot(p, vec3(127.1, 311.7, 74.7)),
      dot(p, vec3(269.5, 183.3, 246.1)),
      dot(p, vec3(113.5, 271.9, 124.6))
    )
  ) * 43758.5453);
}

float voronoiNoise3d(vec3 p) {
  vec3 i = floor(p);
  vec3 f = fract(p);
  float d = 1.0;
  // Unrolled 3x3x3 neighbor search
  for (int x = -1; x <= 1; x++)
  for (int y = -1; y <= 1; y++)
  for (int z = -1; z <= 1; z++) {
    vec3 neighbor = vec3(float(x), float(y), float(z));
    vec3 point = random3(i + neighbor);
    vec3 diff = neighbor + point - f;
    d = min(d, length(diff));
  }
  return d;
}

// ---- fbm.ts -------------------------------------------------
// TSL uses 2 octaves of normalized simplex, weights 0.7/0.3
float fbm(vec3 p) {
  float n1 = simplexNoise3d(p) * 0.5 + 0.5;
  float n2 = simplexNoise3d(p * 2.02 + vec3(19.1, 7.3, 13.7)) * 0.5 + 0.5;
  return n1 * 0.7 + n2 * 0.3;
}

// ---- ridge-noise.ts -----------------------------------------
float ridgeNoise(vec3 p) {
  float value = 0.0;
  float amplitude = 0.5;
  float frequency = 1.0;
  float weight = 1.0;
  for (int i = 0; i < 6; i++) {
    float n = 1.0 - abs(simplexNoise3d(p * frequency) * 2.0);
    float signal = n * n * weight;
    value += signal * amplitude;
    weight = clamp(signal, 0.0, 1.0);
    frequency *= 2.0;
    amplitude *= 0.5;
  }
  return value;
}

// ---- turbulence.ts (XorDev "Turbulent Dark") ----------------
vec2 turbulence(vec2 pin, float time,
                int num, float amp, float speed, float freq, float exp_) {
  const float HALF_PI = 1.5707963267948966;
  const float THETA   = 0.9272952180016122; // atan2(0.8, 0.6) golden-ish angle
  vec2 p = pin;
  float t = time * speed;
  float angle = 0.0;
  float iter = 0.0;
  for (int i = 0; i < num; i++) {
    float c = sin(angle + HALF_PI);
    float s = sin(angle);
    float phase = freq * (p.x * s + p.y * c) + t + iter;
    float scale = amp * sin(phase) / freq;
    p.x += scale * c;
    p.y += scale * -s;
    angle += THETA;
    freq *= exp_;
    iter += 1.0;
  }
  return p - pin;
}

// ---- curl-noise-3d.ts ---------------------------------------
// Finite-difference gradient of simplex, cross product of two fields
vec3 curlNoise3d(vec3 inputA) {
  float EPSILON = 1e-4;
  float aXAverage = (simplexNoise3d(inputA + vec3( EPSILON, 0, 0)) -
                     simplexNoise3d(inputA - vec3( EPSILON, 0, 0))) / (EPSILON * 2.0);
  float aYAverage = (simplexNoise3d(inputA + vec3(0,  EPSILON, 0)) -
                     simplexNoise3d(inputA - vec3(0,  EPSILON, 0))) / (EPSILON * 2.0);
  float aZAverage = (simplexNoise3d(inputA + vec3(0, 0,  EPSILON)) -
                     simplexNoise3d(inputA - vec3(0, 0,  EPSILON))) / (EPSILON * 2.0);
  vec3 aGrabNoise = normalize(vec3(aXAverage, aYAverage, aZAverage));

  vec3 inputB = inputA + 3.5;
  float bXAverage = (simplexNoise3d(inputB + vec3( EPSILON, 0, 0)) -
                     simplexNoise3d(inputB - vec3( EPSILON, 0, 0))) / (EPSILON * 2.0);
  float bYAverage = (simplexNoise3d(inputB + vec3(0,  EPSILON, 0)) -
                     simplexNoise3d(inputB - vec3(0,  EPSILON, 0))) / (EPSILON * 2.0);
  float bZAverage = (simplexNoise3d(inputB + vec3(0, 0,  EPSILON)) -
                     simplexNoise3d(inputB - vec3(0, 0,  EPSILON))) / (EPSILON * 2.0);
  vec3 bGrabNoise = normalize(vec3(bXAverage, bYAverage, bZAverage));

  return normalize(cross(aGrabNoise, bGrabNoise));
}

// ---- curl-noise-4d.ts ---------------------------------------
vec3 curlNoise4d(vec4 inputA) {
  float EPSILON = 1e-4;
  float aXAverage = (simplexNoise4d(inputA + vec4( EPSILON, 0, 0, 0)) -
                     simplexNoise4d(inputA - vec4( EPSILON, 0, 0, 0))) / (EPSILON * 2.0);
  float aYAverage = (simplexNoise4d(inputA + vec4(0,  EPSILON, 0, 0)) -
                     simplexNoise4d(inputA - vec4(0,  EPSILON, 0, 0))) / (EPSILON * 2.0);
  float aZAverage = (simplexNoise4d(inputA + vec4(0, 0,  EPSILON, 0)) -
                     simplexNoise4d(inputA - vec4(0, 0,  EPSILON, 0))) / (EPSILON * 2.0);
  vec3 aGrabNoise = normalize(vec3(aXAverage, aYAverage, aZAverage));

  vec4 inputB = inputA + 3.5;
  float bXAverage = (simplexNoise4d(inputB + vec4( EPSILON, 0, 0, 0)) -
                     simplexNoise4d(inputB - vec4( EPSILON, 0, 0, 0))) / (EPSILON * 2.0);
  float bYAverage = (simplexNoise4d(inputB + vec4(0,  EPSILON, 0, 0)) -
                     simplexNoise4d(inputB - vec4(0,  EPSILON, 0, 0))) / (EPSILON * 2.0);
  float bZAverage = (simplexNoise4d(inputB + vec4(0, 0,  EPSILON, 0)) -
                     simplexNoise4d(inputB - vec4(0, 0,  EPSILON, 0))) / (EPSILON * 2.0);
  vec3 bGrabNoise = normalize(vec3(bXAverage, bYAverage, bZAverage));

  return normalize(cross(aGrabNoise, bGrabNoise));
}
