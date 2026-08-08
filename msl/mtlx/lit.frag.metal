//Metal Shading Language version 2.3
#define __METAL__ 
#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;


struct MetalTexture
{
    texture2d<float> tex;
    sampler s;

    // needed for Storm
    int get_width() { return tex.get_width(); }
    int get_height() { return tex.get_height(); }
    int get_num_mip_levels() { return tex.get_num_mip_levels(); }
};

float4 texture(MetalTexture mtlTex, float2 uv)
{
    return mtlTex.tex.sample(mtlTex.s, uv);
}

float4 textureLod(MetalTexture mtlTex, float2 uv, float lod)
{
    return mtlTex.tex.sample(mtlTex.s, uv, level(lod));
}

float4 textureGrad(MetalTexture mtlTex, float2 uv, float2 dx, float2 dy)
{
    return mtlTex.tex.sample(mtlTex.s, uv, gradient2d(dx, dy));
}

int2 textureSize(MetalTexture mtlTex, int mipLevel)
{
    return int2(mtlTex.tex.get_width(), mtlTex.tex.get_height());
}
struct BSDF { float3 response; float3 throughput; };
#define EDF float3
struct VDF { float3 response; float3 throughput; };
struct surfaceshader { float3 color; float3 transparency; };
struct volumeshader { float3 color; float3 transparency; };
struct displacementshader { float3 offset; float scale; };
struct lightshader { float3 intensity; float3 direction; };
#define material surfaceshader

// Uniform block: PrivateUniforms
struct PrivateUniforms
{
    float4x4 u_envMatrix;
    float u_envLightIntensity;
    int u_envRadianceMips;
    int u_envRadianceSamples;
    bool u_refractionTwoSided;
    float3 u_viewPosition;
    int u_numActiveLightSources;
};

// Uniform block: PublicUniforms
struct PublicUniforms
{
    surfaceshader backsurfaceshader;
    displacementshader displacementshader1;
    float noise_r_amplitude;
    int noise_r_octaves;
    float noise_r_lacunarity;
    float noise_r_diminish;
    float noise_g_amplitude;
    int noise_g_octaves;
    float noise_g_lacunarity;
    float noise_g_diminish;
    float noise_b_amplitude;
    int noise_b_octaves;
    float noise_b_lacunarity;
    float noise_b_diminish;
    float SR_triplanar_base;
    float3 SR_triplanar_base_color;
    float SR_triplanar_diffuse_roughness;
    float SR_triplanar_metalness;
    float SR_triplanar_specular;
    float3 SR_triplanar_specular_color;
    float SR_triplanar_specular_roughness;
    float SR_triplanar_specular_IOR;
    float SR_triplanar_specular_anisotropy;
    float SR_triplanar_specular_rotation;
    float SR_triplanar_transmission;
    float3 SR_triplanar_transmission_color;
    float SR_triplanar_transmission_depth;
    float3 SR_triplanar_transmission_scatter;
    float SR_triplanar_transmission_scatter_anisotropy;
    float SR_triplanar_transmission_dispersion;
    float SR_triplanar_transmission_extra_roughness;
    float SR_triplanar_subsurface;
    float3 SR_triplanar_subsurface_color;
    float3 SR_triplanar_subsurface_radius;
    float SR_triplanar_subsurface_scale;
    float SR_triplanar_subsurface_anisotropy;
    float SR_triplanar_sheen;
    float3 SR_triplanar_sheen_color;
    float SR_triplanar_sheen_roughness;
    float SR_triplanar_coat;
    float3 SR_triplanar_coat_color;
    float SR_triplanar_coat_roughness;
    float SR_triplanar_coat_anisotropy;
    float SR_triplanar_coat_rotation;
    float SR_triplanar_coat_IOR;
    float SR_triplanar_coat_affect_color;
    float SR_triplanar_coat_affect_roughness;
    float SR_triplanar_thin_film_thickness;
    float SR_triplanar_thin_film_IOR;
    float SR_triplanar_emission;
    float3 SR_triplanar_opacity;
    bool SR_triplanar_thin_walled;
};

// Inputs block: VertexData
struct VertexData
{
    float4 pos [[position]];
    float3 normalWorld ;
    float3 tangentWorld ;
    float3 positionObject ;
    float3 positionWorld ;
};
// Pixel shader outputs
struct PixelOutputs
{
    float4 out1;
};

#define DIRECTIONAL_ALBEDO_METHOD 0

#define AIRY_FRESNEL_ITERATIONS 2

#define MAX_LIGHT_SOURCES 1
struct LightData
{
    float3 direction;
    float3 color;
    int type;
    float intensity;
    float pad0;
    float pad1;
};

struct LightData_pixel
{
    LightData u_lightData[MAX_LIGHT_SOURCES];
};

float3x3 operator+(float3x3 a, float b)
{
    return a + float3x3(b,b,b,b,b,b,b,b,b);
}

float4x4 operator+(float4x4 a, float b)
{
    return a + float4x4(b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b);
}

float3x3 operator-(float3x3 a, float b)
{
    return a - float3x3(b,b,b,b,b,b,b,b,b);
}

float4x4 operator-(float4x4 a, float b)
{
    return a - float4x4(b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b);
}

float3x3 operator/(float3x3 a, float3x3 b)
{
    for(int i = 0; i < 3; ++i)
        for(int j = 0; j < 3; ++j)
            a[i][j] /= b[i][j];

    return a;
}

float4x4 operator/(float4x4 a, float4x4 b)
{
    for(int i = 0; i < 4; ++i)
        for(int j = 0; j < 4; ++j)
            a[i][j] /= b[i][j];

    return a;
}

float3x3 operator/(float3x3 a, float b)
{
    for(int i = 0; i < 3; ++i)
        for(int j = 0; j < 3; ++j)
            a[i][j] /= b;

    return a;
}

float4x4 operator/(float4x4 a, float b)
{
    for(int i = 0; i < 4; ++i)
        for(int j = 0; j < 4; ++j)
            a[i][j] /= b;

    return a;
}
struct GlobalContext
{
    GlobalContext(
    VertexData vd
,     constant LightData u_lightData[MAX_LIGHT_SOURCES]
    ,     float4x4 u_envMatrix

, MetalTexture u_envRadiance    ,     float u_envLightIntensity

    ,     int u_envRadianceMips

    ,     int u_envRadianceSamples

, MetalTexture u_envIrradiance    ,     bool u_refractionTwoSided

    ,     float3 u_viewPosition

    ,     int u_numActiveLightSources

    ,     surfaceshader backsurfaceshader

    ,     displacementshader displacementshader1

    ,     float noise_r_amplitude

    ,     int noise_r_octaves

    ,     float noise_r_lacunarity

    ,     float noise_r_diminish

    ,     float noise_g_amplitude

    ,     int noise_g_octaves

    ,     float noise_g_lacunarity

    ,     float noise_g_diminish

    ,     float noise_b_amplitude

    ,     int noise_b_octaves

    ,     float noise_b_lacunarity

    ,     float noise_b_diminish

    ,     float SR_triplanar_base

    ,     float3 SR_triplanar_base_color

    ,     float SR_triplanar_diffuse_roughness

    ,     float SR_triplanar_metalness

    ,     float SR_triplanar_specular

    ,     float3 SR_triplanar_specular_color

    ,     float SR_triplanar_specular_roughness

    ,     float SR_triplanar_specular_IOR

    ,     float SR_triplanar_specular_anisotropy

    ,     float SR_triplanar_specular_rotation

    ,     float SR_triplanar_transmission

    ,     float3 SR_triplanar_transmission_color

    ,     float SR_triplanar_transmission_depth

    ,     float3 SR_triplanar_transmission_scatter

    ,     float SR_triplanar_transmission_scatter_anisotropy

    ,     float SR_triplanar_transmission_dispersion

    ,     float SR_triplanar_transmission_extra_roughness

    ,     float SR_triplanar_subsurface

    ,     float3 SR_triplanar_subsurface_color

    ,     float3 SR_triplanar_subsurface_radius

    ,     float SR_triplanar_subsurface_scale

    ,     float SR_triplanar_subsurface_anisotropy

    ,     float SR_triplanar_sheen

    ,     float3 SR_triplanar_sheen_color

    ,     float SR_triplanar_sheen_roughness

    ,     float SR_triplanar_coat

    ,     float3 SR_triplanar_coat_color

    ,     float SR_triplanar_coat_roughness

    ,     float SR_triplanar_coat_anisotropy

    ,     float SR_triplanar_coat_rotation

    ,     float SR_triplanar_coat_IOR

    ,     float SR_triplanar_coat_affect_color

    ,     float SR_triplanar_coat_affect_roughness

    ,     float SR_triplanar_thin_film_thickness

    ,     float SR_triplanar_thin_film_IOR

    ,     float SR_triplanar_emission

    ,     float3 SR_triplanar_opacity

    ,     bool SR_triplanar_thin_walled

    ) : 
gl_FragCoord(    vd.pos)
,    vd(vd)
,     u_lightData
    {
        u_lightData[0]
    }
    ,     u_envMatrix(u_envMatrix)

,     u_envRadiance(u_envRadiance)
    ,     u_envLightIntensity(u_envLightIntensity)

    ,     u_envRadianceMips(u_envRadianceMips)

    ,     u_envRadianceSamples(u_envRadianceSamples)

,     u_envIrradiance(u_envIrradiance)
    ,     u_refractionTwoSided(u_refractionTwoSided)

    ,     u_viewPosition(u_viewPosition)

    ,     u_numActiveLightSources(u_numActiveLightSources)

    ,     backsurfaceshader(backsurfaceshader)

    ,     displacementshader1(displacementshader1)

    ,     noise_r_amplitude(noise_r_amplitude)

    ,     noise_r_octaves(noise_r_octaves)

    ,     noise_r_lacunarity(noise_r_lacunarity)

    ,     noise_r_diminish(noise_r_diminish)

    ,     noise_g_amplitude(noise_g_amplitude)

    ,     noise_g_octaves(noise_g_octaves)

    ,     noise_g_lacunarity(noise_g_lacunarity)

    ,     noise_g_diminish(noise_g_diminish)

    ,     noise_b_amplitude(noise_b_amplitude)

    ,     noise_b_octaves(noise_b_octaves)

    ,     noise_b_lacunarity(noise_b_lacunarity)

    ,     noise_b_diminish(noise_b_diminish)

    ,     SR_triplanar_base(SR_triplanar_base)

    ,     SR_triplanar_base_color(SR_triplanar_base_color)

    ,     SR_triplanar_diffuse_roughness(SR_triplanar_diffuse_roughness)

    ,     SR_triplanar_metalness(SR_triplanar_metalness)

    ,     SR_triplanar_specular(SR_triplanar_specular)

    ,     SR_triplanar_specular_color(SR_triplanar_specular_color)

    ,     SR_triplanar_specular_roughness(SR_triplanar_specular_roughness)

    ,     SR_triplanar_specular_IOR(SR_triplanar_specular_IOR)

    ,     SR_triplanar_specular_anisotropy(SR_triplanar_specular_anisotropy)

    ,     SR_triplanar_specular_rotation(SR_triplanar_specular_rotation)

    ,     SR_triplanar_transmission(SR_triplanar_transmission)

    ,     SR_triplanar_transmission_color(SR_triplanar_transmission_color)

    ,     SR_triplanar_transmission_depth(SR_triplanar_transmission_depth)

    ,     SR_triplanar_transmission_scatter(SR_triplanar_transmission_scatter)

    ,     SR_triplanar_transmission_scatter_anisotropy(SR_triplanar_transmission_scatter_anisotropy)

    ,     SR_triplanar_transmission_dispersion(SR_triplanar_transmission_dispersion)

    ,     SR_triplanar_transmission_extra_roughness(SR_triplanar_transmission_extra_roughness)

    ,     SR_triplanar_subsurface(SR_triplanar_subsurface)

    ,     SR_triplanar_subsurface_color(SR_triplanar_subsurface_color)

    ,     SR_triplanar_subsurface_radius(SR_triplanar_subsurface_radius)

    ,     SR_triplanar_subsurface_scale(SR_triplanar_subsurface_scale)

    ,     SR_triplanar_subsurface_anisotropy(SR_triplanar_subsurface_anisotropy)

    ,     SR_triplanar_sheen(SR_triplanar_sheen)

    ,     SR_triplanar_sheen_color(SR_triplanar_sheen_color)

    ,     SR_triplanar_sheen_roughness(SR_triplanar_sheen_roughness)

    ,     SR_triplanar_coat(SR_triplanar_coat)

    ,     SR_triplanar_coat_color(SR_triplanar_coat_color)

    ,     SR_triplanar_coat_roughness(SR_triplanar_coat_roughness)

    ,     SR_triplanar_coat_anisotropy(SR_triplanar_coat_anisotropy)

    ,     SR_triplanar_coat_rotation(SR_triplanar_coat_rotation)

    ,     SR_triplanar_coat_IOR(SR_triplanar_coat_IOR)

    ,     SR_triplanar_coat_affect_color(SR_triplanar_coat_affect_color)

    ,     SR_triplanar_coat_affect_roughness(SR_triplanar_coat_affect_roughness)

    ,     SR_triplanar_thin_film_thickness(SR_triplanar_thin_film_thickness)

    ,     SR_triplanar_thin_film_IOR(SR_triplanar_thin_film_IOR)

    ,     SR_triplanar_emission(SR_triplanar_emission)

    ,     SR_triplanar_opacity(SR_triplanar_opacity)

    ,     SR_triplanar_thin_walled(SR_triplanar_thin_walled)

    {}
    #define M_FLOAT_EPS 1e-8
    #define M_PI M_PI_F
    
    #define mx_sin metal::sin
    #define mx_cos metal::cos
    #define mx_tan metal::tan
    #define mx_asin metal::asin
    #define mx_acos metal::acos
    #define mx_float_bits_to_int as_type<int>
    
    float2 mx_matrix_mul(float2 v, float2x2 m) { return v * m; }
    float3 mx_matrix_mul(float3 v, float3x3 m) { return v * m; }
    float4 mx_matrix_mul(float4 v, float4x4 m) { return v * m; }
    float2 mx_matrix_mul(float2x2 m, float2 v) { return m * v; }
    float3 mx_matrix_mul(float3x3 m, float3 v) { return m * v; }
    float4 mx_matrix_mul(float4x4 m, float4 v) { return m * v; }
    float2x2 mx_matrix_mul(float2x2 m1, float2x2 m2) { return m1 * m2; }
    float3x3 mx_matrix_mul(float3x3 m1, float3x3 m2) { return m1 * m2; }
    float4x4 mx_matrix_mul(float4x4 m1, float4x4 m2) { return m1 * m2; }
    
    float mx_square(float x)
    {
        return x*x;
    }
    
    float2 mx_square(float2 x)
    {
        return x*x;
    }
    
    float3 mx_square(float3 x)
    {
        return x*x;
    }
    
    float mx_inversesqrt(float x)
    {
        return metal::rsqrt(x);
    }
    
    template<class T1, class T2>
    T1 mx_mod(T1 x, T2 y)
    {
        return x - y * floor(x/y);
    }
    
