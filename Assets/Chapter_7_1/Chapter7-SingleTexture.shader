Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
	Properties
	{
		_MainTex("Main Tex",2D) = "white"{}
		_Color("Color Tint",Color) = (1,1,1,1)
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
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
		 	float4 _Color;
		 	float4 _Specular;
		 	float _Gloss;
		 	sampler2D _MainTex;
		 	float4 _MainTex_ST;
		 	
		 	struct a2v
		 	{
		 		float4 vertex:POSITION;
		 		float4 normal:NORMAL;
		 		float4 texcoord:TEXCOORD0;
		 	};
		 	
		 	struct v2f
		 	{
		 		float4 pos:SV_POSITION;
		 		float3 worldNormal:TEXCOORD0;
		 		float3 worldPos:TEXCOORD1;
		 		float2 uv:TEXCOORD2;
		 	};
		 	
		 	v2f vert(a2v v)
		 	{
		 		v2f o;
		 		o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
		 		o.worldPos = mul(_Object2World,v.vertex).xyz;
		 		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		 		o.uv = v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
		 		//o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
		 		
		 		return o;
		 	}
		 	fixed4 frag(v2f i):SV_Target
		 	{
		 		float3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
		 	
		 		float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
		 		
		 		float3 worldNormal = normalize(i.worldNormal);
		 		float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		 		
		 		
		 		float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
		 		
		 		float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		 		float3 halfDir = normalize(viewDir+worldLightDir);
		 		float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,worldNormal)),_Gloss);
		 		
		 		return fixed4(ambient+specular+diffuse,1.0);
		 		
		 	}
			ENDCG
		}
	}
	
	FallBack "Specular"
}