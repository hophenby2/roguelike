local lib = {}
mission_lib = lib
---@type mission_unit[]
lib.MissionList = {}
---@type mission_unit<addition_unit,mission_unit>
lib.MissionMap = {}
local truefunc = function()
    return true
end

---添加任务
---@param id number@任务id
---@param master number@母任务
---@param toolid number@要解锁的道具
local function AddMissionFunc(List)
    return function(id, master, x, y, toolid, hide, show_condition)
        local data = {
            progress = 0, --满为100
            new = false, --new感叹号
            open = false, --已经开启的flag
        }
        local tool = List[toolid]
        ---@class mission_unit
        local tmp = {
            id = id,
            master_id = master,

            x = x, y = y,
            R = 255, G = 255, B = 255,
            Rb = 0, Gb = 0, Bb = 0,
            size = 1,
            ratio = 1, --比例系数
            show_condition = show_condition or truefunc,
            hide = hide or false,
            index = 0,
            tool = tool,
        }
        scoredata.mission_data[id] = scoredata.mission_data[id] or data
        tmp.data = scoredata.mission_data[id]
        lib.MissionList[id] = tmp
        lib.MissionMap[tool] = tmp

        return tmp
    end
end
lib.AddMissionFunc = AddMissionFunc

local function GoMission(id, t, sp)
    if not sp and IsSpecialMode() then
        return
    end--特殊情况时不能解锁任务
    t = t or 100
    ---@type mission_unit
    local unit = lib.MissionList[id]
    local data = scoredata
    if not unit.data.open then
        if (not unit.master_id) or data.mission_data[unit.master_id].open then
            unit.data.progress = min(unit.data.progress + t, 100)
            if unit.data.progress == 100 then
                unit.data.open = true
                unit.data.new = true
                ext.achievement:getMission(unit.tool)
                data.new_unlock = id
                data._total_mission = data._total_mission + 1
                ---
                return true
            end
        end
    else
        return true
    end
end
lib.GoMission = GoMission

