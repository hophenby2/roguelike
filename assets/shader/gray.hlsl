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

#define screenSize screen_texture_size.xy
#define alpha user_data_0.x
#define flag  user_data_0.y

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
    float2 xy = input.uv * screenSize;
    if (xy.x < viewport.x || xy.x > viewport.z || xy.y < viewport.y || xy.y > viewport.w)
	{
		discard; // 抛弃不需要的像素，防止意外覆盖画面
	}

    float4 texColor = screen_texture.Sample(screen_texture_sampler, input.uv);

    float1 h = 0.299f * texColor.r + 0.587f * texColor.g + 0.114f * texColor.b; // 计算图像的灰度值
    float1 balpha = 1.0f - alpha;

    float1 col_alpha = 1.0f;
    if (flag > 0.99f)
    {
        col_alpha = texColor.a;
    }
    float4 outcolor = float4(
        texColor.r * balpha + h * alpha,
        texColor.g * balpha + h * alpha,
        texColor.b * balpha + h * alpha,
        col_alpha); // 将灰度值应用到outcolor上

	PS_Output output;
	output.col = outcolor;
	return output;
}
