Shader "AP01/L05/L02_Code" {
    Properties {
        _RampTex ("RampTex", 2D) = "white" {}
        _FresnelCol ("FresnelCol", Color) = (1,1,1,1)
        _HightlightCol ("HightlightCol", Color) = (0.9079778,0.9333333,0.7812,1)
        _HighlightOffset1 ("HighlightOffset1", Vector) = (0,0,0,0)
        _HighlightOffset2 ("HighlightOffset2", Vector) = (0,0,0,0)
        _HightlightRange1 ("HightlightRange1", Range(0.6, 1)) = 0.8
        _HightlightRange2 ("HightlightRange2", Range(0.6, 1)) = 0.8
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
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            uniform sampler2D _RampTex;
            uniform float4 _RampTex_ST;
            uniform float4 _FresnelCol;
            uniform float4 _HightlightCol;
            uniform float4 _HighlightOffset1;
            uniform float4 _HighlightOffset2;
            uniform float _HightlightRange1;
            uniform float _HightlightRange2;

            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;  
                float4 normal : NORMAL;     
            };
            // 输出结构
            struct VertexOutput {
                float4 posCS : SV_POSITION;  
                float4 posWS : TEXCOORD0;
                float3 nDirWS : TEXCOORD1; 
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;              
                    o.posCS = UnityObjectToClipPos( v.vertex );   
                    o.posWS = mul(unity_ObjectToWorld, v.vertex);
                    o.nDirWS = UnityObjectToWorldNormal(v.normal); 
                return o;                                       
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                float3 nDir = i.nDirWS;                         
                float3 lDir = _WorldSpaceLightPos0.xyz;  
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 hDir = normalize(vDir + lDir );

                float nDotl = dot(nDir, lDir);            
                float nDoth= dot(nDir,hDir);
                
                float2 hBlinnPhong = hDir * 0.5 + 0.5;
                float4 RampTex = tex2D(_RampTex,TRANSFORM_TEX(hBlinnPhong, _RampTex));  // 用半blinnPhong采样颜色图

                float highlight1A = step(dot(normalize(( _HighlightOffset1.rgb+nDir)),hDir),_HightlightRange1);
                float highlight1B = step(_HightlightRange1,dot(normalize((_HighlightOffset1.rgb + nDir)), hDir));
                float highlight2A = step(dot(normalize((_HighlightOffset2.rgb+nDir)),hDir),_HightlightRange2);
                float highlight2B = step(_HightlightRange2,dot(normalize((_HighlightOffset2.rgb + nDir)), hDir));

                float lambert = max(0.0, nDotl);
                float3 finalRGB = saturate((1.0-(1.0-lerp(RampTex.rgb,_HightlightCol.rgb,saturate(max(lerp((highlight1A * 0)+(highlight1B * 1),0,highlight1A * highlight1B),lerp((highlight2A*0)+(highlight2A*1),0,highlight2A*highlight2B)))))*(1.0-(pow(1.0-max(0,dot(nDir, vDir)),3.0)*_FresnelCol.rgb))));
                return float4(finalRGB, 1.0); 
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}