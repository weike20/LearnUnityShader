Shader "Custom/NormalMalpInWorldSpace"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Texture",2D) = "white"{}
		_NormalMap("Normal Map",2D) = "white"{}
		_BumpScale("Bump Scale",Float) = 1
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
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;		
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
				o.uv.xy = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
				
				float4 worldPos = mul(_Object2World , v.vertex);
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
				float3 worldLightDir = normalize( UnityWorldSpaceLightDir(worldPos));
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_NormalMap,i.uv.zw)).xyz;
				bump.xy*=_BumpScale;
				bump.z = sqrt(1-dot(bump.xy,bump.xy));
				
				bump = normalize(half3(dot(i.TToW1.xyz,bump)
													,dot(i.TToW2.xyz,bump)
													,dot(i.TToW3.xyz,bump)));
				
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).xyz*_Color.xyz;
				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = albedo * _LightColor0.xyz*saturate(dot(bump,worldLightDir));
				
				
				float3 halfDir = normalize(worldLightDir+worldViewDir);
				fixed3 specular = _Specular.xyz*pow(saturate(dot(bump,halfDir)),_Gloss);
				
				return fixed4(ambient+diffuse+specular,1);
				
			}
			
			ENDCG
		}
	}
}