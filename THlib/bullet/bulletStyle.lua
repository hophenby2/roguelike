---@class bulletStyle
bulletStyle = Class(object)
function bulletStyle:frame()
    if not self.stay then
        if not (self._forbid_ref) then
            --by OLC，修正了defaul action死循环的问题
            self._forbid_ref = true
            self.logclass.frame(self)
            self._forbid_ref = nil
        end
    else
        self.x = self.x - self.vx
        self.y = self.y - self.vy
        self.rot = self.rot - self.omega
    end
    if self.timer == self.fogtime then
        self.class = self.logclass
        self.layer = self._layer - self.imgclass.size * 0.001 + self._index * 0.00001
        if self.stay then
            self.timer = -1
        end
    end
end
function bulletStyle:del()
    New(bubble2, 'preimg' .. self._index, self.x, self.y, self.dx, self.dy, 11, self.imgclass.size, 0,
            Color(0xFFFFFFFF), Color(0xFFFFFFFF), self.layer, 'mul+add')
end
function bulletStyle:kill()
    bulletStyle.del(self)
    BulletBreak_Table:New(self.x, self.y, self._index)
    if GetnObj() >= 5000 then
        item.drop_point.collect()
    else
        New(item.drop_point, self.x, self.y)
    end

end
function bulletStyle:render()
    SetImageState('preimg' .. self._index, self._blend, 255 * self.timer / self.fogtime, 255, 255, 255)
    Render('preimg' .. self._index, self.x, self.y, self.rot, ((self.fogtime - self.timer) / self.fogtime * 3 + 1) * self.imgclass.size)
end
bulletStyles = {}

local path = "assets\\bullet\\img\\"
LoadTexture("bullet1", path .. "bullet1.png", true)
LoadTexture("bullet2", path .. "bullet2.png", true)
LoadTexture("bullet3", path .. "bullet3.png", true)
LoadTexture("bullet4", path .. "bullet4.png", true)
LoadTexture("bullet5", path .. "bullet5.png", true)

