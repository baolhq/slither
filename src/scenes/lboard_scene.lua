local drawer = require("src/utils/drawer")
local file = require("src/utils/file")
local const = require("src/global/const")
local colors = require("src/global/colors")

local lboard_scene = {
    assets = {},
    actions = {},
    highScores = {},
}

local backBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "BACK",
    hovered = false,
}

function lboard_scene:load(assets, actions)
    self.assets = assets
    self.actions = actions
    self.highScores = file.loadScore()

    backBtn.x = (love.graphics.getWidth() - backBtn.width) / 2
    backBtn.y = (love.graphics.getHeight() - backBtn.height) / 2 + 92
end

function lboard_scene:keypressed(key)
    if key == "escape" then
        self.actions.switchScene("title")
    end
end

function lboard_scene:mousepressed(x, y, btn)
    if btn == 1 and backBtn.hovered then
        self.actions.switchScene("title")
    end
end

function lboard_scene:update(dt)
    local mx, my = love.mouse.getPosition()
    backBtn.hovered =
        mx > backBtn.x and mx < backBtn.x + backBtn.width and
        my > backBtn.y and my < backBtn.y + backBtn.height
end

function lboard_scene:draw()
    love.graphics.clear(colors.BG)
    drawer:drawCenteredText("LEADERBOARD", self.assets.mainFont, -84)

    for i = 1, 5 do
        local score = self.highScores[i] or 0
        local text = "?????  " .. string.rep(".", 40) .. "  " .. string.format("%04d", score)
        drawer:drawCenteredText(text, self.assets.subFont, i * const.TILE_SIZE - 48)
    end

    drawer:drawButton(backBtn, self.assets.subFont)
end

return lboard_scene
