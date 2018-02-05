Shader "Unity Shaders Book/Chapter 6/Specular Pixed-Level"
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
		 		
		 		float3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
		 		float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
		 		float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir,reflectDir)),_Gloss);
		 		
		 		return fixed4(ambient+specular+diffuse,1.0);
		 		
		 	}
			ENDCG
		}
	}
	
	FallBack "Specular"
}