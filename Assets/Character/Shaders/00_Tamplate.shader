// 光照模型 ：伯特
Shader "MyShader/Character/00_Tamplate" {
    Properties {
    }
    SubShader {
        Pass {
            Tags{ "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
        
        
            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 nDirWS : COLOR0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.nDirWS = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                // 准备向量
                fixed3 nDir = normalize(i.nDirWS);
                fixed3 lDir = normalize(_WorldSpaceLightPos0.xyz);

                // 计算
                fixed lambert =  saturate(dot(nDir, lDir)); 

                return fixed4(lambert, lambert, lambert,1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
