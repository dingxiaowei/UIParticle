
Shader "CQ2/Effect/distort(BLEND)" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_NoiseTex ("Distort Texture (RG)", 2D) = "white" {}
	_MainTex ("Alpha (A)", 2D) = "white" {}
	_HeatTime  ("Heat Time", range (-1,1)) = 0
	_ForceX  ("Strength X", range (0,1)) = 0.1
	_ForceY  ("Strength Y", range (0,1)) = 0.1

	_ScrollX ("Base layer Scroll speed X", Float) = 0.0
	_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
}

Category {
	Tags { "Queue"="Transparent" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}

	SubShader {
		Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile_particles
#include "UnityCG.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord: TEXCOORD0;
};

struct v2f {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 uvmain1 : TEXCOORD1;
	float2 uvmain2 : TEXCOORD2;
	float2 uvmain:TEXCOORD3;
};

fixed4 _TintColor;
fixed _ForceX;
fixed _ForceY;
fixed _HeatTime;
float4 _MainTex_ST;
float4 _NoiseTex_ST;
sampler2D _NoiseTex;
sampler2D _MainTex;

	float _ScrollX;
	float _ScrollY;

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.color = v.color;
	o.uvmain  = TRANSFORM_TEX( v.texcoord, _MainTex )+ frac(float2(_ScrollX, _ScrollY) * _Time.x);
	o.uvmain1 = o.uvmain+frac(_Time.xz*_HeatTime);
	o.uvmain2 = o.uvmain+frac(_Time.yx*_HeatTime);
	return o;
}

fixed4 frag( v2f i ) : COLOR
{
	//noise effect
	fixed4 offsetColor1 = tex2D(_NoiseTex, i.uvmain1);
    fixed4 offsetColor2 = tex2D(_NoiseTex, i.uvmain2);
	i.uvmain.x += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceX;
	i.uvmain.y += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceY;
	return 2.0f * i.color * _TintColor * tex2D( _MainTex, i.uvmain);
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

