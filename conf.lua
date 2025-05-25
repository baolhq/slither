-- Global constants
require("src/global/constants")
require("src/global/colors")

-- Set up initial stuffs
function love.conf(t)
    t.window.width = ROWS * TILE_SIZE
    t.window.height = COLS * TILE_SIZE
end
