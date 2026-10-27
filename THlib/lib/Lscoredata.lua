---冒出来的null太可恶了
local function CheckData(_data)
    for k, v in pairs(_data) do
        if type(v) == "table" then
            CheckData(v)
        elseif type(v) == "userdata" then
            _data[k] = false
        end
    end
end

local password = { 3, 6, 11, 5, 4, 1, 2, 5, 8, 11, 9, 15, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 100 }
---@param file file
---@param str string
local function writeEncodeData(file, str)
    for i = 1, #str do
        file:write(string.char((str:byte(i) + password[i % #password + 1] - 1) % 127 + 1))
    end
end
---@param file file
local function readDecodeData(file)
    local str = file:read("*a")
    local strs = {}
    for i = 1, #str do
        strs[i] = string.char((str:byte(i) - password[i % #password + 1] - 1) % 127 + 1)
    end
    return table.concat(strs)
end

local path = GetDataPath()
local function NewOrReadFile(name)
    lstg.FileManager.CreateDirectory(path)
    local file = ("%s/%s.dat"):format(path, name)
    --读取文件
    local data
    if not FileExist(file) then
        data = {}
    else
        local scoredata_file = io.open(file, "rb")
        local text = readDecodeData(scoredata_file)
        if pcall(DeSerialize, text) then
            data = DeSerialize(text)
            if type(data) ~= "table" then
                data = {}
            end
        else
            lstg.ExtractRes(file, ("%s/%s_error.dat"):format(path, name))
            --lstg.MsgBoxError(("读取 %s.dat 失败\n已为您保留出现错误的存档\n请及时联系作者反馈此问题"):format(name), "Warning!!", false)
            data = {}
        end
        scoredata_file:close()
        scoredata_file = nil
    end
    return data
end
local function SaveFile(data, file_name)
    lstg.FileManager.CreateDirectory(path)

    local file = ("%s/%s.dat"):format(path, file_name)
    local fake_file = ("%s/%s.dat.fake"):format(path, file_name)
    local score_data_file = assert(io.open(fake_file, "wb"))
    writeEncodeData(score_data_file, Serialize(data))
    score_data_file:close()
    os.remove(file)
    os.rename(fake_file, file)
end


--通常数据
local _initscoredata = function()
    local data = NewOrReadFile("Score1")
    data.Duration = data.Duration or { 0, 0, 0, 0, 0 }
    data.ContinuousLogin = data.ContinuousLogin or 1
    local d = os.date("*t")
    data.LastLoginDate = data.LastLoginDate or os.time({ day = d.day, month = d.month, year = d.year })
    data.first_language = data.first_language or false

    data.money = nil
    ---成就数据
    data.Achievement = data.Achievement or {}
    data.AchievementGetTime = data.AchievementGetTime or {}
    ---加成数据
    data.BookAddition = data.BookAddition or {}--在图鉴里显示
    data.ShowNewAddition = data.ShowNewAddition or {}--选择加成时的new图标
    data.initialAddition = data.initialAddition or {}--是否可以初始携带
    data.NoticeinitialAddition = data.NoticeinitialAddition or {}--初次解锁初始携带的flag
    data.UnlockAddition = data.UnlockAddition or {}--是否解锁加成

    ---主动道具数据
    data.StartActive = data.StartActive or false--是否开启主动道具的获得
    data.ShowNewActive = data.ShowNewActive or {}--选择主动时的new图标
    data.BookActive = data.BookActive or {}--在图鉴里显示
    data.UnlockActive = data.UnlockActive or {}--是否解锁主动道具
    ---天气数据
    data.Weather = data.Weather or {}
    data.FirstWeather = data.FirstWeather or false--初遇天气
    data.First5Season = data.First5Season or false--初遇里季节
    ---抽卡数据
    data.pearlGetIndex = nil
    data.pearlGet = nil
    data.nowPearls = nil
    data.totalPearls = nil
    data.rewarded = nil
    data.rewardedRecord = nil
    data.baodi_tool = nil
    data.baodi_chara = nil
    ---任务数据
    data.mission_data = data.mission_data or {}
    data.new_unlock = data.new_unlock or nil
    ---其他数据
    data._total_miss = data._total_miss or 0
    data._total_bomb = data._total_bomb or 0
    data._total_kill_enemy = data._total_kill_enemy or 0
    data._total_death = data._total_death or 0

    data._total_get_benefit = data._total_get_benefit or 0
    data._total_get_trade = data._total_get_trade or 0
    data._total_get_infringe = data._total_get_infringe or 0
    data._total_get_item = data._total_get_item or 0

    data._total_mission = data._total_mission or 0
    data._total_miss_exp = data._total_miss_exp or 0
    data.NeetQuestions = data.NeetQuestions or { 0, 0, 0, 0, 0, 0 }
    data.guide_flag = data.guide_flag or 0
    data.infinite_clock = data.infinite_clock or false--无间之钟
    data.cheatMode_show = data.cheatMode_show or false
    data.inside_pro = data.inside_pro or 0.05--里季节概率
    data.siyuan_baby_count = data.siyuan_baby_count or 0

    data._total_gongfeng = nil
    data._total_gongfeng_tool = nil
    data._total_gongfeng_chara = nil
    --旧版本兼容
    for k, v in pairs(data.Achievement) do
        if v and type(k) == "number" then
            data.Achievement[tostring(k)] = v
            data.Achievement[k] = nil
        end
    end
    for k, v in pairs(data.AchievementGetTime) do
        if v and type(k) == "number" then
            data.AchievementGetTime[tostring(k)] = v
            data.AchievementGetTime[k] = nil
        end
    end
    CheckData(data)
    scoredata = data
end

--关卡数据（包括菜单选择，通关状态，最高分等）
local _initstagedata = function()
    local data = NewOrReadFile("Score2")
    data.practice_diff_pos = data.practice_diff_pos or 1
    data.player_pos = data.player_pos or 1
    data.spell_pos = data.spell_pos or {}
    data.SceneSelection = data.SceneSelection or 1
    data.DiffSelection = data.DiffSelection or {}
    data.stagePass = data.stagePass or {}
    data.hiscore = data.hiscore or {}
    data.unlockInitialPos = nil
    data.chooseInitial = data.chooseInitial or { { 0, 1 }, { 0, 1 }, { 0, 1 }, { 0, 1 }, { 0, 1 } }
    data.presetInitial = data.presetInitial or {}
    data.scene_unlock = data.scene_unlock or {}
    data.challenge_unlock = data.challenge_unlock or {}
    data.challenge_finish = data.challenge_finish or {}
    data.challenge_time = data.challenge_time or {}
    ---波图鉴数据
    data.BookWave = data.BookWave or {}
    CheckData(data)
    stagedata = data
end

--玩家养成数据
local _initplayerdata = function()
    local data = NewOrReadFile("Score3")
    CheckData(data)
    playerdata = data
end

function InitScoreData()
    _initscoredata()
    _initstagedata()
    _initplayerdata()
end

function SaveScoreData()
    SaveFile(scoredata, "Score1")
    SaveFile(stagedata, "Score2")
    SaveFile(playerdata, "Score3")
end