    float3x3 mx_inverse(float3x3 m)
    {
        float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0];
        float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1];
        float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2];
    
        float det = metal::determinant(m);
        float idet = 1.0f / det;
    
        float3x3 ret;
    
        ret[0][0] = idet * (n22 * n33 - n32 * n23);
        ret[1][0] = idet * (n32 * n13 - n12 * n33);
        ret[2][0] = idet * (n12 * n23 - n22 * n13);
        
        ret[0][1] = idet * (n31 * n23 - n21 * n33);
        ret[1][1] = idet * (n11 * n33 - n31 * n13);
        ret[2][1] = idet * (n21 * n13 - n11 * n23);
        
        ret[0][2] = idet * (n21 * n32 - n31 * n22);
        ret[1][2] = idet * (n31 * n12 - n11 * n32);
        ret[2][2] = idet * (n11 * n22 - n21 * n12);
    
        return ret;
    }
    
    float4x4 mx_inverse(float4x4 m)
    {
        float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
        float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
        float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
        float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];
    
        float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
        float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
        float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
        float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;
    
        float det = metal::determinant(m);
        float idet = 1.0f / det;
    
        float4x4 ret;
    
        ret[0][0] = t11 * idet;
        ret[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
        ret[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
        ret[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;
    
        ret[1][0] = t12 * idet;
        ret[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
        ret[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
        ret[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;
    
        ret[2][0] = t13 * idet;
        ret[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
        ret[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
        ret[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;
    
        ret[3][0] = t14 * idet;
        ret[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
        ret[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
        ret[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;
    
        return ret;
    }
    
    float mx_atan(float y_over_x)
    {
        return metal::atan(y_over_x);
    }
    
    float mx_atan(float y, float x)
    {
        return metal::atan2(y, x);
    }
    
    float2 mx_atan(float2 y, float2 x)
    {
        return metal::atan2(y, x);
    }
    
    float3 mx_atan(float3 y, float3 x)
    {
        return metal::atan2(y, x);
    }
    
    float4 mx_atan(float4 y, float4 x)
    {
        return metal::atan2(y, x);
    }
    
    float mx_radians(float degree)
    {
        return (degree * M_PI_F / 180.0f);
    }
    
    float2 mx_radians(float2 degree)
    {
        return (degree * M_PI_F / 180.0f);
    }

    #define M_PI 3.1415926535897932
    #define M_PI_INV (1.0 / M_PI)
    
    float mx_pow5(float x)
    {
        return mx_square(mx_square(x)) * x;
    }
    
    float mx_pow6(float x)
    {
        float x2 = mx_square(x);
        return mx_square(x2) * x2;
    }
    
    // Standard Schlick Fresnel
    float mx_fresnel_schlick(float cosTheta, float F0)
    {
        float x = clamp(1.0 - cosTheta, 0.0, 1.0);
        float x5 = mx_pow5(x);
        return F0 + (1.0 - F0) * x5;
    }
    float3 mx_fresnel_schlick(float cosTheta, float3 F0)
    {
        float x = clamp(1.0 - cosTheta, 0.0, 1.0);
        float x5 = mx_pow5(x);
        return F0 + (1.0 - F0) * x5;
    }
    
    // Generalized Schlick Fresnel
    float mx_fresnel_schlick(float cosTheta, float F0, float F90)
    {
        float x = clamp(1.0 - cosTheta, 0.0, 1.0);
        float x5 = mx_pow5(x);
        return mix(F0, F90, x5);
    }
    float3 mx_fresnel_schlick(float cosTheta, float3 F0, float3 F90)
    {
        float x = clamp(1.0 - cosTheta, 0.0, 1.0);
        float x5 = mx_pow5(x);
        return mix(F0, F90, x5);
    }
    
    // Generalized Schlick Fresnel with a variable exponent
    float mx_fresnel_schlick(float cosTheta, float F0, float F90, float exponent)
    {
        float x = clamp(1.0 - cosTheta, 0.0, 1.0);
        return mix(F0, F90, pow(x, exponent));
    }
    float3 mx_fresnel_schlick(float cosTheta, float3 F0, float3 F90, float exponent)
    {
        float x = clamp(1.0 - cosTheta, 0.0, 1.0);
        return mix(F0, F90, pow(x, exponent));
    }
    
    // Enforce that the given normal is forward-facing from the specified view direction.
    float3 mx_forward_facing_normal(float3 N, float3 V)
    {
        return (dot(N, V) < 0.0) ? -N : N;
    }
    
    // https://www.graphics.rwth-aachen.de/publication/2/jgt.pdf
    float mx_golden_ratio_sequence(int i)
    {
        const float GOLDEN_RATIO = 1.6180339887498948;
        return fract((float(i) + 1.0) * GOLDEN_RATIO);
    }
    
    // https://people.irisa.fr/Ricardo.Marques/articles/2013/SF_CGF.pdf
    float2 mx_spherical_fibonacci(int i, int numSamples)
    {
        return float2((float(i) + 0.5) / float(numSamples), mx_golden_ratio_sequence(i));
    }
    
    // Generate a uniform-weighted sample on the unit hemisphere.
    float3 mx_uniform_sample_hemisphere(float2 Xi)
    {
        float phi = 2.0 * M_PI * Xi.x;
        float cosTheta = 1.0 - Xi.y;
        float sinTheta = sqrt(1.0 - mx_square(cosTheta));
        return float3(mx_cos(phi) * sinTheta,
                    mx_sin(phi) * sinTheta,
                    cosTheta);
    }
    
    // Generate a cosine-weighted sample on the unit hemisphere.
    float3 mx_cosine_sample_hemisphere(float2 Xi)
    {
        float phi = 2.0 * M_PI * Xi.x;
        float cosTheta = sqrt(Xi.y);
        float sinTheta = sqrt(1.0 - Xi.y);
        return float3(mx_cos(phi) * sinTheta,
                    mx_sin(phi) * sinTheta,
                    cosTheta);
    }
    
    // PDF of a cosine-weighted hemisphere sample.
    float mx_cosine_hemisphere_PDF(float cosTheta)
    {
        return max(cosTheta, 0.0) * M_PI_INV;
    }
    
    // PDF of a uniform hemisphere sample.
    float mx_uniform_hemisphere_PDF()
    {
        return 0.5 * M_PI_INV;
    }
    
    // Construct an orthonormal basis from a unit vector.
    // https://graphics.pixar.com/library/OrthonormalB/paper.pdf
    float3x3 mx_orthonormal_basis(float3 N)
    {
        float sign = (N.z < 0.0) ? -1.0 : 1.0;
        float a = -1.0 / (sign + N.z);
        float b = N.x * N.y * a;
        float3 X = float3(1.0 + sign * N.x * N.x * a, sign * b, -sign * N.x);
        float3 Y = float3(b, sign + N.y * N.y * a, -N.y);
        return float3x3(X, Y, N);
    }
    
    const int FRESNEL_MODEL_DIELECTRIC = 0;
    const int FRESNEL_MODEL_CONDUCTOR = 1;
    const int FRESNEL_MODEL_SCHLICK = 2;
    
    // Parameters for Fresnel calculations
    struct FresnelData
    {
        // Fresnel model
        int model;
        bool airy;
    
        // Physical Fresnel
        float3 ior;
        float3 extinction;
    
        // Generalized Schlick Fresnel
        float3 F0;
        float3 F82;
        float3 F90;
        float exponent;
    
        // Thin film
        float tf_thickness;
        float tf_ior;
    
        // Refraction
        bool refraction;
    };
    
    // https://media.disneyanimation.com/uploads/production/publication_asset/48/asset/s2012_pbs_disney_brdf_notes_v3.pdf
    // Appendix B.2 Equation 13
    float mx_ggx_NDF(float3 H, float2 alpha)
    {
        float2 He = H.xy / alpha;
        float denom = dot(He, He) + mx_square(H.z);
        return 1.0 / (M_PI * alpha.x * alpha.y * mx_square(denom));
    }
    
    // https://ggx-research.github.io/publication/2023/06/09/publication-ggx.html
    float3 mx_ggx_importance_sample_VNDF(float2 Xi, float3 V, float2 alpha)
    {
        // Transform the view direction to the hemisphere configuration.
        V = normalize(float3(V.xy * alpha, V.z));
    
        // Sample a spherical cap in (-V.z, 1].
        float phi = 2.0 * M_PI * Xi.x;
        float z = (1.0 - Xi.y) * (1.0 + V.z) - V.z;
        float sinTheta = sqrt(clamp(1.0 - z * z, 0.0, 1.0));
        float x = sinTheta * mx_cos(phi);
        float y = sinTheta * mx_sin(phi);
        float3 c = float3(x, y, z);
    
        // Compute the microfacet normal.
        float3 H = c + V;
    
        // Transform the microfacet normal back to the ellipsoid configuration.
        H = normalize(float3(H.xy * alpha, max(H.z, 0.0)));
    
        return H;
    }
    
    // PDF of a reflection direction sampled from the GGX VNDF.
    float mx_ggx_VNDF_reflection_PDF(float3 H, float2 alpha, float G1V, float NdotV)
    {
        return mx_ggx_NDF(H, alpha) * G1V / (4.0 * NdotV);
    }
    
    // https://www.cs.cornell.edu/~srm/publications/EGSR07-btdf.pdf
    // Equation 34
    float mx_ggx_smith_G1(float cosTheta, float alpha)
    {
        float cosTheta2 = mx_square(cosTheta);
        float tanTheta2 = (1.0 - cosTheta2) / cosTheta2;
        return 2.0 / (1.0 + sqrt(1.0 + mx_square(alpha) * tanTheta2));
    }
    
    // Height-correlated Smith masking-shadowing
    // http://jcgt.org/published/0003/02/03/paper.pdf
    // Equations 72 and 99
    float mx_ggx_smith_G2(float NdotL, float NdotV, float alpha)
    {
        float alpha2 = mx_square(alpha);
        float lambdaL = sqrt(alpha2 + (1.0 - alpha2) * mx_square(NdotL));
        float lambdaV = sqrt(alpha2 + (1.0 - alpha2) * mx_square(NdotV));
        return 2.0 * NdotL * NdotV / (lambdaL * NdotV + lambdaV * NdotL);
    }
    
    // Rational quadratic fit to Monte Carlo data for GGX directional albedo.
    float3 mx_ggx_dir_albedo_analytic(float NdotV, float alpha, float3 F0, float3 F90)
    {
        float x = NdotV;
        float y = alpha;
        float x2 = mx_square(x);
        float y2 = mx_square(y);
        float4 r = float4(0.1003, 0.9345, 1.0, 1.0) +
                 float4(-0.6303, -2.323, -1.765, 0.2281) * x +
                 float4(9.748, 2.229, 8.263, 15.94) * y +
                 float4(-2.038, -3.748, 11.53, -55.83) * x * y +
                 float4(29.34, 1.424, 28.96, 13.08) * x2 +
                 float4(-8.245, -0.7684, -7.507, 41.26) * y2 +
                 float4(-26.44, 1.436, -36.11, 54.9) * x2 * y +
                 float4(19.99, 0.2913, 15.86, 300.2) * x * y2 +
                 float4(-5.448, 0.6286, 33.37, -285.1) * x2 * y2;
        float2 AB = clamp(r.xy / r.zw, 0.0, 1.0);
        return F0 * AB.x + F90 * AB.y;
    }
    
    float3 mx_ggx_dir_albedo_table_lookup(float NdotV, float alpha, float3 F0, float3 F90)
    {
    #if DIRECTIONAL_ALBEDO_METHOD == 1
        if (textureSize(u_albedoTable, 0).x > 1)
        {
            float2 AB = texture(u_albedoTable, float2(NdotV, alpha)).rg;
            return F0 * AB.x + F90 * AB.y;
        }
    #endif
        return float3(0.0);
    }
    
    // https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
    float3 mx_ggx_dir_albedo_monte_carlo(float NdotV, float alpha, float3 F0, float3 F90)
    {
        NdotV = clamp(NdotV, M_FLOAT_EPS, 1.0);
        float3 V = float3(sqrt(1.0 - mx_square(NdotV)), 0, NdotV);
    
        float2 AB = float2(0.0);
        const int SAMPLE_COUNT = 64;
        for (int i = 0; i < SAMPLE_COUNT; i++)
        {
            float2 Xi = mx_spherical_fibonacci(i, SAMPLE_COUNT);
    
            // Compute the half vector and incoming light direction.
            float3 H = mx_ggx_importance_sample_VNDF(Xi, V, float2(alpha));
            float3 L = -reflect(V, H);
            
            // Compute dot products for this sample.
            float NdotL = clamp(L.z, M_FLOAT_EPS, 1.0);
            float VdotH = clamp(dot(V, H), M_FLOAT_EPS, 1.0);
    
            // Compute the Fresnel term.
            float Fc = mx_fresnel_schlick(VdotH, 0.0, 1.0);
    
            // Compute the per-sample geometric term.
            // https://hal.inria.fr/hal-00996995v2/document, Algorithm 2
            float G2 = mx_ggx_smith_G2(NdotL, NdotV, alpha);
            
            // Add the contribution of this sample.
            AB += float2(G2 * (1.0 - Fc), G2 * Fc);
        }
    
        // Apply the global component of the geometric term and normalize.
        AB /= mx_ggx_smith_G1(NdotV, alpha) * float(SAMPLE_COUNT);
    
        // Return the final directional albedo.
        return F0 * AB.x + F90 * AB.y;
    }
    
    float3 mx_ggx_dir_albedo(float NdotV, float alpha, float3 F0, float3 F90)
    {
    #if DIRECTIONAL_ALBEDO_METHOD == 0
        return mx_ggx_dir_albedo_analytic(NdotV, alpha, F0, F90);
    #elif DIRECTIONAL_ALBEDO_METHOD == 1
        return mx_ggx_dir_albedo_table_lookup(NdotV, alpha, F0, F90);
    #else
        return mx_ggx_dir_albedo_monte_carlo(NdotV, alpha, F0, F90);
    #endif
    }
    
    float mx_ggx_dir_albedo(float NdotV, float alpha, float F0, float F90)
    {
        return mx_ggx_dir_albedo(NdotV, alpha, float3(F0), float3(F90)).x;
    }
    
    // https://blog.selfshadow.com/publications/turquin/ms_comp_final.pdf
    // Equations 14 and 16
    float3 mx_ggx_energy_compensation(float NdotV, float alpha, float3 Fss)
    {
        float Ess = mx_ggx_dir_albedo(NdotV, alpha, 1.0, 1.0);
        return 1.0 + Fss * (1.0 - Ess) / Ess;
    }
    
    float mx_ggx_energy_compensation(float NdotV, float alpha, float Fss)
    {
        return mx_ggx_energy_compensation(NdotV, alpha, float3(Fss)).x;
    }
    
    // Compute the average of an anisotropic alpha pair.
    float mx_average_alpha(float2 alpha)
    {
        return sqrt(alpha.x * alpha.y);
    }
    
    // Convert a real-valued index of refraction to normal-incidence reflectivity.
    float mx_ior_to_f0(float ior)
    {
        return mx_square((ior - 1.0) / (ior + 1.0));
    }
    
    // Convert normal-incidence reflectivity to real-valued index of refraction.
    float mx_f0_to_ior(float F0)
    {
        float sqrtF0 = sqrt(clamp(F0, 0.01, 0.99));
        return (1.0 + sqrtF0) / (1.0 - sqrtF0);
    }
    float3 mx_f0_to_ior(float3 F0)
    {
        float3 sqrtF0 = sqrt(clamp(F0, 0.01, 0.99));
        return (float3(1.0) + sqrtF0) / (float3(1.0) - sqrtF0);
    }
    
    // https://renderwonk.com/publications/wp-generalization-adobe/gen-adobe.pdf
    float3 mx_fresnel_hoffman_schlick(float cosTheta, FresnelData fd)
    {
        const float COS_THETA_MAX = 1.0 / 7.0;
        const float COS_THETA_FACTOR = 1.0 / (COS_THETA_MAX * pow(1.0 - COS_THETA_MAX, 6.0));
    
        float x = clamp(cosTheta, 0.0, 1.0);
        float3 a = mix(fd.F0, fd.F90, pow(1.0 - COS_THETA_MAX, fd.exponent)) * (float3(1.0) - fd.F82) * COS_THETA_FACTOR;
        return mix(fd.F0, fd.F90, pow(1.0 - x, fd.exponent)) - a * x * mx_pow6(1.0 - x);
    }
    
    // https://seblagarde.wordpress.com/2013/04/29/memo-on-fresnel-equations/
    float mx_fresnel_dielectric(float cosTheta, float ior)
    {
        float c = cosTheta;
        float g2 = ior*ior + c*c - 1.0;
        if (g2 < 0.0)
        {
            // Total internal reflection
            return 1.0;
        }
    
        float g = sqrt(g2);
        return 0.5 * mx_square((g - c) / (g + c)) *
                    (1.0 + mx_square(((g + c) * c - 1.0) / ((g - c) * c + 1.0)));
    }
    
    // https://seblagarde.wordpress.com/2013/04/29/memo-on-fresnel-equations/
    float2 mx_fresnel_dielectric_polarized(float cosTheta, float ior)
    {
        float cosTheta2 = mx_square(clamp(cosTheta, 0.0, 1.0));
        float sinTheta2 = 1.0 - cosTheta2;
    
        float t0 = max(ior * ior - sinTheta2, 0.0);
        float t1 = t0 + cosTheta2;
        float t2 = 2.0 * sqrt(t0) * cosTheta;
        float Rs = (t1 - t2) / (t1 + t2);
    
        float t3 = cosTheta2 * t0 + sinTheta2 * sinTheta2;
        float t4 = t2 * sinTheta2;
        float Rp = Rs * (t3 - t4) / (t3 + t4);
    
        return float2(Rp, Rs);
    }
    
    // https://seblagarde.wordpress.com/2013/04/29/memo-on-fresnel-equations/
    void mx_fresnel_conductor_polarized(float cosTheta, float3 n, float3 k, thread float3 & Rp, thread float3 & Rs)
    {
        float cosTheta2 = mx_square(clamp(cosTheta, 0.0, 1.0));
        float sinTheta2 = 1.0 - cosTheta2;
        float3 n2 = n * n;
        float3 k2 = k * k;
    
        float3 t0 = n2 - k2 - float3(sinTheta2);
        float3 a2plusb2 = sqrt(t0 * t0 + 4.0 * n2 * k2);
        float3 t1 = a2plusb2 + float3(cosTheta2);
        float3 a = sqrt(max(0.5 * (a2plusb2 + t0), 0.0));
        float3 t2 = 2.0 * a * cosTheta;
        Rs = (t1 - t2) / (t1 + t2);
    
        float3 t3 = cosTheta2 * a2plusb2 + float3(sinTheta2 * sinTheta2);
        float3 t4 = t2 * sinTheta2;
        Rp = Rs * (t3 - t4) / (t3 + t4);
    }
    
    float3 mx_fresnel_conductor(float cosTheta, float3 n, float3 k)
    {
        float3 Rp, Rs;
        mx_fresnel_conductor_polarized(cosTheta, n, k, Rp, Rs);
        return 0.5 * (Rp  + Rs);
    }
    
    // https://belcour.github.io/blog/research/publication/2017/05/01/brdf-thin-film.html
    void mx_fresnel_conductor_phase_polarized(float cosTheta, float eta1, float3 eta2, float3 kappa2, thread float3 & phiP, thread float3 & phiS)
    {
        float3 k2 = kappa2 / eta2;
        float3 sinThetaSqr = float3(1.0) - cosTheta * cosTheta;
        float3 A = eta2*eta2*(float3(1.0)-k2*k2) - eta1*eta1*sinThetaSqr;
        float3 B = sqrt(A*A + mx_square(2.0*eta2*eta2*k2));
        float3 U = sqrt((A+B)/2.0);
        float3 V = max(float3(0.0), sqrt((B-A)/2.0));
    
        phiS = mx_atan(2.0*eta1*V*cosTheta, U*U + V*V - mx_square(eta1*cosTheta));
        phiP = mx_atan(2.0*eta1*eta2*eta2*cosTheta * (2.0*k2*U - (float3(1.0)-k2*k2) * V),
                       mx_square(eta2*eta2*(float3(1.0)+k2*k2)*cosTheta) - eta1*eta1*(U*U+V*V));
    }
    
    // https://belcour.github.io/blog/research/publication/2017/05/01/brdf-thin-film.html
    float3 mx_eval_sensitivity(float opd, float3 shift)
    {
        // Use Gaussian fits, given by 3 parameters: val, pos and var
        float phase = 2.0*M_PI * opd;
        float3 val = float3(5.4856e-13, 4.4201e-13, 5.2481e-13);
        float3 pos = float3(1.6810e+06, 1.7953e+06, 2.2084e+06);
        float3 var = float3(4.3278e+09, 9.3046e+09, 6.6121e+09);
        float3 xyz = val * sqrt(2.0*M_PI * var) * mx_cos(pos * phase + shift) * exp(- var * phase*phase);
        xyz.x   += 9.7470e-14 * sqrt(2.0*M_PI * 4.5282e+09) * mx_cos(2.2399e+06 * phase + shift[0]) * exp(- 4.5282e+09 * phase*phase);
        return xyz / 1.0685e-7;
    }
    
    // A Practical Extension to Microfacet Theory for the Modeling of Varying Iridescence
    // https://belcour.github.io/blog/research/publication/2017/05/01/brdf-thin-film.html
    float3 mx_fresnel_airy(float cosTheta, FresnelData fd)
    {
        // XYZ to CIE 1931 RGB color space (using neutral E illuminant)
        const float3x3 XYZ_TO_RGB = float3x3(2.3706743, -0.5138850, 0.0052982, -0.9000405, 1.4253036, -0.0146949, -0.4706338, 0.0885814, 1.0093968);
    
        // Assume vacuum on the outside
        float eta1 = 1.0;
        float eta2 = max(fd.tf_ior, eta1);
        float3 eta3 = (fd.model == FRESNEL_MODEL_SCHLICK) ? mx_f0_to_ior(fd.F0) : fd.ior;
        float3 kappa3 = (fd.model == FRESNEL_MODEL_SCHLICK) ? float3(0.0) : fd.extinction;
        float cosThetaT = sqrt(1.0 - (1.0 - mx_square(cosTheta)) * mx_square(eta1 / eta2));
    
        // First interface
        float2 R12 = mx_fresnel_dielectric_polarized(cosTheta, eta2 / eta1);
        if (cosThetaT <= 0.0)
        {
            // Total internal reflection
            R12 = float2(1.0);
        }
        float2 T121 = float2(1.0) - R12;
    
        // Second interface
        float3 R23p, R23s;
        if (fd.model == FRESNEL_MODEL_SCHLICK)
        {
            float3 f = mx_fresnel_hoffman_schlick(cosThetaT, fd);
            R23p = 0.5 * f;
            R23s = 0.5 * f;
        }
        else
        {
            mx_fresnel_conductor_polarized(cosThetaT, eta3 / eta2, kappa3 / eta2, R23p, R23s);
        }
    
        // Phase shift
        float cosB = mx_cos(mx_atan(eta2 / eta1));
        float2 phi21 = float2(cosTheta < cosB ? 0.0 : M_PI, M_PI);
        float3 phi23p, phi23s;
        if (fd.model == FRESNEL_MODEL_SCHLICK)
        {
            phi23p = float3((eta3[0] < eta2) ? M_PI : 0.0,
                          (eta3[1] < eta2) ? M_PI : 0.0,
                          (eta3[2] < eta2) ? M_PI : 0.0);
            phi23s = phi23p;
        }
        else
        {
            mx_fresnel_conductor_phase_polarized(cosThetaT, eta2, eta3, kappa3, phi23p, phi23s);
        }
        float3 r123p = max(sqrt(R12.x*R23p), 0.0);
        float3 r123s = max(sqrt(R12.y*R23s), 0.0);
    
        // Iridescence term
        float3 I = float3(0.0);
        float3 Cm, Sm;
    
        // Optical path difference
        float distMeters = fd.tf_thickness * 1.0e-9;
        float opd = 2.0 * eta2 * cosThetaT * distMeters;
    
        // Iridescence term using spectral antialiasing for Parallel polarization
    
        // Reflectance term for m=0 (DC term amplitude)
        float3 Rs = (mx_square(T121.x) * R23p) / (float3(1.0) - R12.x*R23p);
        I += R12.x + Rs;
    
        // Reflectance term for m>0 (pairs of diracs)
        Cm = Rs - T121.x;
        for (int m = 1; m <= AIRY_FRESNEL_ITERATIONS; m++)
        {
            Cm *= r123p;
            Sm  = 2.0 * mx_eval_sensitivity(float(m) * opd, float(m)*(phi23p+float3(phi21.x)));
            I  += Cm*Sm;
        }
    
        // Iridescence term using spectral antialiasing for Perpendicular polarization
    
        // Reflectance term for m=0 (DC term amplitude)
        float3 Rp = (mx_square(T121.y) * R23s) / (float3(1.0) - R12.y*R23s);
        I += R12.y + Rp;
    
        // Reflectance term for m>0 (pairs of diracs)
        Cm = Rp - T121.y;
        for (int m = 1; m <= AIRY_FRESNEL_ITERATIONS; m++)
        {
            Cm *= r123s;
            Sm  = 2.0 * mx_eval_sensitivity(float(m) * opd, float(m)*(phi23s+float3(phi21.y)));
            I  += Cm*Sm;
        }
    
        // Average parallel and perpendicular polarization
        I *= 0.5;
    
        // Convert back to RGB reflectance
        I = clamp(mx_matrix_mul(XYZ_TO_RGB, I), 0.0, 1.0);
    
        return I;
    }
    
    FresnelData mx_init_fresnel_dielectric(float ior, float tf_thickness, float tf_ior)
    {
        FresnelData fd;
        fd.model = FRESNEL_MODEL_DIELECTRIC;
        fd.airy = tf_thickness > 0.0;
        fd.ior = float3(ior);
        fd.extinction = float3(0.0);
        fd.F0 = float3(0.0);
        fd.F82 = float3(0.0);
        fd.F90 = float3(0.0);
        fd.exponent = 0.0;
        fd.tf_thickness = tf_thickness;
        fd.tf_ior = tf_ior;
        fd.refraction = false;
        return fd;
    }
    
    FresnelData mx_init_fresnel_conductor(float3 ior, float3 extinction, float tf_thickness, float tf_ior)
    {
        FresnelData fd;
        fd.model = FRESNEL_MODEL_CONDUCTOR;
        fd.airy = tf_thickness > 0.0;
        fd.ior = ior;
        fd.extinction = extinction;
        fd.F0 = float3(0.0);
        fd.F82 = float3(0.0);
        fd.F90 = float3(0.0);
        fd.exponent = 0.0;
        fd.tf_thickness = tf_thickness;
        fd.tf_ior = tf_ior;
        fd.refraction = false;
        return fd;
    }
    
    FresnelData mx_init_fresnel_schlick(float3 F0, float3 F82, float3 F90, float exponent, float tf_thickness, float tf_ior)
    {
        FresnelData fd;
        fd.model = FRESNEL_MODEL_SCHLICK;
        fd.airy = tf_thickness > 0.0;
        fd.ior = float3(0.0);
        fd.extinction = float3(0.0);
        fd.F0 = F0;
        fd.F82 = F82;
        fd.F90 = F90;
        fd.exponent = exponent;
        fd.tf_thickness = tf_thickness;
        fd.tf_ior = tf_ior;
        fd.refraction = false;
        return fd;
    }
    
    float3 mx_compute_fresnel(float cosTheta, FresnelData fd)
    {
        if (fd.airy)
        {
             return mx_fresnel_airy(cosTheta, fd);
        }
        else if (fd.model == FRESNEL_MODEL_DIELECTRIC)
        {
            return float3(mx_fresnel_dielectric(cosTheta, fd.ior.x));
        }
        else if (fd.model == FRESNEL_MODEL_CONDUCTOR)
        {
            return mx_fresnel_conductor(cosTheta, fd.ior, fd.extinction);
        }
        else // FRESNEL_MODEL_SCHLICK
        {
            return mx_fresnel_hoffman_schlick(cosTheta, fd);
        }
    }
    
    // Directional albedo accounting for different Fresnel functions.
    float3 mx_ggx_dir_albedo(float NdotV, float alpha, FresnelData fd)
    {
        if (fd.airy)
        {
            // Approximation using a blend between mirror (alpha = 0)
            // and rougher cases. This helps to maintain angular
            // color variation at lower roughness values.
            float3 mirrorDirAlbedo = mx_compute_fresnel(NdotV, fd);
            float3 F0 = mx_fresnel_airy(1.0, fd);
            float3 roughDirAlbedo = mx_ggx_dir_albedo(NdotV, alpha, F0, float3(1.0));
            return mix(mirrorDirAlbedo, roughDirAlbedo, sqrt(alpha));
        }
        else if (fd.model == FRESNEL_MODEL_DIELECTRIC)
        {
            float F0 = mx_ior_to_f0(fd.ior.x);
            return mx_ggx_dir_albedo(NdotV, alpha, float3(F0), float3(1.0));
        }
        else if (fd.model == FRESNEL_MODEL_CONDUCTOR)
        {
            float3 F0 = mx_fresnel_conductor(1.0, fd.ior, fd.extinction);
            return mx_ggx_dir_albedo(NdotV, alpha, F0, float3(1.0));
        }
        else // FRESNEL_MODEL_SCHLICK
        {
            return mx_ggx_dir_albedo(NdotV, alpha, fd.F0, fd.F90);
        }
    }
    
    // Compute the refraction of a ray through a solid sphere.
    float3 mx_refraction_solid_sphere(float3 R, float3 N, float ior)
    {
        R = refract(R, N, 1.0 / ior);
        float3 N1 = normalize(R * dot(R, N) - N * 0.5);
        return refract(R, N1, ior);
    }
    
    float2 mx_latlong_projection(float3 dir)
    {
        float latitude = -mx_asin(dir.y) * M_PI_INV + 0.5;
        float longitude = mx_atan(dir.x, -dir.z) * M_PI_INV * 0.5 + 0.5;
        return float2(longitude, latitude);
    }
    
    float3 mx_latlong_map_lookup(float3 dir, float4x4 transform, float lod, MetalTexture tex_sampler)
    {
        float3 envDir = normalize(mx_matrix_mul(transform, float4(dir,0.0)).xyz);
        float2 uv = mx_latlong_projection(envDir);
        return textureLod(tex_sampler, uv, lod).rgb;
    }
    
    // Return the mip level with the appropriate coverage for a filtered importance sample.
    // https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch20.html
    // Section 20.4 Equation 13
    float mx_latlong_compute_lod(float3 dir, float pdf, float maxMipLevel, int envSamples)
    {
        const float MIP_LEVEL_OFFSET = 1.5;
        float effectiveMaxMipLevel = maxMipLevel - MIP_LEVEL_OFFSET;
        float distortion = sqrt(1.0 - mx_square(dir.y));
        return max(effectiveMaxMipLevel - 0.5 * log2(float(envSamples) * pdf * distortion), 0.0);
    }
    
    float3 mx_environment_radiance(float3 N, float3 V, float3 X, float2 alpha, int distribution, FresnelData fd)
    {
        // Generate tangent frame.
        X = normalize(X - dot(X, N) * N);
        float3 Y = cross(N, X);
        float3x3 tangentToWorld = float3x3(X, Y, N);
    
        // Transform the view vector to tangent space.
        V = float3(dot(V, X), dot(V, Y), dot(V, N));
    
        // Compute derived properties.
        float NdotV = clamp(V.z, M_FLOAT_EPS, 1.0);
        float avgAlpha = mx_average_alpha(alpha);
        float G1V = mx_ggx_smith_G1(NdotV, avgAlpha);
        
        // Integrate outgoing radiance using filtered importance sampling.
        // http://cgg.mff.cuni.cz/~jaroslav/papers/2008-egsr-fis/2008-egsr-fis-final-embedded.pdf
        float3 radiance = float3(0.0);
        int envRadianceSamples = u_envRadianceSamples;
        for (int i = 0; i < envRadianceSamples; i++)
        {
            float2 Xi = mx_spherical_fibonacci(i, envRadianceSamples);
    
            // Compute the half vector and incoming light direction.
            float3 H = mx_ggx_importance_sample_VNDF(Xi, V, alpha);
            float3 L = fd.refraction ? mx_refraction_solid_sphere(-V, H, fd.ior.x) : -reflect(V, H);
            
            // Compute dot products for this sample.
            float NdotL = clamp(L.z, M_FLOAT_EPS, 1.0);
            float VdotH = clamp(dot(V, H), M_FLOAT_EPS, 1.0);
    
            // Sample the environment light from the given direction.
            float3 Lw = mx_matrix_mul(tangentToWorld, L);
            float pdf = mx_ggx_VNDF_reflection_PDF(H, alpha, G1V, NdotV);
            float lod = mx_latlong_compute_lod(Lw, pdf, float(u_envRadianceMips - 1), envRadianceSamples);
            float3 sampleColor = mx_latlong_map_lookup(Lw, u_envMatrix, lod, u_envRadiance);
    
            // Compute the Fresnel term.
            float3 F = mx_compute_fresnel(VdotH, fd);
    
            // Compute the geometric term.
            float G = mx_ggx_smith_G2(NdotL, NdotV, avgAlpha);
    
            // Compute the combined FG term, which simplifies to inverted Fresnel for refraction.
            float3 FG = fd.refraction ? float3(1.0) - F : F * G;
    
            // Add the radiance contribution of this sample.
            // From https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
            //   incidentLight = sampleColor * NdotL
            //   microfacetSpecular = D * F * G / (4 * NdotL * NdotV)
            //   pdf = D * G1V / (4 * NdotV);
            //   radiance = incidentLight * microfacetSpecular / pdf
            radiance += sampleColor * FG;
        }
    
        // Apply the global component of the geometric term and normalize.
        radiance /= G1V * float(envRadianceSamples);
    
        // Return the final radiance.
        return (u_envRadianceSamples == 0 ? float3(0.0) : radiance) * u_envLightIntensity;
    }
    
    float3 mx_environment_irradiance(float3 N)
    {
        float3 Li = mx_latlong_map_lookup(N, u_envMatrix, 0.0, u_envIrradiance);
        return Li * u_envLightIntensity;
    }

    
    float3 mx_surface_transmission(float3 N, float3 V, float3 X, float2 alpha, int distribution, FresnelData fd, float3 tint)
    {
        // Approximate the appearance of surface transmission as glossy
        // environment map refraction, ignoring any scene geometry that might
        // be visible through the surface.
        fd.refraction = true;
        if (u_refractionTwoSided)
        {
            tint = mx_square(tint);
        }
        return mx_environment_radiance(N, V, X, alpha, distribution, fd) * tint;
    }

    float4 gl_FragCoord;
    VertexData vd;

    LightData u_lightData[MAX_LIGHT_SOURCES];
    
    float4x4 u_envMatrix;


MetalTexture u_envRadiance;    
    float u_envLightIntensity;

    
    int u_envRadianceMips;

    
    int u_envRadianceSamples;


MetalTexture u_envIrradiance;    
    bool u_refractionTwoSided;

    
    float3 u_viewPosition;

    
    int u_numActiveLightSources;

    
    surfaceshader backsurfaceshader;

    
    displacementshader displacementshader1;

    
    float noise_r_amplitude;

    
    int noise_r_octaves;

    
    float noise_r_lacunarity;

    
    float noise_r_diminish;

    
    float noise_g_amplitude;

    
    int noise_g_octaves;

    
    float noise_g_lacunarity;

    
    float noise_g_diminish;

    
    float noise_b_amplitude;

    
    int noise_b_octaves;

    
    float noise_b_lacunarity;

    
    float noise_b_diminish;

    
    float SR_triplanar_base;

    
    float3 SR_triplanar_base_color;

    
    float SR_triplanar_diffuse_roughness;

    
    float SR_triplanar_metalness;

    
    float SR_triplanar_specular;

    
    float3 SR_triplanar_specular_color;

    
    float SR_triplanar_specular_roughness;

    
    float SR_triplanar_specular_IOR;

    
    float SR_triplanar_specular_anisotropy;

    
    float SR_triplanar_specular_rotation;

    
    float SR_triplanar_transmission;

    
    float3 SR_triplanar_transmission_color;

    
    float SR_triplanar_transmission_depth;

    
    float3 SR_triplanar_transmission_scatter;

    
    float SR_triplanar_transmission_scatter_anisotropy;

    
    float SR_triplanar_transmission_dispersion;

    
    float SR_triplanar_transmission_extra_roughness;

    
    float SR_triplanar_subsurface;

    
    float3 SR_triplanar_subsurface_color;

    
    float3 SR_triplanar_subsurface_radius;

    
    float SR_triplanar_subsurface_scale;

    
    float SR_triplanar_subsurface_anisotropy;

    
    float SR_triplanar_sheen;

    
    float3 SR_triplanar_sheen_color;

    
    float SR_triplanar_sheen_roughness;

    
    float SR_triplanar_coat;

    
    float3 SR_triplanar_coat_color;

    
    float SR_triplanar_coat_roughness;

    
    float SR_triplanar_coat_anisotropy;

    
    float SR_triplanar_coat_rotation;

    
    float SR_triplanar_coat_IOR;

    
    float SR_triplanar_coat_affect_color;

    
    float SR_triplanar_coat_affect_roughness;

    
    float SR_triplanar_thin_film_thickness;

    
    float SR_triplanar_thin_film_IOR;

    
    float SR_triplanar_emission;

    
    float3 SR_triplanar_opacity;

    
    bool SR_triplanar_thin_walled;

    float4 out1;
    void mx_directional_light(LightData light, float3 position, thread lightshader& result)
    {
        result.direction = -light.direction;
        result.intensity = light.color * light.intensity;
    }

    int numActiveLightSources()
    {
        return min(u_numActiveLightSources, MAX_LIGHT_SOURCES) ;
    }

    void sampleLightSource(LightData light, float3 position, thread lightshader& result)
    {
        result.intensity = float3(0.000000, 0.000000, 0.000000);
        result.direction = float3(0.000000, 0.000000, 0.000000);
        if (light.type == 1)
        {
            mx_directional_light(light, position, result);
        }
    }

    /*
    Noise Library.
    
    This library is a modified version of the noise library found in
    Open Shading Language:
    github.com/imageworks/OpenShadingLanguage/blob/master/src/include/OSL/oslnoise.h
    
    It contains the subset of noise types needed to implement the MaterialX
    standard library. The modifications are mainly conversions from C++ to GLSL.
    Produced results should be identical to the OSL noise functions.
    
    Original copyright notice:
    ------------------------------------------------------------------------
    Copyright (c) 2009-2010 Sony Pictures Imageworks Inc., et al.
    All Rights Reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are
    met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Sony Pictures Imageworks nor the names of its
      contributors may be used to endorse or promote products derived from
      this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    ------------------------------------------------------------------------
    */
    
    float mx_select(bool b, float t, float f)
    {
        return b ? t : f;
    }
    
    float mx_negate_if(float val, bool b)
    {
        return b ? -val : val;
    }
    
    int mx_floor(float x)
    {
        return int(floor(x));
    }
    
    // return mx_floor as well as the fractional remainder
    float mx_floorfrac(float x, thread int & i)
    {
        i = mx_floor(x);
        return x - float(i);
    }
    
    float mx_bilerp(float v0, float v1, float v2, float v3, float s, float t)
    {
        float s1 = 1.0 - s;
        return (1.0 - t) * (v0*s1 + v1*s) + t * (v2*s1 + v3*s);
    }
    float3 mx_bilerp(float3 v0, float3 v1, float3 v2, float3 v3, float s, float t)
    {
        float s1 = 1.0 - s;
        return (1.0 - t) * (v0*s1 + v1*s) + t * (v2*s1 + v3*s);
    }
    float mx_trilerp(float v0, float v1, float v2, float v3, float v4, float v5, float v6, float v7, float s, float t, float r)
    {
        float s1 = 1.0 - s;
        float t1 = 1.0 - t;
        float r1 = 1.0 - r;
        return (r1*(t1*(v0*s1 + v1*s) + t*(v2*s1 + v3*s)) +
                r*(t1*(v4*s1 + v5*s) + t*(v6*s1 + v7*s)));
    }
    float3 mx_trilerp(float3 v0, float3 v1, float3 v2, float3 v3, float3 v4, float3 v5, float3 v6, float3 v7, float s, float t, float r)
    {
        float s1 = 1.0 - s;
        float t1 = 1.0 - t;
        float r1 = 1.0 - r;
        return (r1*(t1*(v0*s1 + v1*s) + t*(v2*s1 + v3*s)) +
                r*(t1*(v4*s1 + v5*s) + t*(v6*s1 + v7*s)));
    }
    
    // 2 and 3 dimensional gradient functions - perform a dot product against a
    // randomly chosen vector. Note that the gradient vector is not normalized, but
    // this only affects the overall "scale" of the result, so we simply account for
    // the scale by multiplying in the corresponding "perlin" function.
    float mx_gradient_float(uint hash, float x, float y)
    {
        // 8 possible directions (+-1,+-2) and (+-2,+-1)
        uint h = hash & 7u;
        float u = mx_select(h<4u, x, y);
        float v = 2.0 * mx_select(h<4u, y, x);
        // compute the dot product with (x,y).
        return mx_negate_if(u, bool(h&1u)) + mx_negate_if(v, bool(h&2u));
    }
    float mx_gradient_float(uint hash, float x, float y, float z)
    {
        // use vectors pointing to the edges of the cube
        uint h = hash & 15u;
        float u = mx_select(h<8u, x, y);
        float v = mx_select(h<4u, y, mx_select((h==12u)||(h==14u), x, z));
        return mx_negate_if(u, bool(h&1u)) + mx_negate_if(v, bool(h&2u));
    }
    float3 mx_gradient_vec3(uint3 hash, float x, float y)
    {
        return float3(mx_gradient_float(hash.x, x, y), mx_gradient_float(hash.y, x, y), mx_gradient_float(hash.z, x, y));
    }
    float3 mx_gradient_vec3(uint3 hash, float x, float y, float z)
    {
        return float3(mx_gradient_float(hash.x, x, y, z), mx_gradient_float(hash.y, x, y, z), mx_gradient_float(hash.z, x, y, z));
    }
    // Scaling factors to normalize the result of gradients above.
    // These factors were experimentally calculated to be:
    //    2D:   0.6616
    //    3D:   0.9820
    float mx_gradient_scale2d(float v) { return 0.6616 * v; }
    float mx_gradient_scale3d(float v) { return 0.9820 * v; }
    float3 mx_gradient_scale2d(float3 v) { return 0.6616 * v; }
    float3 mx_gradient_scale3d(float3 v) { return 0.9820 * v; }
    
    /// Bitwise circular rotation left by k bits (for 32 bit unsigned integers)
    uint mx_rotl32(uint x, int k)
    {
        return (x<<k) | (x>>(32-k));
    }
    
    void mx_bjmix(thread uint & a, thread uint & b, thread uint & c)
    {
        a -= c; a ^= mx_rotl32(c, 4); c += b;
        b -= a; b ^= mx_rotl32(a, 6); a += c;
        c -= b; c ^= mx_rotl32(b, 8); b += a;
        a -= c; a ^= mx_rotl32(c,16); c += b;
        b -= a; b ^= mx_rotl32(a,19); a += c;
        c -= b; c ^= mx_rotl32(b, 4); b += a;
    }
    
    // Mix up and combine the bits of a, b, and c (doesn't change them, but
    // returns a hash of those three original values).
    uint mx_bjfinal(uint a, uint b, uint c)
    {
        c ^= b; c -= mx_rotl32(b,14);
        a ^= c; a -= mx_rotl32(c,11);
        b ^= a; b -= mx_rotl32(a,25);
        c ^= b; c -= mx_rotl32(b,16);
        a ^= c; a -= mx_rotl32(c,4);
        b ^= a; b -= mx_rotl32(a,14);
        c ^= b; c -= mx_rotl32(b,24);
        return c;
    }
    
    // Convert a 32 bit integer into a floating point number in [0,1]
    float mx_bits_to_01(uint bits)
    {
        return float(bits) / float(uint(0xffffffff));
    }
    
    float mx_fade(float t)
    {
       return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
    }
    
    uint mx_hash_int(int x)
    {
        uint len = 1u;
        uint seed = uint(0xdeadbeef) + (len << 2u) + 13u;
        return mx_bjfinal(seed+uint(x), seed, seed);
    }
    
    uint mx_hash_int(int x, int y)
    {
        uint len = 2u;
        uint a, b, c;
        a = b = c = uint(0xdeadbeef) + (len << 2u) + 13u;
        a += uint(x);
        b += uint(y);
        return mx_bjfinal(a, b, c);
    }
    
    uint mx_hash_int(int x, int y, int z)
    {
        uint len = 3u;
        uint a, b, c;
        a = b = c = uint(0xdeadbeef) + (len << 2u) + 13u;
        a += uint(x);
        b += uint(y);
        c += uint(z);
        return mx_bjfinal(a, b, c);
    }
    
    uint mx_hash_int(int x, int y, int z, int xx)
    {
        uint len = 4u;
        uint a, b, c;
        a = b = c = uint(0xdeadbeef) + (len << 2u) + 13u;
        a += uint(x);
        b += uint(y);
        c += uint(z);
        mx_bjmix(a, b, c);
        a += uint(xx);
        return mx_bjfinal(a, b, c);
    }
    
    uint mx_hash_int(int x, int y, int z, int xx, int yy)
    {
        uint len = 5u;
        uint a, b, c;
        a = b = c = uint(0xdeadbeef) + (len << 2u) + 13u;
        a += uint(x);
        b += uint(y);
        c += uint(z);
        mx_bjmix(a, b, c);
        a += uint(xx);
        b += uint(yy);
        return mx_bjfinal(a, b, c);
    }
    
    uint3 mx_hash_vec3(int x, int y)
    {
        uint h = mx_hash_int(x, y);
        // we only need the low-order bits to be random, so split out
        // the 32 bit result into 3 parts for each channel
        uint3 result;
        result.x = (h      ) & 0xFFu;
        result.y = (h >> 8 ) & 0xFFu;
        result.z = (h >> 16) & 0xFFu;
        return result;
    }
    
    uint3 mx_hash_vec3(int x, int y, int z)
    {
        uint h = mx_hash_int(x, y, z);
        // we only need the low-order bits to be random, so split out
        // the 32 bit result into 3 parts for each channel
        uint3 result;
        result.x = (h      ) & 0xFFu;
        result.y = (h >> 8 ) & 0xFFu;
        result.z = (h >> 16) & 0xFFu;
        return result;
    }
    
    float mx_perlin_noise_float(float2 p)
    {
        int X, Y;
        float fx = mx_floorfrac(p.x, X);
        float fy = mx_floorfrac(p.y, Y);
        float u = mx_fade(fx);
        float v = mx_fade(fy);
        float result = mx_bilerp(
            mx_gradient_float(mx_hash_int(X  , Y  ), fx    , fy     ),
            mx_gradient_float(mx_hash_int(X+1, Y  ), fx-1.0, fy     ),
            mx_gradient_float(mx_hash_int(X  , Y+1), fx    , fy-1.0),
            mx_gradient_float(mx_hash_int(X+1, Y+1), fx-1.0, fy-1.0),
            u, v);
        return mx_gradient_scale2d(result);
    }
    
    float mx_perlin_noise_float(float3 p)
    {
        int X, Y, Z;
        float fx = mx_floorfrac(p.x, X);
        float fy = mx_floorfrac(p.y, Y);
        float fz = mx_floorfrac(p.z, Z);
        float u = mx_fade(fx);
        float v = mx_fade(fy);
        float w = mx_fade(fz);
        float result = mx_trilerp(
            mx_gradient_float(mx_hash_int(X  , Y  , Z  ), fx    , fy    , fz     ),
            mx_gradient_float(mx_hash_int(X+1, Y  , Z  ), fx-1.0, fy    , fz     ),
            mx_gradient_float(mx_hash_int(X  , Y+1, Z  ), fx    , fy-1.0, fz     ),
            mx_gradient_float(mx_hash_int(X+1, Y+1, Z  ), fx-1.0, fy-1.0, fz     ),
            mx_gradient_float(mx_hash_int(X  , Y  , Z+1), fx    , fy    , fz-1.0),
            mx_gradient_float(mx_hash_int(X+1, Y  , Z+1), fx-1.0, fy    , fz-1.0),
            mx_gradient_float(mx_hash_int(X  , Y+1, Z+1), fx    , fy-1.0, fz-1.0),
            mx_gradient_float(mx_hash_int(X+1, Y+1, Z+1), fx-1.0, fy-1.0, fz-1.0),
            u, v, w);
        return mx_gradient_scale3d(result);
    }
    
    float3 mx_perlin_noise_vec3(float2 p)
    {
        int X, Y;
        float fx = mx_floorfrac(p.x, X);
        float fy = mx_floorfrac(p.y, Y);
        float u = mx_fade(fx);
        float v = mx_fade(fy);
        float3 result = mx_bilerp(
            mx_gradient_vec3(mx_hash_vec3(X  , Y  ), fx    , fy     ),
            mx_gradient_vec3(mx_hash_vec3(X+1, Y  ), fx-1.0, fy     ),
            mx_gradient_vec3(mx_hash_vec3(X  , Y+1), fx    , fy-1.0),
            mx_gradient_vec3(mx_hash_vec3(X+1, Y+1), fx-1.0, fy-1.0),
            u, v);
        return mx_gradient_scale2d(result);
    }
    
    float3 mx_perlin_noise_vec3(float3 p)
    {
        int X, Y, Z;
        float fx = mx_floorfrac(p.x, X);
        float fy = mx_floorfrac(p.y, Y);
        float fz = mx_floorfrac(p.z, Z);
        float u = mx_fade(fx);
        float v = mx_fade(fy);
        float w = mx_fade(fz);
        float3 result = mx_trilerp(
            mx_gradient_vec3(mx_hash_vec3(X  , Y  , Z  ), fx    , fy    , fz     ),
            mx_gradient_vec3(mx_hash_vec3(X+1, Y  , Z  ), fx-1.0, fy    , fz     ),
            mx_gradient_vec3(mx_hash_vec3(X  , Y+1, Z  ), fx    , fy-1.0, fz     ),
            mx_gradient_vec3(mx_hash_vec3(X+1, Y+1, Z  ), fx-1.0, fy-1.0, fz     ),
            mx_gradient_vec3(mx_hash_vec3(X  , Y  , Z+1), fx    , fy    , fz-1.0),
            mx_gradient_vec3(mx_hash_vec3(X+1, Y  , Z+1), fx-1.0, fy    , fz-1.0),
            mx_gradient_vec3(mx_hash_vec3(X  , Y+1, Z+1), fx    , fy-1.0, fz-1.0),
            mx_gradient_vec3(mx_hash_vec3(X+1, Y+1, Z+1), fx-1.0, fy-1.0, fz-1.0),
            u, v, w);
        return mx_gradient_scale3d(result);
    }
    
    float mx_cell_noise_float(float p)
    {
        int ix = mx_floor(p);
        return mx_bits_to_01(mx_hash_int(ix));
    }
    
    float mx_cell_noise_float(float2 p)
    {
        int ix = mx_floor(p.x);
        int iy = mx_floor(p.y);
        return mx_bits_to_01(mx_hash_int(ix, iy));
    }
    
    float mx_cell_noise_float(float3 p)
    {
        int ix = mx_floor(p.x);
        int iy = mx_floor(p.y);
        int iz = mx_floor(p.z);
        return mx_bits_to_01(mx_hash_int(ix, iy, iz));
    }
    
    float mx_cell_noise_float(float4 p)
    {
        int ix = mx_floor(p.x);
        int iy = mx_floor(p.y);
        int iz = mx_floor(p.z);
        int iw = mx_floor(p.w);
        return mx_bits_to_01(mx_hash_int(ix, iy, iz, iw));
    }
    
    float3 mx_cell_noise_vec3(float p)
    {
        int ix = mx_floor(p);
        return float3(
                mx_bits_to_01(mx_hash_int(ix, 0)),
                mx_bits_to_01(mx_hash_int(ix, 1)),
                mx_bits_to_01(mx_hash_int(ix, 2))
        );
    }
    
    float3 mx_cell_noise_vec3(float2 p)
    {
        int ix = mx_floor(p.x);
        int iy = mx_floor(p.y);
        return float3(
                mx_bits_to_01(mx_hash_int(ix, iy, 0)),
                mx_bits_to_01(mx_hash_int(ix, iy, 1)),
                mx_bits_to_01(mx_hash_int(ix, iy, 2))
        );
    }
    
    float3 mx_cell_noise_vec3(float3 p)
    {
        int ix = mx_floor(p.x);
        int iy = mx_floor(p.y);
        int iz = mx_floor(p.z);
        uint a, b, c;
        a = b = c = uint(0xdeadbeef) + (4u << 2u) + 13u;
        a += uint(ix);
        b += uint(iy);
        c += uint(iz);
        mx_bjmix(a, b, c);
        return float3(
                mx_bits_to_01(mx_bjfinal(a,      b, c)),
                mx_bits_to_01(mx_bjfinal(a + 1u, b, c)),
                mx_bits_to_01(mx_bjfinal(a + 2u, b, c))
        );
    }
    
    float3 mx_cell_noise_vec3(float4 p)
    {
        int ix = mx_floor(p.x);
        int iy = mx_floor(p.y);
        int iz = mx_floor(p.z);
        int iw = mx_floor(p.w);
        uint a, b, c;
        a = b = c = uint(0xdeadbeef) + (5u << 2u) + 13u;
        a += uint(ix);
        b += uint(iy);
        c += uint(iz);
        mx_bjmix(a, b, c);
        a += uint(iw);
        return float3(
                mx_bits_to_01(mx_bjfinal(a, b,      c)),
                mx_bits_to_01(mx_bjfinal(a, b + 1u, c)),
                mx_bits_to_01(mx_bjfinal(a, b + 2u, c))
        );
    }
    
    float mx_fractal2d_noise_float(float2 p, int octaves, float lacunarity, float diminish)
    {
        float result = 0.0;
        float amplitude = 1.0;
        for (int i = 0;  i < octaves; ++i)
        {
            result += amplitude * mx_perlin_noise_float(p);
            amplitude *= diminish;
            p *= lacunarity;
        }
        return result;
    }
    
    float3 mx_fractal2d_noise_vec3(float2 p, int octaves, float lacunarity, float diminish)
    {
        float3 result = float3(0.0);
        float amplitude = 1.0;
        for (int i = 0;  i < octaves; ++i)
        {
            result += amplitude * mx_perlin_noise_vec3(p);
            amplitude *= diminish;
            p *= lacunarity;
        }
        return result;
    }
    
    float2 mx_fractal2d_noise_vec2(float2 p, int octaves, float lacunarity, float diminish)
    {
        return float2(mx_fractal2d_noise_float(p, octaves, lacunarity, diminish),
                    mx_fractal2d_noise_float(p+float2(19, 193), octaves, lacunarity, diminish));
    }
    
    float4 mx_fractal2d_noise_vec4(float2 p, int octaves, float lacunarity, float diminish)
    {
        float3  c = mx_fractal2d_noise_vec3(p, octaves, lacunarity, diminish);
        float f = mx_fractal2d_noise_float(p+float2(19, 193), octaves, lacunarity, diminish);
        return float4(c, f);
    }
    
    float mx_fractal3d_noise_float(float3 p, int octaves, float lacunarity, float diminish)
    {
        float result = 0.0;
        float amplitude = 1.0;
        for (int i = 0;  i < octaves; ++i)
        {
            result += amplitude * mx_perlin_noise_float(p);
            amplitude *= diminish;
            p *= lacunarity;
        }
        return result;
    }
    
    float3 mx_fractal3d_noise_vec3(float3 p, int octaves, float lacunarity, float diminish)
    {
        float3 result = float3(0.0);
        float amplitude = 1.0;
        for (int i = 0;  i < octaves; ++i)
        {
            result += amplitude * mx_perlin_noise_vec3(p);
            amplitude *= diminish;
            p *= lacunarity;
        }
        return result;
    }
    
    float2 mx_fractal3d_noise_vec2(float3 p, int octaves, float lacunarity, float diminish)
    {
        return float2(mx_fractal3d_noise_float(p, octaves, lacunarity, diminish),
                    mx_fractal3d_noise_float(p+float3(19, 193, 17), octaves, lacunarity, diminish));
    }
    
    float4 mx_fractal3d_noise_vec4(float3 p, int octaves, float lacunarity, float diminish)
    {
        float3  c = mx_fractal3d_noise_vec3(p, octaves, lacunarity, diminish);
        float f = mx_fractal3d_noise_float(p+float3(19, 193, 17), octaves, lacunarity, diminish);
        return float4(c, f);
    }
    
    float2 mx_worley_cell_position(int x, int y, int xoff, int yoff, float jitter)
    {
        float3  tmp = mx_cell_noise_vec3(float2(x+xoff, y+yoff));
        float2  off = float2(tmp.x, tmp.y);
    
        off -= 0.5f;
        off *= jitter;
        off += 0.5f;
        
        return float2(float(x), float(y)) + off;
    }
    
    float3 mx_worley_cell_position(int x, int y, int z, int xoff, int yoff, int zoff, float jitter)
    {
        float3  off = mx_cell_noise_vec3(float3(x+xoff, y+yoff, z+zoff));
    
        off -= 0.5f;
        off *= jitter;
        off += 0.5f;
        
        return float3(float(x), float(y), float(z)) + off;
    }
    
    float mx_worley_distance(float2 p, int x, int y, int xoff, int yoff, float jitter, int metric)
    {
        float2 cellpos = mx_worley_cell_position(x, y, xoff, yoff, jitter);
        float2 diff = cellpos - p;
        if (metric == 2)
            return abs(diff.x) + abs(diff.y);       // Manhattan distance
        if (metric == 3)
            return max(abs(diff.x), abs(diff.y));   // Chebyshev distance
        // Either Euclidean or Distance^2
        return dot(diff, diff);
    }
    
    float mx_worley_distance(float3 p, int x, int y, int z, int xoff, int yoff, int zoff, float jitter, int metric)
    {
        float3 cellpos = mx_worley_cell_position(x, y, z, xoff, yoff, zoff, jitter);
        float3 diff = cellpos - p;
        if (metric == 2)
            return abs(diff.x) + abs(diff.y) + abs(diff.z); // Manhattan distance
        if (metric == 3)
            return max(max(abs(diff.x), abs(diff.y)), abs(diff.z)); // Chebyshev distance
        // Either Euclidean or Distance^2
        return dot(diff, diff);
    }
    
    float mx_worley_noise_float(float2 p, float jitter, int style, int metric)
    {
        int X, Y;
        float dist;
        float2 localpos = float2(mx_floorfrac(p.x, X), mx_floorfrac(p.y, Y));
        float sqdist = 1e6f;        // Some big number for jitter > 1 (not all GPUs may be IEEE)
        float2 minpos = float2(0,0);
        for (int x = -1; x <= 1; ++x)
        {
            for (int y = -1; y <= 1; ++y)
            {
                float dist = mx_worley_distance(localpos, x, y, X, Y, jitter, metric);
                float2 cellpos = mx_worley_cell_position(x, y, X, Y, jitter) - localpos;
                if(dist < sqdist)
                {
                    sqdist = dist;
                    minpos = cellpos;
                }
            }
        }
        if (style == 1)
            return mx_cell_noise_float(minpos + p);
        else
        {
            if (metric == 0)
                sqdist = sqrt(sqdist);
            return sqdist;
        }
    }
    
    float2 mx_worley_noise_vec2(float2 p, float jitter, int style, int metric)
    {
        int X, Y;
        float2 localpos = float2(mx_floorfrac(p.x, X), mx_floorfrac(p.y, Y));
        float2 sqdist = float2(1e6f, 1e6f);
        float2 minpos = float2(0,0);
        for (int x = -1; x <= 1; ++x)
        {
            for (int y = -1; y <= 1; ++y)
            {
                float dist = mx_worley_distance(localpos, x, y, X, Y, jitter, metric);
                float2 cellpos = mx_worley_cell_position(x, y, X, Y, jitter) - localpos;
                if (dist < sqdist.x)
                {
                    sqdist.y = sqdist.x;
                    sqdist.x = dist;
                    minpos = cellpos;
                }
                else if (dist < sqdist.y)
                {
                    sqdist.y = dist;
                }
            }
        }
        if (style == 1)
        {
            float3 tmp = mx_cell_noise_vec3(minpos + p);
            return float2(tmp.x,tmp.y);
        }
        else
        {
            if (metric == 0)
                sqdist = sqrt(sqdist);
            return sqdist;
        }
    }
    
    float3 mx_worley_noise_vec3(float2 p, float jitter, int style, int metric)
    {
        int X, Y;
        float2 localpos = float2(mx_floorfrac(p.x, X), mx_floorfrac(p.y, Y));
        float3 sqdist = float3(1e6f, 1e6f, 1e6f);
        float2 minpos = float2(0,0);
        for (int x = -1; x <= 1; ++x)
        {
            for (int y = -1; y <= 1; ++y)
            {
                float dist = mx_worley_distance(localpos, x, y, X, Y, jitter, metric);
                float2 cellpos = mx_worley_cell_position(x, y, X, Y, jitter) - localpos;
                if (dist < sqdist.x)
                {
                    sqdist.z = sqdist.y;
                    sqdist.y = sqdist.x;
                    sqdist.x = dist;
                    minpos = cellpos;
                }
                else if (dist < sqdist.y)
                {
                    sqdist.z = sqdist.y;
                    sqdist.y = dist;
                }
                else if (dist < sqdist.z)
                {
                    sqdist.z = dist;
                }
            }
        }
        if (style == 1)
            return mx_cell_noise_vec3(minpos + p);
        else
        {
            if (metric == 0)
                sqdist = sqrt(sqdist);
            return sqdist;
        }
    }
    
    float mx_worley_noise_float(float3 p, float jitter, int style, int metric)
    {
        int X, Y, Z;
        float3 localpos = float3(mx_floorfrac(p.x, X), mx_floorfrac(p.y, Y), mx_floorfrac(p.z, Z));
        float sqdist = 1e6f;
        float3 minpos = float3(0,0,0);
        for (int x = -1; x <= 1; ++x)
        {
            for (int y = -1; y <= 1; ++y)
            {
                for (int z = -1; z <= 1; ++z)
                {
                    float dist = mx_worley_distance(localpos, x, y, z, X, Y, Z, jitter, metric);
                    float3 cellpos = mx_worley_cell_position(x, y, z, X, Y, Z, jitter) - localpos;
                    if(dist < sqdist)
                    {
                        sqdist = dist;
                        minpos = cellpos;
                    }
                }
            }
        }
        if (style == 1)
            return mx_cell_noise_float(minpos + p);
        else
        {
            if (metric == 0)
                sqdist = sqrt(sqdist);
            return sqdist;
        }
    }
    
    float2 mx_worley_noise_vec2(float3 p, float jitter, int style, int metric)
    {
        int X, Y, Z;
        float3 localpos = float3(mx_floorfrac(p.x, X), mx_floorfrac(p.y, Y), mx_floorfrac(p.z, Z));
        float2 sqdist = float2(1e6f, 1e6f);
        float3 minpos = float3(0,0,0);
        for (int x = -1; x <= 1; ++x)
        {
            for (int y = -1; y <= 1; ++y)
            {
                for (int z = -1; z <= 1; ++z)
                {
                    float dist = mx_worley_distance(localpos, x, y, z, X, Y, Z, jitter, metric);
                    float3 cellpos = mx_worley_cell_position(x, y, z, X, Y, Z, jitter) - localpos;
                    if (dist < sqdist.x)
                    {
                        sqdist.y = sqdist.x;
                        sqdist.x = dist;
                        minpos = cellpos;
                    }
                    else if (dist < sqdist.y)
                    {
                        sqdist.y = dist;
                    }
                }
            }
        }
        if (style == 1)
        {
            float3 tmp = mx_cell_noise_vec3(minpos + p);
            return float2(tmp.x,tmp.y);
        }
        else
        {
            if (metric == 0)
                sqdist = sqrt(sqdist);
            return sqdist;
        }
    }
    
    float3 mx_worley_noise_vec3(float3 p, float jitter, int style, int metric)
    {
        int X, Y, Z;
        float3 localpos = float3(mx_floorfrac(p.x, X), mx_floorfrac(p.y, Y), mx_floorfrac(p.z, Z));
        float3 sqdist = float3(1e6f, 1e6f, 1e6f);
        float3 minpos = float3(0,0,0);
        for (int x = -1; x <= 1; ++x)
        {
            for (int y = -1; y <= 1; ++y)
            {
                for (int z = -1; z <= 1; ++z)
                {
                    float dist = mx_worley_distance(localpos, x, y, z, X, Y, Z, jitter, metric);
                    float3 cellpos = mx_worley_cell_position(x, y, z, X, Y, Z, jitter) - localpos;
                    if (dist < sqdist.x)
                    {
                        sqdist.z = sqdist.y;
                        sqdist.y = sqdist.x;
                        sqdist.x = dist;
                        minpos = cellpos;
                    }
                    else if (dist < sqdist.y)
                    {
                        sqdist.z = sqdist.y;
                        sqdist.y = dist;
                    }
                    else if (dist < sqdist.z)
                    {
                        sqdist.z = dist;
                    }
                }
            }
        }
        if (style == 1)
            return mx_cell_noise_vec3(minpos + p);
        else
        {
            if (metric == 0)
                sqdist = sqrt(sqdist);
            return sqdist;
        }
    }
    
    void mx_fractal3d_float(float amplitude, int octaves, float lacunarity, float diminish, float3 position, thread float & result)
    {
        float value = mx_fractal3d_noise_float(position, octaves, lacunarity, diminish);
        result = value * amplitude;
    }

    void mx_roughness_anisotropy(float roughness, float anisotropy, thread float2 & result)
    {
        float roughness_sqr = clamp(roughness*roughness, M_FLOAT_EPS, 1.0);
        if (anisotropy > 0.0)
        {
            float aspect = sqrt(1.0 - clamp(anisotropy, 0.0, 0.98));
            result.x = min(roughness_sqr / aspect, 1.0);
            result.y = roughness_sqr * aspect;
        }
        else
        {
            result.x = roughness_sqr;
            result.y = roughness_sqr;
        }
    }

    // These are defined based on the HwShaderGenerator::ClosureContextType enum
    // if that changes - these need to be updated accordingly.
    
    #define CLOSURE_TYPE_DEFAULT 0
    #define CLOSURE_TYPE_REFLECTION 1
    #define CLOSURE_TYPE_TRANSMISSION 2
    #define CLOSURE_TYPE_INDIRECT 3
    #define CLOSURE_TYPE_EMISSION 4
    
    struct ClosureData {
        int closureType;
        float3 L;
        float3 V;
        float3 N;
        float3 P;
        float occlusion;
    };
    
    ClosureData makeClosureData(int closureType, float3 L, float3 V, float3 N, float3 P, float occlusion)
    {
        return {closureType, L, V, N, P, occlusion};
    }
    
    // https://fpsunflower.github.io/ckulla/data/s2017_pbs_imageworks_sheen.pdf
    // Equation 2
    float mx_imageworks_sheen_NDF(float NdotH, float roughness)
    {
        float invRoughness = 1.0 / max(roughness, 0.005);
        float cos2 = NdotH * NdotH;
        float sin2 = 1.0 - cos2;
        return (2.0 + invRoughness) * pow(sin2, invRoughness * 0.5) / (2.0 * M_PI);
    }
    
    float mx_imageworks_sheen_brdf(float NdotL, float NdotV, float NdotH, float roughness)
    {
        // Microfacet distribution.
        float D = mx_imageworks_sheen_NDF(NdotH, roughness);
    
        // Fresnel and geometry terms are ignored.
        float F = 1.0;
        float G = 1.0;
    
        // We use a smoother denominator, as in:
        // https://blog.selfshadow.com/publications/s2013-shading-course/rad/s2013_pbs_rad_notes.pdf
        return D * F * G / (4.0 * (NdotL + NdotV - NdotL*NdotV));
    }
    
    // Rational quadratic fit to Monte Carlo data for Imageworks sheen directional albedo.
    float mx_imageworks_sheen_dir_albedo_analytic(float NdotV, float roughness)
    {
        float2 r = float2(13.67300, 1.0) +
                 float2(-68.78018, 61.57746) * NdotV +
                 float2(799.08825, 442.78211) * roughness +
                 float2(-905.00061, 2597.49308) * NdotV * roughness +
                 float2(60.28956, 121.81241) * mx_square(NdotV) +
                 float2(1086.96473, 3045.55075) * mx_square(roughness);
        return r.x / r.y;
    }
    
    float mx_imageworks_sheen_dir_albedo_table_lookup(float NdotV, float roughness)
    {
    #if DIRECTIONAL_ALBEDO_METHOD == 1
        if (textureSize(u_albedoTable, 0).x > 1)
        {
            return texture(u_albedoTable, float2(NdotV, roughness)).b;
        }
    #endif
        return 0.0;
    }
    
    float mx_imageworks_sheen_dir_albedo_monte_carlo(float NdotV, float roughness)
    {
        NdotV = clamp(NdotV, M_FLOAT_EPS, 1.0);
        float3 V = float3(sqrt(1.0f - mx_square(NdotV)), 0, NdotV);
    
        float radiance = 0.0;
        const int SAMPLE_COUNT = 64;
        for (int i = 0; i < SAMPLE_COUNT; i++)
        {
            float2 Xi = mx_spherical_fibonacci(i, SAMPLE_COUNT);
    
            // Compute the incoming light direction and half vector.
            float3 L = mx_uniform_sample_hemisphere(Xi);
            float3 H = normalize(L + V);
            
            // Compute dot products for this sample.
            float NdotL = clamp(L.z, M_FLOAT_EPS, 1.0);
            float NdotH = clamp(H.z, M_FLOAT_EPS, 1.0);
    
            // Compute sheen reflectance.
            float reflectance = mx_imageworks_sheen_brdf(NdotL, NdotV, NdotH, roughness);
    
            // Add the radiance contribution of this sample.
            //   radiance = reflectance * NdotL / uniform_pdf;
            radiance += reflectance * NdotL / mx_uniform_hemisphere_PDF();
        }
    
        // Return the final directional albedo.
        return radiance / float(SAMPLE_COUNT);
    }
    
    float mx_imageworks_sheen_dir_albedo(float NdotV, float roughness)
    {
    #if DIRECTIONAL_ALBEDO_METHOD == 0
        float dirAlbedo = mx_imageworks_sheen_dir_albedo_analytic(NdotV, roughness);
    #elif DIRECTIONAL_ALBEDO_METHOD == 1
        float dirAlbedo = mx_imageworks_sheen_dir_albedo_table_lookup(NdotV, roughness);
    #else
        float dirAlbedo = mx_imageworks_sheen_dir_albedo_monte_carlo(NdotV, roughness);
    #endif
        return clamp(dirAlbedo, 0.0, 1.0);
    }
    
    // The following functions are adapted from https://github.com/tizian/ltc-sheen.
    // "Practical Multiple-Scattering Sheen Using Linearly Transformed Cosines", Zeltner et al.
    
    // Gaussian fit to directional albedo table.
    float mx_zeltner_sheen_dir_albedo(float x, float y)
    {
        float s = y*(0.0206607 + 1.58491*y)/(0.0379424 + y*(1.32227 + y));
        float m = y*(-0.193854 + y*(-1.14885 + y*(1.7932 - 0.95943*y*y)))/(0.046391 + y);
        float o = y*(0.000654023 + (-0.0207818 + 0.119681*y)*y)/(1.26264 + y*(-1.92021 + y));
        return exp(-0.5*mx_square((x - m)/s))/(s*sqrt(2.0*M_PI)) + o;
    }
    
    // Rational fits to LTC matrix coefficients.
    float mx_zeltner_sheen_ltc_aInv(float x, float y)
    {
        return (2.58126*x + 0.813703*y)*y/(1.0 + 0.310327*x*x + 2.60994*x*y);
    }
    
    float mx_zeltner_sheen_ltc_bInv(float x, float y)
    {
        return sqrt(1.0 - x)*(y - 1.0)*y*y*y/(0.0000254053 + 1.71228*x - 1.71506*x*y + 1.34174*y*y);
    }
    
    // V and N are assumed to be unit vectors.
    float3x3 mx_orthonormal_basis_ltc(float3 V, float3 N, float NdotV)
    {
        // Generate a tangent vector in the plane of V and N.
        // This required to correctly orient the LTC lobe.
        float3 X = V - N*NdotV;
        float lenSqr = dot(X, X);
        if (lenSqr > 0.0)
        {
            X *= mx_inversesqrt(lenSqr);
            float3 Y = cross(N, X);
            return float3x3(X, Y, N);
        }
    
        // If lenSqr == 0, then V == N, so any orthonormal basis will do.
        return mx_orthonormal_basis(N);
    }
    
    // Multiplication by directional albedo is handled by the calling function.
    float mx_zeltner_sheen_brdf(float3 L, float3 V, float3 N, float NdotV, float roughness)
    {
        float3x3 toLTC = transpose(mx_orthonormal_basis_ltc(V, N, NdotV));
        float3 w = mx_matrix_mul(toLTC, L);
    
        float aInv = mx_zeltner_sheen_ltc_aInv(NdotV, roughness);
        float bInv = mx_zeltner_sheen_ltc_bInv(NdotV, roughness);
    
        // Transform w to original configuration (clamped cosine).
        //                 |aInv    0 bInv|
        // wo = M^-1 . w = |   0 aInv    0| . w
        //                 |   0    0    1|
        float3 wo = float3(aInv*w.x + bInv*w.z, aInv * w.y, w.z);
        float lenSqr = dot(wo, wo);
    
        // D(w) = Do(M^-1.w / ||M^-1.w||) . |M^-1| / ||M^-1.w||^3
        //      = Do(M^-1.w) . |M^-1| / ||M^-1.w||^4
        //      = Do(wo) . |M^-1| / dot(wo, wo)^2
        //      = Do(wo) . aInv^2 / dot(wo, wo)^2
        //      = Do(wo) . (aInv / dot(wo, wo))^2
        return mx_cosine_hemisphere_PDF(wo.z) * mx_square(aInv / lenSqr);
    }
    
    float3 mx_zeltner_sheen_importance_sample(float2 Xi, float3 V, float3 N, float roughness, thread float & pdf)
    {
        float NdotV = clamp(dot(N, V), 0.0, 1.0);
        roughness = clamp(roughness, 0.01, 1.0); // Clamp to range of original impl.
    
        float3 wo = mx_cosine_sample_hemisphere(Xi);
    
        float aInv = mx_zeltner_sheen_ltc_aInv(NdotV, roughness);
        float bInv = mx_zeltner_sheen_ltc_bInv(NdotV, roughness);
    
        // Transform wo from original configuration (clamped cosine).
        //              |1/aInv      0 -bInv/aInv|
        // w = M . wo = |     0 1/aInv          0| . wo
        //              |     0      0          1|    
        float3 w = float3(wo.x/aInv - wo.z*bInv/aInv, wo.y / aInv, wo.z);
    
        float lenSqr = dot(w, w);
        w *= mx_inversesqrt(lenSqr);
    
        // D(w) = Do(wo) . ||M.wo||^3 / |M|
        //      = Do(wo / ||M.wo||) . ||M.wo||^4 / |M| 
        //      = Do(w) . ||M.wo||^4 / |M| (possible because M doesn't change z component)
        //      = Do(w) . dot(w, w)^2 * aInv^2
        //      = Do(w) . (aInv * dot(w, w))^2
        pdf = mx_cosine_hemisphere_PDF(w.z) * mx_square(aInv * lenSqr);
    
        float3x3 fromLTC = mx_orthonormal_basis_ltc(V, N, NdotV);
        w = mx_matrix_mul(fromLTC, w);
    
        return w;
    }
    
    void mx_sheen_bsdf(ClosureData closureData, float weight, float3 color, float roughness, float3 N, int mode, thread BSDF & bsdf)
    {
        if (weight < M_FLOAT_EPS)
        {
            return;
        }
    
        float3 V = closureData.V;
        float3 L = closureData.L;
    
        N = mx_forward_facing_normal(N, V);
        float NdotV = clamp(dot(N, V), M_FLOAT_EPS, 1.0);
    
        if (closureData.closureType == CLOSURE_TYPE_REFLECTION)
        {
            float dirAlbedo;
            if (mode == 0)
            {
                float3 H = normalize(L + V);
    
                float NdotL = clamp(dot(N, L), M_FLOAT_EPS, 1.0);
                float NdotH = clamp(dot(N, H), M_FLOAT_EPS, 1.0);
    
                float3 fr = color * mx_imageworks_sheen_brdf(NdotL, NdotV, NdotH, roughness);
                dirAlbedo = mx_imageworks_sheen_dir_albedo(NdotV, roughness);
    
                // We need to include NdotL from the light integral here
                // as in this case it's not cancelled thread by & the BRDF denominator.
                bsdf.response = fr * NdotL * closureData.occlusion * weight;
            }
            else
            {
                roughness = clamp(roughness, 0.01, 1.0); // Clamp to range of original impl.
    
                float3 fr = color * mx_zeltner_sheen_brdf(L, V, N, NdotV, roughness);
                dirAlbedo = mx_zeltner_sheen_dir_albedo(NdotV, roughness);
                bsdf.response = dirAlbedo * fr * closureData.occlusion * weight;
            }
            bsdf.throughput = float3(1.0 - dirAlbedo * weight);
        }
        else if (closureData.closureType == CLOSURE_TYPE_INDIRECT)
        {
            float dirAlbedo;
            if (mode == 0)
            {
                dirAlbedo = mx_imageworks_sheen_dir_albedo(NdotV, roughness);
            }
            else
            {
                roughness = clamp(roughness, 0.01, 1.0); // Clamp to range of original impl.
                dirAlbedo = mx_zeltner_sheen_dir_albedo(NdotV, roughness);
            }
    
            float3 Li = mx_environment_irradiance(N);
            bsdf.response = Li * color * dirAlbedo * weight;
            bsdf.throughput = float3(1.0 - dirAlbedo * weight);
        }
    }

    void mx_luminance_color3(float3 _in, float3 lumacoeffs, thread float3 & result)
    {
        result = float3(dot(_in, lumacoeffs));
    }

    void mx_rotate_vector3(float3 _in, float amount, float3 axis, thread float3 & result)
    {
        // Based on https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula, where the
        // Wikipedia formula follows v' = M * v and MaterialX follows v' = v * M, thus the
        // order of parameters to cross are reversed.
    
        axis = normalize(axis);
        float rotationRadians = mx_radians(amount);
        float s = mx_sin(rotationRadians);
        float c = mx_cos(rotationRadians);
        float oc = 1.0 - c;
        result = _in * c + cross(_in, axis) * s + axis * dot(axis, _in) * oc;
    }

    void mx_artistic_ior(float3 reflectivity, float3 edge_color, thread float3 & ior, thread float3 & extinction)
    {
        // "Artist Friendly Metallic Fresnel", Ole Gulbrandsen, 2014
        // http://jcgt.org/published/0003/04/03/paper.pdf
    
        float3 r = clamp(reflectivity, 0.0, 0.99);
        float3 r_sqrt = sqrt(r);
        float3 n_min = (1.0 - r) / (1.0 + r);
        float3 n_max = (1.0 + r_sqrt) / (1.0 - r_sqrt);
        ior = mix(n_max, n_min, edge_color);
    
        float3 np1 = ior + 1.0;
        float3 nm1 = ior - 1.0;
        float3 k2 = (np1*np1 * r - nm1*nm1) / (1.0 - r);
        k2 = max(k2, 0.0);
        extinction = sqrt(k2);
    }

    
    void mx_uniform_edf(ClosureData closureData, float3 color, thread EDF & result)
    {
        if (closureData.closureType == CLOSURE_TYPE_EMISSION)
        {
            result = color;
        }
    }

    
    void mx_multiply_edf_color3(ClosureData closureData, EDF in1, float3 in2, thread EDF & result)
    {
        result = in1 * in2;
    }

    
    void mx_dielectric_bsdf(ClosureData closureData, float weight, float3 tint, float ior, float2 roughness, bool retroreflective, float thinfilm_thickness, float thinfilm_ior, float3 N, float3 X, int distribution, int scatter_mode, thread BSDF & bsdf)
    {
        if (weight < M_FLOAT_EPS)
        {
            return;
        }
        if (closureData.closureType != CLOSURE_TYPE_TRANSMISSION && scatter_mode == 1)
        {
            return;
        }
    
        float3 V = closureData.V;
        float3 L = closureData.L;
    
        // Retroreflective mode is only supported for reflection and indirect
        if (retroreflective && (closureData.closureType != CLOSURE_TYPE_TRANSMISSION))
            V = reflect(-V, N);
        
        N = mx_forward_facing_normal(N, V);
        float NdotV = clamp(dot(N, V), M_FLOAT_EPS, 1.0);
    
        FresnelData fd = mx_init_fresnel_dielectric(ior, thinfilm_thickness, thinfilm_ior);
        float F0 = mx_ior_to_f0(ior);
    
        float2 safeAlpha = clamp(roughness, M_FLOAT_EPS, 1.0);
        float avgAlpha = mx_average_alpha(safeAlpha);
        float3 safeTint = max(tint, 0.0);
    
        if (closureData.closureType == CLOSURE_TYPE_REFLECTION)
        {
            X = normalize(X - dot(X, N) * N);
            float3 Y = cross(N, X);
            float3 H = normalize(L + V);
    
            float NdotL = clamp(dot(N, L), M_FLOAT_EPS, 1.0);
            float VdotH = clamp(dot(V, H), M_FLOAT_EPS, 1.0);
    
            float3 Ht = float3(dot(H, X), dot(H, Y), dot(H, N));
    
            float3 F = mx_compute_fresnel(VdotH, fd);
            float D = mx_ggx_NDF(Ht, safeAlpha);
            float G = mx_ggx_smith_G2(NdotL, NdotV, avgAlpha);
    
            float3 comp = mx_ggx_energy_compensation(NdotV, avgAlpha, F);
            float3 dirAlbedo = mx_ggx_dir_albedo(NdotV, avgAlpha, F0, 1.0) * comp;
            bsdf.throughput = 1.0 - dirAlbedo * weight;
    
            bsdf.response = D * F * G * comp * safeTint * closureData.occlusion * weight / (4.0 * NdotV);
        }
        else if (closureData.closureType == CLOSURE_TYPE_TRANSMISSION)
        {
            float3 F = mx_compute_fresnel(NdotV, fd);
    
            float3 comp = mx_ggx_energy_compensation(NdotV, avgAlpha, F);
            float3 dirAlbedo = mx_ggx_dir_albedo(NdotV, avgAlpha, F0, 1.0) * comp;
            bsdf.throughput = 1.0 - dirAlbedo * weight;
    
            if (scatter_mode != 0)
            {
                bsdf.response = mx_surface_transmission(N, V, X, safeAlpha, distribution, fd, safeTint) * weight;
            }
        }
        else if (closureData.closureType == CLOSURE_TYPE_INDIRECT)
        {
            float3 F = mx_compute_fresnel(NdotV, fd);
    
            float3 comp = mx_ggx_energy_compensation(NdotV, avgAlpha, F);
            float3 dirAlbedo = mx_ggx_dir_albedo(NdotV, avgAlpha, F0, 1.0) * comp;
            bsdf.throughput = 1.0 - dirAlbedo * weight;
    
            float3 Li = mx_environment_radiance(N, V, X, safeAlpha, distribution, fd);
            bsdf.response = Li * safeTint * comp * weight;
        }
    }

    
    void mx_conductor_bsdf(ClosureData closureData, float weight, float3 ior_n, float3 ior_k, float2 roughness, bool retroreflective, float thinfilm_thickness, float thinfilm_ior, float3 N, float3 X, int distribution, thread BSDF & bsdf)
    {
        bsdf.throughput = float3(0.0);
    
        if (weight < M_FLOAT_EPS)
        {
            return;
        }
    
        float3 V = closureData.V;
        float3 L = closureData.L;
    
        V = retroreflective ? reflect(-V, N) : V;
        N = mx_forward_facing_normal(N, V);
        float NdotV = clamp(dot(N, V), M_FLOAT_EPS, 1.0);
    
        FresnelData fd = mx_init_fresnel_conductor(ior_n, ior_k, thinfilm_thickness, thinfilm_ior);
    
        float2 safeAlpha = clamp(roughness, M_FLOAT_EPS, 1.0);
        float avgAlpha = mx_average_alpha(safeAlpha);
    
        if (closureData.closureType == CLOSURE_TYPE_REFLECTION)
        {
            X = normalize(X - dot(X, N) * N);
            float3 Y = cross(N, X);
            float3 H = normalize(L + V);
    
            float NdotL = clamp(dot(N, L), M_FLOAT_EPS, 1.0);
            float VdotH = clamp(dot(V, H), M_FLOAT_EPS, 1.0);
    
            float3 Ht = float3(dot(H, X), dot(H, Y), dot(H, N));
    
            float3 F = mx_compute_fresnel(VdotH, fd);
            float D = mx_ggx_NDF(Ht, safeAlpha);
            float G = mx_ggx_smith_G2(NdotL, NdotV, avgAlpha);
    
            float3 comp = mx_ggx_energy_compensation(NdotV, avgAlpha, F);
    
            // Note: NdotL is cancelled out
            bsdf.response = D * F * G * comp * closureData.occlusion * weight / (4.0 * NdotV);
        }
        else if (closureData.closureType == CLOSURE_TYPE_INDIRECT)
        {
            float3 F = mx_compute_fresnel(NdotV, fd);
            float3 comp = mx_ggx_energy_compensation(NdotV, avgAlpha, F);
            float3 Li = mx_environment_radiance(N, V, X, safeAlpha, distribution, fd);
            bsdf.response = Li * comp * weight;
        }
    }

    
    void mx_translucent_bsdf(ClosureData closureData, float weight, float3 color, float3 N, thread BSDF & bsdf)
    {
        bsdf.throughput = float3(0.0);
    
        if (weight < M_FLOAT_EPS)
        {
            return;
        }
    
        float3 V = closureData.V;
        float3 L = closureData.L;
    
        // Invert normal since we're transmitting light from the other side
        N = -N;
    
        if (closureData.closureType == CLOSURE_TYPE_REFLECTION)
        {
            float NdotL = clamp(dot(N, L), 0.0, 1.0);
            bsdf.response = color * weight * NdotL * M_PI_INV;
        }
        else if (closureData.closureType == CLOSURE_TYPE_INDIRECT)
        {
            float3 Li = mx_environment_irradiance(N);
            bsdf.response = Li * color * weight;
        }
    }

    
    const float FUJII_CONSTANT_1 = 0.5 - 2.0 / (3.0 * M_PI);
    const float FUJII_CONSTANT_2 = 2.0 / 3.0 - 28.0 / (15.0 * M_PI);
    
    // Qualitative Oren-Nayar diffuse with simplified math:
    // https://www1.cs.columbia.edu/CAVE/publications/pdfs/Oren_SIGGRAPH94.pdf
    float mx_oren_nayar_diffuse(float NdotV, float NdotL, float LdotV, float roughness)
    {
        float s = LdotV - NdotL * NdotV;
        float stinv = (s > 0.0) ? s / max(NdotL, NdotV) : 0.0;
    
        float sigma2 = mx_square(roughness);
        float A = 1.0 - 0.5 * (sigma2 / (sigma2 + 0.33));
        float B = 0.45 * sigma2 / (sigma2 + 0.09);
    
        return A + B * stinv;
    }
    
    // Rational quadratic fit to Monte Carlo data for Oren-Nayar directional albedo.
    float mx_oren_nayar_diffuse_dir_albedo_analytic(float NdotV, float roughness)
    {
        float2 r = float2(1.0, 1.0) +
                 float2(-0.4297, -0.6076) * roughness +
                 float2(-0.7632, -0.4993) * NdotV * roughness +
                 float2(1.4385, 2.0315) * mx_square(roughness);
        return r.x / r.y;
    }
    
    float mx_oren_nayar_diffuse_dir_albedo_table_lookup(float NdotV, float roughness)
    {
    #if DIRECTIONAL_ALBEDO_METHOD == 1
        if (textureSize(u_albedoTable, 0).x > 1)
        {
            return texture(u_albedoTable, float2(NdotV, roughness)).b;
        }
    #endif
        return 0.0;
    }
    
    float mx_oren_nayar_diffuse_dir_albedo_monte_carlo(float NdotV, float roughness)
    {
        NdotV = clamp(NdotV, M_FLOAT_EPS, 1.0);
        float3 V = float3(sqrt(1.0 - mx_square(NdotV)), 0, NdotV);
    
        float radiance = 0.0;
        const int SAMPLE_COUNT = 64;
        for (int i = 0; i < SAMPLE_COUNT; i++)
        {
            float2 Xi = mx_spherical_fibonacci(i, SAMPLE_COUNT);
    
            // Compute the incoming light direction.
            float3 L = mx_uniform_sample_hemisphere(Xi);
            
            // Compute dot products for this sample.
            float NdotL = clamp(L.z, M_FLOAT_EPS, 1.0);
            float LdotV = clamp(dot(L, V), M_FLOAT_EPS, 1.0);
    
            // Compute diffuse reflectance.
            float reflectance = mx_oren_nayar_diffuse(NdotV, NdotL, LdotV, roughness);
    
            // Add the radiance contribution of this sample.
            //   uniform_pdf = 1 / (2 * PI)
            //   radiance = (reflectance * NdotL) / (uniform_pdf * PI);
            radiance += reflectance * NdotL;
        }
    
        // Apply global components and normalize.
        radiance *= 2.0 / float(SAMPLE_COUNT);
    
        // Return the final directional albedo.
        return radiance;
    }
    
    float mx_oren_nayar_diffuse_dir_albedo(float NdotV, float roughness)
    {
    #if DIRECTIONAL_ALBEDO_METHOD == 2
        float dirAlbedo = mx_oren_nayar_diffuse_dir_albedo_monte_carlo(NdotV, roughness);
    #else
        float dirAlbedo = mx_oren_nayar_diffuse_dir_albedo_analytic(NdotV, roughness);
    #endif
        return clamp(dirAlbedo, 0.0, 1.0);
    }
    
    // Improved Oren-Nayar diffuse from Fujii:
    // https://mimosa-pudica.net/improved-oren-nayar.html
    float mx_oren_nayar_fujii_diffuse_dir_albedo(float cosTheta, float roughness)
    {
        float A = 1.0 / (1.0 + FUJII_CONSTANT_1 * roughness);
        float B = roughness * A;
        float Si = sqrt(max(0.0, 1.0 - mx_square(cosTheta)));
        float G = Si * (mx_acos(clamp(cosTheta, -1.0, 1.0)) - Si * cosTheta) +
                  2.0 * ((Si / cosTheta) * (1.0 - Si * Si * Si) - Si) / 3.0;
        return A + (B * G * M_PI_INV);
    }
    
    float mx_oren_nayar_fujii_diffuse_avg_albedo(float roughness)
    {
        float A = 1.0 / (1.0 + FUJII_CONSTANT_1 * roughness);
        return A * (1.0 + FUJII_CONSTANT_2 * roughness);
    }   
    
    // Energy-compensated Oren-Nayar diffuse from OpenPBR Surface:
    // https://academysoftwarefoundation.github.io/OpenPBR/
    float3 mx_oren_nayar_compensated_diffuse(float NdotV, float NdotL, float LdotV, float roughness, float3 color)
    {
        float s = LdotV - NdotL * NdotV;
        float stinv = (s > 0.0) ? s / max(NdotL, NdotV) : s;
    
        // Compute the single-scatter lobe.
        float A = 1.0 / (1.0 + FUJII_CONSTANT_1 * roughness);
        float3 lobeSingleScatter = color * A * (1.0 + roughness * stinv);
    
        // Compute the multi-scatter lobe.
        float dirAlbedoV = mx_oren_nayar_fujii_diffuse_dir_albedo(NdotV, roughness);
        float dirAlbedoL = mx_oren_nayar_fujii_diffuse_dir_albedo(NdotL, roughness);
        float avgAlbedo = mx_oren_nayar_fujii_diffuse_avg_albedo(roughness);
        float3 colorMultiScatter = mx_square(color) * avgAlbedo /
                                 (float3(1.0) - color * max(0.0, 1.0 - avgAlbedo));
        float3 lobeMultiScatter = colorMultiScatter *
                                max(M_FLOAT_EPS, 1.0 - dirAlbedoV) *
                                max(M_FLOAT_EPS, 1.0 - dirAlbedoL) /
                                max(M_FLOAT_EPS, 1.0 - avgAlbedo);
    
        // Return the sum.
        return lobeSingleScatter + lobeMultiScatter;
    }
    
    float3 mx_oren_nayar_compensated_diffuse_dir_albedo(float cosTheta, float roughness, float3 color)
    {
        float dirAlbedo = mx_oren_nayar_fujii_diffuse_dir_albedo(cosTheta, roughness);
        float avgAlbedo = mx_oren_nayar_fujii_diffuse_avg_albedo(roughness);
        float3 colorMultiScatter = mx_square(color) * avgAlbedo /
                                 (float3(1.0) - color * max(0.0, 1.0 - avgAlbedo));
        return mix(colorMultiScatter, color, dirAlbedo);
    }
      
    // https://media.disneyanimation.com/uploads/production/publication_asset/48/asset/s2012_pbs_disney_brdf_notes_v3.pdf
    // Section 5.3
    float mx_burley_diffuse(float NdotV, float NdotL, float LdotH, float roughness)
    {
        float F90 = 0.5 + (2.0 * roughness * mx_square(LdotH));
        float refL = mx_fresnel_schlick(NdotL, 1.0, F90);
        float refV = mx_fresnel_schlick(NdotV, 1.0, F90);
        return refL * refV;
    }
    
    // Compute the directional albedo component of Burley diffuse for the given
    // view angle and roughness.  Curve fit provided by Stephen Hill.
    float mx_burley_diffuse_dir_albedo(float NdotV, float roughness)
    {
        float x = NdotV;
        float fit0 = 0.97619 - 0.488095 * mx_pow5(1.0 - x);
        float fit1 = 1.55754 + (-2.02221 + (2.56283 - 1.06244 * x) * x) * x;
        return mix(fit0, fit1, roughness);
    }
    
    // Evaluate the Burley diffusion profile for the given distance and diffusion shape.
    // Based on https://graphics.pixar.com/library/ApproxBSSRDF/
    float3 mx_burley_diffusion_profile(float dist, float3 shape)
    {
        float3 num1 = exp(-shape * dist);
        float3 num2 = exp(-shape * dist / 3.0);
        float denom = max(dist, M_FLOAT_EPS);
        return (num1 + num2) / denom;
    }
    
    // Integrate the Burley diffusion profile over a sphere of the given radius.
    // Inspired by Eric Penner's presentation in http://advances.realtimerendering.com/s2011/
    float3 mx_integrate_burley_diffusion(float3 N, float3 L, float radius, float3 mfp)
    {
        float theta = mx_acos(dot(N, L));
    
        // Estimate the Burley diffusion shape from mean free path.
        float3 shape = float3(1.0) / max(mfp, 0.1);
    
        // Integrate the profile over the sphere.
        float3 sumD = float3(0.0);
        float3 sumR = float3(0.0);
        const int SAMPLE_COUNT = 32;
        const float SAMPLE_WIDTH = (2.0 * M_PI) / float(SAMPLE_COUNT);
        for (int i = 0; i < SAMPLE_COUNT; i++)
        {
            float x = -M_PI + (float(i) + 0.5) * SAMPLE_WIDTH;
            float dist = radius * abs(2.0 * mx_sin(x * 0.5));
            float3 R = mx_burley_diffusion_profile(dist, shape);
            sumD += R * max(mx_cos(theta + x), 0.0);
            sumR += R;
        }
    
        return sumD / sumR;
    }
    
    float3 mx_subsurface_scattering_approx(float3 N, float3 L, float3 P, float3 albedo, float3 mfp)
    {
        float curvature = length(fwidth(N)) / length(fwidth(P));
        float radius = 1.0 / max(curvature, 0.01);
        return albedo * mx_integrate_burley_diffusion(N, L, radius, mfp) / float3(M_PI);
    }
    
    void mx_subsurface_bsdf(ClosureData closureData, float weight, float3 color, float3 radius, float anisotropy, float3 N, thread BSDF & bsdf)
    {
        bsdf.throughput = float3(0.0);
    
        if (weight < M_FLOAT_EPS)
        {
            return;
        }
    
        float3 V = closureData.V;
        float3 L = closureData.L;
        float3 P = closureData.P;
        float occlusion = closureData.occlusion;
    
        N = mx_forward_facing_normal(N, V);
    
        if (closureData.closureType == CLOSURE_TYPE_REFLECTION)
        {
            float3 sss = mx_subsurface_scattering_approx(N, L, P, color, radius);
            float NdotL = clamp(dot(N, L), M_FLOAT_EPS, 1.0);
            float visibleOcclusion = 1.0 - NdotL * (1.0 - occlusion);
            bsdf.response = sss * visibleOcclusion * weight;
        }
        else if (closureData.closureType == CLOSURE_TYPE_INDIRECT)
        {
            // For now, we render indirect subsurface as simple indirect diffuse.
            float3 Li = mx_environment_irradiance(N);
            bsdf.response = Li * color * weight;
        }
    }

    
    void mx_oren_nayar_diffuse_bsdf(ClosureData closureData, float weight, float3 color, float roughness, float3 N, bool energy_compensation, thread BSDF & bsdf)
    {
        bsdf.throughput = float3(0.0);
    
        if (weight < M_FLOAT_EPS)
        {
            return;
        }
    
        float3 V = closureData.V;
        float3 L = closureData.L;
    
        N = mx_forward_facing_normal(N, V);
        float NdotV = clamp(dot(N, V), M_FLOAT_EPS, 1.0);
    
        if (closureData.closureType == CLOSURE_TYPE_REFLECTION)
        {
            float NdotL = clamp(dot(N, L), M_FLOAT_EPS, 1.0);
            float LdotV = clamp(dot(L, V), M_FLOAT_EPS, 1.0);
    
            float3 diffuse = energy_compensation ?
                           mx_oren_nayar_compensated_diffuse(NdotV, NdotL, LdotV, roughness, color) :
                           mx_oren_nayar_diffuse(NdotV, NdotL, LdotV, roughness) * color;
            bsdf.response = diffuse * closureData.occlusion * weight * NdotL * M_PI_INV;
        }
        else if (closureData.closureType == CLOSURE_TYPE_INDIRECT)
        {
            float3 diffuse = energy_compensation ?
                           mx_oren_nayar_compensated_diffuse_dir_albedo(NdotV, roughness, color) :
                           mx_oren_nayar_diffuse_dir_albedo(NdotV, roughness) * color;
            float3 Li = mx_environment_irradiance(N);
            bsdf.response = Li * diffuse * weight;
        }
    }

    void NG_convert_float_color3(float in1, thread float3& out1)
    {
        float3 combine_out = { in1,in1,in1 };
        out1 = combine_out;
    }

    
    void mx_add_bsdf(ClosureData closureData, BSDF in1, BSDF in2, thread BSDF & result)
    {
        result.response = in1.response + in2.response;
    
        // We derive the throughput for closure addition as follows:
        //   throughput_1 = 1 - dir_albedo_1
        //   throughput_2 = 1 - dir_albedo_2
        //   throughput_sum = 1 - (dir_albedo_1 + dir_albedo_2)
        //                  = 1 - ((1 - throughput_1) + (1 - throughput_2))
        //                  = throughput_1 + throughput_2 - 1
        result.throughput = max(in1.throughput + in2.throughput - 1.0, 0.0);
    }

    
    void mx_generalized_schlick_edf(ClosureData closureData, float3 color0, float3 color90, float exponent, EDF base, thread EDF & result)
    {
        if (closureData.closureType == CLOSURE_TYPE_EMISSION)
        {
            float3 N = mx_forward_facing_normal(closureData.N, closureData.V);
            float NdotV = clamp(dot(N, closureData.V), M_FLOAT_EPS, 1.0);
            float3 f = mx_fresnel_schlick(NdotV, color0, color90, exponent);
            result = base * f;
        }
    }

    
    void mx_multiply_bsdf_float(ClosureData closureData, BSDF in1, float in2, thread BSDF & result)
    {
        float weight = clamp(in2, 0.0, 1.0);
        result.response = in1.response * weight;
        result.throughput = in1.throughput;
    }

    
    void mx_mix_edf(ClosureData closureData, EDF fg, EDF bg, float mixValue, thread EDF & result)
    {
        result = mix(bg, fg, mixValue);
    }

    
    void mx_layer_bsdf(ClosureData closureData, BSDF top, BSDF base, thread BSDF & result)
    {
        result.response = top.response + base.response * top.throughput;
        result.throughput = top.throughput * base.throughput;
    }

    
    void mx_multiply_bsdf_color3(ClosureData closureData, BSDF in1, float3 in2, thread BSDF & result)
    {
        float3 tint = clamp(in2, 0.0, 1.0);
        result.response = in1.response * tint;
        result.throughput = in1.throughput;
    }

    void NG_standard_surface_surfaceshader_100(float base, float3 base_color, float diffuse_roughness, float metalness, float specular, float3 specular_color, float specular_roughness, float specular_IOR, float specular_anisotropy, float specular_rotation, float transmission, float3 transmission_color, float transmission_depth, float3 transmission_scatter, float transmission_scatter_anisotropy, float transmission_dispersion, float transmission_extra_roughness, float subsurface, float3 subsurface_color, float3 subsurface_radius, float subsurface_scale, float subsurface_anisotropy, float sheen, float3 sheen_color, float sheen_roughness, float coat, float3 coat_color, float coat_roughness, float coat_anisotropy, float coat_rotation, float coat_IOR, float3 coat_normal, float coat_affect_color, float coat_affect_roughness, float thin_film_thickness, float thin_film_IOR, float emission, float3 emission_color, float3 opacity, bool thin_walled, float3 normal, float3 tangent, thread surfaceshader& out1)
    {
        float2 coat_roughness_vector_out = float2(0.0);
        mx_roughness_anisotropy(coat_roughness, coat_anisotropy, coat_roughness_vector_out);
        const float coat_tangent_rotate_degree_in2_tmp = 360.000000;
        float coat_tangent_rotate_degree_out = coat_rotation * coat_tangent_rotate_degree_in2_tmp;
        const float metalness_mix_fg_weight_in1_tmp = 1.000000;
        float metalness_mix_fg_weight_out = metalness_mix_fg_weight_in1_tmp * metalness;
        float3 metal_reflectivity_out = base_color * base;
        float3 metal_edgecolor_out = specular_color * specular;
        float coat_affect_roughness_multiply1_out = coat_affect_roughness * coat;
        const float tangent_rotate_degree_in2_tmp = 360.000000;
        float tangent_rotate_degree_out = specular_rotation * tangent_rotate_degree_in2_tmp;
        const float transmission_mix_fg_weight_in1_tmp = 1.000000;
        float transmission_mix_fg_weight_out = transmission_mix_fg_weight_in1_tmp * transmission;
        float transmission_roughness_add_out = specular_roughness + transmission_extra_roughness;
        float subsurface_selector_out = float(thin_walled);
        const float subsurface_color_nonnegative_in2_tmp = 0.000000;
        float3 subsurface_color_nonnegative_out = max(subsurface_color, subsurface_color_nonnegative_in2_tmp);
        const float coat_clamped_low_tmp = 0.000000;
        const float coat_clamped_high_tmp = 1.000000;
        float coat_clamped_out = clamp(coat, coat_clamped_low_tmp, coat_clamped_high_tmp);
        float3 subsurface_radius_scaled_out = subsurface_radius * subsurface_scale;
        const float subsurface_mix_mix_inv_amount_tmp = 1.000000;
        float subsurface_mix_mix_inv_out = subsurface_mix_mix_inv_amount_tmp - subsurface;
        const float base_color_nonnegative_in2_tmp = 0.000000;
        float3 base_color_nonnegative_out = max(base_color, base_color_nonnegative_in2_tmp);
        const float transmission_mix_mix_inv_amount_tmp = 1.000000;
        float transmission_mix_mix_inv_out = transmission_mix_mix_inv_amount_tmp - transmission;
        const float metalness_mix_mix_inv_amount_tmp = 1.000000;
        float metalness_mix_mix_inv_out = metalness_mix_mix_inv_amount_tmp - metalness;
        const float3 coat_attenuation_bg_tmp = float3(1.000000, 1.000000, 1.000000);
        float3 coat_attenuation_out = mix(coat_attenuation_bg_tmp, coat_color, coat);
        const float one_minus_coat_ior_in1_tmp = 1.000000;
        float one_minus_coat_ior_out = one_minus_coat_ior_in1_tmp - coat_IOR;
        const float one_plus_coat_ior_in1_tmp = 1.000000;
        float one_plus_coat_ior_out = one_plus_coat_ior_in1_tmp + coat_IOR;
        float3 emission_weight_out = emission_color * emission;
        float3 opacity_luminance_out = float3(0.0);
        mx_luminance_color3(opacity, float3(0.272229, 0.674082, 0.053689), opacity_luminance_out);
        float3 coat_tangent_rotate_out = float3(0.0);
        mx_rotate_vector3(tangent, coat_tangent_rotate_degree_out, coat_normal, coat_tangent_rotate_out);
        float3 artistic_ior_ior = float3(0.0);
        float3 artistic_ior_extinction = float3(0.0);
        mx_artistic_ior(metal_reflectivity_out, metal_edgecolor_out, artistic_ior_ior, artistic_ior_extinction);
        float coat_affect_roughness_multiply2_out = coat_affect_roughness_multiply1_out * coat_roughness;
        float3 tangent_rotate_out = float3(0.0);
        mx_rotate_vector3(tangent, tangent_rotate_degree_out, normal, tangent_rotate_out);
        const float transmission_roughness_clamped_low_tmp = 0.000000;
        const float transmission_roughness_clamped_high_tmp = 1.000000;
        float transmission_roughness_clamped_out = clamp(transmission_roughness_add_out, transmission_roughness_clamped_low_tmp, transmission_roughness_clamped_high_tmp);
        const float selected_subsurface_bsdf_mix_inv_amount_tmp = 1.000000;
        float selected_subsurface_bsdf_mix_inv_out = selected_subsurface_bsdf_mix_inv_amount_tmp - subsurface_selector_out;
        const float selected_subsurface_bsdf_fg_weight_in1_tmp = 1.000000;
        float selected_subsurface_bsdf_fg_weight_out = selected_subsurface_bsdf_fg_weight_in1_tmp * subsurface_selector_out;
        float coat_gamma_multiply_out = coat_clamped_out * coat_affect_color;
        float subsurface_mix_bg_weight_out = base * subsurface_mix_mix_inv_out;
        float coat_ior_to_F0_sqrt_out = one_minus_coat_ior_out / one_plus_coat_ior_out;
        const int opacity_luminance_float_index_tmp = 0;
        float opacity_luminance_float_out = opacity_luminance_out[opacity_luminance_float_index_tmp];
        float3 coat_tangent_rotate_normalize_out = normalize(coat_tangent_rotate_out);
        const float coat_affected_roughness_fg_tmp = 1.000000;
        float coat_affected_roughness_out = mix(specular_roughness, coat_affected_roughness_fg_tmp, coat_affect_roughness_multiply2_out);
        float3 tangent_rotate_normalize_out = normalize(tangent_rotate_out);
        const float coat_affected_transmission_roughness_fg_tmp = 1.000000;
        float coat_affected_transmission_roughness_out = mix(transmission_roughness_clamped_out, coat_affected_transmission_roughness_fg_tmp, coat_affect_roughness_multiply2_out);
        const float selected_subsurface_bsdf_bg_weight_in1_tmp = 1.000000;
        float selected_subsurface_bsdf_bg_weight_out = selected_subsurface_bsdf_bg_weight_in1_tmp * selected_subsurface_bsdf_mix_inv_out;
        const float coat_gamma_in2_tmp = 1.000000;
        float coat_gamma_out = coat_gamma_multiply_out + coat_gamma_in2_tmp;
        float coat_ior_to_F0_out = coat_ior_to_F0_sqrt_out * coat_ior_to_F0_sqrt_out;
        const float coat_tangent_value2_tmp = 0.000000;
        float3 coat_tangent_out = (coat_anisotropy > coat_tangent_value2_tmp) ? coat_tangent_rotate_normalize_out : tangent;
        float2 main_roughness_out = float2(0.0);
        mx_roughness_anisotropy(coat_affected_roughness_out, specular_anisotropy, main_roughness_out);
        const float main_tangent_value2_tmp = 0.000000;
        float3 main_tangent_out = (specular_anisotropy > main_tangent_value2_tmp) ? tangent_rotate_normalize_out : tangent;
        float2 transmission_roughness_out = float2(0.0);
        mx_roughness_anisotropy(coat_affected_transmission_roughness_out, specular_anisotropy, transmission_roughness_out);
        float3 coat_affected_subsurface_color_out = pow(subsurface_color_nonnegative_out, float3(coat_gamma_out));
        float3 coat_affected_diffuse_color_out = pow(base_color_nonnegative_out, float3(coat_gamma_out));
        const float one_minus_coat_ior_to_F0_in1_tmp = 1.000000;
        float one_minus_coat_ior_to_F0_out = one_minus_coat_ior_to_F0_in1_tmp - coat_ior_to_F0_out;
        float3 emission_color0_out = float3(0.0);
        NG_convert_float_color3(one_minus_coat_ior_to_F0_out, emission_color0_out);
        surfaceshader shader_constructor_out = surfaceshader{float3(0.0),float3(0.0)};
        {
            float3 N = normalize(vd.normalWorld);
            float3 V = normalize(u_viewPosition - vd.positionWorld);
            float3 P = vd.positionWorld;
            float3 L = float3(0.000000, 0.000000, 0.000000);
            float occlusion = 1.0;

            float surfaceOpacity = opacity_luminance_float_out;

            // Shadow occlusion

            // Light loop
            int numLights = numActiveLightSources();
            lightshader lightShader;
            for (int activeLightIndex = 0; activeLightIndex < numLights; ++activeLightIndex)
            {
                sampleLightSource(u_lightData[activeLightIndex], vd.positionWorld, lightShader);
                L = lightShader.direction;

                // Calculate the BSDF response for this light source
                ClosureData closureData = makeClosureData(CLOSURE_TYPE_REFLECTION, L, V, N, P, occlusion);
                BSDF coat_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_dielectric_bsdf(closureData, coat, float3(1.000000, 1.000000, 1.000000), coat_IOR, coat_roughness_vector_out, false, 0.000000, 1.500000, coat_normal, coat_tangent_out, 0, 0, coat_bsdf_out);
                BSDF metal_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_conductor_bsdf(closureData, metalness_mix_fg_weight_out, artistic_ior_ior, artistic_ior_extinction, main_roughness_out, false, thin_film_thickness, thin_film_IOR, normal, main_tangent_out, 0, metal_bsdf_out);
                BSDF specular_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_dielectric_bsdf(closureData, specular, specular_color, specular_IOR, main_roughness_out, false, thin_film_thickness, thin_film_IOR, normal, main_tangent_out, 0, 0, specular_bsdf_out);
                BSDF transmission_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_dielectric_bsdf(closureData, transmission_mix_fg_weight_out, transmission_color, specular_IOR, transmission_roughness_out, false, 0.000000, 1.500000, normal, main_tangent_out, 0, 1, transmission_bsdf_out);
                BSDF sheen_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_sheen_bsdf(closureData, sheen, sheen_color, sheen_roughness, normal, 0, sheen_bsdf_out);
                BSDF translucent_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_translucent_bsdf(closureData, selected_subsurface_bsdf_fg_weight_out, coat_affected_subsurface_color_out, normal, translucent_bsdf_out);
                BSDF subsurface_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_subsurface_bsdf(closureData, selected_subsurface_bsdf_bg_weight_out, coat_affected_subsurface_color_out, subsurface_radius_scaled_out, subsurface_anisotropy, normal, subsurface_bsdf_out);
                BSDF selected_subsurface_bsdf_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, translucent_bsdf_out, subsurface_bsdf_out, selected_subsurface_bsdf_add_out);
                BSDF subsurface_mix_fg_mul_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_float(closureData, selected_subsurface_bsdf_add_out, subsurface, subsurface_mix_fg_mul_out);
                BSDF diffuse_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_oren_nayar_diffuse_bsdf(closureData, subsurface_mix_bg_weight_out, coat_affected_diffuse_color_out, diffuse_roughness, normal, false, diffuse_bsdf_out);
                BSDF subsurface_mix_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, subsurface_mix_fg_mul_out, diffuse_bsdf_out, subsurface_mix_add_out);
                BSDF sheen_layer_out = BSDF{float3(0.0),float3(1.0)};
                mx_layer_bsdf(closureData, sheen_bsdf_out, subsurface_mix_add_out, sheen_layer_out);
                BSDF transmission_mix_bg_mul_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_float(closureData, sheen_layer_out, transmission_mix_mix_inv_out, transmission_mix_bg_mul_out);
                BSDF transmission_mix_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, transmission_bsdf_out, transmission_mix_bg_mul_out, transmission_mix_add_out);
                BSDF specular_layer_out = BSDF{float3(0.0),float3(1.0)};
                mx_layer_bsdf(closureData, specular_bsdf_out, transmission_mix_add_out, specular_layer_out);
                BSDF metalness_mix_bg_mul_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_float(closureData, specular_layer_out, metalness_mix_mix_inv_out, metalness_mix_bg_mul_out);
                BSDF metalness_mix_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, metal_bsdf_out, metalness_mix_bg_mul_out, metalness_mix_add_out);
                BSDF thin_film_layer_attenuated_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_color3(closureData, metalness_mix_add_out, coat_attenuation_out, thin_film_layer_attenuated_out);
                BSDF coat_layer_out = BSDF{float3(0.0),float3(1.0)};
                mx_layer_bsdf(closureData, coat_bsdf_out, thin_film_layer_attenuated_out, coat_layer_out);

                // Accumulate the light's contribution
                shader_constructor_out.color += lightShader.intensity * coat_layer_out.response;

                // Clear shadow factor for next light
                occlusion = 1.0;
            }

            // Ambient occlusion
            occlusion = 1.0;

            // Add environment contribution
            {
                ClosureData closureData = makeClosureData(CLOSURE_TYPE_INDIRECT, L, V, N, P, occlusion);
                BSDF coat_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_dielectric_bsdf(closureData, coat, float3(1.000000, 1.000000, 1.000000), coat_IOR, coat_roughness_vector_out, false, 0.000000, 1.500000, coat_normal, coat_tangent_out, 0, 0, coat_bsdf_out);
                BSDF metal_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_conductor_bsdf(closureData, metalness_mix_fg_weight_out, artistic_ior_ior, artistic_ior_extinction, main_roughness_out, false, thin_film_thickness, thin_film_IOR, normal, main_tangent_out, 0, metal_bsdf_out);
                BSDF specular_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_dielectric_bsdf(closureData, specular, specular_color, specular_IOR, main_roughness_out, false, thin_film_thickness, thin_film_IOR, normal, main_tangent_out, 0, 0, specular_bsdf_out);
                BSDF transmission_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_dielectric_bsdf(closureData, transmission_mix_fg_weight_out, transmission_color, specular_IOR, transmission_roughness_out, false, 0.000000, 1.500000, normal, main_tangent_out, 0, 1, transmission_bsdf_out);
                BSDF sheen_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_sheen_bsdf(closureData, sheen, sheen_color, sheen_roughness, normal, 0, sheen_bsdf_out);
                BSDF translucent_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_translucent_bsdf(closureData, selected_subsurface_bsdf_fg_weight_out, coat_affected_subsurface_color_out, normal, translucent_bsdf_out);
                BSDF subsurface_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_subsurface_bsdf(closureData, selected_subsurface_bsdf_bg_weight_out, coat_affected_subsurface_color_out, subsurface_radius_scaled_out, subsurface_anisotropy, normal, subsurface_bsdf_out);
                BSDF selected_subsurface_bsdf_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, translucent_bsdf_out, subsurface_bsdf_out, selected_subsurface_bsdf_add_out);
                BSDF subsurface_mix_fg_mul_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_float(closureData, selected_subsurface_bsdf_add_out, subsurface, subsurface_mix_fg_mul_out);
                BSDF diffuse_bsdf_out = BSDF{float3(0.0),float3(1.0)};
                mx_oren_nayar_diffuse_bsdf(closureData, subsurface_mix_bg_weight_out, coat_affected_diffuse_color_out, diffuse_roughness, normal, false, diffuse_bsdf_out);
                BSDF subsurface_mix_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, subsurface_mix_fg_mul_out, diffuse_bsdf_out, subsurface_mix_add_out);
                BSDF sheen_layer_out = BSDF{float3(0.0),float3(1.0)};
                mx_layer_bsdf(closureData, sheen_bsdf_out, subsurface_mix_add_out, sheen_layer_out);
                BSDF transmission_mix_bg_mul_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_float(closureData, sheen_layer_out, transmission_mix_mix_inv_out, transmission_mix_bg_mul_out);
                BSDF transmission_mix_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, transmission_bsdf_out, transmission_mix_bg_mul_out, transmission_mix_add_out);
                BSDF specular_layer_out = BSDF{float3(0.0),float3(1.0)};
                mx_layer_bsdf(closureData, specular_bsdf_out, transmission_mix_add_out, specular_layer_out);
                BSDF metalness_mix_bg_mul_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_float(closureData, specular_layer_out, metalness_mix_mix_inv_out, metalness_mix_bg_mul_out);
                BSDF metalness_mix_add_out = BSDF{float3(0.0),float3(1.0)};
                mx_add_bsdf(closureData, metal_bsdf_out, metalness_mix_bg_mul_out, metalness_mix_add_out);
                BSDF thin_film_layer_attenuated_out = BSDF{float3(0.0),float3(1.0)};
                mx_multiply_bsdf_color3(closureData, metalness_mix_add_out, coat_attenuation_out, thin_film_layer_attenuated_out);
                BSDF coat_layer_out = BSDF{float3(0.0),float3(1.0)};
                mx_layer_bsdf(closureData, coat_bsdf_out, thin_film_layer_attenuated_out, coat_layer_out);

                shader_constructor_out.color += occlusion * coat_layer_out.response;
            }

            // Add surface emission
            {
                ClosureData closureData = makeClosureData(CLOSURE_TYPE_EMISSION, L, V, N, P, occlusion);
                EDF emission_edf_out = EDF(0.0);
                mx_uniform_edf(closureData, emission_weight_out, emission_edf_out);
                EDF coat_tinted_emission_edf_out = EDF(0.0);
                mx_multiply_edf_color3(closureData, emission_edf_out, coat_color, coat_tinted_emission_edf_out);
                EDF coat_emission_edf_out = EDF(0.0);
                mx_generalized_schlick_edf(closureData, emission_color0_out, float3(0.000000, 0.000000, 0.000000), 5.000000, coat_tinted_emission_edf_out, coat_emission_edf_out);
                EDF blended_coat_emission_edf_out = EDF(0.0);
                mx_mix_edf(closureData, coat_emission_edf_out, emission_edf_out, coat, blended_coat_emission_edf_out);
                shader_constructor_out.color += blended_coat_emission_edf_out;
            }

            // Calculate the BSDF transmission for viewing direction
            ClosureData closureData = makeClosureData(CLOSURE_TYPE_TRANSMISSION, L, V, N, P, occlusion);
            BSDF coat_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_dielectric_bsdf(closureData, coat, float3(1.000000, 1.000000, 1.000000), coat_IOR, coat_roughness_vector_out, false, 0.000000, 1.500000, coat_normal, coat_tangent_out, 0, 0, coat_bsdf_out);
            BSDF metal_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_conductor_bsdf(closureData, metalness_mix_fg_weight_out, artistic_ior_ior, artistic_ior_extinction, main_roughness_out, false, thin_film_thickness, thin_film_IOR, normal, main_tangent_out, 0, metal_bsdf_out);
            BSDF specular_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_dielectric_bsdf(closureData, specular, specular_color, specular_IOR, main_roughness_out, false, thin_film_thickness, thin_film_IOR, normal, main_tangent_out, 0, 0, specular_bsdf_out);
            BSDF transmission_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_dielectric_bsdf(closureData, transmission_mix_fg_weight_out, transmission_color, specular_IOR, transmission_roughness_out, false, 0.000000, 1.500000, normal, main_tangent_out, 0, 1, transmission_bsdf_out);
            BSDF sheen_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_sheen_bsdf(closureData, sheen, sheen_color, sheen_roughness, normal, 0, sheen_bsdf_out);
            BSDF translucent_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_translucent_bsdf(closureData, selected_subsurface_bsdf_fg_weight_out, coat_affected_subsurface_color_out, normal, translucent_bsdf_out);
            BSDF subsurface_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_subsurface_bsdf(closureData, selected_subsurface_bsdf_bg_weight_out, coat_affected_subsurface_color_out, subsurface_radius_scaled_out, subsurface_anisotropy, normal, subsurface_bsdf_out);
            BSDF selected_subsurface_bsdf_add_out = BSDF{float3(0.0),float3(1.0)};
            mx_add_bsdf(closureData, translucent_bsdf_out, subsurface_bsdf_out, selected_subsurface_bsdf_add_out);
            BSDF subsurface_mix_fg_mul_out = BSDF{float3(0.0),float3(1.0)};
            mx_multiply_bsdf_float(closureData, selected_subsurface_bsdf_add_out, subsurface, subsurface_mix_fg_mul_out);
            BSDF diffuse_bsdf_out = BSDF{float3(0.0),float3(1.0)};
            mx_oren_nayar_diffuse_bsdf(closureData, subsurface_mix_bg_weight_out, coat_affected_diffuse_color_out, diffuse_roughness, normal, false, diffuse_bsdf_out);
            BSDF subsurface_mix_add_out = BSDF{float3(0.0),float3(1.0)};
            mx_add_bsdf(closureData, subsurface_mix_fg_mul_out, diffuse_bsdf_out, subsurface_mix_add_out);
            BSDF sheen_layer_out = BSDF{float3(0.0),float3(1.0)};
            mx_layer_bsdf(closureData, sheen_bsdf_out, subsurface_mix_add_out, sheen_layer_out);
            BSDF transmission_mix_bg_mul_out = BSDF{float3(0.0),float3(1.0)};
            mx_multiply_bsdf_float(closureData, sheen_layer_out, transmission_mix_mix_inv_out, transmission_mix_bg_mul_out);
            BSDF transmission_mix_add_out = BSDF{float3(0.0),float3(1.0)};
            mx_add_bsdf(closureData, transmission_bsdf_out, transmission_mix_bg_mul_out, transmission_mix_add_out);
            BSDF specular_layer_out = BSDF{float3(0.0),float3(1.0)};
            mx_layer_bsdf(closureData, specular_bsdf_out, transmission_mix_add_out, specular_layer_out);
            BSDF metalness_mix_bg_mul_out = BSDF{float3(0.0),float3(1.0)};
            mx_multiply_bsdf_float(closureData, specular_layer_out, metalness_mix_mix_inv_out, metalness_mix_bg_mul_out);
            BSDF metalness_mix_add_out = BSDF{float3(0.0),float3(1.0)};
            mx_add_bsdf(closureData, metal_bsdf_out, metalness_mix_bg_mul_out, metalness_mix_add_out);
            BSDF thin_film_layer_attenuated_out = BSDF{float3(0.0),float3(1.0)};
            mx_multiply_bsdf_color3(closureData, metalness_mix_add_out, coat_attenuation_out, thin_film_layer_attenuated_out);
            BSDF coat_layer_out = BSDF{float3(0.0),float3(1.0)};
            mx_layer_bsdf(closureData, coat_bsdf_out, thin_film_layer_attenuated_out, coat_layer_out);
            shader_constructor_out.color += coat_layer_out.response;

            // Compute and apply surface opacity
            {
                shader_constructor_out.color *= surfaceOpacity;
                shader_constructor_out.transparency = mix(float3(1.000000, 1.000000, 1.000000), shader_constructor_out.transparency, surfaceOpacity);
            }
        }

        out1 = shader_constructor_out;
    }

    PixelOutputs FragmentMain()
    {
        float3 geomprop_Nworld_out1 = normalize(vd.normalWorld);
        float3 geomprop_Tworld_out1 = normalize(vd.tangentWorld);
        float3 geomprop_Pobject_out1 = vd.positionObject;
        float noise_r_out = 0.0;
        mx_fractal3d_float(noise_r_amplitude, noise_r_octaves, noise_r_lacunarity, noise_r_diminish, geomprop_Pobject_out1, noise_r_out);
        float noise_g_out = 0.0;
        mx_fractal3d_float(noise_g_amplitude, noise_g_octaves, noise_g_lacunarity, noise_g_diminish, geomprop_Pobject_out1, noise_g_out);
        float noise_b_out = 0.0;
        mx_fractal3d_float(noise_b_amplitude, noise_b_octaves, noise_b_lacunarity, noise_b_diminish, geomprop_Pobject_out1, noise_b_out);
        float3 emi_col_out = { noise_r_out,noise_g_out,noise_b_out };
        surfaceshader SR_triplanar_out = surfaceshader{float3(0.0),float3(0.0)};
        NG_standard_surface_surfaceshader_100(SR_triplanar_base, SR_triplanar_base_color, SR_triplanar_diffuse_roughness, SR_triplanar_metalness, SR_triplanar_specular, SR_triplanar_specular_color, SR_triplanar_specular_roughness, SR_triplanar_specular_IOR, SR_triplanar_specular_anisotropy, SR_triplanar_specular_rotation, SR_triplanar_transmission, SR_triplanar_transmission_color, SR_triplanar_transmission_depth, SR_triplanar_transmission_scatter, SR_triplanar_transmission_scatter_anisotropy, SR_triplanar_transmission_dispersion, SR_triplanar_transmission_extra_roughness, SR_triplanar_subsurface, SR_triplanar_subsurface_color, SR_triplanar_subsurface_radius, SR_triplanar_subsurface_scale, SR_triplanar_subsurface_anisotropy, SR_triplanar_sheen, SR_triplanar_sheen_color, SR_triplanar_sheen_roughness, SR_triplanar_coat, SR_triplanar_coat_color, SR_triplanar_coat_roughness, SR_triplanar_coat_anisotropy, SR_triplanar_coat_rotation, SR_triplanar_coat_IOR, geomprop_Nworld_out1, SR_triplanar_coat_affect_color, SR_triplanar_coat_affect_roughness, SR_triplanar_thin_film_thickness, SR_triplanar_thin_film_IOR, SR_triplanar_emission, emi_col_out, SR_triplanar_opacity, SR_triplanar_thin_walled, geomprop_Nworld_out1, geomprop_Tworld_out1, SR_triplanar_out);
        material proc_noise_mat_out = SR_triplanar_out;
        out1 = float4(proc_noise_mat_out.color, 1.0);
return PixelOutputs{out1        };
    }

};
fragment PixelOutputs FragmentMain(
VertexData vd [[ stage_in ]], constant LightData_pixel& u_lightData[[ buffer(0) ]], texture2d<float> u_envRadiance_tex [[texture(0)]], sampler u_envRadiance_sampler [[sampler(0)]]
, texture2d<float> u_envIrradiance_tex [[texture(1)]], sampler u_envIrradiance_sampler [[sampler(1)]]
, constant PrivateUniforms& u_prv[[ buffer(1) ]], constant PublicUniforms& u_pub[[ buffer(2) ]])
{
	GlobalContext ctx {vd,     u_lightData.u_lightData
    , u_prv.u_envMatrix
, MetalTexture    {
u_envRadiance_tex, u_envRadiance_sampler    }
    , u_prv.u_envLightIntensity
    , u_prv.u_envRadianceMips
    , u_prv.u_envRadianceSamples
, MetalTexture    {
u_envIrradiance_tex, u_envIrradiance_sampler    }
    , u_prv.u_refractionTwoSided
    , u_prv.u_viewPosition
    , u_prv.u_numActiveLightSources
    , u_pub.backsurfaceshader
    , u_pub.displacementshader1
    , u_pub.noise_r_amplitude
    , u_pub.noise_r_octaves
    , u_pub.noise_r_lacunarity
    , u_pub.noise_r_diminish
    , u_pub.noise_g_amplitude
    , u_pub.noise_g_octaves
    , u_pub.noise_g_lacunarity
    , u_pub.noise_g_diminish
    , u_pub.noise_b_amplitude
    , u_pub.noise_b_octaves
    , u_pub.noise_b_lacunarity
    , u_pub.noise_b_diminish
    , u_pub.SR_triplanar_base
    , u_pub.SR_triplanar_base_color
    , u_pub.SR_triplanar_diffuse_roughness
    , u_pub.SR_triplanar_metalness
    , u_pub.SR_triplanar_specular
    , u_pub.SR_triplanar_specular_color
    , u_pub.SR_triplanar_specular_roughness
    , u_pub.SR_triplanar_specular_IOR
    , u_pub.SR_triplanar_specular_anisotropy
    , u_pub.SR_triplanar_specular_rotation
    , u_pub.SR_triplanar_transmission
    , u_pub.SR_triplanar_transmission_color
    , u_pub.SR_triplanar_transmission_depth
    , u_pub.SR_triplanar_transmission_scatter
    , u_pub.SR_triplanar_transmission_scatter_anisotropy
    , u_pub.SR_triplanar_transmission_dispersion
    , u_pub.SR_triplanar_transmission_extra_roughness
    , u_pub.SR_triplanar_subsurface
    , u_pub.SR_triplanar_subsurface_color
    , u_pub.SR_triplanar_subsurface_radius
    , u_pub.SR_triplanar_subsurface_scale
    , u_pub.SR_triplanar_subsurface_anisotropy
    , u_pub.SR_triplanar_sheen
    , u_pub.SR_triplanar_sheen_color
    , u_pub.SR_triplanar_sheen_roughness
    , u_pub.SR_triplanar_coat
    , u_pub.SR_triplanar_coat_color
    , u_pub.SR_triplanar_coat_roughness
    , u_pub.SR_triplanar_coat_anisotropy
    , u_pub.SR_triplanar_coat_rotation
    , u_pub.SR_triplanar_coat_IOR
    , u_pub.SR_triplanar_coat_affect_color
    , u_pub.SR_triplanar_coat_affect_roughness
    , u_pub.SR_triplanar_thin_film_thickness
    , u_pub.SR_triplanar_thin_film_IOR
    , u_pub.SR_triplanar_emission
    , u_pub.SR_triplanar_opacity
    , u_pub.SR_triplanar_thin_walled
    };
    return ctx.FragmentMain();
}

