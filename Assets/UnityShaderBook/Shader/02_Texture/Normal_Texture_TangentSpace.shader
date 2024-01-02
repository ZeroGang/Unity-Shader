Shader "UnityShaderBook/Normal_Texture_TangentSpace"{
    Properties {
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
    SubShader {
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
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

            struct a2v {
                // 点 + 法线 + 贴图 + 切线
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            };
            
            struct v2f {
                float4 vertex : SV_POSITION;
                // 存法线纹理+漫反射纹理的坐标，因此是float4
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };
            
            v2f vert(a2v v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv =  TRANSFORM_TEX(v.texcoord, _MainTex) 与 下面等价
                // name_ST 表示贴图名为name 的偏移 对于贴图属性中的 Tiling值（贴图下u，v 值的缩放）和Offset值 （u，v 的偏移）默认值分别为（1，1）（0，0）
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

                //把模型空间下的TBN三向组成 模型 --> 切线空间的矩阵
                // float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz));
                // float3x3 rotation = float3x3(v,tangent.xyz, binormal, v.normal);  //TBN
                // 内置的获取TBN方法
                TANGENT_SPACE_ROTATION;
                
                //viewDir和lightDir换到切线空间下
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                // 归一化
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 tangentLightDir = normalize(i.lightDir);


                // 获取顶点的法线值（此时是一个像素颜色值）
                fixed4 packNormal = tex2D(_NormalMap, i.uv.zw);

                // 切线空间下的法线（法线纹理上的像素点转换成法线 = packNormal.xy * 2 - 1）
                fixed3 tangentNormal = UnpackNormal(packNormal);
                // 加上bumpScale的影响
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                
                // 计算贴图颜色
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                // 计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // 计算漫反射
                fixed3 diffuse = _LightColor0.rgb * dot(tangentNormal, tangentLightDir) * 0.5 + 0.5;
                // 半程
                fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
                // 计算高光项
                fixed specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss);
                // 混合
                fixed3 color = (diffuse + specular + ambient) * albedo;
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "VertexLit"
}

// 源码
// 查找tex帖图上 坐标为s的点
// float4 Tex2D(sampler2D tex, float2 s) 


// inline fixed3 UnpackNormal(fixed4 packednormal)
// {
    // #if defined(SHADER_API_GLES)  defined(SHADER_API_MOBILE)
    //     return packednormal.xyz * 2 - 1;
    // #else
    //     fixed3 normal;
    //     normal.xy = packednormal.wy * 2 - 1;
    //     normal.z = sqrt(1 - normal.x*normal.x - normal.y * normal.y);
    //     return normal;
    // #endif
// }