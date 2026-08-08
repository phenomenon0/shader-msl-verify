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
    float3 boost_in2;
    float SR_unlit_emission;
    float SR_unlit_transmission;
    float3 SR_unlit_transmission_color;
    float SR_unlit_opacity;
};

// Inputs block: VertexData
struct VertexData
{
    float4 pos [[position]];
    float3 positionObject ;
};
// Pixel shader outputs
struct PixelOutputs
{
    float4 out1;
};

#define AIRY_FRESNEL_ITERATIONS 2

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

    ,     float3 boost_in2

    ,     float SR_unlit_emission

    ,     float SR_unlit_transmission

    ,     float3 SR_unlit_transmission_color

    ,     float SR_unlit_opacity

    ) : 
gl_FragCoord(    vd.pos)
,    vd(vd)
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

    ,     boost_in2(boost_in2)

    ,     SR_unlit_emission(SR_unlit_emission)

    ,     SR_unlit_transmission(SR_unlit_transmission)

    ,     SR_unlit_transmission_color(SR_unlit_transmission_color)

    ,     SR_unlit_opacity(SR_unlit_opacity)

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

    float4 gl_FragCoord;
    VertexData vd;
    
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

    
    float3 boost_in2;

    
    float SR_unlit_emission;

    
    float SR_unlit_transmission;

    
    float3 SR_unlit_transmission_color;

    
    float SR_unlit_opacity;

    float4 out1;
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

    
    void mx_surface_unlit(float emission, float3 emission_color, float transmission, float3 transmission_color, float opacity, thread surfaceshader & result)
    {
        result.color = emission * emission_color * opacity;
        result.transparency = mix(float3(1.0), transmission * transmission_color, opacity);
    }

    PixelOutputs FragmentMain()
    {
        float3 geomprop_Pobject_out1 = vd.positionObject;
        float noise_r_out = 0.0;
        mx_fractal3d_float(noise_r_amplitude, noise_r_octaves, noise_r_lacunarity, noise_r_diminish, geomprop_Pobject_out1, noise_r_out);
        float noise_g_out = 0.0;
        mx_fractal3d_float(noise_g_amplitude, noise_g_octaves, noise_g_lacunarity, noise_g_diminish, geomprop_Pobject_out1, noise_g_out);
        float noise_b_out = 0.0;
        mx_fractal3d_float(noise_b_amplitude, noise_b_octaves, noise_b_lacunarity, noise_b_diminish, geomprop_Pobject_out1, noise_b_out);
        float3 emi_col_out = { noise_r_out,noise_g_out,noise_b_out };
        float3 boost_out = emi_col_out * boost_in2;
        surfaceshader SR_unlit_out = surfaceshader{float3(0.0),float3(0.0)};
        mx_surface_unlit(SR_unlit_emission, boost_out, SR_unlit_transmission, SR_unlit_transmission_color, SR_unlit_opacity, SR_unlit_out);
        material unlit_noise_mat_out = SR_unlit_out;
        out1 = float4(unlit_noise_mat_out.color, 1.0);
return PixelOutputs{out1        };
    }

};
fragment PixelOutputs FragmentMain(
VertexData vd [[ stage_in ]], constant PrivateUniforms& u_prv[[ buffer(0) ]], constant PublicUniforms& u_pub[[ buffer(1) ]])
{
	GlobalContext ctx {vd    , u_prv.u_numActiveLightSources
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
    , u_pub.boost_in2
    , u_pub.SR_unlit_emission
    , u_pub.SR_unlit_transmission
    , u_pub.SR_unlit_transmission_color
    , u_pub.SR_unlit_opacity
    };
    return ctx.FragmentMain();
}

