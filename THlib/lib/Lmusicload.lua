local j = 1
---导入音乐
function AddMusic(id, name, loopend, looplen, source_name)
    table.insert(LoadRes, function()
        id = tostring(id)
        local sourcePath = ("assets\\music\\%s.ogg"):format(source_name)
        if not musicList[id] then
            local str = "Music" .. id
            musicList[id] = { loopend, looplen, name, str, j, sourcePath }
            j = j + 1
        end
    end)
end


---音乐表初始化
function InitMusicList()
    musicList = {}
end