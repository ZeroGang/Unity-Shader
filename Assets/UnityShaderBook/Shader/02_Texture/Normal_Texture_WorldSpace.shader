Shader "UnityShaderBook/Normal_Texture_WorldSpace"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        // 主贴图
        _MainTex ("Main Tex", 2D) = "white" {}
        // 法线纹理贴图
        _NormalMap("Normal Map", 2D) = "bump" {}
        // 凹凸程度
        _BumpScale ("Bump Scale", Range(-1.0, 1.0)) = 0
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
            sampler2D _MainTex;
            float4 _MainTex_ST;     //需要定_ST变量
            sampler2D _NormalMap;
            float4 _NormalMap_ST;     //需要定_ST变量
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW1 : TEXCOORD1;
                float4 TtoW2 : TEXCOORD2;
                float4 TtoW3 : TEXCOORD3;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
                // 切线空间矩阵TBN = worldTangent,worldBinormal,worldNormal
                // 切线空间的逆矩阵，由于该矩阵只有线性变换，所以矩阵的逆矩阵就是它的转置矩阵
                o.TtoW1 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW2 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW3 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                // 先取出模型的世界坐标
                float3 worldPos = float3(i.TtoW1.w,i.TtoW2.w,i.TtoW3.w);  

                // 计算光源方向   
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos)); 
                // 计算观测方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); 

                // 获得法线，对法线贴图进行取样（切线空间）
                fixed3 bump = UnpackNormal(tex2D(_NormalMap, i.uv));
                bump.xy *= _BumpScale;
                // 计算法线（世界空间）
                bump = normalize(float3(dot(i.TtoW1.xyz, bump),dot(i.TtoW2.xyz, bump),dot(i.TtoW3.xyz, bump)));
                // 和一个矩阵相乘就相当于和一个列向量组的每个向量相乘后组合在一起。

                // 计算贴图颜色
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                // 计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 计算漫反射
                fixed3 diffuse = _LightColor0.rgb * dot(bump, lightDir) * 0.5 + 0.5;
                // 半程
                fixed3 halfDir = normalize(viewDir + lightDir);
                // 计算高光项
                fixed specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, bump)), _Gloss);
                // 混合
                fixed3 color = (diffuse + specular + ambient) * albedo;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "VertexLit"
}