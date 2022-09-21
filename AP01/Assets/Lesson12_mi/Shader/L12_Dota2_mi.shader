Shader "AP01/L12/Dota2_mi" {
    Properties {
        [Header(Texture)]
            [NoScaleOffset]_D  ("RGB:基础颜色 A:透明通道",2D)                                  = "white"{}
            [NoScaleOffset]_M  ("RGB:金属度 A:自发光",2D)                                      = "white"{}
            [NoScaleOffset][Normal]_N  ("RGB:法线贴图",2D)                                     = "bump"{}
            [NoScaleOffset]_S  ("R:高光遮罩 G:边缘遮罩 B:色调遮罩 A:高光次幂",2D)              = "black"{}
            _FresnelWarp ("菲涅尔Ramp",2D)                                                     = "gray" {}
            _DiffuseWarp ("颜色Ramp",2D)                                                       = "gray" {}
            _Cubemap        ("环境球", cube) = "_Skybox"{}

        [Header(Emisson)]
            _EmissInt   ("自发光强度",Range(1.0,10.0))    = 1.0
        [Header(DirDiff)]
        _LightCol       ("光颜色", color) = (1.0, 1.0, 1.0, 1.0)
        [Header(DirSpec)]
        _SpecPow        ("高光次幂", range(0.0, 99.0)) = 5
        _SpecInt        ("高光强度", range(0.0, 10.0)) = 5
        [Header(EnvDiff)]
        _EnvCol         ("环境光颜色", color) = (1.0, 1.0, 1.0, 1.0)
        [Header(EnvSpec)]
        _EnvSpecInt     ("环境镜面反射强度", range(0.0, 30.0)) = 0.5
        [Header(RimLight)]
        [HDR]_RimCol    ("轮廓光颜色", color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector]
        _Cutoff         ("Alpha cutoff", Range(0,1)) = 0.5
        [HideInInspector]
        _Color          ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)

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
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //Texture
            uniform sampler2D _D;
            uniform sampler2D _M;
            uniform sampler2D _N;
            uniform sampler2D _S;
            uniform sampler2D _FresnelWarp; 
            uniform sampler2D _DiffuseWarp; 
            uniform samplerCUBE _Cubemap;
            // DirDiff
            uniform half3 _LightCol;
            // DirSpec
            uniform half _SpecPow;
            uniform half _SpecInt;
            // EnvDiff
            uniform half3 _EnvCol;
            // EnvSpec
            uniform half _EnvSpecInt;
            // RimLight
            uniform half3 _RimCol;
            //Emisson
            uniform half _EmissInt;
            // Other
            uniform half _Cutoff;

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
                LIGHTING_COORDS (5,6)
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
                    TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;                                   // 将输出结构 输出
            }
            // 输出结构>>>像素    
            float4 frag(VertexOutput i) : COLOR {


                // 准备向量
                half3 nDirTS = UnpackNormal(tex2D(_N, i.uv0));
                half3x3 TBN = half3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                half3 nDirWS = normalize(mul(nDirTS,TBN));
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 vrDirWS = reflect(-vDirWS, nDirWS);
                half3 lDirWS = _WorldSpaceLightPos0.xyz;
                half3 rDirWS = reflect(-lDirWS,nDirWS);
                half shadow = LIGHT_ATTENUATION(i);
                //采样纹理
                half4 var_D = tex2D(_D,i.uv0);
                half4 var_M = tex2D(_M,i.uv0);
                half4 var_N = tex2D(_N,i.uv0);
                half4 var_S = tex2D(_S,i.uv0);
                
                //提取通道
                half3 baseCol = var_D.rgb;
                half opacity = var_D.a;
                half matellic = var_M.r;
                half emissMask = var_M.a;
                half SpecExp = var_S.a;
                half SpecularMask = var_S.r;
                half Rimlight = var_S.g;
                half TintMask = var_S.b;
                //采样天空球
                half3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, lerp(8.0, 0.0, SpecExp))).rgb;
                half3 envCube = var_Cubemap;
                //中间量
                half vdotn = dot(vDirWS,nDirWS);
                half ndotl = dot(nDirWS,lDirWS);
                half vdotr = dot(vDirWS,rDirWS);
                half ndotv = dot(nDirWS,vDirWS);
                half phong = pow(max(0.0, vdotr), SpecExp * _SpecPow);
                half HalfLambert = max(0.0,ndotl)*0.5+0.5;
                //采样Ramp
                half3 var_FresnelWarp = tex2D(_FresnelWarp,ndotv).rgb;
                half3 var_DiffWarp = tex2D(_DiffuseWarp, half2(HalfLambert, 0.2));
                //菲涅尔
                half3 fresnel = lerp(var_FresnelWarp, 0.0, matellic);
                half fresnelCol = fresnel.r;
                half fresnelRim = fresnel.g;
                half fresnelSpec = fresnel.b;
                //光照模型
                    //漫反射颜色 镜面反射颜色
                    half3 diffCol = lerp(baseCol,half3(0.0,0.0,0.0),matellic);
                    half3 specCol = lerp(baseCol,half3(0.3,0.3,0.3),TintMask)*SpecularMask;
                    //光源漫反射
                    half3 dirDiff = diffCol * var_DiffWarp * _LightCol;
                    //光源镜面反射
                    half spec = phong * max(0.0,ndotl);
                         spec = max(spec,fresnelSpec);
                         spec = spec * _SpecInt;
                    half3 dirSpec = specCol * spec * _LightCol;
                    //环境漫反射
                    half3 envDiff = diffCol * _EnvCol;
                    //环境镜面反射
                    half reflectInt = max(fresnelSpec,matellic) * SpecularMask;
                    half3 envSpec = specCol * reflectInt  * envCube* _EnvSpecInt;
                    // 轮廓光
                    half3 rimLight = _RimCol * fresnelRim * Rimlight * max(0.0, nDirWS.g);
                    // 自发光
                    half3 emission = diffCol * emissMask * _EmissInt;
                    // 混合
                    half3 finalRGB = (dirDiff + dirSpec) * shadow + envDiff + envSpec + rimLight + emission;
                //透明通道
                clip(opacity - _Cutoff);
                // 返回值
                return float4(finalRGB,1.0);
            }
            ENDCG
        }
    }
    FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}