local function InitMission()
    ---任务列表

    lib.MissionList = {}
    ---根据道具得到任务
    lib.MissionMap = {}
    --一个单位的半径大小大概是100

    local AddMissionTool = AddMissionFunc(stg_levelUPlib.AdditionTotalList)
    local AddMissionActive = AddMissionFunc(activeItem_lib.ActiveTotalList)
    --特殊隐藏
    AddMissionTool(2, nil, 1877, 545, 28, true)--历经伤痛之心

    --杀敌数
    AddMissionTool(4, nil, 2360, 1020, 48)--Blood Magic
    AddMissionTool(45, nil, 2260, 1020, 127)--疯狂的火炬
    AddMissionTool(46, nil, 2160, 1020, 47)--妖精联结
    --擦弹
    AddMissionTool(13, nil, 3248, 1200, 62)--to do清单
    AddMissionTool(35, nil, 3248, 1300, 73)--极欲的暴食

    --天气相关
    AddMissionTool(5, nil, 3020, 600, 56)--天地有用
    AddMissionTool(6, nil, 2900, 600, 102)--秘神的指引
    AddMissionTool(29, nil, 2960, 480, 103)--公转轨道异常
    AddMissionTool(41, nil, 3080, 480, 116)--中子星
    AddMissionTool(47, nil, 3140, 600, 58)--樱花结界

    --杂乱
    AddMissionTool(9, nil, 3000, 1500, 17)--金刚不灭之身
    AddMissionTool(40, nil, 3120, 1500, 112)--生之残梦

    --小boss
    AddMissionTool(52, nil, 3300, 1500, 164)--向侧之月
    AddMissionTool(53, nil, 3400, 1500, 159)--小小星之伞
    AddMissionActive(75, nil, 3400, 1600, 15)--超干爽伞妖
    AddMissionActive(76, nil, 3400, 1700, 20)--惊吓日和
    AddMissionTool(77, nil, 3500, 1500, 186)--槐安通路
    AddMissionTool(90, nil, 3600, 1600, 53)--恐慌的笼罩
    AddMissionTool(116, 90, 3520, 1680, 181)--无情之地
    AddMissionTool(117, 77, 3580, 1420, 182)--梦我梦中

    --冰
    AddMissionTool(8, nil, 2909, 1668, 92)--寂静的冬天
    AddMissionTool(14, nil, 2843, 1768, 45)--⑨之祝福
    AddMissionTool(15, nil, 2784, 1668, 24)--冰之妖精
    AddMissionTool(43, nil, 2843, 1888, 124)--冰之鳞

    --死亡
    AddMissionTool(7, nil, 2625, 1183, 79)--以血还血
    AddMissionTool(16, nil, 2700, 1100, 74)--不死的尾羽
    AddMissionTool(32, nil, 2775, 1183, 55)--见血封喉术
    AddMissionTool(33, nil, 2850, 1100, 128)--玻璃大炮
    AddMissionTool(63, nil, 2925, 1183, 205)--亘古的恨意

    --chaos
    AddMissionTool(17, nil, 2166, 1406, 89)--破碎的护身符
    AddMissionTool(12, nil, 2166, 1293, 44)--平安喜乐
    AddMissionTool(91, nil, 2166, 1180, 63)--蓬莱人形
    --符卡
    AddMissionTool(36, nil, 2470, 1720, 2)--轻量储能包
    AddMissionTool(11, nil, 2560, 1620, 30)--魔力护瓶
    AddMissionTool(1, nil, 2560, 1520, 80)--硝酸甘油
    AddMissionTool(18, nil, 2510, 1420, 96)--灵力槽
    AddMissionTool(95, nil, 2610, 1420, 100)--Powerful Point
    AddMissionTool(44, 11, 2610, 1720, 113)--荷取牌能量盾
    AddMissionTool(122, 44, 2560, 1820, 38)--光学迷彩服
    AddMissionTool(130, 122, 2610, 1920, 190)--经纬仪

    --其他
    AddMissionTool(3, nil, 2350, 1300, 39)--疏与密的境界
    AddMissionTool(34, nil, 2350, 1420, 71)--便携式后户
    AddMissionTool(42, nil, 2350, 1540, 106)--九代稗谷
    AddMissionTool(64, nil, 2350, 1660, 175)--多米诺效应

    --五难题
    local cx, cy = 2423, 600
    AddMissionTool(24, nil, cx + cos(90) * 125, cy + sin(90) * 125, 97)--龙颈之玉
    AddMissionTool(25, nil, cx + cos(162) * 125, cy + sin(162) * 125, 117)--佛的御石钵
    AddMissionTool(26, nil, cx + cos(234) * 125, cy + sin(234) * 125, 99)--火鼠的皮衣
    AddMissionTool(27, nil, cx + cos(306) * 125, cy + sin(306) * 125, 114)--燕的子安贝
    AddMissionTool(28, nil, cx + cos(18) * 125, cy + sin(18) * 125, 101)--蓬莱的玉枝

    --玩家升级
    AddMissionTool(30, nil, 2702, 854, 52)--一对的自我
    AddMissionTool(31, nil, 2812, 854, 76)--向神山的供品
    AddMissionTool(10, nil, 2812, 734, 26)--经验探测仪
    AddMissionTool(37, nil, 2922, 734, 81)--经验血袋
    AddMissionTool(38, nil, 3032, 734, 85)--EXHP
    AddMissionTool(39, nil, 3142, 734, 125)--贤者之石
    AddMissionTool(56, nil, 3252, 734, 163)--摆烂小孩

    --梅蒂欣
    AddMissionTool(48, nil, 3567, 877, 90)--甘美之毒

    --紫妈
    AddMissionTool(19, nil, 3687, 757, 54)--便携式隙间
    AddMissionTool(20, nil, 3687, 877, 60)--损坏的空间
    AddMissionTool(21, nil, 3807, 877, 119)--虚与实的境界
    AddMissionTool(22, nil, 3807, 757, 50)--生与死的境界
    AddMissionTool(23, 20, 3567, 997, 82)--月与海的传送门
    AddMissionTool(89, nil, 3970, 718, 37)--心连心

    --纯狐
    AddMissionTool(49, nil, 3548, 1278, 86)--阴晴圆缺

    --铃瑚
    AddMissionTool(51, nil, 3668, 1278, 161)--团子生命力
    AddMissionTool(59, nil, 3761, 1180, 168)--黄豆包
    AddMissionTool(60, nil, 3881, 1180, 169)--红豆包
    AddMissionTool(61, nil, 3881, 1060, 170)--绿豆包
    AddMissionTool(62, nil, 3761, 1060, 171)--蓝豆包

    --圣白莲
    AddMissionTool(66, nil, 3700, 1500, 213)--业火的灯芯
    AddMissionTool(67, nil, 3800, 1500, 214)--未竟者的誓轮
    AddMissionTool(68, nil, 3900, 1500, 215)--时间慧面


    --通关解锁
    AddMissionTool(50, nil, 4120, 978, 133)--封之术法
    AddMissionTool(65, nil, 4250, 978, 201)--绮罗大结界
    AddMissionTool(83, nil, 4380, 978, 115)--护守之莲
    AddMissionTool(85, nil, 4510, 978, 162)--死亡十字
    AddMissionTool(86, nil, 4640, 978, 183)--小槌的魔力

    --挑战
    AddMissionTool(54, nil, 3377, 538, 160)--Game Killer
    AddMissionTool(55, nil, 3477, 538, 152)--Mimichan
    AddMissionTool(57, nil, 3577, 538, 155)--深海七花
    AddMissionTool(58, nil, 3677, 538, 154)--梅露兰的小号

    AddMissionTool(70, nil, 3527, 438, 184)--半分幻魂魄
    AddMissionTool(71, nil, 3627, 438, 198)--特大头条
    AddMissionTool(72, nil, 3727, 438, 212)--百万鬼夜行
    AddMissionActive(73, nil, 3427, 438, 17)--重低音太鼓

    AddMissionTool(69, nil, 3477, 338, 196)--越来越大的如意棒
    AddMissionActive(74, nil, 3577, 338, 7)--箜篌引

    --通关游戏次数（后来加的）
    --1次
    AddMissionTool(78, nil, 1130, 1400, 27)--幽魂梦舞
    AddMissionTool(87, nil, 1240, 1400, 21)--守财奴的教训
    AddMissionTool(104, nil, 1350, 1400, 176)--螺光步
    AddMissionTool(109, nil, 1460, 1400, 25)--专注法阵
    --2次
    AddMissionTool(84, nil, 1100, 1280, 132)--怪力乱神
    AddMissionTool(88, nil, 1210, 1280, 29)--大促销：神子牌令牌
    AddMissionTool(99, nil, 1320, 1280, 126)--宝塔的神光
    AddMissionTool(110, nil, 1430, 1280, 61)--正体不明的飞仓
    AddMissionTool(114, nil, 1540, 1280, 166)--异议！
    --3次
    AddMissionTool(79, nil, 1070, 1160, 40)--红沐愿
    AddMissionTool(92, nil, 1180, 1160, 77)--幽谷回响
    AddMissionTool(97, nil, 1290, 1160, 111)--幻想烟花
    AddMissionTool(111, nil, 1400, 1160, 94)--符海突击学说
    --4次
    AddMissionTool(80, nil, 1040, 1040, 41)--蓝沐愿
    AddMissionTool(93, nil, 1150, 1040, 84)--时间回溯
    AddMissionTool(98, nil, 1260, 1040, 123)--绯红的专注
    --5次
    AddMissionTool(81, nil, 1010, 920, 42)--绿沐愿
    AddMissionTool(94, nil, 1120, 920, 93)--风神的祝歌
    AddMissionTool(113, nil, 1230, 920, 138)--过往的风花
    AddMissionTool(129, nil, 1340, 920, 188)--落向地狱的雨
    --6次
    AddMissionTool(82, nil, 980, 800, 64)--贪欲的敛财
    AddMissionTool(96, nil, 1090, 800, 105)--幻想万华镜
    AddMissionTool(107, nil, 1200, 800, 197)--逢天宇宙仪
    AddMissionTool(112, nil, 1310, 800, 122)--具现化记忆
    --7次
    AddMissionTool(100, nil, 950, 680, 129)--寻求者
    AddMissionTool(101, nil, 1060, 680, 130)--渴望者
    AddMissionTool(102, nil, 1170, 680, 131)--喜爱者
    AddMissionTool(127, nil, 1280, 680, 178)--大地的富饶
    --8次
    AddMissionTool(118, nil, 920, 560, 187)--宝宝们的午夜舞会~
    AddMissionTool(123, nil, 1030, 560, 91)--完美散华
    AddMissionTool(125, nil, 1140, 560, 118)--加长反射弧
    AddMissionTool(131, nil, 1250, 560, 191)--递质不耐受
    --9次
    AddMissionTool(119, nil, 890, 440, 189)--异次元杀弹
    AddMissionTool(120, nil, 1000, 440, 194)--灾衡之天秤
    AddMissionTool(124, nil, 1110, 440, 95)--赤蛮奇之头
    --10次
    AddMissionTool(132, nil, 860, 320, 192)--浓缩熵
    AddMissionTool(133, nil, 970, 320, 204)--强身健体
    AddMissionTool(134, nil, 1080, 320, 210)--华彩波纹
    AddMissionTool(135, nil, 1190, 320, 211)--背水阵
    --角色通关
    --早苗
    AddMissionTool(103, nil, 1720, 1790, 174)--一脉单传的神风
    AddMissionTool(108, nil, 1720, 1690, 207)--本土信仰
    --灵梦
    AddMissionTool(105, nil, 1620, 1790, 177)--永夜刻印
    AddMissionActive(150, nil, 1620, 1690, 5)--红心火龙果
    --射命丸文
    AddMissionTool(106, nil, 1520, 1790, 193)--八十亿劫渡法
    AddMissionActive(141, nil, 1520, 1690, 23)--高清相机
    --魔理沙
    AddMissionTool(115, nil, 1420, 1790, 173)--石是球势
    AddMissionTool(121, nil, 1420, 1690, 35)--幸运的招财猫
    --琪露诺
    AddMissionTool(126, nil, 1320, 1790, 172)--垒叠的石头
    AddMissionActive(149, nil, 1320, 1690, 4)--绿色番荔枝
    --妖梦
    AddMissionTool(128, nil, 1220, 1790, 180)--电子木鱼
    AddMissionActive(147, nil, 1220, 1690, 29)--幻想之翼
    --咲夜
    AddMissionActive(146, nil, 1120, 1790, 21)--埃及路障
    AddMissionActive(148, nil, 1120, 1690, 11)--rewind
    --五季节系统
    cx, cy = 1793, 922
    AddMissionActive(136, nil, cx + cos(90) * 125, cy + sin(90) * 125, 24)--季节解放·春
    AddMissionActive(137, nil, cx + cos(162) * 125, cy + sin(162) * 125, 25)--季节解放·夏
    AddMissionActive(138, nil, cx + cos(234) * 125, cy + sin(234) * 125, 26)--季节解放·秋
    AddMissionActive(139, nil, cx + cos(306) * 125, cy + sin(306) * 125, 27)--季节解放·冬
    AddMissionActive(140, nil, cx + cos(18) * 125, cy + sin(18) * 125, 28)--季节解放·里

    --携带主动通关
    --雾之湖
    AddMissionTool(143, nil, 2049, 2229, 203)--朱莉安娜羽扇
    AddMissionTool(144, nil, 2159, 2229, 202)--烟熏的团扇
    --静海
    AddMissionTool(142, nil, 2049, 2099, 195)--辉夜的百宝箱
    AddMissionActive(145, nil, 2159, 2099, 22)--新月
end
lib.InitMission = InitMission