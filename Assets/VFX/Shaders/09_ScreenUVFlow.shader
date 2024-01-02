Shader "MyShader/VFX/09_ScreenUVFlow" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity ("透明度", Range(0, 1)) = 0.5
        _ScreenTex ("屏幕纹理", 2D) = "black"{}
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

            uniform sampler2D _MainTex; 
            uniform half _Opacity;
            uniform sampler2D _ScreenTex; 
            uniform float4 _ScreenTex_ST; 
        
            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 screenUV : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0; 
                // 获取屏幕uv
                float3 posVS = UnityObjectToViewPos(v.vertex).xyz;
                float originDis = UnityObjectToViewPos(float3(0.0, 0.0, 0.0)).z;
                // 消除激变
                o.screenUV = posVS.xy / posVS.z; 
                o.screenUV *= originDis;
                o.screenUV = o.screenUV * _ScreenTex_ST.xy - frac(_Time.x * _ScreenTex_ST.zw);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                half var_ScreenTex_r = tex2D(_ScreenTex, i.screenUV).r;
                half opacity = var_MainTex.a * _Opacity * var_ScreenTex_r;
                return half4(var_MainTex.rgb * opacity, opacity);
            }
            ENDCG
        }
    }
}
