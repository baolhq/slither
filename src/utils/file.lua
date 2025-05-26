local file = {}

function file.saveScore(score)
    love.filesystem.write("highscore.txt", tostring(score))
end

function file.loadScore()
    if love.filesystem.getInfo("highscore.txt") then
        local contents = love.filesystem.read("highscore.txt")
        return tonumber(contents) or 0
    end
    return 0
end

return file
