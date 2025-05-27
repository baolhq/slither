local vector = require("lib/hump/vector")
local array = require("src/utils/array")
local const = require("src/global/const")
local rng = {}

function rng.getFreePos(snakeBody)
    local freePos = {}

    for i = 1, const.GRID_ROWS - 2, 1 do
        for j = 1, const.GRID_COLS - 2, 1 do
            local pos = vector(i, j)
            if not array.contains(snakeBody, pos) then
                table.insert(freePos, pos)
            end
        end
    end

    if #freePos == 0 then
        print("No room for new apple :(")
    end

    return freePos[love.math.random(#freePos)]
end

return rng
