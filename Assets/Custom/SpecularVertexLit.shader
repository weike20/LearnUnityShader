Shader "Custom/SpecularVertexLit"
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
				fixed3 color:COLOR;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldLightDir =  normalize(_WorldSpaceLightPos0.xyz);
				float3 worldView = normalize(WorldSpaceViewDir(v.vertex));
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _LightColor0.xyz*_Diffuse.xyz*saturate(dot(worldNormal,worldLightDir));
				
				float3 relectDir = normalize(reflect(-worldLightDir,worldNormal));
				fixed3 specular =  _LightColor0.xyz*_Specular.xyz*pow(saturate(dot(worldView,relectDir)),_Gloss);
				
				o.color = ambient +diffuse+specular;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				return fixed4(i.color,1);
			}
			
			
			ENDCG
		}
	}
}