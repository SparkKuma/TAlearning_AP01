Shader "AP01/L09/OldSchoolPro_code" {
    Properties {
        _Cubemap    ("天空球", Cube) = "_Skybox" {}
        _NormalMap  ("法线贴图", 2D) = "bump" {}
        _FresnelPow ("菲涅尔次幂", Range(0, 10)) = 1
        _CubemapMip ("天空球Mip", Range(0, 7)) = 0
        _EnvSpecInt ("环境反射强度", Range(0, 5)) = 0.2
        _BaseCol ("基础色", Color) = (0.6792453,0.3651461,0.08650766,1)
        _LightCol ("光源颜色", Color) = (0.5,0.5,0.5,1)
        _SpecPow ("高光次幂", Range(1, 90)) = 30
        _EnvInt ("环境遮蔽强度", Range(0, 1)) = 0.1
        _EnvUpCol   ("环境上部颜色", Color) = (0.5,0.5,0.5,1)
        _EnvSideCol ("环境侧面颜色", Color) = (0.5,0.5,0.5,1)
        _EnvDownCol ("环境底部颜色", Color) = (0.5,0.5,0.5,1)
        _AO         ("AO图", 2D) = "white" {}
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
            uniform samplerCUBE _Cubemap;
            uniform sampler2D _NormalMap;
            uniform float _CubemapMip;
            uniform float _FresnelPow;
            uniform float _EnvSpecInt;
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
                float4 vertex   : POSITION;     // 顶点信息
                float2 uv0      : TEXCOORD0;    // uv信息
                float3 normal   : NORMAL;       // 法线信息
                float4 tangent  : TANGENT;      // 切线信息
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;       // 屏幕顶点位置
                float2 uv0 : TEXCOORD0;         // uv信息
                float4 posWS : TEXCOORD1;       // 世界顶点位置
                float3 nDirWS : TEXCOORD2;      // 世界法线方向
                float3 tDirWS : TEXCOORD3;      // 世界切线方向
                float3 bDirWS : TEXCOORD4;      // 世界副切线方向
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           // 新建一个输出结构
                    o.pos = UnityObjectToClipPos( v.vertex );
                    o.uv0 = v.uv0;                                  // 传递uv信息
                    o.posWS = mul(unity_ObjectToWorld, v.vertex);   // 顶点位置 OS>WS
                    o.nDirWS = UnityObjectToWorldNormal(v.normal);  // 法线方向 OS>WS
                    o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
                    o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);  // 根据nDir tDir求bDir
                return o;                                   // 将输出结构 输出
            }
            // 输出结构>>>像素    
            float4 frag(VertexOutput i) : COLOR {
                // 准备向量
                float3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);

                float3 nDirTS = UnpackNormal(tex2D(_NormalMap, i.uv0)).rgb;
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS, TBN));   // 计算Fresnel 计算vrDirWS
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);  // 计算Fresnel
                float3 vrDirWS = reflect(-vDirWS, nDirWS);// 采样Cubemap
                float3 rDir = reflect( -lDirWS, nDirWS );
                float shadow = LIGHT_ATTENUATION(i);

                float vdotn = dot(vDirWS, nDirWS);

                float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, _CubemapMip)).rgb;
                float fresnel = pow(max(0.0, 1.0 - vdotn), _FresnelPow);
                float3 envSpecLighting = var_Cubemap * fresnel * _EnvSpecInt;

                return float4(envSpecLighting, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}