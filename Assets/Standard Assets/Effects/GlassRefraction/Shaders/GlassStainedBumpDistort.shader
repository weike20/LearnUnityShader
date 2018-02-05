// Per pixel bumped refraction.
// Uses a normal map to distort the image behind, and
// an additional texture to tint the color.

Shader "FX/Glass/Stained BumpDistort" {
Properties {
	_BumpAmt  ("Distortion", range (0,128)) = 10
	_MainTex ("Tint Color (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
}

Category {

	// We must be transparent, so other objects are drawn before this one.
	Tags { "Queue"="Transparent" "RenderType"="Opaque" }


	SubShader {

		// This pass grabs the screen behind the object into a texture.
		// We can access the result in the next pass as _GrabTexture
		GrabPass {
			Name "BASE"
			Tags { "LightMode" = "Always" }
		}
		
		// Main pass: Take the texture grabbed above and use the bumpmap to perturb it
		// on to the screen
		Pass {
			Name "BASE"
			Tags { "LightMode" = "Always" }
			
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog
#include "UnityCG.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	float2 texcoord: TEXCOORD0;
};

struct v2f {
	float4 vertex : SV_POSITION;
	float4 uvgrab : TEXCOORD0;
	float2 uvbump : TEXCOORD1;
	float2 uvmain : TEXCOORD2;
	//声明这个变量的原因是如果是移动平台或者SM2.0的时候雾效需要在定点着色器里面计算
	//如果知道目标平台是电脑或者SM3.0就可以不需要此命令,直接在片段着色器当中使用UNITY_APPLY_FOG宏
	//UnityCG.cginc可以找到相关定义，Unity这么做是为了更好的跨平台
	UNITY_FOG_COORDS(3)
};

float _BumpAmt;
float4 _BumpMap_ST;
float4 _MainTex_ST;

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	//#if UNITY_UV_STARTS_AT_TOP
	//float scale = -1.0;
	//#else
	//float scale = 1.0;
	//#endif
	//o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
	//o.uvgrab.zw = o.vertex.zw;
	// UNITY_UV_STARTS_AT_TOP 判断是否是DirectX的屏幕坐标系
	// 因为DirectX的原点在左上角，而OpenGL的原点在左下角
	//上述代码和ComputeGrabScreenPos相同，单单光看上述代码或许很难理解
	//如果结合片段着色函数里面的其次除法，就可以理解
	// 上述代码先把x、y坐标变换到[0,w]范围之下
	//进行其次除法，经过除法过后x、y范围[0,1]
	//再根据渲染比例和物理比例，最终将图像渲染到屏幕上
	
	o.uvgrab = ComputeGrabScreenPos(v.vertex);
	o.uvbump = TRANSFORM_TEX( v.texcoord, _BumpMap );
	o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
	//移动平台或SM2.0
	UNITY_TRANSFER_FOG(o,o.vertex);
	return o;
}

sampler2D _GrabTexture;
float4 _GrabTexture_TexelSize;
sampler2D _BumpMap;
sampler2D _MainTex;

half4 frag (v2f i) : SV_Target
{
	// calculate perturbed coordinates
	half2 bump = UnpackNormal(tex2D( _BumpMap, i.uvbump )).rg; // we could optimize this by just reading the x & y without reconstructing the Z
	float2 offset = bump * _BumpAmt * _GrabTexture_TexelSize.xy;
	i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
	
	//tex2Dproj与tex2D的区别是tex2Dproj进行一次其次除法之后再进行tex2D，所以tex2Dproj第二个参数向量有四个分量
	half4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
	half4 tint = tex2D(_MainTex, i.uvmain);
	col *= tint
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}
ENDCG
		}
	}

	// ------------------------------------------------------------------
	// Fallback for older cards and Unity non-Pro

	SubShader {
		Blend DstColor Zero
		Pass {
			Name "BASE"
			SetTexture [_MainTex] {	combine texture }
		}
	}
}

}
