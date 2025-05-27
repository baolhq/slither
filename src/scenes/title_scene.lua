local drawer = require("src/utils/drawer")
local colors = require("src/global/colors")

local titleScene = {
    assets = {},
}

local startBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "START",
    hovered = false
}

function titleScene:load(assets, actions)
    self.assets = assets
    self.actions = actions
end

function titleScene:mousepressed(x, y, btn)
    if btn == 1 and startBtn.hovered then
        self.actions.switchScene("main")
    end
end

function titleScene:update(dt)
    local mx, my = love.mouse.getPosition()
    startBtn.hovered =
        mx > startBtn.x and mx < startBtn.x + startBtn.width and
        my > startBtn.y and my < startBtn.y + startBtn.height
end

function titleScene:draw()
    love.graphics.clear(colors)

    drawer:drawCenteredText("SLITHER", self.assets.mainFont, -28)

    -- Draw centered button
    startBtn.x = (love.graphics.getWidth() - startBtn.width) / 2
    startBtn.y = (love.graphics.getHeight() - startBtn.height) / 2 + 28
    drawer:drawButton(startBtn, self.assets.subFont)
end

return titleScene
