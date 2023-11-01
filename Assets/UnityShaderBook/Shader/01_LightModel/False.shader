// Debug Shader 代码
Shader "UnityShaderBook/False" {
    Properties {
        
    }
    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            
            // 按照debug 需要打开或者关闭注释
            v2f vert(appdata_full v) {
                // 声明输出结构
                v2f o;
                // o.pos = UnityObjectToClipPos(v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // 可视化法线方向
                o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化切线方向
                o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化副切线方向
                fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视第一组纹理坐标
                o.color = fixed4(v.texcoord.xy , 0.0, 1.0);

                // 可视第二组纹理坐标
                o.color = fixed4(v.texcoord1.xy , 0.0, 1.0);

                // 可视第一组纹理坐标，小数部分
                o.color = fixed4(v.texcoord.xy , 0.0, 1.0);
                if(any(saturate(v.texcoord) - v.texcoord)){
                    o.color.b = 0.5;
                }
                o.color.a = 1.0;

                // 可视第二组纹理坐标，小数部分
                o.color = fixed4(v.texcoord1.xy , 0.0, 1.0);
                if(any(saturate(v.texcoord1) - v.texcoord1)){
                    o.color.b = 0.5;
                }
                o.color.a = 1.0;

                // 可视顶点颜色
                // o.color = v.color;

                return o;
            }


            fixed4 frag(v2f i) : SV_Target {
                return i.color;
            }
            ENDCG
        }
    }
}
