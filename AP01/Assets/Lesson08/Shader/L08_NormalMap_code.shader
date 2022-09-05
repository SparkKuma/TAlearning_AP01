Shader "AP01/L08/Normal_code" {
    Properties {
        _normalMap ("normalMap", 2D) = "bump" {}
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
            uniform sampler2D _normalMap;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;   
                float4 normal : NORMAL;  
                float4 tangent : TANGENT;   
                float2 uv0 : TEXCOORD0;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;   // 由模型顶点信息换算而来的顶点屏幕位置
                float3 nDirWS : TEXCOORD0;  // 由模型法线信息换算来的世界空间法线信息
                float3 tDirWS : TEXCOORD1;
                float3 bDirWS : TEXCOORD2;
                float2 uv0    : TEXCOORD3;
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;               // 新建一个输出结构
                o.pos = UnityObjectToClipPos( v.vertex );       // 变换顶点信息 并将其塞给输出结构
                o.uv0 = v.uv0;
                o.nDirWS = UnityObjectToWorldNormal(v.normal);  // 变换法线信息 并将其塞给输出结构
                o.tDirWS = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                return o;                                       // 将输出结构 输出
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                float3 var_NormalMap = UnpackNormal( tex2D(_normalMap,i.uv0));
                float3x3 TBN = float3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                float3 nDirWS = normalize(mul(var_NormalMap,TBN));            
                float3 lDir = _WorldSpaceLightPos0.xyz;         // 获取lDir
                float nDotl = dot(nDirWS, lDir);              // nDir点积lDir
                float lambert = max(0.0, nDotl);                // 截断负值
                return float4(lambert, lambert, lambert, 1.0);  // 输出最终颜色
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}