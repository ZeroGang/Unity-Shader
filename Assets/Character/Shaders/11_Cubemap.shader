//  Cubemap贴图
Shader "MyShader/Character/11_Cubemap" {
    Properties {
        _Cubemap ("环境球", Cube) = "white" {}
        _CubemapMip ("环境球Mip", Range(0,5)) = 1
        _NormalMap ("法线贴图", 2D) = "white" {}
        _FresnelPow ("菲尼尔次幂", Range(0,5)) = 1
        _EvnSpecInt ("环境镜面反射强度", Range(0,7)) = 1
        _Occlusive  ("环境遮挡贴图", 2D) = "white" {}
    }
    SubShader {
        Pass {
            Tags{ "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            uniform samplerCUBE _Cubemap;
            uniform float _CubemapMip;
            uniform sampler2D _NormalMap;
            uniform float _FresnelPow;
            uniform float _EvnSpecInt;
            uniform sampler2D _Occlusive;
        
            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent :TANGENT;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD0;
                float2 uv0 : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                float3 tDirWS : TEXCOORD3;
                float3 bDirWS : TEXCOORD4;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                o.posWS =  mul(unity_ObjectToWorld, v.vertex.xyz);
                o.nDirWS = normalize(mul(unity_ObjectToWorld, v.normal));
                o.tDirWS = normalize(mul(unity_ObjectToWorld, v.tangent));
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                return o;
            }


            float4 frag(v2f i) : SV_Target {
                // 准备向量
                float3x3 TBN = float3x3(i.nDirWS, i.tDirWS, i.bDirWS);
                float3 var_NormalMap = UnpackNormal(tex2D(_NormalMap, i.uv0));
                float3 nDirWS = normalize(mul(var_NormalMap, TBN));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 vrDirWS = reflect(-vDirWS, nDirWS);
                
                // 计算中间量
                float vDotn = dot(vDirWS, nDirWS);

                //  计算效果
                float var_OcclusiveMap = tex2D(_Occlusive, i.uv0).r;
                float3 var_CubeMap = texCUBElod(_Cubemap, float4(vrDirWS, _CubemapMip));
                float fresneil = pow((1 - vDotn), _FresnelPow);
                float3 envSpecLihting = var_OcclusiveMap * var_CubeMap * fresneil *_EvnSpecInt;

                // 返回值
                return float4(envSpecLihting, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
