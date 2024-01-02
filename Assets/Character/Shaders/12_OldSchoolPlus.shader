// 光照模型 ：伯特
Shader "MyShader/Character/12_OldSchoolPlus" {
    Properties {
        [Header(Texture)]
            _MainTex ("RGB:基础颜色 A:环境遮罩", 2D) = "white" {}
            _NormTex ("RGB:法线贴图", 2D) = "bump" {}   
            _SpecTex ("RGB:高光颜色 A:高光次幂", 2D) = "gray" {}
            _EmitTex ("RGB:自发光颜色", 2D) = "black" {}
            _Cubemap ("RGB:环境贴图", Cube) = "_Skybox" {}
        [Header(Diffuse)]
            _MainCol    ("基本色",Color) = (1,1,1,1)
            _EvnDiffInt ("环境漫反射强度", Range(0,1)) = 0.2
            _EnvUpCol   ("朝上环境光", Color) = (1.0, 1.0, 1.0, 1.0)
            _EnvSideCol ("边缘环境光", Color) = (0.5, 0.5, 0.5, 1.0)
            _EnvDownCol ("朝下环境光", Color) = (0.0, 0.0, 0.0, 1.0)
        [Header(Specular)]
            _SpecPow    ("高光次幂", Range(1,90)) = 30
            _EvnSpecInt ("环境镜面反射强度", Range(0,5)) = 1
            _FresnelPow ("菲尼尔次幂", Range(0,5)) = 1
            _CubemapMip ("环境球Mip", Range(0,7)) = 1
        [Header(Emission)]
            _EmisInt ("自发光", Range(1,10)) = 1
    }
    SubShader {
        Pass {
            Tags{ "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadows

            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            uniform sampler2D _MainTex;
            uniform sampler2D _NormTex;
            uniform sampler2D _SpecTex;   
            uniform sampler2D _EmitTex;
            uniform samplerCUBE _Cubemap;
            uniform float3 _MainCol;
            uniform float _EvnDiffInt;
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform float _SpecPow;
            uniform float _EvnSpecInt;
            uniform float _FresnelPow;
            uniform float _CubemapMip;
            uniform float _EmisInt;

            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                float3 tDirWS : TEXCOORD3;
                float3 bDirWS : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                o.posWS =  mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = normalize(mul(unity_ObjectToWorld, v.normal));
                o.tDirWS = normalize(mul(unity_ObjectToWorld, v.tangent));
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                // 向量准备
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 var_NormTex = UnpackNormal(tex2D(_NormTex, i.uv0)).rgb;
                float3 nDirWS = normalize(mul(TBN, var_NormTex));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
                float3 vrDirWS = reflect(-vDirWS, nDirWS);
                float3 lDirWS = _WorldSpaceLightPos0.xyz;
                float3 lrDirWS = reflect(-lDirWS, nDirWS);

                // 中间量计算
                float nDotl = dot(nDirWS, lDirWS);
                float vDotlr = dot(vDirWS, lrDirWS);
                float vDotn = dot(vDirWS, nDirWS);
             

                //纹理采样
                float4 var_MainTex = tex2D(_MainTex, i.uv0);
                float4 var_SpecTex = tex2D(_SpecTex, i.uv0);
                float3 var_EmitTex = tex2D(_EmitTex, i.uv0).rgb;
                float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, lerp(_CubemapMip, 1.0, var_SpecTex.a))).rgb;
                // 光照模型
                float3 baseCol = var_MainTex.rgb * _MainCol;
                    // 光源漫反射 
                float lambert = max(0.0, nDotl); 
                float3 diffCol = baseCol * lambert;
                    // 光源镜面反射
                float specPow = lerp(1, _SpecPow, var_SpecTex.a);
                float phone = pow(max(0.0, vDotlr), specPow);
                float3 specCol = var_SpecTex.rgb * phone;
                    // 光源混合
                float shadow = LIGHT_ATTENUATION(i);
                float3 dirLighting = (diffCol + specCol) * _LightColor0.rgb * shadow;
                    // 环境漫反射
                float upMask = max(0.0, nDirWS.g);
                float downMask = max(0.0, -nDirWS.g);
                float sideMask = 1 - upMask - downMask;
                float3 envCol = _EnvUpCol * upMask + _EnvDownCol * downMask + _EnvSideCol * sideMask;
                float3 envDiffCol = baseCol * envCol * _EvnDiffInt;
                    // 环境镜面反射
                float fresneil = pow((1 - vDotn), _FresnelPow);
                float3 envSpecCol = var_Cubemap * fresneil * _EvnSpecInt;
                    // 环境混合
                float occlusion = var_MainTex.a;
                float3 envLighting = (envDiffCol + envSpecCol) * occlusion;
                    // 自发光
                float3 emisLighting = var_EmitTex * _EmisInt;
                // 输出
                return fixed4(dirLighting + envLighting + emisLighting, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
