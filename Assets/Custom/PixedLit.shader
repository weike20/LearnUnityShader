Shader "Custom/PixedLit"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
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
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag(v2f i):SV_Target
			{
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//fixed3 diffuse =  _Diffuse.xyz*_LightColor0.xyz * saturate(dot(i.worldNormal,lightDir));
				//half lambert
				fixed halfLambert = dot(i.worldNormal,lightDir)*0.5+0.5;
				fixed3 diffuse = _Diffuse.xyz*_LightColor0.xyz*halfLambert;
				
				return fixed4(ambient+diffuse,1);
			}
			
			ENDCG
		}
	}
}