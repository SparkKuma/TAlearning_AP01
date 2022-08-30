// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32717,y:32695,varname:node_3138,prsc:2|emission-2044-RGB,olwid-7067-OUT,olcol-9241-RGB;n:type:ShaderForge.SFN_NormalVector,id:6061,x:31860,y:32554,cmnt:NDir,prsc:2,pt:False;n:type:ShaderForge.SFN_Dot,id:7240,x:32022,y:32673,cmnt:NDir dot LDir,varname:node_7240,prsc:2,dt:0|A-6061-OUT,B-1653-OUT;n:type:ShaderForge.SFN_LightVector,id:1653,x:31860,y:32723,cmnt:LDir,varname:node_1653,prsc:2;n:type:ShaderForge.SFN_Multiply,id:1252,x:32298,y:32557,cmnt:x 0.5,varname:node_1252,prsc:2|A-7240-OUT,B-1320-OUT;n:type:ShaderForge.SFN_Add,id:4230,x:32459,y:32558,cmnt: 0.5,varname:node_4230,prsc:2|A-1252-OUT,B-1320-OUT;n:type:ShaderForge.SFN_Tex2d,id:2044,x:32475,y:32857,ptovrint:False,ptlb:RampTex,ptin:_RampTex,cmnt:采样,varname:node_2044,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-4787-OUT;n:type:ShaderForge.SFN_Vector1,id:1320,x:32298,y:32693,varname:node_1320,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Vector1,id:9235,x:32297,y:32993,varname:node_9235,prsc:2,v1:0.3;n:type:ShaderForge.SFN_Append,id:4787,x:32297,y:32857,cmnt:构建UV坐标,varname:node_4787,prsc:2|A-4230-OUT,B-9235-OUT;n:type:ShaderForge.SFN_Color,id:9241,x:32477,y:33230,ptovrint:False,ptlb:OutlineCol,ptin:_OutlineCol,cmnt:描边颜色,varname:node_9241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Slider,id:7067,x:32320,y:33109,ptovrint:False,ptlb:OutlineWidth,ptin:_OutlineWidth,cmnt:描边宽度,varname:node_7067,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.015,max:0.05;proporder:2044-9241-7067;pass:END;sub:END;*/

Shader "AP01/L02/Cell_SF" {
    Properties {
        _RampTex ("RampTex", 2D) = "white" {}
        _OutlineCol ("OutlineCol", Color) = (0,0,0,1)
        _OutlineWidth ("OutlineWidth", Range(0, 0.05)) = 0.015
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Tags {
            }
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma target 3.0
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float4, _OutlineCol)
                UNITY_DEFINE_INSTANCED_PROP( float, _OutlineWidth)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                float _OutlineWidth_var = UNITY_ACCESS_INSTANCED_PROP( Props, _OutlineWidth ); // 描边宽度
                o.pos = UnityObjectToClipPos( float4(v.vertex.xyz + v.normal*_OutlineWidth_var,1) );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float4 _OutlineCol_var = UNITY_ACCESS_INSTANCED_PROP( Props, _OutlineCol ); // 描边颜色
                return fixed4(_OutlineCol_var.rgb,0);
            }
            ENDCG
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
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            uniform sampler2D _RampTex; uniform float4 _RampTex_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                LIGHTING_COORDS(2,3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
////// Lighting:
////// Emissive:
                float node_1320 = 0.5;
                float2 node_4787 = float2(((dot(i.normalDir,lightDirection)*node_1320)+node_1320),0.3); // 构建UV坐标
                float4 _RampTex_var = tex2D(_RampTex,TRANSFORM_TEX(node_4787, _RampTex)); // 采样
                float3 emissive = _RampTex_var.rgb;
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma target 3.0
            uniform sampler2D _RampTex; uniform float4 _RampTex_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                LIGHTING_COORDS(2,3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
////// Lighting:
                float3 finalColor = 0;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
