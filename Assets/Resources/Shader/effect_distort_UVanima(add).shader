// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CQ2/Effect/distort_UVanima(ADD)" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_NoiseTex ("Distort Texture (RG)", 2D) = "white" {}
	_MainTex ("Alpha (A)", 2D) = "white" {}
	_HeatTime  ("Heat Time", range (-1,1)) = 0
	_ForceX  ("Strength X", range (0,1)) = 0.1
	_ForceY  ("Strength Y", range (0,1)) = 0.1
	_SpeedX("Base Layer Scroll Speed X", float) = 0.1
	_SpeedY("Base Layer Scroll Speed Y",float) = 0.1
}

Category {
	Tags { "Queue"="Transparent" "RenderType"="Transparent" }
	Blend SrcAlpha One
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
#include "UnityUI.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord: TEXCOORD0;
};

struct v2f {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float4 uvmain : TEXCOORD1;
};

fixed4 _TintColor;
fixed _ForceX, _SpeedX;
fixed _ForceY, _SpeedY;
fixed _HeatTime;
float4 _MainTex_ST;
float4 _NoiseTex_ST;
sampler2D _NoiseTex;
sampler2D _MainTex;

float4 _ClipRect;
float _UseClipRect;

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.color = v.color;
	o.uvmain.xy = TRANSFORM_TEX( v.texcoord, _MainTex );
	o.uvmain.zw = mul(unity_ObjectToWorld, v.vertex).xy;
	return o;
}

fixed4 frag( v2f i ) : COLOR
{
	//noise effect
	fixed4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz*_HeatTime);
    fixed4 offsetColor2 = tex2D(_NoiseTex, i.uvmain + _Time.yx*_HeatTime);
	i.uvmain.x += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceX;
	i.uvmain.y += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceY;
	fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.uvmain + float2(_SpeedX, _SpeedY)*_Time.x);
	float c = UnityGet2DClipping(i.uvmain.zw, _ClipRect);
	col.a = lerp(col.a, c * col.a, _UseClipRect);

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
