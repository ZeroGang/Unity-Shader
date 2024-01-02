Shader "MyShader/VFX/11_Sequence" {
    Properties {
        _MainTex    ("RGB：颜色 A：透贴", 2D) = "gray"{}
        _Opacity    ("透明度", Range(0, 1)) = 0.5
        _Sequence   ("序列帧", 2D) = "gray"{}
        _ColCount   ("列数", int) = 1
        _RowCount   ("行数", int) = 1 
        _Speed      ("速度", range(-10, 10)) = 0
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
                o.uv0 = v.uv0; 
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_MainTex = tex2D(_MainTex, i.uv0);
                half opacity = var_MainTex.a * _Opacity;
                return half4(var_MainTex.rgb * opacity, opacity);
            }
            ENDCG
        }

        Pass {
            Name "FORWARD_AD"
            Tags{ 
                "LightMode" = "ForwardBase" 
            } 
            Blend One One //修好混合方式
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform half _Opacity;
            uniform sampler2D _Sequence; 
            uniform float4 _Sequence_ST; 
            uniform int _RowCount;
            uniform int _ColCount;
            uniform half _Speed;

        
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                // 顶点沿法线偏移
                v.vertex.xyz += v.normal * 0.03;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv0, _Sequence); 
                // 计算序列
                int index = floor(_Time.z * _Speed);         
                int indexU = index % _ColCount;         
                int indexV = index / _ColCount;
                float stepU = 1.0 / _ColCount;    
                float stepV = 1.0 / _RowCount;  
                // 锁定在第一帧
                o.uv0 = o.uv0 * float2(stepU, stepV) + float2(0.0, stepV * (_ColCount - 1.0)); 
                // 移动 
                o.uv0 += float2(indexU * stepU, - indexV * stepV);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                half4 var_Sequence = tex2D(_Sequence, i.uv0);      // 采样贴图 RGB颜色 A透贴
                half3 finalRGB = var_Sequence.rgb;
                half opacity = var_Sequence.a * _Opacity;
                return half4(finalRGB * opacity, opacity);        // 返回值
            }
            ENDCG
        }
    }
}
