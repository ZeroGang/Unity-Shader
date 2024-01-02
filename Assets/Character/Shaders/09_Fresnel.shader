//  菲尼尔效果
Shader "MyShader/Character/09_Fresnel" {
    Properties {
        _FresnelPow ("菲尼尔次幂", Range(0,5)) = 1
    }
    SubShader {
        Pass {
            Tags{ "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            float _FresnelPow;
        
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD0;
                float3 nDirWS : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex.xyz);
                o.nDirWS = mul(unity_ObjectToWorld, v.normal);
                return o;
            }


            float4 frag(v2f i) : SV_Target {
                // 准备向量
                float3 nDir = normalize(i.nDirWS);
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float vDotn = dot(vDir, nDir);

                // 计算
                float fresneil = pow((1 - vDotn), _FresnelPow);

                return float4(fresneil, fresneil, fresneil, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
