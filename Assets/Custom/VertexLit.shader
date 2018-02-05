Shader "Custom/VertexLit"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	
	
	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			fixed4 _Diffuse;
			
			
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
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 diffuse = _LightColor0.xyz*saturate(dot(worldNormal,_WorldSpaceLightPos0.xyz)); 
				o.color = fixed3(ambient+diffuse);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				return  fixed4(i.color,1);
			}
			
			ENDCG
			
		}
	}
}