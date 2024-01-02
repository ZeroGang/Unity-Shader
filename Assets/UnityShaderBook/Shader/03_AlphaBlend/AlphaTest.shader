Shader "UnityShaderBook/AlphaTest"{
    Properties{
        _MainTex ("Main Tex", 2D) = "white" {}
        _CutOff ("Alpha CutOff",Range(0,1)) = 0.5
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
    }
    SubShader{
        Tags { "Queue"="Transparent" "IgnoreProjector" = "true" "RenderType"="Transparent" }
        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            
            struct a2v{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f{
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal :TEXCOORD2;
                float3 worldPos :TEXCOORD1;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _CutOff;
            fixed4  _Color;
            
            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(v.vertex, (float3x3)unity_ObjectToWorld);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                //正常计算颜色
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                // Alpha text (舍弃透明度小于 _CutOff 的片元)
                // = if ((texColor.a - _Cutoff) < 0.0) discard; 
                clip(texColor.a - _CutOff);
                // 计算物体表面颜色
                fixed3 albedo = _Color * texColor.rgb;
                // 计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 计算漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
                fixed4 color = fixed4(diffuse + ambient, 1.0f);  
                return color;
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}