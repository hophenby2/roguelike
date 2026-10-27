---luastg+ 专用强化脚本库
---该脚本库完全独立于lstg的老lua代码
---所有功能函数暴露在全局plus表中
---@author CHU
plus = {}

lstg.DoFile("THlib\\plus\\Utility.lua")
lstg.DoFile("THlib\\plus\\NativeAPI.lua")
lstg.DoFile("THlib\\plus\\IO.lua")
lstg.DoFile("THlib\\plus\\Replay.lua")