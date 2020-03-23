Shader "UI/Particles/GlowAdditiveSimple" {
	Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_CoreColor ("Core Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_TintStrength ("Tint Color Strength", Float) = 1
	_CoreStrength ("Core Color Strength", Float) = 1
	_CutOutLightCore ("CutOut Light Core", Range(0, 1)) = 0.5

	_StencilComp ("Stencil Comparison", Float) = 8
	_Stencil ("Stencil ID", Float) = 0
	_StencilOp ("Stencil Operation", Float) = 0
	_StencilWriteMask ("Stencil Write Mask", Float) = 255
	_StencilReadMask ("Stencil Read Mask", Float) = 255

	_ColorMask ("Color Mask", Float) = 15

	[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

	Stencil
	{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
	}

	ColorMask [_ColorMask]
	Blend SrcAlpha One
	Cull Off 
	Lighting Off 
	ZWrite Off 
	Fog { Color (0,0,0,0) }
	ZTest [unity_GUIZTestMode]
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
		
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			sampler2D _MainTex;
			fixed4 _TintColor;
			fixed4 _CoreColor;
			float _CutOutLightCore;
			float _TintStrength;
			float _CoreStrength;
			float4 _ClipRect;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float4 color : COLOR;
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				fixed4 col = (_TintColor * tex.g * _TintStrength + tex.r * _CoreColor * _CoreStrength  - _CutOutLightCore); 
				col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				return i.color *clamp(col, 0, 255);

			}
			ENDCG 
		}
	}	
}
}
