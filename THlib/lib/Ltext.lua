--======================================
--luastg text
--======================================

----------------------------------------
--文字渲染

local ENUM_TTF_FMT = {
    left = 0x00000000,
    center = 0x00000001,
    right = 0x00000002,

    top = 0x00000000,
    vcenter = 0x00000004,
    bottom = 0x00000008,

    wordbreak = 0x00000010,

    noclip = 0x00000100,

    paragraph = 0x00000010,
    centerpoint = 0x00000105,
}
setmetatable(ENUM_TTF_FMT, { __index = load("return 0") })

local lstg = lstg
function RenderTTF(ttfname, text, x, y, color, ...)
    local fmt = 0
    for _, t in ipairs({ ... }) do
        fmt = fmt + ENUM_TTF_FMT[t]
    end
    lstg.RenderTTF(ttfname, text, x, x, y, y, fmt, color)
end

function RenderTTF2(ttfname, text, x, y, scale, color, ...)
    local fmt = 0
    for _, t in ipairs({ ... }) do
        fmt = fmt + ENUM_TTF_FMT[t]
    end
    lstg.RenderTTF(ttfname, text, x, x, y, y, fmt, color, scale)
end
function OriginalRenderTTF(ttfname, text, left, right, bottom, top, scale, color, ...)
    local fmt = 0
    for _, t in ipairs({ ... }) do
        fmt = fmt + ENUM_TTF_FMT[t]
    end
    lstg.RenderTTF(ttfname, text, left, right, bottom, top, fmt, color, scale)
end

function RenderText(fontname, text, x, y, size, ...)
    local fmt = 0
    for _, t in ipairs({ ... }) do
        fmt = fmt + ENUM_TTF_FMT[t]
    end
    lstg.RenderText(fontname, text, x, y, size, fmt)
end

---@param ttfname string
---@param text string
---@param x number
---@param y number
---@param rot number
---@param hscale number
---@param vscale number
---@param blend lstg.BlendMode
---@param color lstg.Color
---@return number, number
function RenderTTF3(ttfname, text, x, y, rot, hscale, vscale, blend, color, ...)
    -- 警告：这里的实现代码以后可能会变化，甚至转为 C++ 实现
    -- 警告：请勿直接使用这些 Native API

    -- 翻译对齐
    local args = { ... }
    local halign = 0
    local valign = 0
    for _, v in ipairs(args) do
        if v == "center" then
            halign = 1
        elseif v == "right" then
            halign = 2
        elseif v == "vcenter" then
            valign = 1
        elseif v == "bottom" then
            valign = 2
        elseif v == "centerpoint" then
            halign = 1
            valign = 1
        end
    end

    -- 设置字体

    local fr = lstg.FontRenderer
    fr.SetFontProvider(ttfname)
    fr.SetScale(hscale, vscale)

    -- 计算笔触位置

    local x0, y0 = x, y
    local l, r, b, t = fr.MeasureTextBoundary(text)
    local w, h = r - l, t - b
    if halign == 0 then
        x = x - l -- 使左边缘对齐 x
    elseif halign == 1 then
        x = (x - l) - (w / 2) -- 居中
    else
        -- "right"
        x = x - r -- 使右边缘对齐 x
    end
    if valign == 0 then
        y = y - t -- 使顶边缘对齐 y
    elseif valign == 1 then
        y = (y - b) - (h / 2) -- 居中
    else
        -- "bottom"
        y = y - b -- 使底边缘对齐 y
    end

    -- 对笔触位置进行旋转

    local cos_v = math.cos(math.rad(rot))
    local sin_v = math.sin(math.rad(rot))
    local dx = x - x0
    local dy = y - y0
    local x1 = x0 + dx * cos_v - dy * sin_v
    local y1 = y0 + dx * sin_v + dy * cos_v

    -- 绘制

    local ret, x2, y2 = fr.RenderTextInSpace(
            text,
            x1, y1, 0.5,
            math.cos(math.rad(rot)), math.sin(math.rad(rot)), 0,
            math.cos(math.rad(rot - 90)), math.sin(math.rad(rot - 90)), 0,
            blend, color
    )
    assert(ret)

    return x2, y2
end

