--======================================
--THlib se
--======================================

----------------------------------------
---音效
--修正的音量系统
--！警告：该修正方法有问题

local soundVolume = {
    bonus = 0.6, bonus2 = 0.6, boon00 = 0.9, boon01 = 0.7,
    cancel00 = 0.4, cardget = 0.8, cat00 = 0.55,
    ch00 = 0.9, ch02 = 1,
    don00 = 0.85, damage00 = 0.35, damage01 = 0.5,
    enep00 = 0.35, enep02 = 0.45, enep01 = 0.6, explode = 0.4, extend = 0.6,
    graze = 0.4, gun00 = 0.6, invalid = 0.8, item00 = 0.32,
    kira00 = 0.1, kira01 = 0.1, kira02 = 0.1,
    lazer00 = 0.1, lazer01 = 0.1, lazer02 = 0.1,
    lgods1 = 0.6, lgods2 = 0.3, lgods3 = 0.6, lgods4 = 0.6, lgodsget = 0.2,
    msl = 0.37, msl2 = 0.37, nep00 = 0.5, nodamage = 0.5,
    ok00 = 0.4, option = 0.7, pause = 0.5, pldead00 = 0.7, plst00 = 0.27,
    power0 = 0.7, power02 = 0.7, power1 = 0.6,
    powerup = 0.6, powerup1 = 0.55,
    select00 = 0.4, slash = 0.45,
    tan00 = 0.1, tan01 = 0.1, tan02 = 0.1,
    timeout = 0.6, timeout2 = 0.7, water = 0.6,
    piyo = 0.6, ufo = 0.8, ufoalert = 0.5, changeitem = 0.2,
}

---@param name string
---@param vol number
---@param pan number
---@param sndflag boolean
function PlaySound(name, vol, pan)
    if lstg.tmpvar and lstg.tmpvar.lost then
        return
    end
    local v
    if not vol then
        v = soundVolume[name]
    else
        v = vol
    end
    lstg.PlaySound(name, v or 1, (pan or 0) / 1024)
end

