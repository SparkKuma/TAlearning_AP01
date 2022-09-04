Shader "AP01/L07/3ColAmbient" {
    Properties {
        _EnvUpCol   ("EnvUpCol", Color) = (0.5,0.5,0.5,1)
        _EnvSideCol ("EnvSideCol", Color) = (0.5,0.5,0.5,1)
        _EnvDownCol ("EnvDownCol", Color) = (0.5,0.5,0.5,1)
        _AO         ("AO", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //输入参数
            uniform float3  _EnvUpCol;
            uniform float3  _EnvSideCol;
            uniform float3  _EnvDownCol;
            uniform sampler2D  _AO;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;   
                float4 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;   
                float3 nDirWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           
                o.pos = UnityObjectToClipPos( v.vertex );   
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv0;
                return o;                                   
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                float3 nDir = i.nDirWS;
                
                float upMask = max(0.0, nDir.g);
                float downMask = max(0.0,-nDir.g);
                float sideMask = 1.0 - upMask- downMask;

                float3 EnvCol = upMask*_EnvUpCol + sideMask*_EnvSideCol + downMask*_EnvDownCol;
                float occlusion = tex2D(_AO,i.uv);
                float3 finalColor = EnvCol *occlusion ;

                return float4 (finalColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}