Shader "MyShader/VFX/12_PolarCoord" {
    Properties {
        _MainTex    ("RGB：颜色 A：透贴", 2D)   = "gray"{}
        [HDR]_Color ("混合颜色", Color)         = (1.0, 1.0, 1.0, 1.0)
        _Opacity    ("透明度", range(0, 1))     = 0.5
    }
    SubShader {
        Tags{
            "Queue" = "Transparent"             // 渲染队列
            "RenderType" = "TransparentCutout"  // 改为对应的CutOut
            "ForceNoShadowCasting" = "True"     // 关闭阴影投射
            "IgnoreProject" = "True"            // 不响应投射器
        }
        LOD 1000

        Pass {
            Name "FORWARD_AB"
            Tags{ 
                "LightMode" = "ForwardBase" 
            } 
            Blend One OneMinusSrcAlpha //修好混合方式
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex; 
            uniform half4 _Color;
            uniform half _Opacity;
        
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

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0; 
                o.color = v.color; 
                return o;
            }

            // 直角坐标转极坐标方法
            float2 RectToPolar(float2 uv, float2 centerUV) {
                uv = uv - centerUV;
                // atan()值域[-π/2, π/2]一般不用; atan2()值域[-π, π]
                float theta = atan2(uv.y, uv.x);    
                float r = length(uv);
                // 角度 , 半径
                return float2(theta, r);
            }


            fixed4 frag(v2f i) : SV_Target {
                // 直角坐标转极坐标
                float2 thetaR = RectToPolar(i.uv0, float2(0.5, 0.5));
                // 极坐标转纹理采样UV
                i.uv0 = float2(
                    thetaR.x / 3.141593 * 0.5 + 0.5,    // θ映射到[0, 1]
                    thetaR.y + frac(_Time.x * 3.0)      // r随时间流动
                );
                // 采样MainTex
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                // 处理最终输出
                half3 finalRGB = (1 - var_MainTex.rgb) * _Color;
                half opacity = (1 - var_MainTex.r) * _Opacity * i.color.r;
                // 返回值
                return half4(finalRGB * opacity, opacity);
            }
            ENDCG
        }
    }
}
