Shader "Unity_Shader_Book/Chapter6/Blinn-Phone_Frag" {
    Properties{
        // 整体颜色
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        // 高光颜色
        _Specular("Specular",Color) = (1,1,1,1)
        // 高光强度
        _Gloss("Gloss",Range(0,200)) = 10
    }
    SubShader {
        Pass{
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;
            float _Gloss;
            fixed4 _Specular;

            struct a2v {
                // 顶点坐标
                float4 vertex : POSITION;
                // 法向量
                float3 normal: NORMAL;
            };

            struct v2f{
                // 顶点坐标
                float4 position:SV_POSITION;
                  // 世界空间下的法向量
                fixed3 worldNormal: TEXCOORD0;
                // 世界空间下坐标
                float3 worldVertex: TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
                o.worldVertex = mul(v.vertex, unity_WorldToObject).xyz;

                return o;
            };

            fixed4 frag(v2f i):SV_TARGET{
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 法向量
                fixed3 normalDir = normalize(i.worldNormal);
                // 光源方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
                // 相机视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldVertex);
                // 对视角方向
                fixed3 halfDir = normalize(lightDir + viewDir);
                // 高光反射
                fixed3 specular = _LightColor0.rgb * pow(max(0,dot(i.worldNormal, halfDir)), _Gloss) * _Specular;
                // 合并漫反射，环境光，高光反射
                fixed3 color = diffuse + ambient + specular;
                
                return fixed4(color, 1);
            };

            ENDCG
        }
    }
    FallBack "VertexLit"
}