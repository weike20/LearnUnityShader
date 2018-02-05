Shader "Custom/FalseColor"
{
	Properties
	{
	
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed4 color:COLOR;	
			};
			
			
			v2f vert(appdata_full v)
			{
				v2f o;
				
				
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				//o.color = fixed4(v.normal*0.5+fixed3(0.5,0.5,0.5),1);
				
				o.color = fixed4(v.tangent*0.5f+fixed4(0.5,0.5,0.5,0.5));
				
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				return i.color;
			}
			ENDCG
		}
	}
}