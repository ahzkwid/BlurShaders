Shader "Unlit/Blur"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        blurStrength("BlurStrength", Range(0,1)) = 0.1
    
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float blurStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col ;
                for (int x = 0; x < 4; x++)
                {
                    for (int y = 0; y < 4; y++)
                    {
                        //col += tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * int2(x - 4, y - 4) * blurStrength);
                        col += tex2D(_MainTex, i.uv + float2(blurStrength, blurStrength)/(4*10) * int2(x - 2, y - 2) );
                    }
                }
                col /= 4*4;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
