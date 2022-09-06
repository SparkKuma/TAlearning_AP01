// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:0,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:915,x:32732,y:32725,varname:node_915,prsc:2|emission-5835-OUT;n:type:ShaderForge.SFN_Tex2d,id:8948,x:31229,y:32802,ptovrint:False,ptlb:NormalMap,ptin:_NormalMap,varname:node_8948,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:4ef303839d6d05249b5144a6e1ecbdcd,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Transform,id:2056,x:31410,y:32802,varname:node_2056,prsc:2,tffrom:2,tfto:0|IN-8948-RGB;n:type:ShaderForge.SFN_Fresnel,id:35,x:31730,y:32957,varname:node_35,prsc:2|NRM-2056-XYZ,EXP-7843-OUT;n:type:ShaderForge.SFN_Slider,id:7843,x:31369,y:33066,ptovrint:False,ptlb:FresnelPow,ptin:_FresnelPow,varname:node_7843,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Multiply,id:7460,x:32328,y:32832,varname:node_7460,prsc:2|A-4039-OUT,B-35-OUT;n:type:ShaderForge.SFN_ViewVector,id:9597,x:31278,y:32380,varname:node_9597,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6323,x:31437,y:32436,varname:node_6323,prsc:2|A-9597-OUT,B-9829-OUT;n:type:ShaderForge.SFN_Vector1,id:9829,x:31278,y:32521,varname:node_9829,prsc:2,v1:-1;n:type:ShaderForge.SFN_Reflect,id:5361,x:31619,y:32515,varname:node_5361,prsc:2|A-6323-OUT,B-2056-XYZ;n:type:ShaderForge.SFN_Cubemap,id:241,x:31933,y:32595,ptovrint:False,ptlb:Cubemap,ptin:_Cubemap,varname:node_241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,pvfc:0|DIR-5361-OUT,MIP-1881-OUT;n:type:ShaderForge.SFN_Slider,id:1881,x:31602,y:32722,ptovrint:False,ptlb:CubemapMip,ptin:_CubemapMip,varname:node_1881,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:7;n:type:ShaderForge.SFN_Multiply,id:4039,x:32159,y:32746,varname:node_4039,prsc:2|A-241-RGB,B-35-OUT;n:type:ShaderForge.SFN_Multiply,id:5835,x:32521,y:32832,varname:node_5835,prsc:2|A-7460-OUT,B-5551-OUT;n:type:ShaderForge.SFN_Slider,id:5551,x:32044,y:33099,ptovrint:False,ptlb:EnvSpecint,ptin:_EnvSpecint,varname:node_5551,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.2,max:5;proporder:8948-7843-241-1881-5551;pass:END;sub:END;*/

Shader "AP01/L09/Cubemap_SF" {
    Properties {
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _FresnelPow ("FresnelPow", Range(0, 10)) = 0
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
        _CubemapMip ("CubemapMip", Range(0, 7)) = 0
        _EnvSpecint ("EnvSpecint", Range(0, 5)) = 0.2
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
            uniform samplerCUBE _Cubemap;
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float, _FresnelPow)
                UNITY_DEFINE_INSTANCED_PROP( float, _CubemapMip)
                UNITY_DEFINE_INSTANCED_PROP( float, _EnvSpecint)
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
                float _CubemapMip_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CubemapMip );
                float _FresnelPow_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FresnelPow );
                float node_35 = pow(1.0-max(0,dot(node_2056.rgb, viewDirection)),_FresnelPow_var);
                float _EnvSpecint_var = UNITY_ACCESS_INSTANCED_PROP( Props, _EnvSpecint );
                float3 emissive = (((texCUBElod(_Cubemap,float4(reflect((viewDirection*(-1.0)),node_2056.rgb),_CubemapMip_var)).rgb*node_35)*node_35)*_EnvSpecint_var);
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
