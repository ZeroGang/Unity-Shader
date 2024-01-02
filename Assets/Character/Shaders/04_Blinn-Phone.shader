// 光照模型 ：Blinn-Phone
Shader "MyShader/Character/04_Blinn-Phone" {
    Properties{
        // 整体颜色
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        // 高光颜色
        _Specular("Specular",Color) = (1,1,1,1)
        // 高光强度
        _Gloss("Gloss",Range(0,100)) = 10
    }
    SubShader {
        Pass{
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            float _Gloss;
            fixed4 _Specular;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f{
                fixed4 position:SV_POSITION;
                fixed3 worldNormal: TEXCOORD0;
                fixed3 worldVertex: TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                // 世界坐标下的法向量
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                // 世界空间下坐标
                o.worldVertex = mul(v.vertex, (float3x3)unity_WorldToObject);
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
                fixed3 diffuse = _LightColor0.rgb * max(0 , dot(normalDir, lightDir)) * _Diffuse.rgb;
                // 计算视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldVertex);
                // 计算反射光方向（视角方向和光照方向夹角一半的方向）
                fixed3 reflectDir = normalize(lightDir + viewDir);
                // 计算高光反射（用法线方向和反射光方向夹角来计算强度）
                fixed3 specular = _LightColor0.rgb * pow(max(0, dot(normalDir, reflectDir)), _Gloss) * _Specular;
                // 合并环境光， 漫反射，高光反射
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1);
            };

            ENDCG
        }
    }
    FallBack "Diffuse"
}