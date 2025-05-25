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

return drawer
