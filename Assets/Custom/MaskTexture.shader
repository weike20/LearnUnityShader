Shader "Custom/MaskTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Texture",2D) = "white"{}
		_NormalMap("Bump Texture",2D) = "white"{}
		_BumpScale("Bump Scale",Float) = 1
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
		_SpecularMask("Specular Mask",2D) = "white"{}
		_SpecularScale("Specular Scale",Float) = 1
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
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			sampler2D _SpecularMask;
			float _SpecularScale;
			
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
				float2 uv:TEXCOORD0;
				float3 tangentLightDir:TEXCOORD1;
				float3 tangentViewDir:TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.uv = _MainTex_ST.xy*v.texcoord + _MainTex_ST.zw;
				TANGENT_SPACE_ROTATION;
				o.tangentLightDir = mul(rotation,ObjSpaceLightDir(v.vertex));
				o.tangentViewDir = mul(rotation,ObjSpaceViewDir(v.vertex));
				
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
			
				fixed3 tangentLightDir = normalize(i.tangentLightDir);
				fixed3 tangentViewDir = normalize(i.tangentViewDir);
				
				fixed3 bump = UnpackNormal(tex2D(_NormalMap,i.uv)).xyz;
				bump.xy *= _BumpScale;
				bump.z = sqrt(1-dot(bump.xy,bump.xy));
				
				fixed3 albedo = tex2D(_MainTex,i.uv).xyz * _Color.xyz;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				
				fixed3 diffuse = saturate(dot(tangentLightDir,bump))*_LightColor0.xyz*albedo;
				
				fixed3 halfDir = normalize(tangentViewDir+tangentLightDir);
				
				fixed specularMask = tex2D(_SpecularMask,i.uv).r*_SpecularScale;
				
				fixed3 specular = pow(saturate(dot(halfDir,bump)),_Gloss)*_LightColor0.xyz*_Specular.xyz*specularMask;
				
				return fixed4(ambient+diffuse+specular,1);
				
			}
			
			ENDCG
		}
	}
}