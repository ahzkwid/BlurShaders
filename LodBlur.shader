Shader "Ahzkwid/Blur/LodBlur"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        blurStrength("BlurStrength", Range(0,1)) = 0.1
        detail("Detail", Range(1,4)) = 1
            
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
                int detail;


                


                fixed4 lodBlur(float blurStrength, float2 uv)
                {
                    fixed radius = pow(2, blurStrength) / 128;
                    fixed mipmap = blurStrength * log(_MainTex_TexelSize.z)/ log(128);

                    fixed4 col = tex2Dlod(_MainTex, float4(uv, 0, mipmap));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(-radius, 0) , 0, mipmap));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(radius, 0) , 0, mipmap));

                    col += tex2Dlod(_MainTex, float4(uv + fixed2(-radius, -radius)  / 1.414, 0, mipmap));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(0, -radius) , 0, mipmap));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(radius, -radius)  / 1.414, 0, mipmap));

                    col += tex2Dlod(_MainTex, float4(uv + fixed2(-radius, radius)  / 1.414, 0, mipmap));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(0, -radius) , 0, mipmap));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(radius, radius)  / 1.414, 0, mipmap));
                    return col / 9;
                }
                fixed4 lodBlurTexel(float blurStrength, float2 uv)
                {
                    fixed4 col = tex2Dlod(_MainTex, float4(uv, 0, blurStrength));
                    fixed radius = pow(2, blurStrength);
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(-_MainTex_TexelSize.x, 0) * radius, 0, blurStrength));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(_MainTex_TexelSize.x, 0) * radius, 0, blurStrength));

                    col += tex2Dlod(_MainTex, float4(uv + fixed2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y) * radius / 1.414, 0, blurStrength));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(0, -_MainTex_TexelSize.y) * radius, 0, blurStrength));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y) * radius / 1.414, 0, blurStrength));

                    col += tex2Dlod(_MainTex, float4(uv + fixed2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y) * radius / 1.414, 0, blurStrength));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(0, -_MainTex_TexelSize.y) * radius, 0, blurStrength));
                    col += tex2Dlod(_MainTex, float4(uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * radius / 1.414, 0, blurStrength));
                    return col / 9;
                }
                fixed4 lodBlurTexelSimple(float blurStrength, float2 uv)
                {
                    fixed4 col = tex2Dlod(_MainTex, float4(uv, 0, blurStrength));
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
                    //fixed4 col = tex2D(_MainTex, i.uv);
                    fixed4 col = fixed4(0,0,0,0);
                //col += tex2dlod(_MainTex, float4(i.uv, 0, 0));
                /*
                col = fixed4(0,0,0,0);
                col += tex2Dlod(_MainTex, float4(i.uv, 0, blurStrength * 1 + 1))*0.1;
                col += tex2Dlod(_MainTex, float4(i.uv, 0, blurStrength * 2 + 1))*0.2;
                col += tex2Dlod(_MainTex, float4(i.uv, 0, blurStrength * 3 + 1))*0.3;
                col += tex2Dlod(_MainTex, float4(i.uv, 0, blurStrength * 4 + 1))*0.4;
                */

                col += tex2D(_MainTex, i.uv);

                if (blurStrength>0)
                {
                    col = fixed4(0, 0, 0, 0);
                    /*
                    for (int j = blurStrength * 8; j < blurStrength * 8 + 1; j++)
                    {
                        col += lodBlur(j,i.uv);
                        
                        //col += tex2Dlod(_MainTex, float4(i.uv + fixed2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y) * (j), 0, blurStrength * j)) * 0.25;
                        //col += tex2Dlod(_MainTex, float4(i.uv + fixed2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y) * (j), 0, blurStrength * j)) * 0.25;
                        //col += tex2Dlod(_MainTex, float4(i.uv + fixed2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y) * (j), 0, blurStrength * j)) * 0.25;
                        //col += tex2Dlod(_MainTex, float4(i.uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * (j), 0, blurStrength * j)) * 0.25;
                        
                    }
                    */
                    blurStrength = sqrt(blurStrength);
                    blurStrength = (blurStrength) * 8;
                   // detail = clamp(detail, 1 , blurStrength);
                    for (int j = 0; j < detail; j++)
                    {
                        col += lodBlurTexel(blurStrength + j, i.uv);
                    }
                    //col += lodBlur(blurStrength * 4+2, i.uv);
                    col /= floor(detail);
                }


                //col /= 30; 
                //col = tex2Dlod(_MainTex, float4(i.uv, 0, blurStrength * 4 + 1)) ;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
        }
}
