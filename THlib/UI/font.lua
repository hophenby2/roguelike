
local path = "assets\\UI\\font\\"
local ntext1 = path .. "text.otf"
local ntext2 = path .. "text2.ttf"
LoadTTF("pretty_title", ntext2, 32)
LoadTTF("pretty", ntext2, 80)
LoadTTF("title", ntext1, 32)
LoadTTF("big_text", ntext1, 80)
--LoadTTF("huge_text", ntext, 160)
LoadTTF("small_text", ntext1, 28)

--LoadTTF("sc_menu", ntext, 26)
--LoadTTF("manual", ntext, 25)
--LoadTTF('sc_name', ntext[2], 26)

LoadFont('Score', path .. 'score_new.fnt', false)
--LoadFont('time', path .. 'score_new_score.fnt', true)
LoadFont('replay', path .. 'replay.fnt', false)

