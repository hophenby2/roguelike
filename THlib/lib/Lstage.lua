--======================================
--luastg stage
--======================================

----------------------------------------
--单关卡

---@class stage
stage = { stages = {} }

function stage:init()
end
function stage:frame()
end
function stage:render()
end
function stage:del()
end

---@return stage
function stage.New(stage_name, as_entrance, is_menu)
    local result = {
        init = stage.init,
        del = stage.del,
        render = stage.render,
        frame = stage.frame,
    }
    setmetatable(result, { __index = stage })
    if as_entrance then
        stage.next_stage = result
    end
    result.is_menu = is_menu
    result.stage_name = tostring(stage_name)
    stage.stages[stage_name] = result
    return result
end

function stage.SetTimer(t)
    stage.current_stage.timer = t - 1
end

function stage.QuitGame()
    lstg.quit_flag = true
end

LoadImageFromFile("stage_clear", "assets\\UI\\stage_clear.png")
SetImageCenter("stage_clear", 256, 256)

local stage_clear = Class(object)
stage.stage_clear_object = stage_clear
function stage_clear:init(score)
    self.score = score
    lstg.var.score = lstg.var.score + score
    self.alph = 0
end
function stage_clear:frame()
    if self.timer <= 30 then
        self.alph = self.timer / 30
    end
    if self.timer > 90 then
        self.alph = 1 - (self.timer - 90) / 30
    end
    if self.timer >= 120 then
        Del(self)
    end
end
function stage_clear:render()
    SetViewMode "world"
    local alpha = self.alph
    ui:RenderText("title", self.score, 0, 0, 1.1,
            Color(alpha * 255, 255, 255, 255), "centerpoint")
    SetImageState("stage_clear", "", alpha * 255, 255, 255, 255)
    Render("stage_clear", 0, 0, 0, 0.5)

end
