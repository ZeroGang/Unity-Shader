Shader "UnityShaderBook/Ramp_Texture"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        // 渐变纹理
        _RampTex ("Ramp Tex", 2D) = "white" {}
        // 高光颜色
        _Specular("Specular", Color) = (1, 1, 1, 1)
        // 高光强度
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader{
        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;     //需要定_ST变量
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                fixed3 worldNormal = normalize(i.worldNormal); 
                // 计算光源方向   
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); 
                // 计算观测方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); 

                // 计算贴图颜色
                // fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                // 计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 计算漫反射
                // fixed3 diffuse = _LightColor0.rgb * dot(worldNormal, lightDir) * 0.5 + 0.5;

                fixed halfLambert = dot(worldNormal, lightDir) * 0.5 + 0.5;

                fixed3 diffuse = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;
                // 半程
                fixed3 halfDir = normalize(viewDir + lightDir);
                // 计算高光项
                fixed specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);
                // 混合
                fixed3 color = (diffuse + specular + ambient) * _Color.rgb;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}