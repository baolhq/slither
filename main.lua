local sceneManager = require("src/managers/scene_manager")
local const = require("src/global/const")
local lick = require("lib/lick")
lick.reset = true -- Enable hot reload

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

-- Shared assets
local assets = {}

function love.load()
    love.window.setTitle(const.GAME_TITTLE)
    local gameIcon = love.image.newImageData("res/img/icon.png")
    love.window.setIcon(gameIcon)

    assets.mainFont = love.graphics.newFont("res/font/Valorant.ttf", const.FONT_MAIN_SIZE)
    assets.subFont = love.graphics.newFont("res/font/Valorant.ttf", const.FONT_SUB_SIZE)
    assets.bgSound = love.audio.newSource("res/audio/background.ogg", "stream")
    assets.blipSound = love.audio.newSource("res/audio/blip.wav", "static")
    assets.bgSound:setLooping(true)
    assets.blipSound:setVolume(0.5)

    sceneManager:switch("title", assets)
end

function love.keypressed(key)
    sceneManager:keypressed(key)
end

function love.mousepressed(x, y, btn)
    sceneManager:mousepressed(x, y, btn)
end

function love.update(dt)
    sceneManager:update(dt)
end

function love.draw()
    sceneManager:draw()
end
