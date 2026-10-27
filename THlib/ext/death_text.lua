---@class death_text
local M = {}

---死亡提示语词典
---同种死亡方式提示语可以有多种，因此用一个数组来表示
---@type table<string,table<string,string[]|fun[]>>
M.dict = {
    using_kamikaze = {
        ch = {
            "<p>是玉面手雷王。",
            "爆炸是一种艺术。",
            "<p>误把自爆当成了战术。",
            "<p>成为了全场最响的爆炸声。",
            "<p>做了一次壮烈的自我牺牲——但失败了。",
        },
        en = {
            "<p> went out with a bang... literally.",
            "<p> mistook self-destruction for a strategy.",
            "<p> blew themselves up trying to take out the enemies.",
            "<p> became the biggest explosion in the room.",
            "<p> made a heroic sacrifice — and lost.",
        },
    },

    using_glass_bon = {
        ch = {
            "<p>就是一颗/t128。",
            "<p>全身由无机物组成。",
            "<p>的端粒破碎了。",
            "<p>变成了钻石尘。",
        },
        en = {
            "<p> was a fragile /t128.",
            "<p> made entirely of inorganic matter.",
            "<p> had its telomeres shattered.",
            "<p> turned into diamond dust.",
        },
    },
    die_with_moon_dmg_reduction = {
        ch = {
            function()
                local name = player_list[lstg.var.player_select].display_name
                local str = sp.string(name)
                return ("即使是阴晴圆缺也还会死吗，哈基%s，你这家伙。"):format(str.string[#str.string])
            end,
            "月有阴晴圆缺，人也有阴晴圆缺。",
            "人被悲欢离合，月有阴晴圆缺。"
        },
        en = {
            "The moon waxes and wanes, as do human fortunes.",
            "Just as the moon has phases, so do we have joys and sorrows.",
            "Like the changing moon, life has its highs and lows.",
            "The moon's cycles mirror the tides of the human heart.",
        },
    },
    using_cowrie_shell = {
        ch = {
            "<p>被/t114反噬了。",
            "<p>未能解出五难题之一。",
            "<p>被写进了竹取传说。",
        },
        en = {
            "<p> was undone by the curse of the /t114.",
            "<p> failed one of the Five Requests.",
            "<p> became a part of the Tale of the Bamboo Cutter.",
        },
    },
    using_heart_link = {
        ch = {
            "<p>和敌人心连心了。",
            "<p>染色体DNA上的ATCG错误连接了。",
            "<p>成为了配体，配位分子是<p>。",
        },
        en = {
            "<p> got too close—heart linked with the enemy.",
            "<p> suffered a fatal ATCG crossover in their DNA.",
            "<p> became a ligand, coordinated by <p>.",
        },
    },
    JingZhe = {
        ch = {
            "<p>被雷劈成碎片。",
            "<p>，天公不作美。",
            "<p>被恶意的游戏设计毁灭了。",
            "<p>尝试渡劫但失败。",
            "<p>被永江衣玖盯上了。",
            "<p>被当成了电解池。",
        },
        en = {
            "<p> was shredded by a lightning strike.",
            "<p> had bad luck with the weather gods.",
            "<p> was crushed by cruel game design.",
            "<p> tried to survive the storm... and failed.",
            "<p> got turned into a human battery.",
        },
    },
    die_at_9961 = {
        ch = {
            "<p>9961了。",
        },
        en = {
            "<p> died at the very last moment.",
            "<p> fell at the final hurdle.",
            "<p> was stopped just before the finish line.",
            "<p> gave up with the goal in sight.",
            "<p> joined the 9961 club.",
            "<p> took a final bow before the credits.",
        },
    },
    ZuanShiChen = {
        ch = {
            "<p>吸入了1克拉的钻石。",
            "<p>获得了成就：钻石！",
            "<p>现在全身上下均由共价键组成。",
            "一种新的共价晶体被发现了，其命名为<p>",
            "<p>的折射率高达99.8%。",
        },
        en = {
            "<p> inhaled a whole carat of diamonds.",
            "<p> was swallowed by a blizzard of diamond dust.",
            "<p> now bonded covalently from head to toe.",
            "A new covalent crystal was discovered: <p>.",
            "<p> boasts a refractive index of 99.8%.",
        },
    },
    QiuLaoHu = {
        ch = {
            "<p>的的确确被烧死了。",
            "<p>不擅长秋天。",
            "<p>不喜欢秋天。",
            "<p>准备去买台空调。",
            "<p>像冰淇淋一样融化了。",
            "<p>过于细皮嫩肉。",
        },
        en = {
            "<p> was officially roasted.",
            "<p> didn't survive autumn heat.",
            "<p> hates fall. Confirmed.",
            "<p> should've invested in AC.",
            "<p> melted like cheap ice cream.",
            "<p> was a bit too tender for this world.",
        },
    },
    screen_full_of_bullets = {
        ch = {
            "<p>试图在弹幕海里游泳。",
            "<p>确诊了密集恐惧症。",
            "<p>，为什么会变成这样呢？",
            "<p>尝试挑战obj池上限。",
            "<p>忘了这不是弹幕风游戏。",
            "<p>被弹幕包裹着窒息而亡。",
            "<p>现在拥有一床席幕思。",
        },
        en = {
            "<p> tried to swim through a bullet ocean.",
            "<p> developed a sudden case of bulletphobia.",
            "<p> stared at the chaos and questioned life choices.",
            "<p> stress-tested the engine... and lost.",
            "<p> forgot this isn't Danmukufu.",
            "<p> suffocated under a weighted blanket of pain.",
            "<p> unlocked the Bullet Memory Foam Mattress™.",
        },
    },
    all_enemy = {
        ch = {
            "<p>想和妖精亲密接触但被婉拒了。",
            "<p>没把持住分子间碰撞。",
            "<p>尝试玩碰碰车。",
            "<p>被打了很痛的一巴掌。",
        },
        en = {
            "<p> got too close for comfort.",
            "<p> collided with reality.",
            "<p> thought this was bumper cars.",
            "<p> took a slap from the universe.",
        },
    },
    all_bullet = {
        ch = {
            "弹幕在抽奖时连续抽到了<p>。",
            "<p>尝试着品尝弹幕。",
            "<p>与弹幕有约。",
            "<p>满身疮痍。",
            "<p>尝试躲避弹幕。",
        },
        en = {
            "<p> took every bullet personally.",
            "<p> wanted to see what bullets taste like.",
            "<p> mistook the bullets for collectibles.",
            "<p> got absolutely shredded.",
            "<p> had a heartfelt reunion with a bullet.",
        },
    },
    die_too_fast = {
        ch = {
            "<p>匆匆忙忙地离开了人世。",
            "<p>在本次游玩中获得了坚持0.1秒的好成绩，你也来试试吧！",
            "<p>厌倦了这个世界。",
            "<p>游玩未半而中道崩殂。",
            "<p>的体重比鸿毛还轻。",
            "<p>草创未就。",
            "<p>尝试速通游戏。",
        },
        en = {
            "<p>left this world in a hurry.",
            "<p>survived a whole 0.1 seconds. Can you beat that?",
            "<p> grew tired of existence.",
            "<p> perished halfway through the tutorial.",
            "<p> was lighter than air.",
            "<p> barely got started.",
            "<p> tried speedrunning.",
        },
    },
    normal = {
        ch = {
            "<p>的旅程结束了。",
            "<p>的旅程到达了终点。",
            "<p>的梦想破碎了。",
            "<p>前去赴约神奈子。",
            "<p>安息了。",
            "<p>迷失了。",
            "<p>现在拥有/t28。",
        },
        en = {
            "<p> is now a fun fact.",
            "<p> took the early exit.",
            "<p> has logged off life.",
            "<p> was here. Not anymore.",
            "<p> got remembered in the credits.",
            "<p> has gone to meet Kanako.",
        },
    },
}

---@type fun(type_cache:{string,number}[]):string[]
---死亡提示语检查函数列表
M.check_funcs = {
    function()
        local v = lstg.var
        if v.wave == v.maxwave then
            return "die_at_9961"
        end
    end, --9961
    function(type_cache)
        if M.getCountInTable(type_cache, "kamikaze") >= 1 then
            return "using_kamikaze"
        end
    end, --玻璃大炮
    function(type_cache)
        if M.getCountInTable(type_cache, "GlassBon") >= 1 then
            return "using_glass_bon"
        end
    end, --玻璃大炮
    function(type_cache)
        if M.getCountInTable(type_cache, "moonDmgReduction") >= 1 then
            return "die_with_moon_dmg_reduction"
        end
    end, --即使是阴晴圆缺还是死了
    function(type_cache)
        if M.getCountInTable(type_cache, "CowrieShell") >= 1 then
            return "using_cowrie_shell"
        end
    end, --使用燕的子安贝的后果
    function(type_cache)
        if M.getCountInTable(type_cache, "kokoro_musubu") >= 1 then
            return "using_heart_link"
        end
    end, --使用心连心的后果
    function(type_cache)
        if type_cache[1][1] == "Lightning" then
            return "JingZhe"
        end
    end, --惊蛰
    function(type_cache)
        if type_cache[1][1] == "ZuanShiChen" then
            return "ZuanShiChen"
        end
    end, --钻石尘
    function(type_cache)
        if M.getCountInTable(type_cache, "QiuLaoHu") >= lstg.var.save_dmg_maxtime - 10 then
            return "QiuLaoHu"
        end
    end, --秋老虎
    function()
        local count = 0
        object.BulletIndesDo(function()
            count = count + 1
        end)
        if count >= 1000 then
            return "screen_full_of_bullets"
        end
    end, --满屏弹幕
    function(type_cache)
        if M.getCountInTable(type_cache, "IsEnemy") == #type_cache then
            return "all_enemy"
        end
    end, --全程被体术
    function(type_cache)
        if M.getCountInTable(type_cache, "IsBullet") == #type_cache then
            return "all_bullet"
        end
    end, --全程被弹
    function()
        local s = stage.current_stage
        if s.timer < 600 then
            return "die_too_fast"
        end
    end, --过快死亡
}

---根据死亡方式获取提示语
---@param dtype string 死亡方式
---@return string 死亡提示语
function M.get_text(dtype)
    local lang = { "ch", "en" }
    local texts = M.dict[dtype][lang[setting.language]]
    if texts and #texts > 0 then
        local name = scoredata.PlayerBrand
        local pos = texts[math.random(1, #texts)]
        if type(pos) == "string" then
            return ReplaceTextWithCommand(pos:gsub("<p>", name)):gsub("§.", "")
        elseif type(pos) == "function" then
            return pos()
        end
    else
        return ""
    end
end

function M.getCountInTable(type_cache, type)
    local count = 0
    for _, v in ipairs(type_cache) do
        if v[1] == type then
            count = count + 1
        end
    end
    return count
end

function M.check_death(type_cache)
    type_cache = type_cache or lstg.var.dmg_type_cache
    local texts = {}
    for _, check_func in ipairs(M.check_funcs) do
        local type = check_func(type_cache)

        if type then
            table.insert(texts, (M.get_text(type)))
        end
    end
    if #texts == 0 then
        return M.get_text("normal")
    else
        local pro = math.random()
        return texts[min(1, math.ceil(#texts * pro * pro))]
    end
end

return M