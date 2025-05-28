local drawer = require("src/utils/drawer")
local colors = require("src/global/colors")

local titleScene = {
    assets = {},
}

local startBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "START",
    focused = true,
    hovered = false,
}

local lboardBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "LEADERBOARD",
    focused = false,
    hovered = false,
}

function titleScene:load(assets, actions)
    self.assets = assets
    self.actions = actions
end

function titleScene:keypressed(key)
    if key == "escape" then self.actions.quit() end

    if key == "return" then
        if startBtn.focused then
            self.actions.switchScene("main")
        elseif key == "return" and lboardBtn.focused then
            self.actions.switchScene("leaderboard")
        end
        return
    end

    if key == "tab" or key == "up" or key == "down" then
        startBtn.focused = not startBtn.focused
        lboardBtn.focused = not lboardBtn.focused
    end
end

function titleScene:mousepressed(x, y, btn)
    if btn == 1 and startBtn.hovered then
        startBtn.focused = true
        lboardBtn.focused = false
        self.actions.switchScene("main")
    elseif btn == 1 and lboardBtn.hovered then
        startBtn.focused = false
        lboardBtn.focused = true
        self.actions.switchScene("leaderboard")
    end
end

function titleScene:update(dt)
    local mx, my = love.mouse.getPosition()
    startBtn.hovered =
        mx > startBtn.x and mx < startBtn.x + startBtn.width and
        my > startBtn.y and my < startBtn.y + startBtn.height

    lboardBtn.hovered =
        mx > lboardBtn.x and mx < lboardBtn.x + lboardBtn.width and
        my > lboardBtn.y and my < lboardBtn.y + lboardBtn.height
end

function titleScene:draw()
    love.graphics.clear(colors.BG)

    drawer:drawCenteredText("SLITHER", self.assets.mainFont, -28)

    -- Draw start button
    startBtn.x = (love.graphics.getWidth() - startBtn.width) / 2
    startBtn.y = (love.graphics.getHeight() - startBtn.height) / 2 + 48
    drawer:drawButton(startBtn, self.assets.subFont)

    -- Draw leaderboard button
    lboardBtn.x = startBtn.x
    lboardBtn.y = startBtn.y + 48
    drawer:drawButton(lboardBtn, self.assets.subFont)
end

return titleScene
