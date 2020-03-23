// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CQ2/Effect/Mobile_UVAnim(ADD)" {
Properties {
	 _Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("MainTex", 2D) = "gray" {}
	_ScrollX ("Base layer Scroll speed X", Float) = 1.0
	_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
}

SubShader {
	Tags { "Queue"="Transparent-110" "IgnoreProjector"="True"}
	
	ZWrite Off
       Cull Off
       Blend SrcAlpha one
	
	LOD 10
	
		
	CGINCLUDE
	#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
	#include "UnityUI.cginc"
	#include "UnityCG.cginc"
	sampler2D _MainTex;

	float4 _MainTex_ST;
	
	float _ScrollX;
	float _ScrollY;

	float4 _Color;

	struct appdata_t {
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		float2 uv : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};
	
	struct v2f {
		float4 pos : SV_POSITION;
		float4 uv : TEXCOORD0;
		fixed4 color : TEXCOORD2;
		fixed4 color2:COLOR;		
	};

	
	
	v2f vert (appdata_t v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		//o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
   		o.color2=v.color;

		o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex).xy + frac(float2(_ScrollX, _ScrollY) * _Time);
		o.uv.zw = mul(unity_ObjectToWorld, v.vertex).xy;

		return o;
	}
	ENDCG


	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest		

		float4 _ClipRect;
		float _UseClipRect;

		fixed4 frag (v2f i) : COLOR
		{
			fixed4 o;
			fixed4 tex = tex2D (_MainTex, i.uv);
			o = tex  * _Color *i.color2;
			
			float c = UnityGet2DClipping(i.uv.zw, _ClipRect);
			o.a = lerp(o.a, c * o.a, _UseClipRect);

			return o;
		}
		ENDCG 
	}	
}
}