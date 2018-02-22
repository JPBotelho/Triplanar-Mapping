Shader "Unlit/Triplanar Additive"
{
	Properties
	{
		_ColorX ("Color X", Color) = (0, 0, 0, 0)
		_ColorY ("Color Y", Color) = (0, 0, 0, 0)
		_ColorZ ("Color Z", Color) = (0, 0, 0, 0)
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

			fixed4 _ColorX;
			float4 _ColorY;
			float4 _ColorZ;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = mul(unity_ObjectToWorld, v.normal); //Use worldspace normal

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 blending = abs(i.normal);
				blending = normalize(blending);
				float sum = blending.x + blending.y + blending.z;
				blending /= float3(sum, sum, sum);

				//Maximum of the values of the normal (XYZ)				
				float4 c = max(
								max(_ColorX * blending.x, _ColorY * blending.y), 
																				_ColorZ * blending.z);
				return c;
			}
			ENDCG
		}
	}
}