Shader "Ahzkwid/Blur/LoopbackBlur"
{
    Properties
    {
        _MainTex("MainRenderTexture", 2D) = "white" {}
        _BufferTex("BufferRenderTexture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            sampler2D _BufferTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _BufferTex_TexelSize;

            float4 NearbyMax(sampler2D tex, float2 uv, float2 texelSize)
            {
                fixed4 col = tex2D(tex, uv + texelSize * float2(1, 0));
                col = max(col, tex2D(tex, uv + texelSize * float2(-1, 0)));
                col = max(col, tex2D(tex, uv + texelSize * float2(0, 1)));
                col = max(col, tex2D(tex, uv + texelSize * float2(0, -1)));

                col = max(col, tex2D(tex, uv + texelSize * (float2(1, 1) * 1 / 1.414)));
                col = max(col, tex2D(tex, uv + texelSize * (float2(1, -1) * 1 / 1.414)));
                col = max(col, tex2D(tex, uv + texelSize * (float2(-1, 1) * 1 / 1.414)));
                col = max(col, tex2D(tex, uv + texelSize * (float2(-1, -1) * 1 / 1.414)));
                return col;
            }
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                /*
                fixed4 mainCol = tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * float2(1,0));
                mainCol = max(mainCol, tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * float2(-1, 0)));
                mainCol = max(mainCol, tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * float2(0, 1)));
                mainCol = max(mainCol, tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * float2(0, -1)));

                fixed4 col = tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(1, 0));
                col +=  tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(-1, 0));
                col +=  tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(0, 1));
                col +=  tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(0, -1));
                col /= 4;
                col.a = col.b;
                col.b = col.g;
                col.g = col.r;
                col.r = mainCol.r;

                */
                fixed4 mainCol = tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy);
                fixed4 col = NearbyMax(_BufferTex, i.uv, _BufferTex_TexelSize.xy);
                 /*
                fixed4 col = tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(1, 0));
                col = max(col,tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(-1, 0)));
                col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(0, 1)));
                col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(0, -1)));

                col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * (float2(1, 1) * 1 / 1.414)));
                col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * (float2(1, -1) * 1 / 1.414)));
                col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * (float2(-1, 1) * 1 / 1.414)));
                col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * (float2(-1, -1) * 1 / 1.414)));
                */
                //col *= 0.8;
            /*
                fixed4 col = fixed4(0, 0, 0, 0);
                for (float d = 0; d < 360; d+=360/8)
                {
                    col = max(col, tex2D(_BufferTex, i.uv + _BufferTex_TexelSize.xy * float2(2*cos(d*3.14/180.0), 2*sin(d* 3.14 / 180.0))));
                }
                */

                col.r = max(mainCol.r, col.r - 0.01f);
                col.gb = 0;
                col.a = 1;




                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
