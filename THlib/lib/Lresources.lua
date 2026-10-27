---=====================================
---luastg resources
---=====================================

----------------------------------------
---脚本载入
local table, string = table, string

local included = {}
local current_script_path = { '' }

function Include(filename)
    filename = tostring(filename)
    if string.sub(filename, 1, 1) == '~' then
        filename = current_script_path[#current_script_path] .. string.sub(filename, 2)
    end
    if not included[filename] then
        local i, j = string.find(filename, '^.+[\\/]+')
        if i then
            table.insert(current_script_path, string.sub(filename, i, j))
        else
            table.insert(current_script_path, '')
        end
        included[filename] = true
        lstg.DoFile(filename)
        current_script_path[#current_script_path] = nil
    end
end

----------------------------------------
--资源载入
local number = "number"
local type = type

local ImageParam = {}
local ImageSize = {}

local FontColor = {}
local ImageColor = {}
local AniColor = {}

local OriginalColor = Color
local FF = 255
local empty = 0
local colorFFFFFFFF = Color(255, 255, 255, 255)
local color0000000 = Color(0, 0, 0, 0)
local color00FFFFFF = Color(0, 255, 255, 255)
local colorFF000000 = Color(255, 0, 0, 0)
---@return lstg.Color
function Color(a, r, g, b)
    if not r then
        return OriginalColor(a)
    else
        if a == FF and r == FF and g == FF and b == FF then
            return colorFFFFFFFF
        elseif a == empty and r == empty and g == empty and b == empty then
            return color0000000
        elseif a == empty and r == FF and g == FF and b == FF then
            return color00FFFFFF
        elseif a == FF and r == empty and g == empty and b == empty then
            return colorFF000000
        else
            return OriginalColor(a, r, g, b)
        end
    end
end

local OriginalLoadImage = LoadImage
function LoadImage(img, tex, x, y, w, h, a, b, rect)
    OriginalLoadImage(img, tex, x, y, w, h, a, b, rect)
    ImageParam[img] = { tex, x, y, w, h, a, b, rect }
    ImageSize[img] = { w, h }--由OLC添加，储存加载的图片的大小
    ImageColor[img] = { "", 255, 255, 255, 255 }
end

local OriginalLoadFont = LoadFont
function LoadFont(font, path, bind_tex, mipmap)
    OriginalLoadFont(font, path, bind_tex, mipmap)
    FontColor[font] = { "", 255, 255, 255, 255 }
end

local OriginalLoadAnimation = LoadAnimation
function LoadAnimation(ani, tex, x, y, w, h, n, m, intv, a, b, rect)
    OriginalLoadAnimation(ani, tex, x, y, w, h, n, m, intv, a, b, rect)
    AniColor[ani] = { "", 255, 255, 255, 255 }
end

local OriginalSetImageState = SetImageState
function SetImageState(img, blend, a, r, g, b)
    local i = ImageColor[img]
    if a == nil then
        if i[1] ~= blend then
            OriginalSetImageState(img, blend)
            i[1] = blend
        end
    elseif type(a) ~= number then
        local A, R, G, B = a:ARGB()
        if A ~= i[2] or R ~= i[3] or G ~= i[4] or B ~= i[5] or i[1] ~= blend then
            OriginalSetImageState(img, blend, a)
            i[1] = blend
            i[2], i[3], i[4], i[5] = A, R, G, B
        end
    else
        if a ~= i[2] or r ~= i[3] or g ~= i[4] or b ~= i[5] or i[1] ~= blend then
            OriginalSetImageState(img, blend, Color(a, r, g, b))
            i[1] = blend
            i[2], i[3], i[4], i[5] = a, r, g, b
        end
    end
end
_G.OriginalSetImageState = OriginalSetImageState

local OriginalSetFontState = SetFontState
function SetFontState(font, blend, a, r, g, b)
    local i = FontColor[font]
    if a == nil then
        if i[1] ~= blend then
            OriginalSetFontState(font, blend)
            i[1] = blend
        end
    elseif type(a) ~= number then
        local A, R, G, B = a:ARGB()
        if A ~= i[2] or R ~= i[3] or G ~= i[4] or B ~= i[5] or i[1] ~= blend then
            OriginalSetFontState(font, blend, a)
            i[1] = blend
            i[2], i[3], i[4], i[5] = A, R, G, B
        end
    else
        if a ~= i[2] or r ~= i[3] or g ~= i[4] or b ~= i[5] or i[1] ~= blend then
            OriginalSetFontState(font, blend, Color(a, r, g, b))
            i[1] = blend
            i[2], i[3], i[4], i[5] = a, r, g, b
        end
    end
end
_G.OriginalSetFontState = OriginalSetFontState

local OriginalSetAnimationState = SetAnimationState
function SetAnimationState(ani, blend, a, r, g, b)
    local i = AniColor[ani]
    if a == nil then
        if i[1] ~= blend then
            OriginalSetAnimationState(ani, blend)
            i[1] = blend
        end
    elseif type(a) ~= number then
        local A, R, G, B = a:ARGB()
        if A ~= i[2] or R ~= i[3] or G ~= i[4] or B ~= i[5] or i[1] ~= blend then
            OriginalSetAnimationState(ani, blend, a)
            i[1] = blend
            i[2], i[3], i[4], i[5] = A, R, G, B
        end
    else
        if a ~= i[2] or r ~= i[3] or g ~= i[4] or b ~= i[5] or i[1] ~= blend then
            OriginalSetAnimationState(ani, blend, Color(a, r, g, b))
            i[1] = blend
            i[2], i[3], i[4], i[5] = a, r, g, b
        end
    end
end
_G.OriginalSetAnimationState = OriginalSetAnimationState

function LoadImageSetCenter(img, tex, x, y, w, h, cx, cy, a, b, rect)
    LoadImage(img, tex, x, y, w, h, a, b, rect)
    SetImageCenter(img, cx, cy)
end--加载图像并设置图像中心

---由OLC添加，获得加载的图片的大小
function GetImageSize(img)
    return unpack(ImageSize[img])
end

local TextureSize = {}--缓存纹理大小
local OriginalLoadTexture = LoadTexture
local OriginalGetTextureSize = GetTextureSize
function LoadTexture(tex, path, mipmap)
    OriginalLoadTexture(tex, path, mipmap)
    TextureSize[tex] = { OriginalGetTextureSize(tex) }
end

function LoadTexture2(tex, path, mipmap)
    LoadTexture(tex, path, mipmap)
    SetTextureSamplerState(tex, "linear+wrap")
end

function GetTextureSize(tex)
    return unpack(TextureSize[tex])
end

function CopyImage(newname, img)
    if ImageParam[img] then
        LoadImage(newname, unpack(ImageParam[img]))
    elseif img then
        error("The image \"" .. img .. "\" can't be copied.")
    else
        error("Wrong argument #2 (expect string get nil)")
    end
end

function LoadImageGroup(prefix, texname, x, y, w, h, cols, rows, a, b, rect)
    for i = 0, cols * rows - 1 do
        LoadImage(prefix .. (i + 1), texname, x + w * (i % cols), y + h * (int(i / cols)), w, h, a or 0, b or 0, rect or false)
    end
end

function LoadImageFromFile(teximgname, filename, mipmap, a, b, rect)
    LoadTexture(teximgname, filename, mipmap)
    local w, h = GetTextureSize(teximgname)
    LoadImage(teximgname, teximgname, 0, 0, w, h, a or 0, b or 0, rect)
end

function LoadAniFromFile(texaniname, filename, mipmap, n, m, intv, a, b, rect)
    LoadTexture(texaniname, filename, mipmap)
    local w, h = GetTextureSize(texaniname)
    LoadAnimation(texaniname, texaniname, 0, 0, w / n, h / m, n, m, intv, a, b, rect)
end

function LoadImageGroupFromFile(texaniname, filename, mipmap, n, m, a, b, rect)
    LoadTexture(texaniname, filename, mipmap)
    local w, h = GetTextureSize(texaniname)
    LoadImageGroup(texaniname, texaniname, 0, 0, w / n, h / m, n, m, a, b, rect)
end

_TTF_SIZES = {}

function LoadTTF(ttfname, filename, size)
    lstg.LoadTTF(ttfname, filename, 0, size)
    _TTF_SIZES[ttfname] = size
end

----------------------------------------
---资源判断和枚举

local ENUM_RES_TYPE = { tex = 1, img = 2, ani = 3, bgm = 4, snd = 5, psi = 6, fnt = 7, ttf = 8, fx = 9 }

function CheckRes(typename, resname)
    local t = ENUM_RES_TYPE[typename]
    if t == nil then
        error('Invalid resource type name.')
    else
        return lstg.CheckRes(t, resname)
    end
end

function EnumRes(typename)
    local t = ENUM_RES_TYPE[typename]
    if t == nil then
        error('Invalid resource type name.')
    else
        return lstg.EnumRes(t)
    end
end
function EnumRes2(typename)
    local t = {}
    local a, b = {}, {}
    a, b = EnumRes(typename)
    if a then
        for _, p in pairs(a) do
            table.insert(t, p)
        end
    end
    if b then
        for _, p in pairs(b) do
            table.insert(t, p)
        end
    end
    return t
end

function FileExist(filename)
    return lstg.FileManager.FileExist(filename, true)
end
