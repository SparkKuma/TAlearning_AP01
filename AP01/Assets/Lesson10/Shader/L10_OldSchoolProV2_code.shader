Shader "AP01/L10/OldSchoolProV2_code" {
    Properties {
        [Header(Texture)]
            _MainTex    ("RGB基础颜色 A环境遮罩" , 2D )      = "white" {}
            _NormalTex  ("RGB法线贴图" , 2D )               = "bump"  {}
            _SpecTex    ("RGB高光贴图 A高光次幂",  2D )      = "grey"  {}
            _EmitTex     ("RGB自发光贴图", 2D  )            ="black"{}
            _Cubemap    ("RGB天空球", Cube)                = "_Skybox" {}
        [Header(Diffuse)]
            _BaseCol    ("基础色", Color)              = (0.5,0.5,0.5,1)
            _EnvDiffInt ("环境遮蔽强度", Range(0, 1))   = 0.2
            _EnvUpCol   ("环境上部颜色", Color)         = (0.5,0.5,0.5,1)
            _EnvSideCol ("环境侧面颜色", Color)         = (0.5,0.5,0.5,1)
            _EnvDownCol ("环境底部颜色", Color)         = (0.5,0.5,0.5,1)
        [Herder(Specular)]
            _SpecPow    ("高光次幂", Range(1, 90))      = 30
            _EnvSpecInt ("环境反射强度", Range(0, 5))   = 0.2
            _FresnelPow ("菲涅尔次幂", Range(0, 10))    = 1
            _CubemapMip ("天空球Mip", Range(0, 7))      = 0
        [Header(Emisson)]
            _EmissInt ("高光强度",Range(1,10))=1
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
            //Texture
            uniform sampler2D       _MainTex ;
            uniform sampler2D       _NormalTex ;
            uniform sampler2D       _SpecTex ;
            uniform sampler2D       _EmitTex ;
            uniform samplerCUBE     _Cubemap ;
            //Diffuse
            uniform half3 _BaseCol ;
            uniform half _EnvDiffInt ;
            uniform half3 _EnvUpCol ;
            uniform half3 _EnvSideCol ;
            uniform half3 _EnvDownCol ;
            //Specular
            uniform half _SpecPow;
            uniform half _EnvSpecInt;
            uniform half _FresnelPow;
            uniform half _CubemapMip;
            //Emisson
            uniform half _EmissInt;


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
                float3 nDirTS = UnpackNormal(tex2D(_NormalTex, i.uv0)).rgb;
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS, TBN));   
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);  
                float3 vrDirWS = reflect(-vDirWS, nDirWS); 
                float3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);
                float3 rDirWS = reflect( -lDirWS, nDirWS );

                //点乘结果
                float vdotn = dot(vDirWS, nDirWS);
                float ndotl = dot(nDirWS,lDirWS);
                float vdotr = dot(vDirWS,rDirWS);
        
                //采样纹理
                float4 var_MainTex = tex2D(_MainTex, i.uv0);
                float4 var_SpecTex = tex2D(_SpecTex, i.uv0);
                float3 var_EmitTex = tex2D(_EmitTex, i.uv0).rgb;
                float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, _CubemapMip)).rgb;

                //光照模型——直接光照
                float3 baseCol = var_MainTex * _BaseCol;
                float3 lambert = max(0,ndotl);

                float phong = pow(max(0,vdotr),_SpecPow);
                float specCol = var_SpecTex.rgb;
                float specPow = lerp(1, _SpecPow, var_SpecTex.a);

                float shadow = LIGHT_ATTENUATION(i);
                float3 dirLighting = (lambert * baseCol + specCol * phong) * _LightColor0 * shadow;

                //光照模型——环境光照影响
                float upMask = max(0.0, nDirWS.g);
                float downMask = max(0.0,-nDirWS.g);
                float sideMask = 1.0 - upMask- downMask;
                float occlusion = var_MainTex.a;
                float3 EnvCol = upMask*_EnvUpCol + 
                                sideMask*_EnvSideCol + 
                                downMask*_EnvDownCol;

                float fresnel = pow(max(0.0, 1.0 - vdotn), _FresnelPow);
                float3 envSpecLighting = var_Cubemap * fresnel * _EnvSpecInt;

                float3 EnvLighting = (baseCol* EnvCol*_EnvDiffInt + envSpecLighting*_EnvSpecInt *var_SpecTex.a)* occlusion ;
                
                //光照模型——自发光
                float emitInt = _EmissInt * (sin(frac(_Time.z))* 0.5 + 0.5);
                float3 emission = var_EmitTex * emitInt;

                //最终颜色

                float3 finalRGB = dirLighting + EnvLighting + emission;

                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}