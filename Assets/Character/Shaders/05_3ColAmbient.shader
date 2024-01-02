// 三色环境光
Shader "MyShader/Character/05_3ColAmbient" {
    Properties{
        _Occlusive ("环境遮挡贴图", 2D) = "white" {}
        _EnvUpCol ("朝上环境光", Color) = (1.0, 1.0, 1.0, 1.0)
        _EnvSideCol ("边缘环境光", Color) = (1.0, 1.0, 1.0, 1.0)
        _EnvDownCol ("朝下环境光", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader {
        Pass {
            Tags{ "RenderType" = "Opaque" "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            uniform sampler2D _Occlusive;
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;


            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 nDirWS : COLOR0;
                float2 uv : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 世界坐标下的法线方向
                o.nDirWS = mul(v.normal, (float3x3)unity_WorldToObject);
                o.uv = v.uv0;
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                // 计算三部分遮罩
                float upMask = max(0.0, i.nDirWS.g);
                float downMask = max(0.0, -i.nDirWS.g);
                float sideMask = 1.0 - upMask - downMask;
                // 混合颜色 
                float3 envCol = _EnvUpCol * upMask + _EnvSideCol * sideMask + _EnvDownCol * downMask;
                // 采集Occasion贴图
                float occlusive = tex2D(_Occlusive, i.uv);
                // 计算环境光
                float3 envLighting = envCol * occlusive;
                return fixed4(envLighting, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
