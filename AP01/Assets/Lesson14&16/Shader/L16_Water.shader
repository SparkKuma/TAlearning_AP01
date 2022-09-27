Shader "AP01/L16/Water" {
    Properties {
        _MainTex        ("颜色贴图", 2d) = "white"{}
        _WarpTex        ("扰动图", 2d) = "gray"{}
        _Speed          ("X:流速x Y:流速y", vector) = (1.0,1.0,1.0,1.0)
        _Warp1Params    ("X:大小 Y:流速x Z:流速y W:强度", vector) = (1.0,1.0,1.0,1.0)
        _Warp2Params    ("X:大小 Y:流速x Z:流速y W:强度", vector) = (1.0,1.0,1.0,1.0)
    }
    SubShader {
        Tags {
            "Queue"="Transparent"               // 调整渲染顺序
            "RenderType"="Transparent"          // 对应改为Cutout
            "ForceNoShadowCasting"="True"       // 关闭阴影投射
            "IgnoreProjector"="True"            // 不响应投射器
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha     // 修改混合方式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            // 输入参数
            uniform sampler2D _MainTex;   uniform float4 _MainTex_ST;
            uniform sampler2D _WarpTex;   
            uniform half2 _Speed;
            uniform half4 _Warp1Params;
            uniform half4 _Warp2Params;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;       // 顶点位置 总是必要
                float2 uv0 : TEXCOORD0;        
                float2 uv1 : TEXCOORD1;         
                float2 uv2 : TEXCOORD2;
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                    o.pos = UnityObjectToClipPos( v.vertex);        // 顶点位置 OS>CS
                    o.uv0 = v.uv - frac(-_Time.x * _Speed);
                    o.uv1 = v.uv * _Warp1Params.x - frac(-_Time.x * _Warp1Params.yz);
                    o.uv2 = v.uv * _Warp2Params.x - frac(-_Time.x * _WarpParams.yz);
                return o;
            }
            // 输出结构>>>像素
            half4 frag(VertexOutput i) : COLOR {
                half3 var_Warp1 = tex2D(_WarpTex,i.uv1).rgb;
                half3 var_Warp2 = tex2D(_WarpTex,i.uv2).rgb;
                half2 warp = (var_Warp1.xy - 0.5) * _Warp1Params.w +
                             (var_Warp2.xy - 0.5) * _Warp2Params.w ;
                            
                float2 warpUV = i.uv0 + warp;
                half4 var_Maintex = tex2D(_MainTex,warpUV);


                return half4(var_Maintex.xyz, 1.0);                    // 返回值
            }
            ENDCG
        }
    }
}