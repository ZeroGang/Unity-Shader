// 简单的 Unity ShaderLab 的模板
Shader "UnityShaderBook/Template" {
    Properties {
        // 属性 暴露在unity面板可调参数
        // 声明一个 Color 类型的属性
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader {
        // 针对显卡A的SubShader
        Pass {
            // 设置渲染标签
            // tag {"key" = "value"}

            // 开始 CG 代码片段
            CGPROGRAM
            
            // 在此处指定顶点着色器和片元着色器的入口点
            #pragma vertex vert
            #pragma fragment frag

            // 在 CG 代码中，需要定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;

 

            // a2v：定义顶点着色器的输入
            struct a2v {
                // POSITION 语义：用模型空间的顶点坐标填充 vertex 变量
                float4 vertex : POSITION;
                // NORMAL 语义：用模型空间的发现方向填充 normal 变量
                float3 normal : NORMAL;
                // TEXCOORD0 语义：用模型的第一套纹理坐标填充 texcoord 变量
                float4 texcoord : TEXCOORD0;
            };

            // v2f：定义顶点着色器的输出
            struct v2f {
                // SV_POSITION 语义：pos包含顶点在裁剪空间中的位置信息
                float4 pos : SV_POSITION;
                // COLOR0 语义：color用于存储颜色信息在第0通道
                fixed3 color : COLOR0;
            };

            // 顶点着色器函数，将输入a2v转换为输出v2f
            v2f vert(a2v v) {
                // 声明输出结构
                v2f o;
                // 使用UnityObjectToClipPos函数将顶点位置转换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                // 计算新的颜色，基于法线方向，将法线范围[-1.0, 1.0]映射到[0.0, 1.0]
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }


            // 片元着色器函数，将输入v2f转换为输出y颜色
            // SV_Target 语义：将输出颜色缓存到一个渲染目标中
            fixed4 frag(v2f i) : SV_Target {
                // 将插值后的i.color显示到屏幕上
                fixed3 c = i .color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }
            ENDCG

            // 可以继续写其他的pass
            // pass{}
        }
    }
    
    SubShader {
        // 针对显卡 B 的 SubShader
        Pass{
        }
    }

    // 上诉 SubShader 都失败后用于回调Unity Shader
    Fallback "VertexLit"
}
