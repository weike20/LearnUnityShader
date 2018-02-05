Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space"
{
	Properties
	{
		_MainTex("Main Tex",2D) = "white"{}
		_Color("Color Tint",Color) = (1,1,1,1)
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",float) = 1.0
		_Specular("Specular",Color) =  (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
	}
	
	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
		 	float4 _Color;
		 	float4 _Specular;
		 	float _Gloss;
		 	sampler2D _MainTex;
		 	float4 _MainTex_ST;
		 	sampler2D _BumpMap;
		 	float _BumpScale;
		 	float4 _BumpMap_ST;
		 	
		 	struct a2v
		 	{
		 		float4 vertex:POSITION;
		 		float3 normal:NORMAL;
		 		float4 tangent:TANGENT;
		 		float4 texcoord:TEXCOORD0;
		 	};
		 	
		 	struct v2f
		 	{
		 		float4 pos:SV_POSITION;
		 		float4 uv:TEXCOORD0;
		 		float3 lightDir:TEXCOORD1;
		 		float3 viewDir:TEXCOORD2;
		 	};
		 	
		 	v2f vert(a2v v)
		 	{
		 		v2f o;
		 		o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
		 		
		 		o.uv.xy = v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
		 		o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
		 		
		 		//float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
		 		//float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
		 		TANGENT_SPACE_ROTATION;
		 		
		 		o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
		 		o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
		 		
		 		return o;
		 	}
		 	fixed4 frag(v2f i):SV_Target
		 	{
		 		float3 tangentLightDir = normalize(i.lightDir);
		 		float3 tangentViewDir = normalize(i.viewDir);
		 		
		 		float4 packedNormal = tex2D(_BumpMap,i.uv.zw);
		 		float3 tangentNormal;
		 		
		 		//tangentNormal.xy = (packedNormal.xy*2-1)*_BumpScale;
		 		//tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
		 		
		 		tangentNormal = UnpackNormal(packedNormal);
		 		tangentNormal.xy *=_BumpScale;
		 		tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
		 		
		 		float3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
		 		float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
		 		float3 diffuse = _LightColor0.rgb *albedo*saturate(dot(tangentLightDir,tangentNormal));
		 		float3 halfDir = normalize(tangentLightDir+tangentViewDir);
		 		float3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,tangentNormal)),_Gloss);
		 		
		 		return fixed4(ambient+diffuse+specular,1.0);
		 	}
			ENDCG
		}
	}
	
	FallBack "Specular"
}