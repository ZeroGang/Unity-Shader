Shader "MyShader/VFX/05_UVFlow" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity ("透明度", Range(0, 1)) = 0.5
        _NoiseTex ("噪声图", 2D) = "gray"{}
        _NoiseInt ("噪声强度", Range(0, 5)) = 0.5
        _FlowSpeed ("流动速度", Range(-10, 10)) = 0
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
            Blend SrcAlpha OneMinusSrcAlpha //修好混合方式
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex; 
            uniform half _Opacity;
            uniform sampler2D _NoiseTex;
            uniform float4 _NoiseTex_ST;
            uniform half _NoiseInt;
            uniform half _FlowSpeed;
        
            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                o.uv1 = TRANSFORM_TEX(v.uv0, _NoiseTex); 
                // 流动
                o.uv1.y = o.uv1.y + frac(_Time.x * _FlowSpeed);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                half var_NoiseTex = tex2D(_NoiseTex, i.uv1);

                half3 finalRGB = var_MainTex.rgb;
                half noise = lerp(1.0, var_NoiseTex * 2.0, _NoiseInt);
                noise = max(0.0, noise);
                half opacity = var_MainTex.a * _Opacity * noise;

                return half4(finalRGB * opacity, opacity);
            }
            ENDCG
        }
    }
}
