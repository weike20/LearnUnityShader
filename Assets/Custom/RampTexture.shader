Shader "Custom/RampTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Texture",2D) = "white"{}
		_RampTex("Ramp Texture",2D) = "white"{}
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
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float4 worldPos:TEXCOORD1;
				float3 worldNormal:TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldPos = mul(_Object2World,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).xyz*_Color.xyz;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				
				fixed halfLambert = dot(i.worldNormal,worldLightDir)*0.5f+0.5f;
				fixed3 diffuse = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).xyz * albedo;
				
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldViewDir+worldLightDir);
				fixed3 specular = _LightColor0.xyz*_Specular.xyz*pow(saturate(dot(halfDir,worldNormal)),_Gloss);
				
				return fixed4(ambient+diffuse+specular,1);		
				
			}
			
			ENDCG
		}
	}
}