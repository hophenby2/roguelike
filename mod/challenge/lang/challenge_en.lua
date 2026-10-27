local dict = {
    ["正体不明的X"] = "X is equal to ?",
    des1 = [[Initial Chaos are §r12.5%§d
When Upgrading, §ronly§d §g+5§d Maxlife
The weather is fixed to /w76]],
    ["测测你的"] = "Geogebra",
    des2 = [[Initially gain 1 /t78, 1 /t126
/player can't shoot, Upgrading can't select, §yno Boss wave
For every 2 levels, gain 1 /t78]],
    ["贪吃蛇"] = "SNAKE!!",
    des3 = [[Initially gain 3 /t143, 1 /t131
For every levels, gain 1 /t143]],
    ["好了知道你是0了"] = "OK I know you are BOTTOM",
    des4 = [[Path of Pain #34
Initially gain all 0 Quality Items (except /t134)
Enabling §b/wxsys§d]],
    ["尘肺病"] = "Pneumoconiosis",
    des5 = [[The weather is fixed to /w37]],
    ["我是地质学家，这就是神金"] = "F~I~R~E",
    des6 = [[Initially gain 3 /t38
§rBan low Speed
The weather is fixed to /w29]],
    ["打妖精"] = "Hit Yousei",
    des7 = [[Initially gain /t64, §rPlayer Stops All Actions§d
Use §yMOUSE§d to control /player, Use §yMOUSE LEFT§d to hit small-area strikes on enemies
Enabling §b/wxsys§d]],
    ["东方游戏手机版"] = "Touhou Mobile Game",
    des8 = [[Use §yMOUSE§d to control /player
Enabling §b/wxsys§d]],
    ["蓬莱之药"] = "Hourai's Medicine",
    des9 = [[As you progress, the game slows from §c2x§d to §c0.25x speed.
Enabling §b/wxsys§d]],
    ["滑动变阻器"] = "Made in Heaven",
    des10 = [[Initial Chaos are §r30%§d, Enabling §b/wxsys§d
Game speed increases gradually to §c6x§d while moving,
and decreases to §c0x§d when stationary]],
    ["收起你的小霁霁"] = "Holy Light",
    des11 = [[All comes with §rhigh-powered motion blur§d!!
Enabling §b/wxsys§d]],
    ["新「文」直播间"] = "Live Ayas Studio",
    des12 = [[The camera zooms in and automatically follows §pthe most bullet-dense area.
Enabling §b/wxsys§d]],
    ["引力超大的(魔理沙)"] = "Kirisame Gigantic",
    des13 = [[Initially gain /t86，/player shoots §gGreen Bullet§d forever
/player has a strong §rattraction§d to objects.
Chaos grows §gextremely slowly§d, Enabling §b/wxsys§d]],
    ["东方弹幕风"] = "TOUHOU DANMUKUFU",
    des14 = [[Game FPS gradually §cdecreases§d as the number of objs increases.
Press §ySpace§d to speed up the game. All boss sprites are §rRumia§d.
Enabling §b/wxsys§d]],
    ["只能听见歌声了"] = "Deaf to All but the Song",
    des15 = [[All are rendered using an unusual blend mode.
Enabling §b/wxsys§d]],
    ["塔防游戏"] = "Tower Defense",
    des16 = [[Initially gain /t197，BulletV Power fixed to §r0§d，Range Power §g+33%
Killing an fairy gets §g0.1 Range§d and a slight Range Power.
Enabling §b/wxsys§d]],
    ["乾坤大挪移"] = "Celestial Shift",
    des17 = [[Initially gain /t72
When /player move, all entities get reversed /w30
Enabling §b/wxsys§d]],
    ["等比稀释"] = "One Makes You Small",
    des18 = [[All entities are greatly §pscaled down§d.
Enabling §b/wxsys§d]],
    ["昨日重现"] = "Yesterday Once More",
    des19 = [[Initially gain /t179, /t119, §gItem collect line drops by 600
Enemy bullets move §g40% slower§d. When /hitbes are disabled, their speed becomes §r0§d.
The weather is fixed to /w60]],
    ["这就是你想要的无尽模式"] = "Endless mode? You got it.",
    des20 = [[§rHard Boss Wave§d can appear infinitely.
The max wave number is always §b2 waves§d higher than the current wave.
If the current wave is over §b20§d, the §gchallenge is complete§d.]],
    ["布朗运动"] = "Brownian Movement",
    des21 = [[Enemy bullets follow §rBrownian motion§d.
The higher the Chaos, the greater the average kinetic energy of the bullets.
Enabling §b/wxsys§d]],
}
for k, v in pairs(dict) do
    dict[k] = ReplaceTextWithCommand(v)
end
return dict