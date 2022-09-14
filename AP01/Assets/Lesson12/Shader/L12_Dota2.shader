Shader "AP01/L12/Dota2" {
    Properties {
        [Header(Texture)]
        [NoScaleOffset]_D  ("RGB:基础颜色 A:透明通道",2D)                                   = "white"{}
        [NoScaleOffset]_M  ("RGB:金属度",2D)                                                   = "black"{}
        [NoScaleOffset][Normal]_N  ("RGB:法线贴图",2D)                                     = "bump"{}
        [NoScaleOffset]_S  ("R:高光遮罩 G:边缘遮罩 B:色调遮罩 A:高光次幂",2D)                = "grey"{}
        [NoScaleOffset]_CubeMap ("RGB:天空球",cube)                                        ="_Skybox"{}

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
            uniform sampler2D           _D;
            uniform sampler2D           _M;
            uniform sampler2D           _N;
            uniform sampler2D           _S;
            uniform samplerCUBE         _CubeMap;

            //Diffuse

            //Specular

            //Emisson



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


                //点乘结果

        
                //采样纹理
                float3 var_D = tex2D(_D,i.uv0);

                //光照模型——直接光照



                //光照模型——环境光照影响

                //光照模型——自发光


                //最终颜色

                

                return float4(var_D, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}