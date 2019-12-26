Shader "NPR/Base"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        
        //NPR Outline
        _OutlineWidth ("Outline Width", Range(0, 0.02)) = 0
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _NoiseTillOffset ("Noise Till Offset", Vector) = (0,0,0,0)
        _NoiseAmplify ("Noise Amplify", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks" = "False" }
        LOD 300

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertBase
            #pragma fragment fragBaseNPR
//            #pragma fragment fragBase
            
            
//            #include "UnityStandardConfig.cginc"
//           #include "UnityStandardCoreForwardSimple.cginc"
            #include "NPRCG.cginc"

            half4 fragBaseNPR (VertexOutputForwardBase i) : SV_Target
            {
                return fragForwardBaseInternalNPR(i);
            }

            ENDCG
        }
        
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite On
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                #include "NPRCG.cginc"
                
                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 uv : TEXCOORD0;
                };
                
                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float4 color : COLOR;
                    float4 uv : TEXCOORD0;
                };
                
                half _OutlineWidth;
                fixed4 _OutlineColor;
                half4 _NoiseTillOffset;
                half _NoiseAmplify;
                
                v2f vert(appdata v)
                {
                    v2f o;
                    o.color = _OutlineColor;
                    o.uv = v.uv;
                    
                    o.pos = UnityObjectToClipPos(v.vertex);
                    float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                    float2 extensionDir = normalize(TransformViewToProjection(normal.xy));
                    
                    float2 noiseSampleTex = v.uv;
                    noiseSampleTex = noiseSampleTex * _NoiseTillOffset.xy + _NoiseTillOffset.zw;
                    float noiseWidth = perlin_noise(noiseSampleTex);
                    noiseWidth = noiseWidth * 2 - 1;
                    
                    half outlineWidth = _OutlineWidth + _OutlineWidth * noiseWidth * _NoiseAmplify;
              
                    o.pos.xy += extensionDir * (outlineWidth * o.pos.w);
                    
                    return o;
                }
                
                half4 frag(v2f i) : SV_Target
                {
                    return i.color;
                }
            
            ENDCG
        }
    }
    
    FallBack "VertexLit"
}
