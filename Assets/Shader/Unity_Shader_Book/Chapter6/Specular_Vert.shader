Shader "Unity_Shader_Book/Chapter6/Specular_Vert" {
    Properties{
        // 整体颜色
        _Diffuse("_Diffuse",Color) = (1,1,1,1)
        // 高光颜色
        _Specular("_Specular",Color) = (1,1,1,1)
        // 高光强度
        _Gloss("_Gloss",Range(8,200)) = 10
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
                // 顶点颜色
                fixed3 color: COLOR0;
            };

            //顶点着色
            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                fixed3 worldNormal = mul(v.normal,(float3x3) unity_WorldToObject);
                float3 worldVertex = mul(v.vertex, unity_WorldToObject).xyz;

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 法向量
                fixed3 normalDir = normalize(worldNormal);
                // 光源方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
                // 反射光方向
                fixed3 reflectDir = reflect(-lightDir,normalDir);
                // 相机视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldVertex);
                // 高光反射
                fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)), _Gloss) * _Specular;
                // 合并漫反射，环境光，高光反射
                o.color = diffuse + ambient + specular;

                return o;
            };

            // 片元着色器
            fixed4 frag(v2f i):SV_TARGET{
                return fixed4(i.color, 1);
            };

            ENDCG
        }
    }
    FallBack "VertexLit"
}