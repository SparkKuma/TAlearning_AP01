Shader "AP01/L16/Fire" {
    Properties {
        _Mask           ("R:外焰 G:内焰 B:透贴",2d) = "blue" {} 
        _Noise          ("R:噪波1 G:噪波2",2d) = "gray"{}
        _Noise1Params   ( "噪波1 X:大小Y:流速Z:强度",vector) = (1.0,0.2,0.2,1.0) 
        _Noise2Params   ( "噪波2 X:大小Y:流速Z:强度",vector) = (1.0,0.2,0.2,1.0) 
        [HDR]_Color1    ("外焰颜色",color) = (1,1,1,1)
        [HDR]_Color2    ("内焰颜色",color) = (1,1,1,1)
    }
    SubShader {
        Tags {
            "Queue" = "Transparent"
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
            uniform sampler2D _Mask;     uniform float4 _Mask_ST;   
            uniform sampler2D _Noise;
            uniform half3 _Noise1Params;
            uniform half3 _Noise2Params;
            uniform half3 _Color1;
            uniform half3 _Color2;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv : TEXCOORD0;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;   // 由模型顶点信息换算而来的顶点屏幕位置
                float2 uv0 : TEXCOORD0;     //UV 采样Mask
                float2 uv1 : TEXCOORD1;     //UV 采样Noise1
                float2 uv2 : TEXCOORD2;     //UV 采样Noise2
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           
                    o.pos = UnityObjectToClipPos( v.vertex );   
                    o.uv0 = v.uv;
                    o.uv1 = v.uv * _Noise1Params.x - float2(0.0,frac(_Time.x *_Noise1Params.y));
                    o.uv2 = v.uv * _Noise2Params.x - float2(0.0,frac(_Time.x *_Noise2Params.y));
                return o;                               
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                half warpMask = tex2D (_Mask,i.uv0).b;

                half var_Noise1 = tex2D(_Noise,i.uv1).r;
                half var_Noise2 = tex2D(_Noise,i.uv2).g;
                half noise = var_Noise1* _Noise1Params.z + var_Noise2*_Noise2Params.z;

                float2 warpUV = i.uv0 - float2(0.0,noise) * warpMask;

                half3 var_Mask = tex2D(_Mask, warpUV);

                half3 finalRGB = _Color1 * var_Mask.r +_Color2 * var_Mask.g ;
                half opacity = var_Mask.r + var_Mask.g ;
            
                return half4(finalRGB,opacity) ;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}