WalkImage = {}
local SQColor = {
    RED = { { 160, 32, 32 }, { 160, 0, 0 }, { 224, 0, 0 } },
    GREEN = { { 32, 160, 32 }, { 0, 160, 0 }, { 20, 224, 20 } },
    BLUE = { { 32, 32, 160 }, { 0, 0, 160 }, { 0, 0, 224 } },
    ORANGE = { { 224, 160, 0 }, { 160, 160, 0 }, { 224, 224, 0 } },
    WHITE = { { 230, 220, 230 }, { 128, 120, 128 }, { 224, 224, 224 } },
    PURPLE = { { 224, 0, 160 }, { 160, 0, 160 }, { 224, 0, 224 } },
    YELLOW = { { 224, 130, 18 }, { 160, 150, 30 }, { 224, 180, 30 } },
    CYAN = { { 0, 160, 224 }, { 0, 160, 160 }, { 0, 224, 224 } },
}
WalkImage.imglist = {
    ["Rumia"] = { 3, 4, { 4, 4, 2 }, { 1, 1 } },
    ["Chiruno"] = { 4, 4, { 4, 4, 4, 4 }, { 1, 1, 1 } },
    ["Meirin"] = { 3, 4, { 4, 3, 2 }, { 1, 1 } },
    ["Knowledge"] = { 3, 4, { 4, 4, 2 }, { 1, 1 } },
    ["Sakuya"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Remilia"] = { 3, 3, { 1, 3, 1 }, { 1, 1 } },
    ["Flandre"] = { 3, 4, { 4, 4, 1 }, { 1, 1 } },

    ["Daiyousei"] = { 3, 3, { 3, 3, 3 }, { 1, 1 }, nil, 3, 5 },
    ["Whiterock"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Chen"] = { 3, 4, { 4, 3, 3 }, { 1, 1 } },
    ["Alice"] = { 3, 5, { 1, 5, 4 }, { 1, 1 } },
    ['Whitelily'] = { 3, 4, { 4, 3, 2 }, { 1, 1 } },
    ["Lunasa"] = { 3, 3, { 1, 3, 3 }, { 1, 1 } },
    ["Merlin"] = { 3, 4, { 1, 4, 2 }, { 1, 1 } },
    ["Lyrica"] = { 3, 3, { 1, 3, 3 }, { 1, 1 } },
    ["Youmu"] = { 4, 5, { 5, 4, 4, 5 }, { 1, 1, 1 }, nil, 22, 0 },
    ["Yuyuko"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Ran"] = { 3, 4, { 4, 3, 1 }, { 1, 1 } },
    ["Yukari"] = { 4, 3, { 1, 3, 3, 3 }, { 1, 1, 1 }, nil, -5, 0 },

    ["Nightbug"] = { 3, 5, { 5, 4, 2 }, { 1, 1 } },
    ["Lorelei"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Lorelei2"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Kamishirasawa"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Reimu"] = { 3, 4, { 4, 4, 4 }, { 1, 4 } },
    ["Marisa"] = { 3, 4, { 4, 4, 1 }, { 1, 1 } },
    ["Tewi"] = { 3, 4, { 4, 4, 2 }, { 1, 1 } },
    ["Reisen"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Yagokoro"] = { 3, 4, { 1, 4, 4 }, { 1, 1 } },
    ["Neet"] = { 3, 3, { 1, 3, 3 }, { 1, 1 } },
    ["Kamishirasawa2"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Mokou"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },

    ["Aya"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Medicine"] = { 3, 4, { 4, 4, 1 }, { 1, 1 } },
    ["Komachi"] = { 3, 4, { 4, 4, 2 }, { 1, 1 } },
    ["Yuka"] = { 3, 4, { 4, 4, 2 }, { 1, 1 } },
    ["Shikieiki"] = { 3, 4, { 4, 4, 1 }, { 1, 1 } },

    ["Suika"] = { 3, 4, { 4, 4, 1 }, { 1, 1 } },

    ["Sizuha"] = { 3, 4, { 4, 4, 4 }, { 1, 1 }, 10 },
    ["Minoriko"] = { 3, 3, { 1, 3, 3 }, { 1, 1 } },
    ["Hina"] = { 1, 8, { 8 }, {} },
    ["Nitori"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Momizi"] = { 4, 4, { 4, 4, 4, 4 }, { 1, 1, 1 } },
    ["Sanae"] = { 3, 4, { 4, 4, 3 }, { 1, 1 } },
    ["Kanako"] = { 3, 8, { 4, 3, 8 }, { 1, 4 } },
    ["Suwako"] = { 3, 8, { 4, 4, 8 }, { 1, 4 } },

    ["Kisume"] = { 1, 8, { 8 }, {} },
    ["Yamame"] = { 3, 4, { 1, 4, 4 }, { 1, 1 } },
    ["Parsee"] = { 3, 5, { 1, 5, 4 }, { 1, 1 } },
    ["Yugi"] = { 3, 4, { 1, 4, 4 }, { 1, 1 } },
    ["Satori"] = { 3, 8, { 8, 4, 1 }, { 1, 1 } },
    ["Rin"] = { 3, 4, { 4, 3, 3 }, { 1, 1 } },
    ["Rin2"] = { 3, 4, { 1, 4, 2 }, { 1, 2 }, nil, 0, 7 },
    ["Utsuho"] = { 4, 4, { 4, 3, 3, 4 }, { 1, 1, 1 } },
    ["Koishi"] = { 3, 6, { 6, 4, 4 }, { 1, 1 } },

    ["Nazrin"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Kogasa"] = { 3, 6, { 4, 4, 6 }, { 1, 6 } },
    ["Ichirin"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Murasa"] = { 3, 6, { 4, 3, 6 }, { 1, 1 } },
    ["Murasa2"] = { 3, 6, { 4, 3, 6 }, { 1, 1 } },
    ["Shou"] = { 3, 7, { 4, 4, 7 }, { 1, 2 } },
    ["Byakuren"] = { 4, 4, { 4, 4, 4, 4 }, { 1, 1, 3 } },
    ["Nue"] = { 4, 7, { 7, 4, 4, 5 }, { 1, 1, 2 } },

    ["Tenshi"] = { 3, 5, { 4, 4, 5 }, { 1, 1 } },
    ["Iku"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Hatate"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },

    ["LunaChild"] = { 3, 4, { 4, 4, 3 }, { 1, 2 } },
    ["StarSapphire"] = { 3, 4, { 4, 4, 3 }, { 1, 2 } },
    ["SunnyMilk"] = { 3, 4, { 4, 4, 3 }, { 1, 2 } },
    ["Marisa2"] = { 3, 4, { 4, 4, 4 }, { 1, 2 } },

    ["Kyouko"] = { 3, 4, { 4, 4, 4 }, { 1, 2 } },
    ["Yoshika"] = { 3, 5, { 5, 5, 5 }, { 1, 5 } },
    ["NyanNyan"] = { 4, 4, { 4, 3, 3, 4 }, { 1, 1, 4 } },
    ["Toziko"] = { 1, 4, { 4 }, {} },
    ["Futo"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Miko"] = { 4, 12, { 4, 4, 4, 12 }, { 1, 1, 4 }, nil, 4, 15 },
    ["Mamizou"] = { 3, 4, { 4, 4, 4 }, { 1, 4 } },

    ["Wakasagihime"] = { 3, 8, { 8, 4, 8 }, { 1, 8 } },
    ["Wakasagihime2"] = { 1, 5, { 5 }, { } },
    ["Sekibanki"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Sekibanki2"] = { 3, 4, { 4, 4, 4 }, { 1, 1 } },
    ["Sekibanki_head"] = { 3, 4, { 4, 2, 1 }, { 1, 1 } },
    ["Sekibanki_head2"] = { 3, 4, { 4, 2, 1 }, { 1, 1 } },
    ["Kagerou"] = { 3, 10, { 10, 6, 7 }, { 1, 1 } },
    ["Benben"] = { 4, 7, { 4, 7, 7, 4 }, { 3, 3, 4 } },
    ["Yatsuhashi"] = { 4, 8, { 4, 8, 5, 4 }, { 1, 1, 4 } },
    ["Seija"] = { 4, 8, { 4, 8, 7, 8 }, { 1, 4, 1 } },
    ["Shinmyoumaru"] = { 4, 10, { 10, 9, 9, 1 }, { 1, 1, 1 } },
    ["Raiko"] = { 4, 5, { 4, 5, 5, 5 }, { 1, 1, 1 } },

    ["Seiran"] = { 3, 5, { 5, 5, 5 }, { 1, 1 } },
    ["Ringo"] = { 4, 5, { 5, 5, 5, 5 }, { 1, 1, 1 } },
    ["Doremy"] = { 4, 6, { 4, 6, 6, 6 }, { 3, 3, 3 } },
    ["Sagume"] = { 4, 8, { 7, 5, 5, 8 }, { 3, 3, 1 } },
    ["Clownpiece"] = { 4, 11, { 11, 5, 5, 7 }, { 3, 3, 5 }, nil, 0, 10 },
    ["Junko"] = { 3, 5, { 5, 4, 5 }, { 1, 3 }, nil, 0, 7 },
    ["Hecatia1"] = { 4, 7, { 7, 5, 5, 3 }, { 1, 1, 1 } },
    ["Hecatia2"] = { 4, 7, { 7, 5, 5, 3 }, { 1, 1, 1 } },
    ["Hecatia3"] = { 4, 7, { 7, 5, 5, 3 }, { 1, 1, 1 } },

    ["EternityLarva"] = { 3, 6, { 6, 6, 6 }, { 3, 6 } },
    ["Nemuno"] = { 3, 7, { 4, 7, 7 }, { 4, 4 } },
    ["Aunn"] = { 3, 8, { 8, 6, 8 }, { 4, 8 } },
    ["Narumi"] = { 4, 7, { 7, 5, 5, 7 }, { 3, 3, 7 } },
    ["Satono"] = { 4, 9, { 6, 5, 5, 9 }, { 3, 3, 9 }, nil, 2, 0 },
    ["Mai"] = { 4, 9, { 6, 5, 5, 9 }, { 3, 3, 9 }, nil, -3, 6 },
    ["Okina1"] = { 4, 7, { 7, 5, 5, 1 }, { 3, 3, 1 }, nil, 3, 9 },
    ["Okina2"] = { 3, 5, { 4, 5, 4 }, { 3, 4 } },

    ["Eika"] = { 3, 9, { 6, 4, 9 }, { 2, 9 } },
    ["Urumi"] = { 4, 8, { 8, 6, 6, 8 }, { 4, 4, 8 }, nil, -3, 0 },
    ["Kutaka"] = { 4, 5, { 5, 5, 5, 4 }, { 3, 3, 3 } },
    ["Yachie"] = { 4, 8, { 5, 5, 5, 8 }, { 3, 3, 5 }, nil, 7, 0 },
    ["Mayumi"] = { 4, 6, { 6, 5, 5, 6 }, { 3, 3, 6 } },
    ["Keiki"] = { 3, 6, { 4, 6, 1 }, { 4, 1 }, nil, 0, 5 },
    ["Saki"] = { 3, 5, { 5, 5, 5 }, { 3, 5 }, nil, 13, 0 },

    ["Sumireko"] = { 3, 4, { 4, 4, 1 }, { 1, 1 } },

    ["Kokoro"] = { 3, 5, { 5, 4, 5 }, { 1, 5 } },
    ["Jyoon"] = { 3, 5, { 5, 4, 5 }, { 2, 4 } }
}
WalkImage.saoqilist = {
    ["Rumia"] = SQColor.RED,
    ["Chiruno"] = SQColor.BLUE,
    ["Meirin"] = SQColor.RED,
    ["Knowledge"] = SQColor.BLUE,
    ["Sakuya"] = SQColor.BLUE,
    ["Remilia"] = SQColor.RED,
    ["Flandre"] = SQColor.RED,

    ["Daiyousei"] = SQColor.GREEN,
    ["Whiterock"] = SQColor.BLUE,
    ["Chen"] = SQColor.ORANGE,
    ["Alice"] = SQColor.BLUE,
    ['Whitelily'] = SQColor.WHITE,
    ["Lunasa"] = SQColor.RED,
    ["Merlin"] = SQColor.WHITE,
    ["Lyrica"] = SQColor.RED,
    ["Youmu"] = SQColor.GREEN,
    ["Yuyuko"] = SQColor.PURPLE,
    ["Ran"] = SQColor.ORANGE,
    ["Yukari"] = SQColor.PURPLE,

    ["Nightbug"] = SQColor.ORANGE,
    ["Lorelei"] = SQColor.GREEN,
    ["Lorelei2"] = SQColor.BLUE,
    ["Kamishirasawa"] = SQColor.BLUE,
    ["Reimu"] = SQColor.RED,
    ["Marisa"] = SQColor.YELLOW,
    ["Tewi"] = SQColor.WHITE,
    ["Reisen"] = SQColor.RED,
    ["Yagokoro"] = SQColor.PURPLE,
    ["Neet"] = SQColor.RED,
    ["Kamishirasawa2"] = SQColor.GREEN,
    ["Mokou"] = SQColor.RED,

    ["Aya"] = SQColor.RED,
    ["Medicine"] = SQColor.PURPLE,
    ["Komachi"] = SQColor.PURPLE,
    ["Yuka"] = SQColor.PURPLE,
    ["Shikieiki"] = SQColor.PURPLE,

    ["Suika"] = SQColor.RED,

    ["Sizuha"] = SQColor.ORANGE,
    ["Minoriko"] = SQColor.ORANGE,
    ["Hina"] = SQColor.PURPLE,
    ["Nitori"] = SQColor.BLUE,
    ["Momizi"] = SQColor.WHITE,
    ["Sanae"] = SQColor.GREEN,
    ["Kanako"] = SQColor.RED,
    ["Suwako"] = SQColor.GREEN,

    ["Kisume"] = SQColor.GREEN,
    ["Yamame"] = SQColor.PURPLE,
    ["Parsee"] = SQColor.GREEN,
    ["Yugi"] = SQColor.RED,
    ["Satori"] = SQColor.BLUE,
    ["Rin"] = SQColor.RED,
    ["Rin2"] = SQColor.RED,
    ["Utsuho"] = SQColor.YELLOW,
    ["Koishi"] = SQColor.GREEN,

    ["Nazrin"] = SQColor.GREEN,
    ["Kogasa"] = SQColor.BLUE,
    ["Ichirin"] = SQColor.RED,
    ["Murasa"] = SQColor.BLUE,
    ["Murasa2"] = SQColor.BLUE,
    ["Shou"] = SQColor.YELLOW,
    ["Byakuren"] = SQColor.PURPLE,
    ["Nue"] = SQColor.PURPLE,

    ["Tenshi"] = SQColor.BLUE,
    ["Iku"] = SQColor.PURPLE,
    ["Hatate"] = SQColor.PURPLE,


    ["LunaChild"] = SQColor.ORANGE,
    ["StarSapphire"] = SQColor.BLUE,
    ["SunnyMilk"] = SQColor.YELLOW,
    ["Marisa2"] = SQColor.ORANGE,

    ["Kyouko"] = SQColor.GREEN,
    ["Yoshika"] = SQColor.PURPLE,
    ["NyanNyan"] = SQColor.BLUE,
    ["Toziko"] = SQColor.CYAN,
    ["Futo"] = SQColor.BLUE,
    ["Miko"] = SQColor.ORANGE,
    ["Mamizou"] = SQColor.ORANGE,

    ["Wakasagihime"] = SQColor.BLUE,
    ["Wakasagihime2"] = SQColor.BLUE,
    ["Sekibanki"] = SQColor.PURPLE,
    ["Sekibanki2"] = SQColor.PURPLE,
    ["Kagerou"] = SQColor.RED,
    ["Benben"] = SQColor.CYAN,
    ["Yatsuhashi"] = SQColor.CYAN,
    ["Seija"] = SQColor.PURPLE,
    ["Shinmyoumaru"] = SQColor.YELLOW,
    ["Raiko"] = SQColor.CYAN,

    ["Seiran"] = SQColor.CYAN,
    ["Ringo"] = SQColor.RED,
    ["Doremy"] = SQColor.PURPLE,
    ["Sagume"] = SQColor.BLUE,
    ["Clownpiece"] = SQColor.ORANGE,
    ["Junko"] = SQColor.RED,
    ["Hecatia1"] = SQColor.PURPLE,
    ["Hecatia2"] = SQColor.PURPLE,
    ["Hecatia3"] = SQColor.PURPLE,

    ["EternityLarva"] = SQColor.GREEN,
    ["Nemuno"] = SQColor.ORANGE,
    ["Aunn"] = SQColor.RED,
    ["Narumi"] = SQColor.CYAN,
    ["Satono"] = SQColor.PURPLE,
    ["Mai"] = SQColor.GREEN,
    ["Okina1"] = SQColor.PURPLE,
    ["Okina2"] = SQColor.YELLOW,

    ["Eika"] = SQColor.RED,
    ["Urumi"] = SQColor.CYAN,
    ["Kutaka"] = SQColor.YELLOW,
    ["Yachie"] = SQColor.RED,
    ["Mayumi"] = SQColor.PURPLE,
    ["Keiki"] = SQColor.RED,
    ["Saki"] = SQColor.PURPLE,

    ["Sumireko"] = SQColor.PURPLE,

    ["Kokoro"] = SQColor.CYAN,
    ["Jyoon"] = SQColor.ORANGE
}

WalkImage.LoadFunc = {}
local number_n, bt_n, bt_m, w, h, count
local GetTextureSize = GetTextureSize
local LoadImage = LoadImage
local SetImageCenter = SetImageCenter
local int = int
for name, data in pairs(WalkImage.imglist) do
    WalkImage.LoadFunc[name] = function()
        number_n = {}
        for i = 1, data[1] do
            number_n[i] = data[2]
        end
        count = 0
        bt_n, bt_m = GetTextureSize(name)
        w, h = bt_n / data[2], bt_m / data[1]
        for i = 1, data[1] do
            for j = 0, number_n[i] - 1 do
                LoadImage(name .. i .. (j + 1), name, w * (j % number_n[i]), h * (i - 1) + h * (int(j / number_n[i])), w, h, 16, 16)
                if data[6] and data[7] then
                    SetImageCenter(name .. i .. (j + 1), w / 2 - data[6], h / 2 + data[7])
                end
                count = count + 1
            end
        end
    end
end