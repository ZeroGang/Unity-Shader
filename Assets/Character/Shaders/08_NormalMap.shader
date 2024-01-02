// 光照模型 ：伯特
Shader "MyShader/Character/08_NormalMap" {
    Properties {
        _NormalMap ("法线贴图", 2D) = "white" {}
    }
    SubShader {
        Pass {
            Tags{ "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            sampler2D _NormalMap;

            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                fixed3 nDirWS : TEXCOORD1;
                fixed3 tDirWS : TEXCOORD2;
                fixed3 bDirWS : TEXCOORD3;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                // 世界坐标下的法线方向
                o.nDirWS = normalize(mul(unity_ObjectToWorld, v.normal));
                o.tDirWS = normalize(mul(unity_ObjectToWorld, v.tangent)) ;
                o.bDirWS = normalize(cross(o.nDirWS,o.tDirWS) * v.tangent.w);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                // 计算向量   
                float3 var_NormalMap = UnpackNormal(tex2D(_NormalMap, i.uv0));
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                fixed3 nDir = normalize(mul(var_NormalMap, TBN));
                fixed3 lDir = normalize(_WorldSpaceLightPos0.xyz);

                // 计算Lambert系数 saturate（CG方法：把值限制在[0,1]）
                fixed lambert = saturate(dot(nDir, lDir)); 

                return fixed4(lambert, lambert, lambert,1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
