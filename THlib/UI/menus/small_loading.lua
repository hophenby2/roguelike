SMALL_LOADING = {}
local function _t(str)
    return i18n("sth", str) or ""
end
local string = string
local clock = os.clock

local Color = Color
--0.016666666666
local time = 1 / 60

local Text = TIP

local stage_init = stage.New('small_loading', false, true)
function stage_init:init()
    math.randomseed(os.time())
    self.start_time = clock()
    self.res = SMALL_LOADING
    self.index = 1
    self.maxindex = #self.res
    self.textindex = math.random(1, #Text)
    self.text = Text[self.textindex]
    self.settime = self.timer
    self.alpha = 1
    self.jump = false
    task.New(self, function()
        while not self.jump do
            task.Wait()
        end
        SMALL_LOADING = {}--清空smallloading表
        --   Print("\n\n\n\n" .. (clock() - self.start_time) .. "\n\n\n\n")
        mask_fader:Do("close")
        task.Wait(15)
        stage.next_stage = stage.next_next_stage
        stage.next_next_stage = nil
    end)
end
function stage_init:frame()
    self.timer = int((clock() - self.start_time) * 60)
    if self.timer - self.settime > 150 then
        local t = self.textindex
        while self.textindex == t do
            self.textindex = math.random(1, #Text)
        end
        self.text = Text[self.textindex]
        self.settime = self.timer
    end
    if self.index > self.maxindex then
        self.jump = true
    elseif not self.jump then
        local resFunc
        local start_time, end_time = clock(), clock()
        while end_time - start_time <= time do
            if self.index > self.maxindex then
                break
            end
            resFunc = self.res[self.index]
            if resFunc then
                resFunc()
            end
            self.index = self.index + 1
            end_time = clock()
        end
    end
end
function stage_init:render()
    if self.stop_render then
        return
    end
    local length = min(self.index / self.maxindex, 1)
    local Y = 270
    local x = 480
    local w = 350
    local h = 14
    local x1, x2 = x - w / 2, x + w / 2
    SetImageState("white", "", 255 * self.alpha, 255, 255, 255)
    RenderRect("white", x1 - 1, x2 + 1, Y - h / 2 - 1, Y + h / 2 + 1)
    SetImageState("white", "", 255 * self.alpha, 0, 0, 0)
    RenderRect("white", x1, x2, Y - h / 2, Y + h / 2)
    SetImageState("white", "",
            Color(180 * self.alpha, 255 - 155 * length, 255 * length, 0 + 100 * length))
    RenderRect("white", x1, x1 + length * w, Y - h / 2, Y + h / 2)
    ui:RenderText("title", ("%0.2f%%"):format(length * 100), x, Y, 0.85,
            Color(255 * self.alpha, 255 * length, 255 - 28 * length, 100 + 32 * length), "centerpoint")
    ui:RenderText("title", _t("savingView") .. string.rep(".", int(self.timer / 20 % 6) + 1),
            480, Y - 50, 1, Color(self.alpha * 255, 255, 227, 132), "centerpoint")
    ui:RenderText("small_text", "Tips : " .. self.text,
            480, Y - 90, 1.15, Color(self.alpha * 255, 250, 128, 114 + 50 * sin(self.timer * 2)), "centerpoint")
end