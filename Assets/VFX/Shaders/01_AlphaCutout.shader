// 用途：
// • 常用于复杂轮廓，明确边缘的物体表现，如：镂空金属，裙摆边缘，特定风格下的头发，树叶，等；
// • 卡通渲染的特效表现；
// 优点：
// • 没有排序问题；
// 缺点：
// • 边缘效果太实；
// • 移动端性能较差；

Shader "MyShader/VFX/01_AlphaCutout" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _CutOff ("透明阈值", Range(0.0 ,1.0)) = 0.5
    }
    SubShader {
        Tags{
            "RenderType" = "TransparentCutout"  // 改为对应的CutOut
            "ForceNoShadowCasting" = "True"     // 关闭阴影投射
            "IgnoreProject" = "True"            // 不响应投射器
        }
        Pass {
            Name "FORWARD"
            Tags{ 
                "LightMode" = "ForwardBase" 
            } 
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST; 
            uniform half _CutOff; 
        
            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex); 
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                clip(var_MainTex.a - _CutOff);
                return var_MainTex;
            }
            ENDCG
        }
    }
}
