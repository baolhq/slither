local vector = require("lib/hump/vector")
local wall = {
    tiles = {}
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
    love.graphics.setColor(WALL_COLOR)
    for _, v in ipairs(self.tiles) do
        love.graphics.rectangle("fill", v.x * TILE_SIZE, v.y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
    end
end

return wall
