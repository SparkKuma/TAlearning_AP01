Shader "AP01/L17/ScreenWarp2" {
    Properties {
        _MainTex    ("RGB：颜色 A：透贴",2d) = "gray" {} 
        _Opacity    ("不透明度",range(0,1)) = 0.5
        _WarpMidVal ("扰动中间值",range(0,1)) = 0.5 
        _WarpInt    ("扰动强度",range(0,5)) = 1 

    }
    SubShader {
        Tags {
            "Quue" = "Transparent"
            "RenderType" = "Transparent"
            "ForceNoShadowCasting" = "True"
            "IgnoreProjector" = "Ture"
        }
        GrabPass{
            "_BGTex"
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
            uniform half _WarpMidVal;
            uniform half _WarpInt;
            uniform sampler2D _BGTex;  // 拿到背景纹理
            // 输入结构
            struct appdata {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv : TEXCOORD0;
            };
            // 输出结构
            struct v2f {
                float4 pos : SV_POSITION;   // 顶点位置
                float2 uv : TEXCOORD0;     // UV信息
                float4 grabPos : TEXCOORD1;   //背景纹理采样坐标
            };
            // 输入结构>>>顶点Shader>>>输出结构
            v2f vert (appdata v) {
                v2f o = (v2f)0;           
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;                               
            }
            // 输出结构>>>像素
            float4 frag(v2f i) : COLOR {
                // 采样 基本纹理 RGB颜色 A透明
                half4 var_MainTex = tex2D(_MainTex,i.uv);
                // 扰动背景采样UV
                i.grabPos.xy += (var_MainTex.b - _WarpMidVal) * _WarpInt * _Opacity;
                // 采样背景
                half3 var_BGTex = tex2Dproj(_BGTex,i.grabPos).rgb;
                // FinalRGB 不透明度
                half3 finalRGB = lerp(1.0,var_MainTex.rgb,_Opacity)* var_BGTex;
                half opacity = var_MainTex.a;
                return half4(finalRGB *opacity ,opacity);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}