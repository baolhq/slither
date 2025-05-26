local file = require("src/utils/file")
local snake = require("src/entities/snake")
local wall = require("src/entities/wall")
local apple = require("src/entities/apple")

local drawer = require("src/utils/drawer")
local vector = require("lib/hump/vector")

local mainScene = {
    moveTicks = 0,
    moveTickMax = 2,
    score = 0,
    highScore = 0,
    shakeTime = 0,
    shakeDuration = 0.3,
    shakeMagnitude = 5,
    gameState = "playing",
    assets = {}
}

function mainScene:reset()
    snake:reset()
    apple:spawn(snake.body)
    self.score = 0
    self.shakeTime = 0

    self.assets.bgSound:play()
    self.gameState = "playing"
end

function mainScene:load(assets)
    self.highScore = file.loadScore()
    self.assets = assets
    wall:generate(COLS, ROWS)
    apple:init()

    self:reset()
end

function mainScene:keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "space" and self.gameState == "paused" then
        self.gameState = "playing"
    elseif key == "space" then
        self.gameState = "paused"
    end

    if key == "return" then
        self:reset()
    end

    local dirMap = {
        right = vector(1, 0),
        left = vector(-1, 0),
        down = vector(0, 1),
        up = vector(0, -1),
    }
    local newDir = dirMap[key]

    if newDir then
        -- Add to queue only if not reversing current velocity or last queued input
        -- Allows maximum of 2 inputs queued
        local lastDir = #snake.inputQueue > 0 and
            snake.inputQueue[#snake.inputQueue] or snake.velocity
        if lastDir + newDir ~= vector(0, 0) and #snake.inputQueue <= 2 then
            table.insert(snake.inputQueue, newDir)
        end
    end
end

local function isAccelerated()
    if love.keyboard.isDown("right") and snake.velocity.x == 1 then
        return true
    elseif love.keyboard.isDown("left") and snake.velocity.x == -1 then
        return true
    elseif love.keyboard.isDown("down") and snake.velocity.y == 1 then
        return true
    elseif love.keyboard.isDown("up") and snake.velocity.y == -1 then
        return true
    end

    return false
end

function mainScene:update(dt)
    if snake:checkCollision(wall.tiles) then self.gameState = "gameOver" end
    if snake:checkCollision(snake:getBodyTail()) then self.gameState = "gameOver" end

    -- Update screenshake
    if self.shakeTime > 0 then self.shakeTime = self.shakeTime - dt end

    if self.gameState == "gameOver" then
        self.assets.bgSound:stop()

        if not snake.hasExploded then
            snake:explode()
            snake.hasExploded = true
            self.shakeTime = self.shakeDuration
        end

        if self.score > self.highScore then
            self.highScore = self.score
            file.saveScore(self.score)
        end

        snake:update(dt)
        return
    end

    apple:update(dt)
    if self.gameState ~= "paused" then
        self.moveTicks = self.moveTicks + snake.moveSpeed * dt
        if self.moveTicks >= self.moveTickMax then
            snake:update(dt)

            -- Eating apple
            if snake.body[1] == apple.position then
                snake:handleApple(apple.position)
                apple:explode()
                apple:spawn(snake.body)
                self.assets.blipSound:play()
                self.score = self.score + 1
            end

            -- Accelerate if holding directional key
            if isAccelerated() then
                snake.moveSpeed = snake.maxSpeed
            else
                snake.moveSpeed = snake.baseSpeed
            end

            self.moveTicks = self.moveTicks - self.moveTickMax
        end
    end
end

function mainScene:draw()
    love.graphics.clear(BG_COLOR)

    -- Apply screenshake
    local offsetX, offsetY = 0, 0
    if self.shakeTime > 0 then
        offsetX = love.math.random(-self.shakeMagnitude, self.shakeMagnitude)
        offsetY = love.math.random(-self.shakeMagnitude, self.shakeMagnitude)
    end
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- Draw map
    love.graphics.setColor(TILE_COLOR)
    for i = 0, COLS do
        for j = 0, ROWS do
            love.graphics.rectangle("line", i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end

    wall:draw()
    snake:draw()
    apple:draw()

    love.graphics.pop()

    -- Draw paused
    if self.gameState == "paused" then
        drawer:drawCenteredText("GAME PAUSED", self.assets.mainFont, -14)
        drawer:drawCenteredText("PRESS <SPACE> TO RESUME", self.assets.subFont, 14)
    end

    -- Draw game over
    if self.gameState == "gameOver" then
        local scoreText = "YOUR SCORE: " .. string.format("%04d", self.score)
        local highScoreText = "HIGH SCORE: " .. string.format("%04d", self.highScore)

        drawer:drawCenteredText("GAME OVER", self.assets.mainFont, -28)
        drawer:drawCenteredText(scoreText, self.assets.subFont, 0)
        drawer:drawCenteredText(highScoreText, self.assets.subFont, 20)
        drawer:drawCenteredText("PRESS <ENTER> TO RESTART", self.assets.subFont, 48)
    end
end

return mainScene
