// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:0,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3263,x:33149,y:32830,varname:node_3263,prsc:2|emission-3230-OUT;n:type:ShaderForge.SFN_NormalVector,id:2237,x:31155,y:32715,prsc:2,pt:False;n:type:ShaderForge.SFN_ComponentMask,id:6108,x:31313,y:32715,varname:node_6108,prsc:2,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-2237-OUT;n:type:ShaderForge.SFN_Color,id:7095,x:32045,y:32418,ptovrint:False,ptlb:EnvUpCol,ptin:_EnvUpCol,varname:node_7095,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Max,id:4693,x:31614,y:32714,varname:node_4693,prsc:2|A-6108-OUT,B-3104-OUT;n:type:ShaderForge.SFN_Vector1,id:3104,x:31532,y:32892,varname:node_3104,prsc:2,v1:0;n:type:ShaderForge.SFN_Max,id:555,x:31762,y:33124,varname:node_555,prsc:2|A-3104-OUT,B-5474-OUT;n:type:ShaderForge.SFN_Negate,id:5474,x:31549,y:33144,varname:node_5474,prsc:2|IN-6108-OUT;n:type:ShaderForge.SFN_Vector1,id:9395,x:31817,y:32824,varname:node_9395,prsc:2,v1:1;n:type:ShaderForge.SFN_Add,id:4242,x:31817,y:32893,varname:node_4242,prsc:2|A-4693-OUT,B-555-OUT;n:type:ShaderForge.SFN_Subtract,id:8321,x:32043,y:32875,varname:node_8321,prsc:2|A-9395-OUT,B-4242-OUT;n:type:ShaderForge.SFN_Color,id:1889,x:32043,y:32717,ptovrint:False,ptlb:EnvSideCol,ptin:_EnvSideCol,varname:node_1889,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Color,id:8418,x:32053,y:33247,ptovrint:False,ptlb:EnvDownCol,ptin:_EnvDownCol,varname:node_8418,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:5714,x:32278,y:32565,varname:node_5714,prsc:2|A-7095-RGB,B-4693-OUT;n:type:ShaderForge.SFN_Multiply,id:7666,x:32273,y:32824,varname:node_7666,prsc:2|A-1889-RGB,B-8321-OUT;n:type:ShaderForge.SFN_Multiply,id:7001,x:32253,y:33125,varname:node_7001,prsc:2|A-555-OUT,B-8418-RGB;n:type:ShaderForge.SFN_Add,id:9684,x:32433,y:32695,varname:node_9684,prsc:2|A-5714-OUT,B-7666-OUT;n:type:ShaderForge.SFN_Add,id:5066,x:32586,y:32932,varname:node_5066,prsc:2|A-9684-OUT,B-7001-OUT;n:type:ShaderForge.SFN_Tex2d,id:6609,x:32665,y:32726,ptovrint:False,ptlb:AO,ptin:_AO,varname:node_6609,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:35f8576879031a640b231517d6277b84,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3230,x:32863,y:32846,varname:node_3230,prsc:2|A-6609-R,B-5066-OUT;proporder:7095-1889-8418-6609;pass:END;sub:END;*/

Shader "AP01/L07/3ColAmbient_SF" {
    Properties {
        _EnvUpCol ("EnvUpCol", Color) = (0.5,0.5,0.5,1)
        _EnvSideCol ("EnvSideCol", Color) = (0.5,0.5,0.5,1)
        _EnvDownCol ("EnvDownCol", Color) = (0.5,0.5,0.5,1)
        _AO ("AO", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma target 3.0
            uniform sampler2D _AO; uniform float4 _AO_ST;
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float4, _EnvUpCol)
                UNITY_DEFINE_INSTANCED_PROP( float4, _EnvSideCol)
                UNITY_DEFINE_INSTANCED_PROP( float4, _EnvDownCol)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _AO_var = tex2D(_AO,TRANSFORM_TEX(i.uv0, _AO));
                float4 _EnvUpCol_var = UNITY_ACCESS_INSTANCED_PROP( Props, _EnvUpCol );
                float node_6108 = i.normalDir.g;
                float node_3104 = 0.0;
                float node_4693 = max(node_6108,node_3104);
                float4 _EnvSideCol_var = UNITY_ACCESS_INSTANCED_PROP( Props, _EnvSideCol );
                float node_555 = max(node_3104,(-1*node_6108));
                float4 _EnvDownCol_var = UNITY_ACCESS_INSTANCED_PROP( Props, _EnvDownCol );
                float3 emissive = (_AO_var.r*(((_EnvUpCol_var.rgb*node_4693)+(_EnvSideCol_var.rgb*(1.0-(node_4693+node_555))))+(node_555*_EnvDownCol_var.rgb)));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
