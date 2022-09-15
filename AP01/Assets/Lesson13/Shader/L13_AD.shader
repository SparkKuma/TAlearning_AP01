Shader "AP01/L13/AD" {
    Properties {
        _MainTex("RGB：颜色 A：透贴",2d) = "gray" {} 
    }
    SubShader {
        Tags {
            "Quue" = "Transparent"
            "RenderType" = "Transparent"
            "ForceNoShadowCasting" = "True"
            "IgnoreProjector" = "Ture"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One  // 修改混合方式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //输入参数
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform half _Cutoff;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv0 : TEXCOORD0;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;   // 由模型顶点信息换算而来的顶点屏幕位置
                float2 uv0 : TEXCOORD0;
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           
                    o.pos = UnityObjectToClipPos( v.vertex );   
                    o.uv0 = TRANSFORM_TEX(v.uv0,_MainTex);
                return o;                               
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                half3 var_MainTex = tex2D(_MainTex,i.uv0).rgb; 
                return half4(var_MainTex,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}