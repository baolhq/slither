local vector = require("lib/hump/vector")
local lick = require("lib/lick")
lick.reset = true -- Enable hot reload

local drawer = require("src/utils/drawer")
local snake = require("src/entities/snake")
local apple = require("src/entities/apple")
local wall = require("src/entities/wall")

--#region Debugger setup
local love_errorhandler = love.errorhandler
-- Enables code debugger via launch.json
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Tell Love to throw an error instead of showing it on screen
function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end

--#endregion

local moveTicks = 0
local moveTickMax = 2
local score = 0
local highScore = 0
local shakeTime = 0
local shakeDuration = 0.3
local shakeMagnitude = 5

local gameState = "playing" -- "playing", "paused", "gameOver"
local mainFont = {}
local scoreFont = {}
local bgSound = {}
local blipSound = {}

local function reset()
    snake:reset()
    apple:spawn(snake.body)
    score = 0
    shakeTime = 0

    bgSound:setLooping(true)
    bgSound:play()
    gameState = "playing"
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

local function saveHighScore()
    love.filesystem.write("highscore.txt", tostring(score))
end

local function loadHighScore()
    if love.filesystem.getInfo("highscore.txt") then
        local contents = love.filesystem.read("highscore.txt")
        return tonumber(contents) or 0
    end
    return 0
end

function love.load()
    local icon = love.image.newImageData("res/img/icon.png")
    love.window.setTitle(GAME_TITTLE)
    love.window.setIcon(icon)

    highScore = loadHighScore()
    wall:generate(COLS, ROWS)
    apple:init()

    mainFont = love.graphics.newFont("res/font/Valorant.ttf", FONT_MAIN_SIZE)
    scoreFont = love.graphics.newFont("res/font/Valorant.ttf", FONT_SUB_SIZE)
    bgSound = love.audio.newSource("res/audio/background.ogg", "stream")
    blipSound = love.audio.newSource("res/audio/blip.wav", "static")
    blipSound:setVolume(0.5)
    reset()
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "space" and gameState == "paused" then
        gameState = "playing"
    elseif key == "space" then
        gameState = "paused"
    end

    if key == "return" then
        reset()
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

function love.update(dt)
    if snake:checkCollision(wall.tiles) then gameState = "gameOver" end
    if snake:checkCollision(snake:getBodyTail()) then gameState = "gameOver" end

    -- Update screenshake
    if shakeTime > 0 then shakeTime = shakeTime - dt end

    if gameState == "gameOver" then
        bgSound:stop()

        if not snake.hasExploded then
            snake:explode()
            snake.hasExploded = true
            shakeTime = shakeDuration
        end

        if score > highScore then
            highScore = score
            saveHighScore()
        end

        snake:update(dt)
        return
    end

    apple:update(dt)
    if gameState ~= "paused" then
        moveTicks = moveTicks + snake.moveSpeed * dt
        if moveTicks >= moveTickMax then
            snake:update(dt)

            -- Eating apple
            if snake.body[1] == apple.position then
                snake:handleApple(apple.position)
                apple:explode()
                apple:spawn(snake.body)
                blipSound:play()
                score = score + 1
            end

            -- Accelerate if holding directional key
            if isAccelerated() then
                snake.moveSpeed = snake.maxSpeed
            else
                snake.moveSpeed = snake.baseSpeed
            end

            moveTicks = moveTicks - moveTickMax
        end
    end
end

function love.draw()
    love.graphics.clear(BG_COLOR)

    -- Apply screenshake
    local offsetX, offsetY = 0, 0
    if shakeTime > 0 then
        offsetX = love.math.random(-shakeMagnitude, shakeMagnitude)
        offsetY = love.math.random(-shakeMagnitude, shakeMagnitude)
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
    if gameState == "paused" then
        drawer:drawCenteredText("GAME PAUSED", mainFont, -14)
        drawer:drawCenteredText("PRESS <SPACE> TO RESUME", scoreFont, 14)
    end

    -- Draw game over
    if gameState == "gameOver" then
        drawer:drawCenteredText("GAME OVER", mainFont, -28)
        drawer:drawCenteredText("YOUR SCORE: " .. string.format("%04d", score), scoreFont, 0)
        drawer:drawCenteredText("HIGH SCORE: " .. string.format("%04d", highScore), scoreFont, 20)
        drawer:drawCenteredText("PRESS <ENTER> TO RESTART", scoreFont, 48)
    end
end
