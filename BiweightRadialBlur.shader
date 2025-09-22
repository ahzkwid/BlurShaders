Shader "Unlit/BiweightRadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        blurStrength("BlurStrength", Range(0,100)) = 0
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
            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            int blurStrength;

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
                fixed4 col = fixed4(0,0,0,0);


                fixed weightAll = 0;
                for (int x = -blurStrength; x <= blurStrength; x++)
                {
                    for (int y = -blurStrength; y <= blurStrength; y++)
                    {
                        fixed weight = x * x + y * y;
                        if (blurStrength>0)
                        {
                            weight /= blurStrength * blurStrength;
                        }
                        weight = 1 - weight;
                        weight *=weight;
                        //if (x*x+y*y<= blurStrength* blurStrength)
                        if (weight>0)
                        {
                            weightAll += weight;
                            //weight *= weight;
                            col += tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * fixed2(x, y))* weight;
                        }
                    }
                }
                return col / max(1, weightAll);


                fixed volume = pow(blurStrength, 2) * 3.14; //원기둥 높이는 1이라서 곱하기 1은 안했음
                volume /= 2.5; //원뿔이라서 나누기3
                return col / max(1, volume);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
