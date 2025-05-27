local const = require("src/global/const")
local file = {}

-- Save only the five highest scores
function file.saveScore(scores)
    -- Sort and keep top 5
    table.sort(scores, function(a, b)
        return a > b
    end)

    -- Build the list to save
    local lines = {}
    for i = 1, math.min(5, #scores) do
        table.insert(lines, tostring(scores[i]))
    end

    local content = table.concat(lines, "\n")
    love.filesystem.write(const.SAVE_PATH, content)
end

function file.loadScore()
    local result = {}

    if love.filesystem.getInfo(const.SAVE_PATH) then
        for line in love.filesystem.lines(const.SAVE_PATH) do
            table.insert(result, tonumber(line))
        end
    end

    return result
end

return file
