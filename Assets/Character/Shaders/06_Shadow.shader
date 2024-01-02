// 三色环境光
Shader "MyShader/Character/06_Shadow" {
    Properties{
    }
    SubShader {
        Pass {
            Tags{ "RenderType" = "Opaque" "LightMode" = "ForwardBase" } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

			//可以保证我们在Shader中使用光照衰减等,光照变量可以被正确赋值。这是不可缺少的
            #pragma multi_compile_fwdbase_fullshadows
            // #pragma target 3.0

            struct a2v {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                
                // 投影信息 unity 已经封装
                LIGHTING_COORDS(0, 1)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                float shadow = LIGHT_ATTENUATION(i);
                return float4(shadow, shadow, shadow, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
