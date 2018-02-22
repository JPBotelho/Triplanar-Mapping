Shader "Unlit/Triplanar Textures"
{
	Properties
	{
		_TextureX ("Texture X", 2D) = "white" {}
		_TextureY ("Texture Y", 2D) = "white" {}
		_TextureZ ("Texture Z", 2D) = "white" {}

		_ColorX ("Color X", Color) = (1, 1, 1, 1)
		_ColorY ("Color Y", Color) = (1, 1, 1, 1)
		_ColorZ ("Color Z", Color) = (1, 1, 1, 1)
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

			sampler2D _TextureX;
			sampler2D _TextureY;
			sampler2D _TextureZ;

			fixed4 _ColorX;
			fixed4 _ColorY;
			fixed4 _ColorZ;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = mul(unity_ObjectToWorld, v.normal);
				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				float3 blending = abs(i.normal); //Get abs of the normal

				blending = normalize(blending);

				float sum = blending.x + blending.y + blending.z;

				blending /= float3(sum, sum, sum); //Normalize it again
				
				float4 sampleX = tex2D(_TextureX, i.uv);
				float4 sampleY = tex2D(_TextureY, i.uv);
				float4 sampleZ = tex2D(_TextureZ, i.uv);	

				float4 colorX = sampleX * _ColorX;
				float4 colorY = sampleY * _ColorY;
				float4 colorZ = sampleZ * _ColorZ;			
				
				//Return the color that matches the higher axis of the normal
				float4 c = max(
								max(colorX * blending.x, colorY * blending.y),
																				colorZ * blending.z);
				return c;
			}
			ENDCG
		}
	}
}
