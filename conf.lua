local const = require("src/global/const")

-- Set up initial stuffs
function love.conf(t)
    t.window.width = const.GRID_ROWS * const.TILE_SIZE
    t.window.height = const.GRID_COLS * const.TILE_SIZE
end
