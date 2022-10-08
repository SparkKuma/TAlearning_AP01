﻿Shader "AP01/L19/AnimGhost" {
    Properties {
        _MainTex            ("RGB：颜色 A：透贴",2d) = "gray" {} 
        _Opacity            ("透明度", range(0, 1)) = 0.5 
        _OpacityParams      ("透明度闪烁周期",range(0, 10)) = 1 
        _ScaleParams        ("天使圈缩放 X:强度 Y:速度 Z:校正", vector) = (0.2, 1.0, 4.5, 0.0)
        _SwingXParams       ("X轴扭动 X:强度 Y:速度 Z:波长", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingZParams       ("Z轴扭动 X:强度 Y:速度 Z:波长", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingYParams       ("Y轴起伏 X:强度 Y:速度 Z:滞后", vector) = (1.0, 3.0, 0.3, 0.0)
        _ShakeYParams       ("Y轴摇头 X:强度 Y:速度 Z:滞后", vector) = (20.0, 3.0, 0.3, 0.0)
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
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform half    _Opacity;
            uniform half _OpacityParams;
            uniform float4 _ScaleParams;
            uniform float3 _SwingXParams;
            uniform float3 _SwingZParams;
            uniform float3 _SwingYParams;
            uniform float3 _ShakeYParams;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv : TEXCOORD0;
                float4 color : COLOR;   // 顶点色  遮罩
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;   // 由模型顶点信息换算而来的顶点屏幕位置
                float2 uv : TEXCOORD0;
                float4 color: COLOR;
            };
            // 声明2Π
            #define TWO_PI 6.283185
            //顶点动画
            void AnimGhost(inout float3 vertex , inout float3 color) {
                //天使圈缩放
                float scale = _ScaleParams.x * color.g * sin(frac(_Time.z * _ScaleParams.y) * TWO_PI); // 缩放范围 受时间影响的正弦函数
                vertex *= 1.0 + scale;  // 1 + 缩放范围
                vertex.y -= _ScaleParams.z * scale; // 矫正Z轴
                //幽灵摆动yan
                float swingX = _SwingXParams *sin(frac(_Time.z * _SwingXParams.y + vertex.y *_SwingXParams.z)*TWO_PI); //X轴摆动 
                float swingZ = _SwingZParams *sin(frac(_Time.z * _SwingZParams.y + vertex.y *_SwingZParams.z)*TWO_PI); //Z轴摆动
                vertex.xz += float2(swingX,swingZ) * color.r; // 将波动带入顶点的X轴与Z轴
                //幽灵摇头
                float radY = radians(_ShakeYParams.x)* (1.0 - color.r)* sin(frac(_Time.z * _ShakeYParams.y - color.g * _ShakeYParams.z) * TWO_PI);// 计算出弧长
                float sinY, cosY = 0;
                sincos(radY,sinY,cosY);                         //求得sinY 和cosY
                vertex.xz = float2(                             //带入旋转矩阵 
                    vertex.x * cosY - vertex.z * sinY,
                    vertex.x * sinY + vertex.z * cosY
                );
                // 幽灵起伏
                float swingY = _SwingYParams.x * sin(frac(_Time.z * _SwingYParams.y - color.g * _SwingYParams.z) * TWO_PI); // 上下运动范围 受时间影响的正弦函数
                vertex.y += swingY; // 将波动带入顶点的Y轴
                //顶点色
                float lightness = 1.0 + color.g * 1.0 + scale * 2.0;
                color = float3(lightness, lightness, lightness);
            }
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;          
                    AnimGhost(v.vertex.xyz, v.color.rgb); 
                    o.pos = UnityObjectToClipPos( v.vertex );   
                    o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                    o.color = v.color;
                return o;                               
            }
            // 输出结构>>>像素
            half4 frag(VertexOutput i) : COLOR {
                half4 var_MainTex = tex2D(_MainTex, i.uv);      // 采样贴图 RGB颜色 A透贴
                half3 finalRGB = var_MainTex.rgb * i.color.rgb;
                half opacity = var_MainTex.a * _Opacity * +sin( frac(_Time.y*_OpacityParams) * 3.1415926);
                return half4(finalRGB * opacity, opacity);                // 返回值
            }
            ENDCG
        }
    }
}