---=====================================
---luastg simple log system
---=====================================

----------------------------------------
---simple MessageBox

local ffi = require("ffi")
ffi.cdef [[
    int MessageBoxA(void *w, const char *txt, const char *cap, int type);
]]

---简单的警告弹窗
---@param msg string
function lstg.MsgBoxWarn(msg)
    local ret = ffi.C.MessageBoxA(nil, __UTF8ToANSI(tostring(msg)), __UTF8ToANSI("LuaSTGPlus脚本警告"), 1 + 48)
    if ret == 2 then
        os.exit()
    end
end

function lstg.MsgBoxChoose(msg, func1, func2)
    local ret = ffi.C.MessageBoxA(nil, __UTF8ToANSI(tostring(msg)), __UTF8ToANSI("TouHou Roguelike"), 1 + 48)
    if ret == 1 then
        func1()
    elseif ret == 2 then
        func2()
    end
end

---简单的错误弹窗
---@param msg string
function lstg.MsgBoxError(msg, title, exit)
    local ret = ffi.C.MessageBoxA(nil, __UTF8ToANSI(tostring(msg)), __UTF8ToANSI(tostring(title)), 0 + 16)
    if ret == 1 and exit then
        os.exit()
    end
end
