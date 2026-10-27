local lib = stage_lib
local servant = _editor_class.SimpleServant
local class = SceneClass[4]
local HP = lib.GetHP
local function _t(str)
    return i18n("scene4", str) or ""
end
local function name(str)
    return i18n("bossname", str)
end

lib.NewNodeEvent(class, 21, 1, 0, 4, function(var)
    var.stop_getting = true
    local list = stage_lib.GetStoreAddition(5)
    local j = 1
    local c = (#list - 1) / 2
    for k = -c, c do
        stage_lib.NewStoreBubble(k * 80, 120, list[j], function(self)
            local _j = j
            if _j % 2 == 0 then
                task.New(self, function()
                    while true do
                        self.y = 160 * cos(self.timer * (_j * 0.2 + 0.4))
                        task.Wait()
                    end
                end)
            end
        end)
        j = j + 1
    end
    New(tasker2, function()
        while true do
            NewSimpleBullet(ball_mid, 4, -345, 0,
                    stage_lib.GetValue(2, 3, 4, 12), 0)
            PlaySound("tan00")
            task.Wait(stage_lib.GetValue(18, 12, 8, 2))
        end
    end)
end, _t("到得了的彼岸"))
lib.NewNodeEvent(class, 22, 1, 0, 4, function(var)
    var.stop_getting = true

    local lists = {}
    for y = 2, 4 do
        local addition = stage_lib.GetStoreAddition(1, y - 1, y, lists)[1]
        stage_lib.NewStoreBubble(0, (y - 2.5) * 120 + 30, addition, function(self)
            local _j = y
            task.New(self, function()
                while true do
                    self.x = 200 * cos(self.timer * (_j * 0.2 + 0.4))
                    task.Wait()
                end
            end)
        end)
        table.insert(lists, addition)
    end
    New(tasker2, function()
        while true do
            for y = -1, 1 do
                NewSimpleBullet(ball_mid, 6 + y, 345, y * 120 + 30,
                        stage_lib.GetValue(2, 3, 4, 12), 180)
            end
            PlaySound("tan00")
            task.Wait(stage_lib.GetValue(18, 12, 8, 2))
        end
    end)
end, _t("到不了的彼岸"))
lib.NewNodeEvent(class, 23, 1, 0, 4, function(var)
    local list = stage_lib.GetStoreAddition(5)
    local j = 1
    local c = (#list - 1) / 2
    local t = { "l", "r", "b", "t" }
    local offset = { x = 32, y = 32 }
    for k = -c, c do
        stage_lib.NewStoreBubble(k * 80, 120, list[j], function(self)
            local v = stage_lib.GetValue(1, 1.2, 1.5, 5)
            self.vx = 3 * cos(j * 90 + 45) * v
            self.vy = 2 * sin(j * 90 + 45) * v
            task.New(self, function()
                while true do
                    object.ReBound(self, t, offset, true)
                    task.Wait()
                end
            end)
        end)
        j = j + 1
    end
end, _t("空谷传响，哀转久绝"))
lib.NewNodeEvent(class, 24, 1, 0, 4, function(var)
    var.stop_getting = true
    local list = stage_lib.GetStoreAddition(10)
    New(tasker2, function()
        local iv = stage_lib.GetValue(2, 3, 4, 12)
        local it = max(1, stage_lib.GetValue(10, 8, 5, -2))
        local j = 0
        while true do
            if j % 25 == 1 and #list > 0 then
                local id = sp:TweakValue(math.ceil(j / 25), #list, 1)
                local b = stage_lib.NewStoreBubble(ran:Float(-280, 280), 285, list[id], function(self)
                    for i = #list, 1, -1 do
                        local a = list[i]
                        if a == self.addition then
                            table.remove(list, i)
                        end
                    end
                    self.bound = false
                    self.vy = -iv
                    task.New(self, function()
                        task.Wait(15)
                        self.bound = true
                    end)
                end)
                b.delFunc = function(self)
                    table.insert(list, self.addition)
                end
            end
            NewSimpleBullet(grain_a, 6, ran:Float(-320, 320), 256, iv, -90)
            task.Wait(it)
            j = j + 1
            iv = stage_lib.GetValue(2, 3, 4, 12, var.chaos + j)
            it = max(1, stage_lib.GetValue(10, 8, 5, -2, var.chaos + j))
        end
    end)
end, _t("天上的道具不说话"))
lib.NewNodeEvent(class, 25, 1, 0, 4, function(var)
    local list = stage_lib.GetStoreAddition(5)
    local j = 1
    local c = (#list - 1) / 2
    for k = -c, c do
        stage_lib.NewStoreBubble(k * 150, -200, list[j], nil, function(self)
            local n = int(stage_lib.GetValue(28, 34, 50, 150))
            local vn = int(stage_lib.GetValue(1, 3, 5, 21))
            local iv = stage_lib.GetValue(2, 1.5, 0.9, 0.2)
            local vindex = stage_lib.GetValue(0.3, 0.4, 0.5, 1.8)
            for a in sp.math.AngleIterator(-90, n) do
                for v = 0, vn do
                    local b = NewSimpleBullet(ball_mid, 16, self.x, self.y, iv + v * vindex, a)
                    b.fogtime = 60
                    b.colli = false
                    task.New(b, function()
                        b.colli = true
                    end)
                end
            end
            PlaySound("tan00")
        end)
        j = j + 1
    end
end, _t("地上的道具想爆炸"))
lib.NewNodeEvent(class, 26, 1, 0, 5, function(var)
    local list = stage_lib.GetBonusAddition(3)

    local index = stage_lib.GetValue(0.4, 0.5, 0.6, 1)
    local v = 6
    local vindex = stage_lib.GetValue(0.2, 0.4, 0.6, 1)
    stage_lib.NewBonusBubble(0, 120, list[1], function(self)
        task.New(self, function()
            local k = 0
            while true do
                for a in sp.math.AngleIterator(index * k * k, 3) do
                    Create.bullet_accel(self.x + cos(a) * 45, self.y + sin(a) * 45, grain_a,
                            6, v * vindex, v, a)
                    PlaySound("tan00")
                end
                k = k + 1
                task.Wait(3)
            end
        end)
    end, function()
        stage_lib.NewBonusBubble(0, -120, list[2], function(self)
            task.New(self, function()
                local k = 0
                while true do
                    for a in sp.math.AngleIterator(180 - k * k * index, 3) do
                        Create.bullet_accel(self.x + cos(a) * 45, self.y + sin(a) * 45, grain_a,
                                6, v * vindex, v, a)
                        PlaySound("tan00")
                    end
                    k = k + 1
                    task.Wait(3)
                end
            end)
        end, function()
            stage_lib.NewBonusBubble(0, 120, list[3], function(self)
                task.New(self, function()
                    local k = 0
                    while true do
                        for a in sp.math.AngleIterator(k * k * index, 6) do
                            Create.bullet_accel(self.x + cos(a) * 45, self.y + sin(a) * 45, grain_a,
                                    6, v * vindex, v, a)
                            PlaySound("tan00")
                        end
                        k = k + 1
                        task.Wait(3)
                    end
                end)
            end, function()
            end)
        end)
    end)
end, _t("波与粒的道具"))
