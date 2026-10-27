---=====================================
---luastg input
---=====================================

----------------------------------------
---按键状态更新

local KeyState = {}
local KeyStatePre = {}
_G.KeyState = KeyState
_G.KeyStatePre = KeyStatePre
---刷新输入
function GetInput()
    local keys = setting.keys
    local GetKeyState = GetKeyState
    if stage.next_stage then
        KeyStatePre = {}
    else
        -- 刷新KeyStatePre
        for k in pairs(keys) do
            KeyStatePre[k] = KeyState[k]
        end
    end
    if not lstg.tmpvar.lost then
        for k, v in pairs(keys) do
            KeyState[k] = GetKeyState(v)
        end
    end
end

---是否按下
function KeyIsDown(key)
    return KeyState[key]
end

---是否在当前帧按下
function KeyIsPressed(key)
    return KeyState[key] and (not KeyStatePre[key])
end

---是否在当前帧放开
function KeyIsUp(key)
    return KeyStatePre[key] and (not KeyState[key])
end

---将按键二进制码转换为字面值，用于设置界面
function KeyCodeToName()
    local key2name = {}
    --按键code（参见launch和微软文档）作为索引，名称为值
    for k, v in pairs(KEY) do
        key2name[v] = k
    end
    --似乎是按照keycode从0到255重新排列keyname
    for i = 0, 255 do
        key2name[i] = key2name[i] or '?'
    end
    return key2name
end

lstg.GetLastKey()
