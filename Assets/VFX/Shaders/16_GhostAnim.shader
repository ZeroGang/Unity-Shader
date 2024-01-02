Shader "MyShader/VFX/16_GhostAnim" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity ("透明度", Range(0, 1)) = 0.5
        _ScaleParams ("天使圈缩放 X:强度 Y:速度 Z:校正", vector) = (0.2, 1.0, 4.5, 0.0)
        _SwingXParams ("X轴扭动 X:强度 Y:速度 Z:校正", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingYParams ("Y轴扭动 X:强度 Y:速度 Z:校正", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingZParams ("Z轴扭动 X:强度 Y:速度 Z:校正", vector) = (1.0, 3.0, 0.3, 0.0)
        _ShakeYParams ("Y轴摇头 X:强度 Y:速度 Z:校正", vector) = (20.0, 3.0, 0.3, 0.0)
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
            uniform float4 _ScaleParams;
            uniform float4 _SwingXParams;
            uniform float4 _SwingYParams;
            uniform float4 _SwingZParams;
            uniform float4 _ShakeYParams;
            
            #define TWO_PI 6.283185
            

            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 color : COLOR;
            };
            

            void Anim(inout float4 vertex, inout float4 color) {
                // 缩放天使轮
                float scale = _ScaleParams.x * color.g  * sin(frac(_Time.x * _ScaleParams.y) * TWO_PI);
                vertex *= 1 + scale;
                vertex.y += _ScaleParams.z * scale;

                // 幽灵摆动(呈现一个波形 vertex.y *_SwingXParams.z)
                float swingX = _SwingXParams.x * sin(frac(_Time.x *  _SwingXParams.y + vertex.y *_SwingXParams.z) * TWO_PI);
                float swingZ = _SwingZParams.x * sin(frac(_Time.x *  _SwingZParams.y + vertex.y *_SwingZParams.z) * TWO_PI);
                vertex.xz += float2(swingX, swingZ) * color.r;

                // 幽灵摇头(天使圈摇头滞后 - color.g *_ShakeYParams.z)
                float shakeY = (1 - color.r) * _ShakeYParams.x * sin(frac(_Time.x * _ShakeYParams.y - color.g *_ShakeYParams.z) * TWO_PI);
                float3x3 rotateYMatrix = float3x3(cos(shakeY), 0, -sin(shakeY),
                                                  0, 1, 0,
                                                  sin(shakeY), 0, cos(shakeY));
                vertex.xyz = mul(rotateYMatrix, vertex.xyz);

                // 幽灵起伏(天使圈起伏滞后 - color.g *_SwingYParams.z)
                float swingY = _SwingYParams.x * sin(frac(_Time.x *  _SwingYParams.y - color.g *_SwingYParams.z) * TWO_PI);
                vertex.y += swingY;

                // 处理顶点色(提亮 color.g * 1.0， 闪烁 scale * 2.0)
                float lighting = 1.0 + color.g * (1.0 + scale * 0.5);
                color.rgb =  float3(lighting, lighting, lighting);
            }

            v2f vert(a2v v) {
                v2f o;
                Anim(v.vertex, v.color);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex); 
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                half3 finalColor = var_MainTex.rgb * i.color.rgb;
                half opacity = var_MainTex.a * _Opacity;
                return half4(finalColor * opacity, opacity);
            }
            ENDCG
        }
    }
}