function RenderTTF4(ttfname, text, x, y, size, maxw, color, ...)
    size = size * 0.5
    -- 警告：这里的实现代码以后可能会变化，甚至转为 C++ 实现
    -- 警告：请勿直接使用这些 Native API

    -- 翻译对齐
    local args = { ... }
    local halign = 0
    local valign = 0
    for _, v in ipairs(args) do
        if v == "center" then
            halign = 1
        elseif v == "right" then
            halign = 2
        elseif v == "vcenter" then
            valign = 1
        elseif v == "bottom" then
            valign = 2
        elseif v == "centerpoint" then
            halign = 1
            valign = 1
        end
    end

    -- 设置字体

    local fr = lstg.FontRenderer
    fr.SetFontProvider(ttfname)
    fr.SetScale(size, size)

    -- 计算笔触位置
    local l, r, b, t = fr.MeasureTextBoundary(text)
    local w, h = r - l, t - b
    if w > maxw then
        fr.SetScale(size * maxw / w, size)
        w = maxw
        r = l + w
    end
    if halign == 0 then
        x = x - l -- 使左边缘对齐 x
    elseif halign == 1 then
        x = (x - l) - (w / 2) -- 居中
    else
        -- "right"
        x = x - r -- 使右边缘对齐 x
    end
    if valign == 0 then
        y = y - t -- 使顶边缘对齐 y
    elseif valign == 1 then
        y = (y - b) - (h / 2) -- 居中
    else
        -- "bottom"
        y = y - b -- 使底边缘对齐 y
    end

    -- 绘制
    local ret, x2, y2 = fr.RenderTextInSpace(text, x, y, 0.5, 1, 0, 0, 0, -1, 0, "", color)
    assert(ret)
    return x2, y2
end

local text_command = {
    ["d"] = function()
        return 255, 255, 255, 1, 1
    end, --default
    ["r"] = function()
        return 255, 130, 130
    end, --red
    ["b"] = function()
        return 130, 130, 255
    end, --blue
    ["c"] = function()
        return 130, 255, 255
    end, --cyan
    ["o"] = function()
        return 255, 255, 130
    end, --orange
    ["g"] = function()
        return 130, 255, 130
    end, --green
    ["y"] = function()
        return 255, 227, 132
    end, --yellow,
    ["p"] = function()
        return 255, 130, 255
    end, --purple
    ["-"] = function()
        return 150, 150, 150
    end, --gray
}

---text内指令实现多颜色，多大小渲染一串字符，仅支持单行渲染
function RenderTTF5(ttfname, format_text, x, y, size, alpha, black, ...)
    size = size * 0.5
    local args = { ... }
    local halign = 0
    local valign = 0
    for _, v in ipairs(args) do
        if v == "center" then
            halign = 1
        elseif v == "right" then
            halign = 2
        elseif v == "vcenter" then
            valign = 1
        elseif v == "bottom" then
            valign = 2
        elseif v == "centerpoint" then
            halign = 1
            valign = 1
        end
    end

    -- 设置字体

    local fr = lstg.FontRenderer
    fr.SetFontProvider(ttfname)

    local init_R, init_G, init_B = 255, 255, 255
    if black then
        init_R, init_G, init_B = 0, 0, 0
    end
    local init_color = Color(alpha, init_R, init_G, init_B)
    local init_size = 1
    local split_str = "§"
    local strs = sp:SplitText(format_text, split_str)
    local x_off = 0
    local l, r, b, t
    local w, h
    local init_A = 1
    fr.SetScale(size * init_size, size * init_size)
    local pure_texts = {}
    for i, v in ipairs(strs) do
        if i == 1 then
            pure_texts[i] = v
        else
            pure_texts[i] = v:sub(2)
        end
    end
    l, r, b, t = fr.MeasureTextBoundary(table.concat(pure_texts, " "))
    w, h = r - l, t - b
    if halign == 0 then
        x = x - l -- 使左边缘对齐 x
    elseif halign == 1 then
        x = (x - l) - (w / 2) -- 居中
    else
        x = x - r -- 使右边缘对齐 x
    end
    if valign == 0 then
        y = y - t - 4 -- 使顶边缘对齐 y
    elseif valign == 1 then
        y = (y - b) - (h / 2) -- 居中
    else
        y = y - b -- 使底边缘对齐 y
    end
    for i, text in ipairs(strs) do
        -- 计算笔触位置
        if i ~= 1 then
            local R, G, B, Ai, sizei = text_command[text:sub(1, 1)]()
            text = " " .. text:sub(2)
            if Ai then
                init_A = Ai
            end
            if sizei then
                init_size = sizei
            end
            if not black then
                if R then
                    init_R, init_G, init_B = R, G, B
                end
            end
            init_color = Color(alpha * init_A, init_R, init_G, init_B)
        end
        fr.SetScale(size * init_size, size * init_size)
        l, r = fr.MeasureTextBoundary(text)
        w = r - l
        -- 绘制
        fr.RenderTextInSpace(text, x + x_off, y, 0.5, 1, 0, 0, 0, -1, 0, "", init_color)
        x_off = x_off + w
    end
end


