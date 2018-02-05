﻿Shader "Custom/SimpleTex"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_Specular ("Specular",Color) = (1,1,1,1)
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
			
			fixed4 _Specular;
			float _Gloss;
			
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				
				return o;
			}
			
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 albedo = tex2D(_MainTex,i.uv)*_Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz *albedo;
				
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 halfDir = normalize((worldLightDir + worldViewDir)/2);
				
				fixed3 diffuse = albedo*_LightColor0.xyz*saturate(dot(i.worldNormal,worldLightDir));
				
				fixed3 specular = _LightColor0.xyz*_Specular.xyz*pow(saturate(dot(halfDir,i.worldNormal)),_Gloss);
				
				return fixed4(ambient+diffuse+specular,1);
			}
			
			ENDCG
		}
	}
}