Shader "MyShader/VFX/07_Fire" {
    Properties {
        _Mask ("R：外焰 G：内焰 B：扰动遮罩 + 透贴", 2D) = "blue"{}
        _NoiseTex ("R：噪声图1 G：噪声图2 ", 2D) = "gray"{}
        _Noise1Params("噪声图1 X：大小  Y：流速  Z：强度", vector) = (1.0, 0.2, 0.2, 1.0)
        _Noise2Params("噪声图2 X：大小  Y：流速  Z：强度", vector) = (1.0, 0.2, 0.2, 1.0)
        [HDR]_Color1    ("外焰颜色", color) = (1,1,1,1)
        [HDR]_Color2    ("内焰颜色", color) = (1,1,1,1)
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

            uniform sampler2D _Mask;    uniform float4 _Mask_ST;
            uniform sampler2D _NoiseTex;
            uniform half3 _Noise1Params;
            uniform half3 _Noise2Params;
            uniform half3 _Color1;
            uniform half3 _Color2;
        
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
                o.uv0 = TRANSFORM_TEX(v.uv0, _Mask);
                o.uv1 = o.uv0 * _Noise1Params.x - float2(0, frac(_Time.x * _Noise1Params.y)); 
                o.uv2 = o.uv0 * _Noise2Params.x - float2(0, frac(_Time.x * _Noise2Params.y)); 
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half warpMask = tex2D(_Mask, i.uv0).b;
                half var_NoiseTex1 = tex2D(_NoiseTex, i.uv1).r;
                half var_NoiseTex2 = tex2D(_NoiseTex, i.uv2).g;
                half noise = var_NoiseTex1 * _Noise1Params.z +  var_NoiseTex2 * _Noise2Params.z;

                float2 warpUV = i.uv0 - float2(0, noise) * warpMask;
                half3 var_Mask = tex2D(_Mask, warpUV);
                
                half3 finalRGB = _Color1 * var_Mask.r + _Color2 * var_Mask.g;
                half opacity = var_Mask.r + var_Mask.g;

                return half4(finalRGB, opacity);
            }
            ENDCG
        }
    }
}
