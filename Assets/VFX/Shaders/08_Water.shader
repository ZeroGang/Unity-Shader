Shader "MyShader/VFX/08_Water" {
    Properties {
        _MainTex        ("颜色贴图", 2d) = "white"{}
        _WarpTex        ("扰动图", 2d) = "gray"{}
        _Speed          ("X：流速X Y：流速Y", vector) = (1.0, 1.0, 0.0, 0.0)
        _Warp1Params    ("X：大小 Y：流速X Z：流速Y W：强度", vector) = (1.0, 1.0, 0.5, 1.0)
        _Warp2Params    ("X：大小 Y：流速X Z：流速Y W：强度", vector) = (2.0, 0.5, 0.5, 1.0)
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

            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _WarpTex;
            uniform half2 _Speed;
            uniform half4 _Warp1Params;
            uniform half4 _Warp2Params;
        
            struct a2v {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0 - frac(_Time.x * _Speed.xy);
                o.uv1 = v.uv0 * _Warp1Params.x - frac(_Time.x * _Warp1Params.yz); 
                o.uv2 = v.uv0 * _Warp2Params.x - frac(_Time.x * _Warp2Params.yz); 
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half3 var_WarpTex1 = tex2D(_WarpTex, i.uv1).rgb;
                half3 var_WarpTex2 = tex2D(_WarpTex, i.uv2).rgb;
                half2 warp = (var_WarpTex1.xy - 0.5) * _Warp1Params.w +  (var_WarpTex2.xy - 0.5) * _Warp2Params.w;

                float2 warpUV = i.uv0 + warp;
                half3 var_MainTex = tex2D(_MainTex, warpUV);

                return half4(var_MainTex.xyz, 1);
            }
            ENDCG
        }
    }
}
