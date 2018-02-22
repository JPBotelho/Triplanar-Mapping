Shader "Unlit/Triplanar Snow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_SnowColor ("Snow Color", Color) = (1, 1, 1, 1)

		_SnowHeight ("Snow Height", Range (-1, 1)) = .2
		_MinHeight ("Min Snow Height", Range (-1, 1)) = .2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _SnowColor;

			half _MinHeight;
			half _SnowHeight;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = mul(unity_ObjectToWorld, v.normal); //Use worldspace normal

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 blending = abs(i.normal);
				blending = normalize(blending);
				float sum = blending.x + blending.y + blending.z; //Second normalization pass
				blending /= float3(sum, sum, sum);

				float4 texSample = tex2D(_MainTex, i.uv);				
				
				//Max of the 3 normal axis
				float4 c = max(
								max(texSample * blending.x, //X
								_SnowHeight + _SnowColor * blending.y * (i.normal.y > _MinHeight)), //SHeight + Y * OverMinHeight
								texSample * blending.z); //Y
				return c;
			}
			ENDCG
		}
	}
}
