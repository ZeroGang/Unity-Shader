// 三色环境光
Shader "MyShader/Character/07_OldSchool" {
    Properties{
        _BaseCol    ("基本色",Color) = (1,1,1,1)
        _LightCol   ("光照颜色",Color) = (1,1,1,1)
        _SpecPow    ("高光强度",Range(0,100)) = 10

        _Occlusive  ("环境遮挡贴图", 2D) = "white" {}
        _EnvInt     ("环境光强度", Range(0, 10)) = 1
        _EnvUpCol   ("环境天顶颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _EnvSideCol ("环境水平颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _EnvDownCol ("环境地表颜色", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader {
        Pass {
            Tags{ "RenderType" = "Opaque" "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadows

            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            uniform sampler2D _Occlusive;
            uniform float _EnvInt;
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform float3 _BaseCol;
            uniform float _SpecPow;
            uniform float3 _LightCol;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                // 投影信息 unity 已经封装
                LIGHTING_COORDS(3, 4)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = mul(unity_ObjectToWorld, v.normal);
                o.uv0 = v.uv0;
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                // 法向量
                float3 nDir = normalize(i.nDirWS);
                // 光源方向
                float3 lDir = _WorldSpaceLightPos0.xyz;
                // 计算视角方向
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                // 计算反射光方向（视角方向和光照方向夹角一半的方向）
                float3 rDir = reflect(-lDir, nDir);
               
                // 光照模型（直接光照）
                // 漫反射
                float diffuse = max(0.0 , dot(nDir, lDir));
                // 高光反射（用法线方向和反射光方向夹角来计算强度）
                float specular = pow(max(0, dot(vDir, rDir)), _SpecPow);
                // 投影
                float shadow = LIGHT_ATTENUATION(i);
                // 直接光照
                float3 dirLighting =  (_BaseCol * diffuse + specular ) *_LightCol * shadow;


                // 光照模型（环境光照）
                float upMask = max(0.0, nDir.g);
                float downMask = max(0.0, -nDir.g);
                float sideMask = 1.0 - upMask - downMask;
                // 采集Occasion贴图
                float occlusive = tex2D(_Occlusive, i.uv0);
                // 环境光照
                float3 envLighting = (_EnvUpCol * upMask + _EnvSideCol * sideMask + _EnvDownCol * downMask) * _EnvInt * _BaseCol * occlusive;

                return fixed4(dirLighting + envLighting, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
