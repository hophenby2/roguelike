// 作者：<云绝>

SamplerState u_texture_sampler : register(s0);
Texture2D u_texture : register(t0);
SamplerState u_texture_h_sampler : register(s1);
Texture2D u_texture_h : register(t1);

cbuffer g_buffer : register(b0)
{
    float height;
    float width;
    float4 edge_color;
};

// 主函数
struct PS_Input
{
    float4 sxy : SV_Position;
    float2 uv : TEXCOORD0;
    float4 col : COLOR0;
};
struct PS_Output
{
    float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
  // 获取纹理颜色
    float4 ori = u_texture.Sample(u_texture_sampler, input.uv);
    float4 h_map = u_texture_h.Sample(u_texture_h_sampler, input.uv);

    // 根据高度图的值计算透明度
    float a = clamp(height - h_map.r, 0.0, width) / width;

    // 设置边缘颜色的透明度
    float4 ec = edge_color;
    if (a <= 0.0)
    {
        ori.a = 0.0;
        ec.a = 0.0;
    }
    else
    {
        ec.a = ori.a * (0.5 + 0.5 * a);
    }

    // 混合颜色
    PS_Output output;
    output.col = input.col * lerp(ec, ori, a);
    
    return output;
}
