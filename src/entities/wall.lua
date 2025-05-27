local vector = require("lib/hump/vector")
local colors = require("src/global/colors")
local const = require("src/global/const")

local wall = {
    tiles = {},
}

function wall:generate(cols, rows)
    self.tiles = {}

    for i = 0, cols do
        table.insert(self.tiles, vector(0, i))
        table.insert(self.tiles, vector(cols - 1, i))
    end

    for i = 0, rows do
        table.insert(self.tiles, vector(i, 0))
        table.insert(self.tiles, vector(i, rows - 1))
    end
end

function wall:draw()
    love.graphics.setColor(colors.WALL)
    for _, v in ipairs(self.tiles) do
        love.graphics.rectangle(
            "fill",
            v.x * const.TILE_SIZE,
            v.y * const.TILE_SIZE,
            const.TILE_SIZE,
            const.TILE_SIZE
        )
    end
end

return wall
