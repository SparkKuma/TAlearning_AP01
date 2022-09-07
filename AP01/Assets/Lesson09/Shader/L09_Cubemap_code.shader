Shader "AP01/L09/Cubemap" {
    Properties {
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _FresnelPow ("FresnelPow", Range(0, 10)) = 0
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
        _CubemapMip ("CubemapMip", Range(0, 7)) = 0
        _EnvSpecint ("EnvSpecint", Range(0, 5)) = 0.2
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
            uniform sampler2D _NormalMap;
            uniform sampler2D _MatcapTex;
            uniform float     _FresnelPow;
            uniform float     _EnvSpecInt;
            // 输入结构
            struct VertexInput {
                float4 vertex   : POSITION; 
                float2 uv0      : TEXCOORD0;
                float3 normal   : NORMAL;
                float4 tangent  : TANGENT;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos      : SV_POSITION;   
                float2 uv0      : TEXCOORD0;
                float4 posWS    : TEXCOORD1;
                float3 nDirWS   : TEXCOORD2;
                float3 tDirWS   : TEXCOORD3;
                float3 bDirWS   : TEXCOORD4;
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;          
                o.pos = UnityObjectToClipPos( v.vertex );
                o.uv0 = v.uv0;
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.tDirWS = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                return o;                                   
            }
            // 输出结构>>>像素    
            float4 frag(VertexOutput i) : COLOR {
                float3 nDirTS = UnpackNormal(tex2D(_NormalMap ,i.uv0)).rgb; //采样解码切线空间下的法线方向
                float3x3 TBN  = float3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS,TBN));
                float3 nDirVS = mul(UNITY_MATRIX_V,nDirWS);
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);

                float vdotn = dot(vDirWS,nDirWS);
                float2 matcapUV = nDirVS *  0.5  + 0.5;

                float3 matcap = tex2D(_MatcapTex,matcapUV);
                float fresnel = pow(max(0.0, 1.0 - vdotn),_FresnelPow);
                float3 emvSpecLighting = matcap * fresnel * _EnvSpecInt;

                return float4(emvSpecLighting, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}