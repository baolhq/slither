local vector = require("lib/hump/vector")
local file = require("src/utils/file")
local snake = require("src/entities/snake")
local wall = require("src/entities/wall")
local apple = require("src/entities/apple")
local const = require("src/global/const")
local colors = require("src/global/colors")
local drawer = require("src/utils/drawer")

local mainScene = {
    assets = {},
    actions = {},
    moveTicks = 0,
    moveTickMax = 2,
    score = 0,
    highScores = {},
    shakeTime = 0,
    shakeDuration = 0.3,
    shakeMagnitude = 5,
    gameState = "playing",
    scoreSaved = false,
}

function mainScene:reset()
    snake:reset()
    apple:spawn(snake.body)
    self.score = 0
    self.shakeTime = 0

    self.assets.bgSound:play()
    self.gameState = "playing"
end

function mainScene:load(assets, actions)
    self.assets = assets
    self.actions = actions
    self.highScores = file.loadScore()
    wall:generate(const.GRID_COLS, const.GRID_ROWS)
    apple:init()

    self:reset()
end

function mainScene:keypressed(key)
    if key == "space" and self.gameState == "paused" then
        self.gameState = "playing"
    elseif key == "escape" then
        self.actions.switchScene("title")
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

        -- Saving high score and push lower scores below
        if not self.scoreSaved then
            table.insert(self.highScores, self.score)
            table.sort(self.highScores, function(a, b)
                return a > b
            end)

            while #self.highScores > 5 do
                table.remove(self.highScores)
            end
            file.saveScore(self.highScores)
            self.scoreSaved = true
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
    love.graphics.clear(colors.BG)

    -- Apply screenshake
    local offsetX, offsetY = 0, 0
    if self.shakeTime > 0 then
        offsetX = love.math.random(-self.shakeMagnitude, self.shakeMagnitude)
        offsetY = love.math.random(-self.shakeMagnitude, self.shakeMagnitude)
    end

    -- Save current screen state into the stack
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- Draw map
    love.graphics.setColor(colors.TILE)
    for i = 0, const.GRID_COLS do
        for j = 0, const.GRID_ROWS do
            love.graphics.rectangle(
                "line",
                i * const.TILE_SIZE,
                j * const.TILE_SIZE,
                const.TILE_SIZE,
                const.TILE_SIZE
            )
        end
    end

    wall:draw()
    snake:draw()
    apple:draw()

    -- Load previous screen state
    love.graphics.pop()
    -- We don't shake UI elements below

    -- Draw paused
    if self.gameState == "paused" then
        drawer:drawCenteredText("GAME PAUSED", self.assets.mainFont, -14)
        drawer:drawCenteredText("PRESS <SPACE> TO RESUME", self.assets.subFont, 14)
    end

    -- Draw game over
    if self.gameState == "gameOver" then
        local scoreText = "YOUR SCORE: " .. string.format("%04d", self.score)
        local highScoreText = "HIGH SCORE: " .. string.format("%04d", self.highScores[1])

        drawer:drawCenteredText("GAME OVER", self.assets.mainFont, -28)
        drawer:drawCenteredText(scoreText, self.assets.subFont, 0)
        drawer:drawCenteredText(highScoreText, self.assets.subFont, 20)
        drawer:drawCenteredText("PRESS <ENTER> TO RESTART", self.assets.subFont, 48)
    end
end

return mainScene
