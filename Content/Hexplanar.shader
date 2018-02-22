Shader "Unlit/Hexaplanar"
{
	Properties
	{
		_ColorX ("Color X", Color) = (0, 0, 0, 0)
		_ColorY ("Color Y", Color) = (0, 0, 0, 0)
		_ColorZ ("Color Z", Color) = (0, 0, 0, 0)

		_ColorXM ("Color -X", Color) = (0, 0, 0, 0)
		_ColorYM ("Color -Y", Color) = (0, 0, 0, 0)
		_ColorZM ("Color -Z", Color) = (0, 0, 0, 0)
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

			float4 _ColorXM;
			float4 _ColorYM;
			float4 _ColorZM;

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
				float c = max(
								max(blending.x, blending.y), 
															blending.z);

				if (c == blending.x)
				{
					if (i.normal.x > 0)
					{
						return _ColorX * blending.x;
					}
					else
					{
						return _ColorXM * blending.x;
					}
				}
				if (c == blending.y)
				{
					if (i.normal.y > 0)
					{
						return _ColorY * blending.y;
					}
					else
					{
						return _ColorYM * blending.y;
					}
				}
				if (c == blending.z)
				{
					if (i.normal.z > 0)
					{
						return _ColorZ * blending.z;
					}
					else
					{
						return _ColorZM * blending.z;
					}
				}
				return 0;
			}
			ENDCG
		}
	}
}
