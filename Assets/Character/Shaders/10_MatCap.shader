//  MatCap贴图
Shader "MyShader/Character/10_Matcap" {
    Properties {
        _NormalMap ("法线贴图", 2D) = "white" {}
        _Matcap ("Matcap贴图", 2D) = "white" {}
        _FresnelPow ("菲尼尔次幂", Range(0,5)) = 1
        _EvnSpecInt ("环境镜面反射强度", Range(0,5)) = 1
    }
    SubShader {
        Pass {
            Tags{ "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            uniform sampler2D _NormalMap;
            uniform sampler2D _Matcap;
            uniform float _FresnelPow;
            uniform float _EvnSpecInt;
        
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
                float3 nDirVS = normalize(mul(UNITY_MATRIX_V, float4(nDirWS, 0.0)));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                
                // 计算中间量
                float2 matcapUV = nDirVS.rg * 0.5 + 0.5;    //将观测空间下的法线的rg 通道（-1，1）映射到0-1
                float vDotn = dot(vDirWS, nDirWS);

                //  计算效果
                float3 var_matcap =  tex2D(_Matcap, matcapUV);
                float fresneil = pow((1 - vDotn), _FresnelPow);
                float3 envSpecLihting = var_matcap * fresneil *_EvnSpecInt;

                // 返回值
                return float4(envSpecLihting, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
