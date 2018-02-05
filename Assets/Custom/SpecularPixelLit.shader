Shader "Custom/SpecularPixelLit"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
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
			#include "UnityLightingCommon.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
			};	
			
			v2f vert(a2v v)
			{				
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldPos =mul(_Object2World,v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)_World2Object);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
				float3 worldNormal = normalize(i.worldNormal);
				
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
				float3 reflectDir = reflect(-lightDir,worldNormal);
				
				fixed3 diffuse = _LightColor0.xyz*_Diffuse.xyz*saturate(dot(worldNormal,lightDir));
				
				fixed3 specular = _LightColor0.xyz*_Specular.xyz* pow( saturate(dot(reflectDir,viewDir)),_Gloss);
				
				return fixed4(ambient + diffuse+specular,1);
			}
			ENDCG
		}
	}
}