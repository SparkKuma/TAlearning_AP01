// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:0,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:915,x:32719,y:32712,varname:node_915,prsc:2|emission-7460-OUT;n:type:ShaderForge.SFN_Tex2d,id:8948,x:31364,y:32810,ptovrint:False,ptlb:NormalMap,ptin:_NormalMap,varname:node_8948,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:4ef303839d6d05249b5144a6e1ecbdcd,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Transform,id:2056,x:31555,y:32810,varname:node_2056,prsc:2,tffrom:2,tfto:0|IN-8948-RGB;n:type:ShaderForge.SFN_ComponentMask,id:4446,x:31768,y:32810,varname:node_4446,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-2056-XYZ;n:type:ShaderForge.SFN_Multiply,id:941,x:31980,y:32810,varname:node_941,prsc:2|A-4446-OUT,B-6338-OUT;n:type:ShaderForge.SFN_Vector1,id:6338,x:31768,y:32975,varname:node_6338,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Add,id:1973,x:32154,y:32810,varname:node_1973,prsc:2|A-941-OUT,B-6338-OUT;n:type:ShaderForge.SFN_Tex2d,id:1863,x:32320,y:32810,ptovrint:False,ptlb:MatcapTex,ptin:_MatcapTex,varname:node_1863,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:5fcf8cd9d741c67439d9afe952d45e7b,ntxv:1,isnm:False|UVIN-1973-OUT;n:type:ShaderForge.SFN_Fresnel,id:35,x:31768,y:33073,varname:node_35,prsc:2|NRM-2056-XYZ,EXP-7843-OUT;n:type:ShaderForge.SFN_Slider,id:7843,x:31383,y:33141,ptovrint:False,ptlb:FresnelPow,ptin:_FresnelPow,varname:node_7843,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:7460,x:32517,y:32876,varname:node_7460,prsc:2|A-1863-RGB,B-35-OUT;proporder:8948-1863-7843;pass:END;sub:END;*/

Shader "AP01/L09/Matcap_SF" {
    Properties {
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _MatcapTex ("MatcapTex", 2D) = "gray" {}
        _FresnelPow ("FresnelPow", Range(0, 1)) = 0
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
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform sampler2D _MatcapTex; uniform float4 _MatcapTex_ST;
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float, _FresnelPow)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float3 _NormalMap_var = UnpackNormal(tex2D(_NormalMap,TRANSFORM_TEX(i.uv0, _NormalMap)));
                float3 node_2056 = mul( _NormalMap_var.rgb, tangentTransform ).xyz;
                float node_6338 = 0.5;
                float2 node_1973 = ((node_2056.rgb.rg*node_6338)+node_6338);
                float4 _MatcapTex_var = tex2D(_MatcapTex,TRANSFORM_TEX(node_1973, _MatcapTex));
                float _FresnelPow_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FresnelPow );
                float3 emissive = (_MatcapTex_var.rgb*pow(1.0-max(0,dot(node_2056.rgb, viewDirection)),_FresnelPow_var));
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
