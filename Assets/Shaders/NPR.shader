Shader "NPR/Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _OutlineWidth ("Outline Width", Range(0, 0.02)) = 0
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
        
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite On
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                
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
                
                v2f vert(appdata v)
                {
                    v2f o;
                    o.color = _OutlineColor;
                    o.uv = v.uv;
                    
                    o.pos = UnityObjectToClipPos(v.vertex);
                    float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                    float2 extensionDir = normalize(TransformViewToProjection(normal.xy));
                    o.pos.xy += extensionDir * (_OutlineWidth * o.pos.w);
                    
                    return o;
                }
                
                half4 frag(v2f i) : COLOR
                {
                    return i.color;
                }
            
            ENDCG
        }
    }
}
