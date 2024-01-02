// 通用混合模板
// 追加 _Opacity 控制透明度 
// 统一认为纹理没有进行预乘，在 shader 中进行乘法
// Blend One OneMinusSrcAlpha = 02_AlphaBlend
// Blend One One = 03_Addtive
Shader "MyShader/VFX/04_BlendModel" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity ("透明度", Range(0, 1)) = 0.5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendSrc("混合源乘子", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendDst("混合目标乘子", int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("混合算符", int) = 0
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
            BlendOp [_BlendOp] 
            Blend [_BlendSrc] [_BlendDst] //修好混合方式
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST; 
            uniform half _Opacity;
        
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
                half3 finalRGB = var_MainTex.rgb;
                half opacity = var_MainTex.a * _Opacity;
                return half4(finalRGB * opacity, opacity);
            }
            ENDCG
        }
    }
}
