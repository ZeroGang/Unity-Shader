// 用途：
// • 常用于发光体，辉光的表现；
// • 一般的特效表现，提亮用；
// 问题：
// • 有排序问题；
// • 多层叠加容易堆爆性能(OverDraw)；
// • 作为辉光效果，通常可用后处理代替；
Shader "MyShader/VFX/03_Addtive" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
    }
    SubShader {
        Tags{
            "Queue" = "Transparent"             // 渲染队列
            "RenderType" = "TransparentCutout"  // 改为对应的CutOut
            "ForceNoShadowCasting" = "True"     // 关闭阴影投射
            "IgnoreProject" = "True"            // 不响应投射器
        }
        Pass {
            Name "FORWARD"
            Tags{ 
                "LightMode" = "ForwardBase" 
            } 
            Blend One One //修好混合方式
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST; 
        
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
                half3 var_MainTex = tex2D(_MainTex, i.uv0).rgb;
                return half4(var_MainTex, 1.0);
            }
            ENDCG
        }
    }
}
