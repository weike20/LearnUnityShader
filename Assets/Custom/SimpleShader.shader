Shader "Custom/SimpleShader"
{
	Properties
	{
		_Color("Color",Color) =(1,1,1,1)
		_RimColor("Rim Color",Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			fixed4 _Color;
			fixed4 _RimColor;
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
				o.worldPos = mul(_Object2World,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
				float rim = saturate(1- dot(viewDir,i.worldNormal));
				fixed4 rimColor = rim*_RimColor;
				return lerp(_Color,rimColor,rim);
			}
			ENDCG
		}
	}
}