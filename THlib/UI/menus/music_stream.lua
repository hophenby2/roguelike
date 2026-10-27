---@class Music
local M = plus.Class()

StreamMusic = M

function M:init(name)
    self.timer = 0
    self.real_timer = 0
    self.frameEvent = ext.eventListener
    self.eventgroup = "frameEvent@before"
    self.task = {}

    self:SetName(name)
    self:SetVolume(1)
    self:SetStartTime(0)
    self:SetState("stopped")
end

function M:SetName(name)
    local oldname = self.name
    self.name = name
    self.eventname = ("PlayMusic:%s"):format(self.name)
    self.frameEvent:remove(self.eventgroup, ("task:%s"):format(oldname))
    self.frameEvent:addEvent(self.eventgroup, ("task:%s"):format(name), -1, function()
        task.Do(self)
    end)
end

---设置音量
function M:SetVolume(vol)
    self.vol = vol or self.vol
    SetBGMVolume2(self.name, self.vol)
end

---设置开始时间
function M:SetStartTime(time)
    self.start_time = time or self.start_time
end

---获取状态
function M:GetState()
    return self.state
end
function M:SetState(state)
    self.state = state
end

function M:GetTimer()
    return self.timer
end

function M:GetRealTimer()
    return self.real_timer
end

---设置timer，timer和real_timer是联系在一起的
function M:SetTimer(timer)
    timer = int(timer)
    local btimer = self:GetTimer()
    self.timer = timer
    self.real_timer = self.real_timer + (timer - btimer)
    if self:GetState() == "playing" then
        ext.PlayMusic(self.name, self.vol, self.timer / 60)
    end
end

---设置real_timer，timer和real_timer是联系在一起的
function M:SetRealTimer(real_timer)
    real_timer = int(real_timer)
    local brealtimer = self:GetRealTimer()
    self.real_timer = real_timer
    self.timer = self.timer + (real_timer - brealtimer)
    if self:GetState() == "playing" then
        ext.PlayMusic(self.name, self.vol, self.timer / 60)
    end
end

---普通播放
function M:Play(volume, start_time)
    self:SetVolume(volume)
    self:SetStartTime(start_time)
    self:SetState("playing")
    ext.PlayMusic(self.name, self.vol, self.start_time)
    self.timer = int(self.start_time * 60)
    self.real_timer = 0
    self.frameEvent:addEvent(self.eventgroup, self.eventname, 0, function()
        self.timer = self.timer + 1
        self.real_timer = self.real_timer + 1
    end)
end

---普通停止
function M:Stop()
    if self:GetState() == "playing" then
        StopMusic2(self.name)
        self:SetState("stopped")
        self.real_timer = 0
        self.timer = 0
        self.frameEvent:remove(self.eventgroup, self.eventname)
    end

end

---普通暂停
function M:Pause()
    if self:GetState() == "playing" then
        self:SetState("paused")
        PauseMusic2(self.name)
        self.frameEvent:remove(self.eventgroup, self.eventname)
    end
end

---普通继续
function M:Resume()
    if self:GetState() == "paused" then
        self:SetState("playing")
        ResumeMusic2(self.name)
        self.frameEvent:addEvent(self.eventgroup, self.eventname, 0, function()
            self.timer = self.timer + 1
            self.real_timer = self.real_timer + 1
        end)
    end
end

function M:FadePlay(time, volume, start_time)
    volume = volume or 1
    self:SetVolume(0)
    self:SetStartTime(start_time)
    self:SetState("playing")
    task.Clear(self)
    task.New(self, function()
        ext.PlayMusic(self.name, 0, self.start_time)
        self.timer = int(self.start_time * 60)
        self.real_timer = 0
        for i = 1, time do
            self:SetVolume(i / time * volume)
            task.Wait()
        end
    end)
    self.frameEvent:addEvent(self.eventgroup, self.eventname, 0, function()
        self.timer = self.timer + 1
        self.real_timer = self.real_timer + 1
    end)
end

function M:FadeStop(time)

    if self:GetState() == "playing" then
        time = time or 30
        local volume = self.vol
        task.Clear(self)
        task.New(self, function()
            for i = time - 1, 0, -1 do
                self:SetVolume(i / time * volume)
                task.Wait()
            end
            ext.StopMusic(self.name)
            self:SetState("stopped")
            self.real_timer = 0
            self.timer = 0
            self.frameEvent:remove(self.eventgroup, self.eventname)
        end)
    end

end

