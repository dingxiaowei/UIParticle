Shader "UI/Particles/Alpha Blended" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}

	_StencilComp ("Stencil Comparison", Float) = 8
	_Stencil ("Stencil ID", Float) = 0
	_StencilOp ("Stencil Operation", Float) = 0
	_StencilWriteMask ("Stencil Write Mask", Float) = 255
	_StencilReadMask ("Stencil Read Mask", Float) = 255

	_ColorMask ("Color Mask", Float) = 15

	[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

	Stencil
	{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
	}

	Blend SrcAlpha OneMinusSrcAlpha
	ColorMask [_ColorMask]
	Cull Off Lighting Off ZWrite Off
	ZTest [unity_GUIZTestMode]

	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			sampler2D _MainTex;
			fixed4 _TintColor;
			float4 _ClipRect;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
				#endif
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(float4(v.vertex));
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : SV_Target
			{					
				fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				return col;
			}
			ENDCG 
		}
	}	
}
}
