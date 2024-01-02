Shader "MyShader/VFX/10_ScreenUVWarp" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity ("透明度", Range(0, 1)) = 0.5
        _WarpMidVal ("扰动修正中值", Range(0, 1)) = 0.5
        _WarpInt ("扰动强度", Range(0, 5)) = 1
    }
    SubShader {
        Tags{
            "Queue" = "Transparent"             // 渲染队列
            "RenderType" = "TransparentCutout"  // 改为对应的CutOut
            "ForceNoShadowCasting" = "True"     // 关闭阴影投射
            "IgnoreProject" = "True"            // 不响应投射器
        }

        GrabPass{
            "_BGTex"
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

            uniform sampler2D _MainTex; 
            uniform half _Opacity;
            uniform half _WarpMidVal;
            uniform half _WarpInt;
            uniform sampler2D _BGTex; 
        
            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0; 
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                i.grabPos.xy += (var_MainTex.b - _WarpMidVal) * _WarpInt * _Opacity;
                half3 var_BGTex = tex2Dproj(_BGTex, i.grabPos).rgb;
                half3 finalColor = var_MainTex.rgb * var_BGTex;
                half opacity = var_MainTex.a * _Opacity;
                return half4(finalColor * _Opacity, opacity);
            }
            ENDCG
        }
    }
}
