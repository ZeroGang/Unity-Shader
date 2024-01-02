Shader "MyShader/VFX/14_ScaleAnim" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity ("透明度", Range(0, 1)) = 0.5
        _ScaleRange ("缩放范围", Range(0, 3)) = 1
        _ScaleSpeed ("缩放速度", Range(0, 3)) = 1
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
            Blend One OneMinusSrcAlpha //修好混合方式
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST; 
            uniform half _Opacity;
            uniform float _ScaleRange;
            uniform float _ScaleSpeed;
            
            #define TWO_PI 6.283185
            

            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };

            void ScaleAnim(inout float4 vertex) {
                vertex *= 1 + _ScaleRange * sin(frac(_Time.x * _ScaleSpeed) * TWO_PI);
            }

            v2f vert(a2v v) {
                v2f o;
			    ScaleAnim(v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex); 
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                half3 finalColor = var_MainTex.rgb;
                half opacity = var_MainTex.a * _Opacity;
                return half4(finalColor * opacity, opacity);
            }
            ENDCG
        }
    }
}
