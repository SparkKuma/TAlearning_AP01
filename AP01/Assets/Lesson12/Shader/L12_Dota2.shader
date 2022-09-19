Shader "AP01/L12/Dota2" {
    Properties {
        [Header(Texture)]
            [NoScaleOffset]_D  ("RGB:基础颜色 A:透明通道",2D)                                   = "white"{}
            [NoScaleOffset]_M  ("RGB:金属度 A:自发光",2D)                                      = "black"{}
            [NoScaleOffset][Normal]_N  ("RGB:法线贴图",2D)                                     = "bump"{}
            [NoScaleOffset]_S  ("R:高光遮罩 G:边缘遮罩 B:色调遮罩 A:高光次幂",2D)                = "grey"{}
            [NoScaleOffset]_Cubemap    ("RGB:环境贴图", cube)                                  = "_Skybox" {}
            _FresnelWarp ("菲涅尔Ramp",2D)                                   = "white" {}
            _DiffuseWarp ("颜色Ramp",2D) = "white" {}
            _Cutoff("透切阈值",range(0.0,1.0)) = 0.5
        [Herder(Specular)]
            _SpecPow    ("高光次幂", Range(1, 90))      = 20
            _EnvSpecInt ("环境反射强度", Range(0, 5))   = 0.2
            _FresnelPow ("菲涅尔次幂", Range(0, 10))    = 2
            _CubemapMip ("天空球Mip", Range(0, 7))      = 3
        [Header(Emisson)]
            _EmissInt   ("自发光强度",Range(1.0,10.0))    = 1.0

    }
    SubShader {
        Tags {
            "RenderType" = "TransparentCutout"
            "ForceNoShadowCasting" = "True"
            "IgnoreProjector" = "Ture"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //Texture
            uniform sampler2D           _D;
            uniform sampler2D           _M;
            uniform sampler2D           _N;
            uniform sampler2D           _S;
            uniform samplerCUBE         _CubeMap;
            uniform sampler2D           _FresnelWarp; uniform float4 _FresnelWarp_ST;
            uniform sampler2D           _DiffuseWarp; uniform float4 _DiffuseWarp_ST;
            //Transparent
            uniform half                _Cutoff;
            //Specular
            uniform half                _SpecPow;
            uniform half                _EnvSpecInt;
            uniform half                _FresnelPow;
            uniform half                _CubemapMip;
            //Emisson
            uniform half                _EmissInt;


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
                //采样纹理
                half4 var_D = tex2D(_D,i.uv0);
                half4 var_M = tex2D(_M,i.uv0);
                half4 var_N = tex2D(_N,i.uv0);
                half4 var_S = tex2D(_S,i.uv0);
                
                //提取通道
                half MetalMask = var_M.r;
                half emissMask = var_M.a;
                half SpecExp = var_S.a;
                half SpecularMask = var_S.r;
                half Rimlight = var_S.g;
                half TintMask = var_S.b;

                // 准备向量
                half3 nDirTS = UnpackNormal(var_N).rgb;
                float3x3 TBN = float3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS,TBN));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 vrDirWS = reflect(-vDirWS,nDirWS);
                float3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);
                float3 rDirWS = reflect(-lDirWS,nDirWS);
                float shadow = LIGHT_ATTENUATION(i);
                //采样天空球
                half3 var_Cubemap = texCUBElod(_CubeMap,float4(vrDirWS,_CubemapMip)).rgb;
                //点乘结果
                half vdotn = dot(vDirWS,nDirWS);
                half ndotl = dot(nDirWS,lDirWS);
                half vdotr = dot(vDirWS,rDirWS);
                half specPow = lerp(1, _SpecPow, SpecExp);
                half phong = pow(max(0.0, vdotr), specPow);
                half HalfLambert = max(0.0,ndotl)*0.5+0.5;
                //采样Ramp
                half2 RampUV = half2(phong,0.5);
                half4 var_FresnelWarp = tex2D(_FresnelWarp,TRANSFORM_TEX(RampUV, _FresnelWarp));
                half4 var_DiffuseWarp = tex2D(_DiffuseWarp,TRANSFORM_TEX(RampUV, _FresnelWarp));
                //我也不知道warp那几张图怎么用先踩出来再说
                half fresnelWarpColor = var_FresnelWarp.r;
                half fresnelWarpRim = var_FresnelWarp.g;
                half fresnelWarpSpec = var_FresnelWarp.b;
                //光照模型——直接光照 baseCol* (1.0-TintMask)
                half3 baseCol = var_D.rgb;
                //预留half specCol =lerp( baseCol* (1.0-TintMask),1,SpecularMask);
                half specCol = SpecularMask + lerp( baseCol* (1.0-TintMask),1,SpecularMask);
                half3 dirLighting = (baseCol * HalfLambert+ fresnelWarpColor*var_DiffuseWarp  +  specCol * phong  ) * _LightColor0 * shadow ;//直射光的影响比较好理解 


                //光照模型——环境光照影响
                half fresnel = pow(max(0.0,1.0-vdotn),_FresnelPow);
                half3 Rim = Rimlight * fresnel * fresnelWarpRim;// 就是楞乘菲涅尔 达到背光的效果  就是肉眼看的 感觉不够精妙
                half3 EnvLighting = (baseCol * MetalMask  + var_Cubemap * fresnel * _EnvSpecInt *SpecExp*MetalMask)*SpecExp; //颜色乘金属度Mask是为了得到会产生环境反射的位置 

                //光照模型——自发光
                half3 emission = baseCol * emissMask * _EmissInt;


                //透明通道
                clip(var_D.a - _Cutoff);
                //最终颜色
                half3 finalRGB =  dirLighting + EnvLighting + emission + Rim+ pow(fresnel,2.0)*nDirWS.g;// +Rim 是为了背光  + 手动二次方再成个0.5 的菲涅尔  这个是因为背光不够 理论我应该加上面 但是我急了

                return half4(finalRGB,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}