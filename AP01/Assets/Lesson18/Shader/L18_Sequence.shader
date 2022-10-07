Shader "AP01/L18/Sequence" {
    Properties {
        _Opacity    ("透明度", range(0, 1)) = 0.5
        _Sequence   ("序列帧", 2d) = "gray"{}
        _RowCount   ("行数", int) = 1
        _ColCount   ("列数", int) = 1
        _Speed      ("速度", range(0.0, 15.0)) = 1
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
            Blend One OneMinusSrcAlpha  // 修改混合方式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //输入参数
            uniform sampler2D _Sequence; uniform float4 _Sequence_ST;
            uniform half _Opacity;
            uniform half _RowCount;
            uniform half _ColCount;
            uniform half _Speed;

            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv : TEXCOORD0;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;   // 由模型顶点信息换算而来的顶点屏幕位置
                float2 uv : TEXCOORD0;
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           
                    o.pos = UnityObjectToClipPos( v.vertex );   
                    o.uv = TRANSFORM_TEX(v.uv,_Sequence);
                    float id = floor(_Time.z*_Speed);
                    float idV = floor(id/_ColCount);
                    float idU = id - idV * _ColCount;
                    float stepU = 1.0 / _ColCount;
                    float stepV = 1.0 / _RowCount;
                    float2 initUV = o.uv * float2(stepU,stepV) + float2(0.0,stepV*(_ColCount-1));
                    o.uv = initUV + float2(idU*stepU,-idV*stepV);
                return o;                               
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                half4 var_Sequence = tex2D(_Sequence,i.uv);
                half3 finalRGB = var_Sequence.rgb;
                half opacity = var_Sequence.a * _Opacity;
                return half4(finalRGB * opacity, opacity); 
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}