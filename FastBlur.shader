Shader "Unlit/FastBlur"
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
            #pragma target 3.0

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



            fixed4 tex2Dlod(sampler2D _sampler, float4 _pos)
            {
                int _BoardSize = _MainTex_TexelSize.z / (_pos.w + 1);
                return tex2D(_MainTex, (floor(_pos.xy * _BoardSize) + 0.5) / _BoardSize);
            }
            fixed4 tex2DlodLinear(sampler2D _sampler, float4 _pos)
            {
                int _BoardSize = _MainTex_TexelSize.z / (_pos.w + 1);
                float4 col = tex2Dlod(_sampler, float4(_pos.xy, _pos.zw));
                float4 col2 = tex2Dlod(_sampler, float4(_pos.xy + float2(1,0) / _BoardSize, _pos.zw));
                float4 col3 = tex2Dlod(_sampler, float4(_pos.xy + float2(0, 1) / _BoardSize, _pos.zw));
                float4 col4 = tex2Dlod(_sampler, float4(_pos.xy + float2(1, 1) / _BoardSize, _pos.zw));

                 col = lerp(col, col2, frac(_pos.x * _BoardSize));
                 float4 col5 = lerp(col3, col4, frac(_pos.x * _BoardSize));
                 col = lerp(col, col5, frac(_pos.y * _BoardSize));
                return col;
            }


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
                fixed4 col = fixed4(0,0,0,0);
                //col += tex2dlod(_MainTex, float4(i.uv, 0, 0));
                col += tex2DlodLinear(_MainTex, float4(i.uv, 0, blurStrength * 8));
                //col /= 4; 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
