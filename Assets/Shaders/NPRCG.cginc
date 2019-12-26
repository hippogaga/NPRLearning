#ifndef NPR_CG_INCLUDED
#define NPR_CG_INCLUDED

#include "UnityStandardCoreForward.cginc"

float2 hash22(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float2 hash21(float2 p) {
    float h = dot(p, float2(127.1, 311.7));
    return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

//perlin
float perlin_noise(float2 p) {
    float2 pi = floor(p);
    float2 pf = p - pi;
    float2 w = pf * pf * (3.0 - 2.0 * pf);
    return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
        dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
        lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
            dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
}

half4 fragForwardBaseInternalNPR (VertexOutputForwardBase i)
{
 UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

 FRAGMENT_SETUP(s)

 UNITY_SETUP_INSTANCE_ID(i);
 UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

 UnityLight mainLight = MainLight ();
 UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

 half occlusion = Occlusion(i.tex.xy);
 UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

 half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
 c.rgb += Emission(i.tex.xy);

 UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
 UNITY_APPLY_FOG(_unity_fogCoord, c.rgb);
 return OutputForward (c, s.alpha);
}

#endif