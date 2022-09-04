Shader "AP01/L07/OldSchoolPlus" {
    Properties { 
        _BaseCol ("BaseCol", Color) = (0.6792453,0.3651461,0.08650766,1)
        _LightCol ("LightCol", Color) = (0.5,0.5,0.5,1)
        _SpecPow ("SpecPow", Range(1, 90)) = 30
        _EnvInt ("EnvInt", Range(0, 1)) = 0.1
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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //输入参数
            uniform float3  _BaseCol;
            uniform float3  _LightCol;
            uniform float   _SpecPow;
            uniform float   _EnvInt;
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
                float4 posWS : TEXCOORD2;
                LIGHTING_COORDS (3,4)
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           
                o.pos = UnityObjectToClipPos( v.vertex );   
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv0;
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;                                   
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                float3 nDir = i.nDirWS;
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 rDir = reflect( -lDir, nDir );
                float shadow = LIGHT_ATTENUATION(i);
                //基础光照
                float ndotl = dot(nDir,lDir);
                float vdotr = dot(vDir,rDir);
                float phong = pow(max(0,vdotr),_SpecPow);
                float upMask = max(0.0, nDir.g);
                float downMask = max(0.0,-nDir.g);
                float sideMask = 1.0 - upMask- downMask;
                float occlusion = tex2D(_AO,i.uv);
                //颜色
                float3 EnvCol = upMask*_EnvUpCol + sideMask*_EnvSideCol + downMask*_EnvDownCol;
                float3 lambertCol = max(0,ndotl)*_BaseCol;
                float3 PhongLambertShadow = (lambertCol + phong) * _LightCol * shadow;
                float3 EnvLighting = EnvCol* _EnvInt * occlusion ;
                float3 finalCol = PhongLambertShadow + EnvLighting;
                return float4 (finalCol, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}