//======================================
// code by Xiliusha(ETC)
// powered by OLC
// port to LuaSTG-Sub by 璀境石
// 做正邪的卡可以用上
//======================================

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
    float4 user_data_1;
};

// 为了方便使用，定义的一些宏

#define screenSize screen_texture_size.xy
// 指定效果的中心坐标
#define center  user_data_0.xy
// 水平缩放（这里是不是写错了……）
#define vscale  user_data_0.z
// 垂直缩放（这里是不是写错了……）
#define hscale  user_data_0.w
// 旋转
#define angle   user_data_1.x
#define flag    user_data_1.y

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
    float2 xy = input.uv * screenSize;//屏幕上真实位置
    float2 delta = xy - center;//计算效果中心到坐标的向量
    
    float2 xy2 = center;
    if (abs(vscale) > 0.001f)
    {
        xy2.x = center.x + delta.x * 1.0f / vscale; // 缩放水平坐标
    }
    if (abs(hscale) > 0.001f)
    {
        xy2.y = center.y + delta.y * 1.0f / hscale; // 缩放垂直坐标
    }
    
    float2 delta2 = xy2 - center; // 效果中心到坐标的向量
    float rot = radians(angle); // 角度化弧度
    float2 trans = float2(cos(rot), sin(rot)); // 转为向量？形式
    float2 xy3 = float2(delta2.x * trans.x - delta2.y * trans.y, delta2.x * trans.y + delta2.y * trans.x) + center; // 坐标旋转
    if (xy3.x < viewport.x || xy3.x > viewport.z || xy3.y < viewport.y || xy3.y > viewport.w)
	{
		discard; // 抛弃不需要的像素，防止意外覆盖画面
	}

    float2 uv2 = xy3 / screenSize; // 转换为uv坐标
    float4 texColor = screen_texture.Sample(screen_texture_sampler, uv2); //对纹理进行采样

    float1 col_alpha = 1.0f;
    if (flag > 0.9f)
    {
        col_alpha = texColor.a;
    }
    texColor.a = min(col_alpha, 1.0f);

	PS_Output output;
	output.col = texColor;
	return output;
}
