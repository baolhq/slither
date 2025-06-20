local colors = require "src/global/colors"

local drawer = {
    screenW = love.graphics.getWidth(),
    screenH = love.graphics.getHeight()
}

function drawer:drawCenteredText(text, font, yOffset)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()

    local x = math.floor((self.screenW - textWidth) / 2 + 0.5)
    local y = math.floor((self.screenH - textHeight) / 2 + 0.5) + yOffset

    love.graphics.print(text, x, y)
end

function drawer:drawButton(button, font)
    -- Hover effect
    if button.hovered then
        love.graphics.setColor(colors.BTN_HIGHLIGHT)
    else
        love.graphics.setColor(colors.BTN)
    end

    -- Button rectangle
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 4, 4)

    -- Button outline on focused
    if button.focused then
        love.graphics.setColor(colors.BTN_HIGHLIGHT)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 4, 4)
    end

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(button.text)
    local textHeight = font:getHeight()
    love.graphics.print(button.text,
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2
    )
end

return drawer
