// 引擎设置的参数，不可修改

SamplerState screen_texture_sampler : register(s4); // RenderTarget 纹理的采样器
Texture2D screen_texture            : register(t4); // RenderTarget 纹理
cbuffer engine_data : register(b1)
{
	float4 screen_texture_size; // 纹理大小
	float4 viewport;            // 视口
};

// 用户传递的浮点参数
// 由多个 float4 组成，且 float4 是最小单元，最多可传递 8 个 float4

cbuffer user_data : register(b0)
{
	float4 user_data_0;
};

// 为了方便使用，定义的一些宏

// 色相（-1~1）
#define Hue  user_data_0.x
// 默认为1
#define flag user_data_0.y
// 默认为1
#define open user_data_0.z

// 函数

float Hue_2_RGB(float v1, float v2, float vH)
{
    float vH1 = vH;
    if ( vH < 0 ) vH1 += 1;
    if ( vH > 1 ) vH1 -= 1;
    if ( ( 6 * vH1 ) < 1 ) return ( v1 + ( v2 - v1 ) * 6 * vH1 );
    if ( ( 2 * vH1 ) < 1 ) return ( v2 );
    if ( ( 3 * vH1 ) < 2 ) return ( v1 + ( v2 - v1 ) * ( ( 2 / 3.0 ) - vH1 ) * 6.0 );
    return ( v1 );
}

float3 HSL2RGB(float H, float S, float L)
{
    float R,G,B;
    if ( S == 0 )                       //HSL from 0 to 1
    {
        R = L;                      //RGB results from 0 to 255
        G = L;
        B = L;
    }
    else
    {
        float var_2,var_1;
        if ( L < 0.5 ) var_2 = L * ( 1 + S );
        else           var_2 = ( L + S ) - ( S * L );

        var_1 = 2.0 * L - var_2;

        R = Hue_2_RGB( var_1, var_2, H + ( 1 / 3.0 ) ) ;
        G = Hue_2_RGB( var_1, var_2, H );
        B = Hue_2_RGB( var_1, var_2, H - ( 1 / 3.0 ) );
    }
    return float3(R,G,B);
}

// 主函数

struct PS_Input
{
	float4 sxy : SV_Position;
	float2 uv  : TEXCOORD0;
	float4 col : COLOR0;
};
struct PS_Output
{
	float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
    float4 texColor = screen_texture.Sample(screen_texture_sampler, input.uv);
	if (open < 0.99f)
    {
		float1 col_alpha = 1.0f;
        if (flag > 0.99f)
        {
            col_alpha = texColor.a;
        }
        texColor.a = col_alpha;
    }
    else
    {
        float1 l = 0.299f * texColor.r + 0.587f * texColor.g + 0.114f * texColor.b; // 计算图像的亮度值
        float1 s = 1.0f - l;
        float3 rgb = HSL2RGB(Hue,s,l);

        float1 col_alpha = 1.0f;
        if (flag > 0.99f)
        {
            col_alpha = texColor.a;
        }
        texColor = float4(rgb.x, rgb.y, rgb.z, col_alpha);
    }

    PS_Output output;
	output.col = texColor;
	return output;
}