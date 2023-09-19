// 逐像素光照
Shader "Unity_Shader_Book/Chapter6/Lambert_Vert" {
    Properties {
        _Diffuse("Diffuse", color) = (1, 1, 1, 1)
    }
    SubShader {
        tags{ "LightMode" = "ForwardBase" }

        Pass {
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 position : SV_POSITION;
                fixed3 color : COLOR0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                // 世界坐标下的法线方向
                fixed3 worldNormalDir = mul(v.normal, (float3x3)unity_WorldToObject);

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 法向量
                fixed3 normalDir = normalize(worldNormalDir);
                // 光照方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 漫反射计算
                // saturate（CG方法：把值限制在[0,1]）
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(normalDir,lightDir)) * _Diffuse.rgb;

                o.color = diffuse + ambient;

                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
