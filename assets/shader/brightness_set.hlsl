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
#define delta  user_data_0.x
// 默认为1
#define flag user_data_0.y
// 默认为1
#define open user_data_0.z

// 函数

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

    texColor.r = texColor.r * delta;
    texColor.g = texColor.g * delta;
    texColor.b = texColor.b * delta;
    texColor.a = texColor.a * delta;

    PS_Output output;
    output.col = texColor;
	return output;
}