Shader "Unity Shaders Book/Chapter 7/Normal Map In World Space"
{
	Properties
	{
		_MainTex("Main Tex",2D) = "white"{}
		_Color("Color Tint",Color) = (1,1,1,1)
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",float) = 1.0
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
		 	sampler2D _BumpMap;
		 	float _BumpScale;
		 	float4 _BumpMap_ST;
		 	
		 	struct a2v
		 	{
		 		float4 vertex:POSITION;
		 		float3 normal:NORMAL;
		 		float4 tangent:TANGENT;
		 		float4 texcoord:TEXCOORD0;
		 	};
		 	
		 	struct v2f
		 	{
		 		float4 pos:SV_POSITION;
		 		float4 uv:TEXCOORD0;
		 		float4 TToW1:TEXCOORD1;
		 		float4 TToW2:TEXCOORD2;
		 		float4 TToW3:TEXCOORD3;
		 	};
		 	
		 	v2f vert(a2v v)
		 	{
		 		v2f o;
		 		o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
		 		
		 		o.uv.xy = v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
		 		o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
		 		
				float3 worldPos = mul(_Object2World,v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;
				
				o.TToW1 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TToW2 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TToW3 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
		 		
		 		return o;
		 	}
		 	fixed4 frag(v2f i):SV_Target
		 	{
		 	
		 	
				float3 worldPos = float3(i.TToW1.w,i.TToW2.w,i.TToW3.w);
				
		 		float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
		 		float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		 		
		 		float4 packedNormal = tex2D(_BumpMap,i.uv.zw);
		 		float3 worldNormal;
		 		
		 		//tangentNormal.xy = (packedNormal.xy*2-1)*_BumpScale;
		 		//tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
		 		
		 		worldNormal = UnpackNormal(packedNormal);
		 		worldNormal.xy *=_BumpScale;
		 		worldNormal.z = sqrt(1-saturate(dot(worldNormal.xy,worldNormal.xy)));
		 		worldNormal = normalize(float3(dot(i.TToW1.xyz,worldNormal),dot(i.TToW2,worldNormal),dot(i.TToW3,worldNormal)));
		 		
		 		float3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
		 		float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
		 		float3 diffuse = _LightColor0.rgb *albedo*saturate(dot(lightDir,worldNormal));
		 		float3 halfDir = normalize(lightDir+viewDir);
		 		float3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,worldNormal)),_Gloss);
		 		
		 		return fixed4(ambient+diffuse+specular,1.0);
		 	}
			ENDCG
		}
	}
	
	FallBack "Specular"
}