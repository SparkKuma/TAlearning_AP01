Shader "AP01/L17/ScreenUV" {
    Properties {
        _MainTex    ("RGB：颜色 A：透贴",2d) = "gray" {} 
        _Opacity    ("透明度",Range(0,1)) = 0.5
        _ScreenTex  ("屏幕纹理",2d) = "black"{}

    }
    SubShader {
        Tags {
            "Quue" = "Transparent"
            "RenderType" = "Transparent"
            "ForceNoShadowCasting" = "True"
            "IgnoreProjector" = "Ture"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One OneMinusSrcAlpha  // 修改混合方式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //输入参数
            uniform sampler2D _MainTex; 
            uniform half _Opacity;
            uniform sampler2D _ScreenTex; uniform float4 _ScreenTex_ST;
            // 输入结构
            struct appdata {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv : TEXCOORD0;
            };
            // 输出结构
            struct v2f {
                float4 pos : SV_POSITION;   // 顶点位置
                float2 uv : TEXCOORD0;     // UV信息
                float2 screenUV : TEXCOORD1;// 屏幕UV
            };
            // 输入结构>>>顶点Shader>>>输出结构
            v2f vert (appdata v) {
                v2f o = (v2f)0;           
                    o.pos = UnityObjectToClipPos( v.vertex );   // 顶点位置信息 OS>CS
                    o.uv = v.uv;                               //UV信息
                    float3 posVS = UnityObjectToViewPos(v.vertex).xyz; // 顶点位置 OS>VS
                    float originDist = UnityObjectToViewPos(float3(0.0,0.0,0.0)).z;
                    o.screenUV = posVS.xy / posVS.z;        //空间畸变矫正
                    o.screenUV *= originDist;
                    o.screenUV = o.screenUV * _ScreenTex_ST.xy - frac(_Time.x * _ScreenTex_ST.zw);

                return o;                               
            }
            // 输出结构>>>像素
            float4 frag(v2f i) : COLOR {
                half4 var_MainTex = tex2D(_MainTex,i.uv);
                half var_ScreenTex = tex2D(_ScreenTex,i.screenUV).r;
                half3 finalRGB = var_MainTex.rgb;
                half opacity = var_MainTex.a * _Opacity * var_ScreenTex;
                return half4(finalRGB *opacity ,opacity);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}