do
    local other_class = {}
    function other_class.render(blend)
        return function(self)
            SetImageState('fade_' .. self.img, blend, 255 * self.timer / self.fogtime, 255, 255, 255)
            Render('fade_' .. self.img, self.x, self.y, self.rot, self.hscale * ((self.fogtime - self.timer) / self.fogtime + 1))
        end
    end
    function other_class.del(blend)
        return function(self)
            New(bubble2, 'fade_' .. self.img, self.x, self.y, self.dx, self.dy, 11, 1, 0, Color(0xFFFFFFFF), Color(0x00FFFFFF), self.layer, blend)
        end
    end
    function other_class.kill(blend)
        return function(self)
            New(bubble2, 'fade_' .. self.img, self.x, self.y, self.dx, self.dy, 11, 1, 0, Color(0xFFFFFFFF), Color(0x00FFFFFF), self.layer, blend)
            BulletBreak_Table:New(self.x, self.y, self._index)
            New(item.drop_point, self.x, self.y)
        end
    end
    local function init(img, colorful, blend)
        return function(self, index)
            self.img = img .. (colorful and int(index) or math.ceil(index / 2))
            self._blend = blend or self._blend
        end
    end

    local function DeFineBulletStyle(size, is_ani, DIY_init, used_img, colorful, blend, set_other)
        local u = Class(bulletStyle)
        u.size = size
        u.init = DIY_init or init(used_img, colorful, blend)
        if is_ani then
            u.RenderFunc = function(img, x, y, rot, hscale, vscale, _, ani)
                RenderAnimation(img, ani, x, y, rot, hscale, vscale)
            end
            u.SetColorFunc = SetAnimationState
        else
            u.RenderFunc = Render
            u.SetColorFunc = SetImageState
        end
        if set_other then
            u.render = other_class.render(blend)
            u.del = other_class.del(blend)
            u.kill = other_class.kill(blend)
        end
        table.insert(bulletStyles, u)
        return u
    end
    sakura = DeFineBulletStyle(0.4, false, function(self)
        self.img = 'cherry_bullet'
        self.a = 2
        self.b = 2
        self.hscale = 0.6
        self.vscale = 0.6
        self._blend = "mul+add"
    end)
    flower2 = DeFineBulletStyle(1.6, false, function(self)
        self.img = 'cherry_bullet2'
        self.a = 2
        self.b = 2
        self.hscale = 0.6
        self.vscale = 0.6
        self._blend = "mul+add"
    end)
    table.remove(bulletStyles)

    local FormerImg = EnumRes2("img")
    for i = 1, 8 do
        LoadImage('preimg' .. (i * 2 - 1), 'bullet1', 160, 64 * (i - 1), 64, 64)
        LoadImage('preimg' .. (i * 2), 'bullet1', 160 + 64, 64 * (i - 1), 64, 64)
    end
    LoadImageGroup('arrow_big', 'bullet2', 160, 0, 32, 32, 1, 16, 2.5, 2.5)
    LoadImageGroup('arrow_big_b', 'bullet2', 192, 0, 32, 32, 1, 16, 2.5, 2.5)
    LoadImageGroup('arrow_big_c', 'bullet3', 0, 0, 50, 36, 1, 16, 2.5, 2.5)
    for i = 1, 16 do
        SetImageCenter('arrow_big_c' .. i, 20, 18)
    end
    arrow_big = DeFineBulletStyle(0.6, false, nil, "arrow_big", true)
    arrow_big_b = DeFineBulletStyle(0.61, false, nil, "arrow_big_b", true)
    arrow_big_c = DeFineBulletStyle(0.59, false, nil, "arrow_big_c", true)

    LoadImageGroup('arrow_mid', 'bullet3', 50, 0, 82, 36, 1, 16, 2.5, 2.5)
    for i = 1, 16 do
        SetImageCenter('arrow_mid' .. i, 66, 18)
    end
    arrow_mid = DeFineBulletStyle(0.61, false, nil, "arrow_mid", true)

    LoadImageGroup('arrow_small', 'bullet2', 32, 0, 32, 32, 1, 16, 2.5, 2.5)
    LoadImageGroup('arrow_small_b', 'bullet3', 133, 0, 56, 36, 1, 16, 2.5, 2.5)
    for i = 1, 16 do
        SetImageCenter('arrow_small_b' .. i, 32, 18)
    end
    arrow_small = DeFineBulletStyle(0.407, false, nil, "arrow_small", true)
    arrow_small_b = DeFineBulletStyle(0.406, false, nil, "arrow_small_b", true)

    LoadTexture("gun", path .. "gun.png", true)
    for i = 1, 16 do
        LoadAnimation("gun_bullet" .. i, "gun", 0, (i - 1) * 48, 48, 48, 3, 1, 4, 2.5, 2.5)
        SetAnimationScale("gun_bullet" .. i, 0.5)
    end
    gun_bullet = DeFineBulletStyle(0.4, true, nil, "gun_bullet", true)

    LoadImageGroup('butterfly', 'bullet4', 832, 0, 32, 32, 1, 8, 4, 4)
    butterfly = DeFineBulletStyle(0.7, false, nil, "butterfly")

    LoadImageGroup('square', 'bullet2', 0, 0, 32, 32, 1, 16, 3, 3)
    square = DeFineBulletStyle(0.8, false, nil, "square", true)

    LoadImageGroup('mildew', 'bullet1', 131, 0, 32, 32, 1, 16, 2, 2)
    mildew = DeFineBulletStyle(0.401, false, nil, "mildew", true)

    LoadImageGroup('ellipse', 'bullet1', 81, 0, 48, 32, 1, 16, 4.5, 4.5)
    ellipse = DeFineBulletStyle(0.701, false, nil, "ellipse", true)

    LoadImageGroup('star_small', 'bullet3', 581, 0, 36, 36, 1, 16, 3, 3)
    star_small = DeFineBulletStyle(0.5, false, nil, "star_small", true)
    LoadImageGroup('star_big', 'bullet5', 1025, 190, 64, 64, 16, 1, 5.5, 5.5)
    star_big = DeFineBulletStyle(0.998, false, nil, "star_big", true)

    LoadImageGroup('ball_small', 'bullet1', 0, 0, 32, 32, 1, 16, 2, 2)
    ball_small = DeFineBulletStyle(0.402, false, nil, "ball_small", true)

    LoadImageGroup('ball_mid', 'bullet3', 191, 0, 36, 36, 1, 16, 4, 4)
    LoadImageGroup('ball_mid_c', 'bullet3', 239, 0, 40, 36, 1, 16, 4, 4)
    ball_mid = DeFineBulletStyle(0.75, false, nil, "ball_mid", true)
    ball_mid_c = DeFineBulletStyle(0.752, false, nil, "ball_mid_c", true)

    LoadImageGroup('ball_big', 'bullet5', 0, 190, 64, 64, 16, 1, 8, 8)
    ball_big = DeFineBulletStyle(1, false, nil, "ball_big", true)

    for i = 1, 8 do
        LoadImage('ball_huge' .. (i * 2 - 1), 'bullet3', 768, 128 * (i - 1), 128, 128, 13.5, 13.5)
        LoadImage('ball_huge' .. (i * 2), 'bullet3', 768 + 128, 128 * (i - 1), 128, 128, 13.5, 13.5)
    end
    for i = 1, 16 do
        CopyImage("fade_ball_huge" .. i, "ball_huge" .. i)
    end
    ball_huge = DeFineBulletStyle(2, false, nil, "ball_huge", true, "mul+add", true)

    LoadImageGroupFromFile("ball_light", path .. "ball_light.png", true, 4, 4, 11.5, 11.5)
    for i = 1, 16 do
        CopyImage("fade_ball_light" .. i, "ball_light" .. i)
    end
    ball_light = DeFineBulletStyle(2, false, nil, "ball_light", true, "mul+add", true)

    LoadImageGroup('grain_a', 'bullet2', 128, 0, 32, 32, 1, 16, 2.5, 2.5)
    LoadImageGroup('grain_b', 'bullet2', 224, 0, 32, 32, 1, 16, 2.5, 2.5)
    LoadImageGroup('grain_c', 'bullet2', 96, 0, 32, 32, 1, 16, 2.5, 2.5)
    LoadImageGroup('grain_d', 'bullet2', 64, 0, 32, 32, 1, 16, 2.5, 2.5)
    grain_a = DeFineBulletStyle(0.403, false, nil, "grain_a", true)
    grain_b = DeFineBulletStyle(0.404, false, nil, "grain_b", true)
    grain_c = DeFineBulletStyle(0.405, false, nil, "grain_c", true)
    grain_d = DeFineBulletStyle(0.406, false, nil, "grain_d", true)

    LoadImageGroupFromFile("knife", path .. "knife.png", true, 1, 16, 4, 4)
    LoadImageGroup('knife_b', 'bullet5', 0, 392, 102, 44, 16, 1, 3.5, 3.5)
    knife = DeFineBulletStyle(0.754, false, nil, "knife", true)
    knife_b = DeFineBulletStyle(0.755, false, nil, "knife_b", true)

    for i = 1, 8 do
        LoadAnimation("music" .. i, "bullet4", (i - 1) * 102, 480,
                96, 64, 1, 3, 8, 4, 4)
        SetAnimationCenter("music" .. i, 51, 32)
        SetAnimationScale("music" .. i, 0.5)
    end
    music = DeFineBulletStyle(0.8, true, nil, "music")

    for i = 1, 8 do
        LoadAnimation("water_drop" .. (-1 + i * 2), "bullet4", (i - 1) * 96, 0,
                96, 60, 1, 4, 4, 4, 4)
        SetAnimationCenter("water_drop" .. (-1 + i * 2), 60, 30)
        SetAnimationScale("water_drop" .. (-1 + i * 2), 0.5)
        LoadAnimation("water_drop" .. (i * 2), "bullet4", (i - 1) * 96, 60 * 4,
                96, 60, 1, 4, 4, 4, 4)
        SetAnimationCenter("water_drop" .. (i * 2), 60, 30)
        SetAnimationScale("water_drop" .. (i * 2), 0.5)
    end
    water_drop = DeFineBulletStyle(0.702, true, nil, "water_drop", true, "mul+add")

    LoadImageGroup('diamond', 'bullet5', 1056, 0, 45, 30, 16, 1, 2.5, 2.5)
    diamond = DeFineBulletStyle(0.406, false, nil, "diamond", true)

    LoadImageGroup('silence', 'bullet5', 0, 446, 78, 40, 16, 1, 4.5, 4.5)
    silence = DeFineBulletStyle(0.8, false, nil, "silence", true)

    LoadImageGroup('heart', 'bullet5', 0, 66, 64, 64, 16, 1, 9, 9)
    heart = DeFineBulletStyle(1, false, nil, "heart", true)
    do
        LoadImage("money11", "bullet4", 404, 676, 42, 42, 4, 4)
        LoadImage("money15", "bullet4", 404 + 50, 676, 42, 42, 4, 4)
        LoadImage("money13", "bullet4", 404 + 100, 676, 42, 42, 4, 4)
        LoadImage("money12", "bullet4", 404, 676 + 50, 42, 42, 4, 4)
        LoadImage("money16", "bullet4", 404 + 50, 676 + 50, 42, 42, 4, 4)
        LoadImage("money14", "bullet4", 404 + 100, 676 + 50, 42, 42, 4, 4)
        LoadImage("money1", "bullet4", 404, 676, 42, 42, 4, 4)
        LoadImage("money2", "bullet4", 404 + 50, 676, 42, 42, 4, 4)
        LoadImage("money3", "bullet4", 404 + 100, 676, 42, 42, 4, 4)
        LoadImage("money4", "bullet4", 404, 676 + 50, 42, 42, 4, 4)
        LoadImage("money5", "bullet4", 404 + 50, 676 + 50, 42, 42, 4, 4)
        LoadImage("money6", "bullet4", 404 + 100, 676 + 50, 42, 42, 4, 4)
        LoadImage("money7", "bullet4", 404 + 100, 676, 42, 42, 4, 4)
        LoadImage("money8", "bullet4", 404, 676 + 50, 42, 42, 4, 4)
        LoadImage("money9", "bullet4", 404 + 50, 676 + 50, 42, 42, 4, 4)
        LoadImage("money10", "bullet4", 404 + 100, 676 + 50, 42, 42, 4, 4)
        LoadImage("money_big11", "bullet4", 7, 679, 86, 86, 8, 8)
        LoadImage("money_big15", "bullet4", 7 + 100, 679, 86, 86, 8, 8)
        LoadImage("money_big13", "bullet4", 7 + 200, 679, 86, 86, 8, 8)
        LoadImage("money_big12", "bullet4", 7, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big16", "bullet4", 7 + 100, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big14", "bullet4", 7 + 200, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big1", "bullet4", 7, 679, 86, 86, 8, 8)
        LoadImage("money_big2", "bullet4", 7 + 100, 679, 86, 86, 8, 8)
        LoadImage("money_big3", "bullet4", 7 + 200, 679, 86, 86, 8, 8)
        LoadImage("money_big4", "bullet4", 7, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big5", "bullet4", 7 + 100, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big6", "bullet4", 7 + 200, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big7", "bullet4", 7 + 200, 679, 86, 86, 8, 8)
        LoadImage("money_big8", "bullet4", 7, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big9", "bullet4", 7 + 100, 679 + 100, 86, 86, 8, 8)
        LoadImage("money_big10", "bullet4", 7 + 200, 679 + 100, 86, 86, 8, 8)
    end

    ---注意有些颜色是重复的
    money = DeFineBulletStyle(0.753, false, nil, "money", true)
    ---注意有些颜色是重复的
    money_big = DeFineBulletStyle(0.743, false, nil, "money_big", true)

    local NowImg = EnumRes2("img")
    for _, img in ipairs(NowImg) do
        SetImageScale(img, 0.5)
    end
    for i = 1, 8 do
        SetImageScale("butterfly" .. i, 1)
    end
    for i = 1, 16 do
        SetImageScale("ellipse" .. i, 0.75)
        SetImageScale("knife_b" .. i, 0.375)
        SetImageScale("arrow_mid" .. i, 0.375)
    end
    for _, img in ipairs(FormerImg) do
        SetImageScale(img, 1)
    end
end
---bullet_style
--------------------------------------------------------------
COLOR = {
    DEEP_RED = 1,
    RED = 2,
    DEEP_PURPLE = 3,
    PURPLE = 4,
    DEEP_BLUE = 5,
    BLUE = 6,
    ROYAL_BLUE = 7,
    CYAN = 8,
    DEEP_GREEN = 9,
    GREEN = 10,
    CHARTREUSE = 11,
    YELLOW = 12,
    GOLDEN_YELLOW = 13,
    ORANGE = 14,
    DEEP_GRAY = 15,
    GRAY = 16
}