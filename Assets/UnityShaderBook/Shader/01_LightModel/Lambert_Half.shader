// 半兰伯特光照模型
Shader "UnityShaderBook/Lambert_Half"{
    Properties {
        _Diffuse("Diffuse", color) = (0, 0, 0, 0)
    }
    SubShader {
        Pass {
            tags{ "LightMode" = "ForwardBase" }
            
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
                fixed3 worldNormalDir : COLOR0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                // 世界坐标下的法线方向
                o.worldNormalDir = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 法向量
                fixed3 normalDir = normalize(i.worldNormalDir);
                // 光照方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 计算 halfLambert系数[0, 1]
                fixed3 halfLambert = dot(normalDir, lightDir) * 0.5 + 0.5; 
                // 漫反射计算
                fixed3 diffuse = _LightColor0.rgb * halfLambert * _Diffuse.rgb;
                // 计算最终颜色 
                fixed3 color = diffuse + ambient;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}