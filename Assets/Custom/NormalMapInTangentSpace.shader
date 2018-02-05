Shader "Custom/NormalMapInTangentSpace"
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
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 tangentLightDir:TEXCOORD1;
				float3 tangentViewDir:TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				
				TANGENT_SPACE_ROTATION;
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy  +  _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				
				o.tangentLightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.tangentViewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}
			
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 normal =  UnpackNormal(tex2D(_NormalMap,i.uv.zw));
				normal.xy*=_BumpScale;
				normal.z = sqrt(1-(saturate(dot(normal.xy,normal.xy))));
				
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).xyz*_Color.xyz;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				float3 tangentLightDir = normalize(i.tangentLightDir);
				float3 tangentViewDir = normalize(i.tangentViewDir);
				
				float3 halfDir = normalize(tangentLightDir+tangentViewDir);
				
				fixed3 diffuse = albedo*_LightColor0.xyz*saturate(dot(normal,tangentLightDir));
				
				fixed3 specular = _Specular.xyz*_LightColor0.xyz*pow(saturate(dot(halfDir,normal)),_Gloss);
				
				return fixed4(ambient+diffuse+specular,1);
				
			}
			
			ENDCG
		}
	}
}