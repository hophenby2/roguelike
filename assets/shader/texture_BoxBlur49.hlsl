//==============================================================================
// 模糊 code by Xiliusha(ETC)
// port to LuaSTG-Sub by 璀境石
// 49点模式：中心和四周8个点加上外围16个再加上最外围24点平均
// 推荐参数：半径x，迭代(最少~推荐)次(最多别超过4次！)
//           半径1，迭代1~1次(可用于一些符卡的特效)
//           半径2，迭代1~1次(可用于一些符卡的特效)
//           半径3，迭代1~2次(推荐的级别，可用于暂停菜单模糊)
//           半径4，迭代2~2次(一般到这个级别就够用了)
//           半径5，迭代2~3次(已经很模糊了)
//           半径6，迭代3~3次(模糊程度非常高)
//==============================================================================

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

#define screenSize   screen_texture_size.xy
#define screenHeight screen_texture_size.y
// 采样半径，单位为游戏内坐标系
#define radiu user_data_0.x

// 常量

float inner = 1.0f; // 边沿缩进

// 函数

// 根据采样半径对纹理周围 48 个点进行采样，然后和中心的点进行混合，49 点模式
float4 BoxBlur49(float2 uv, float r)
{
    float2 xy = uv * screenSize;
    
    float ratble[8]={9961.0f,-1.0f,-0.65f,-0.35f,0.0f,0.35f,0.65f,1.0f};
    float4 TexColor=float4(0.0f,0.0f,0.0f,0.0f);
    float2 SamplerPointx[22];
    float2 SamplerPointy[22];
    float2 SamplerPointz[8];
    float2 Lxy;
    float2 Luv;
    float num;
    
    //获得采样点偏移
    for (int sa = 1; sa <= 7; sa = sa + 1)
    {
        num = ratble[sa];
        SamplerPointx[sa] = float2(-1.0f * r, num * r);
        SamplerPointx[7+sa] = float2(-0.65f * r, num * r);
        SamplerPointx[14+sa] = float2(-0.35f * r, num * r);
        SamplerPointy[sa] = float2(0.0f * r, num * r);
        SamplerPointy[7+sa] = float2(0.35f * r, num * r);
        SamplerPointy[14+sa] = float2(0.65f * r, num * r);
        SamplerPointz[sa] = float2(1.0f * r, num * r);
    }
    
    for (int se = 1; se <= 21; se = se + 1)
    {
        Lxy = xy + SamplerPointx[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screenSize; //获得采样点uv坐标
        TexColor = TexColor + screen_texture.Sample(screen_texture_sampler, Luv); //得到采样颜色并相加
    }
    for (int se = 1; se <= 21; se = se + 1)
    {
        Lxy = xy + SamplerPointy[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screenSize; //获得采样点uv坐标
        TexColor = TexColor + screen_texture.Sample(screen_texture_sampler, Luv); //得到采样颜色并相加
    }
    for (int se = 1; se <= 7; se = se + 1)
    {
        Lxy = xy + SamplerPointz[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screenSize; //获得采样点uv坐标
        TexColor = TexColor + screen_texture.Sample(screen_texture_sampler, Luv); //得到采样颜色并相加
    }
    
    return TexColor / 49.0f; //取平均值
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
    float scale = screenHeight / 480.0f; // 保证画面效果在不同分辨率下相同，除以的数为游戏基础坐标系的y
    float4 texColor = BoxBlur49(input.uv, radiu * scale); // 获得均值颜色，49点
    texColor.a = 1.0f;

    PS_Output output;
	output.col = texColor;
	return output;
}
