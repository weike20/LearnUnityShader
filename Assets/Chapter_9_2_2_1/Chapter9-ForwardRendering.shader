Shader "Unity Shaders Book/Chapter 9/Forward Rendering"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) =  (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
	}
	
	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag


			#include "Lighting.cginc"
			
		 	float4 _Diffuse;
		 	float4 _Specular;
		 	float _Gloss;
		 	
		 	struct a2v
		 	{
		 		float4 vertex:POSITION;
		 		float4 normal:NORMAL;
		 	};
		 	
		 	struct v2f
		 	{
		 		float4 pos:SV_POSITION;
		 		float3 worldNormal:TEXCOORD0;
		 		float3 worldPos:TEXCOORD1;
		 	};
		 	
		 	v2f vert(a2v v)
		 	{
		 		v2f o;
		 		o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
		 		o.worldPos = mul(_Object2World,v.vertex).xyz;
		 		o.worldNormal = mul(v.normal,(float3x3)_World2Object);
		 		return o;
		 	}
		 	fixed4 frag(v2f i):SV_Target
		 	{
		 		float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		 		
		 		float3 worldNormal = normalize(i.worldNormal);
		 		
		 		float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
	
		 		float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
		 		
		 		float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
		 		float3 halfDir = normalize(viewDir+worldLightDir);
		 		float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,worldNormal)),_Gloss);

		 		float atten = 1;
		
		 		return fixed4(ambient+(specular+diffuse)*atten,1.0);
		 		
		 	}
			ENDCG
		}
		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
		 	float4 _Diffuse;
		 	float4 _Specular;
		 	float _Gloss;
		 	
		 	struct a2v
		 	{
		 		float4 vertex:POSITION;
		 		float4 normal:NORMAL;
		 	};
		 	
		 	struct v2f
		 	{
		 		float4 pos:SV_POSITION;
		 		float3 worldNormal:TEXCOORD0;
		 		float3 worldPos:TEXCOORD1;
		 	};
		 	
		 	v2f vert(a2v v)
		 	{
		 		v2f o;
		 		o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
		 		o.worldPos = mul(_Object2World,v.vertex).xyz;
		 		o.worldNormal = mul(v.normal,(float3x3)_World2Object);
		 		return o;
		 	}
		 	fixed4 frag(v2f i):SV_Target
		 	{	 		
		 		float3 worldNormal = normalize(i.worldNormal);
		 		
		 		#ifdef USING_DIRECTIONAL_LIGHT
		 		float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
		 		#else
		 		float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
		 		#endif
		 		
		 		float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
		 		
		 		float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
		 		float3 halfDir = normalize(viewDir+worldLightDir);
		 		float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,worldNormal)),_Gloss);
		 		
		 		#ifdef USING_DIRECTIONAL_LIGHT
		 		float atten = 1;
		 		#else
		 		float3 lightCoord = mul(_LightMatrix0,float4(i.worldPos,1)).xyz;
		 		float atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
		 		#endif
		 		return fixed4((specular+diffuse)*atten,1.0);
		 		
		 	}
			ENDCG
		}
	}
	
	FallBack "Specular"
}