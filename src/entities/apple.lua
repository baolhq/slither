local rng = require("src/utils/rng")
local const = require("src/global/const")
local colors = require("src/global/colors")

local apple = {
    position = {},
    particle = {},
    activateParticles = false,
    particleTimer = 0,
}

function apple:spawn(snakeBody)
    self.position = rng.getFreePos(snakeBody)
end

function apple:update(dt)
    if self.activateParticles then
        self.particle:update(dt)
        self.particleTimer = self.particleTimer + dt
        if self.particleTimer > 1 then
            self.activateParticles = false
        end
    end
end

function apple:draw()
    love.graphics.setColor(colors.APPLE)
    love.graphics.rectangle(
        "fill",
        self.position.x * const.TILE_SIZE,
        self.position.y * const.TILE_SIZE,
        const.TILE_SIZE,
        const.TILE_SIZE
    )

    if self.activateParticles then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.particle)
    end
end

local function initParticle()
    local img = love.graphics.newImage("res/img/rectangle.png")
    local ps = love.graphics.newParticleSystem(img, 100)

    ps:setParticleLifetime(0.8, 1.2)
    ps:setEmissionRate(0)
    ps:setSizes(1.0, 0.6, 0.2)
    ps:setSpeed(40, 100)
    ps:setSpread(math.pi * 2)
    ps:setLinearDamping(1.5, 2.5)
    ps:setRadialAcceleration(-20, -50)
    ps:setColors(0.8, 0.8, 0.8, 1, 0.2, 0.2, 0.2, 0)

    return ps
end

function apple:init()
    self.particle = initParticle()
end

function apple:explode()
    self.particle:setPosition(
        self.position.x * const.TILE_SIZE + const.TILE_SIZE / 2,
        self.position.y * const.TILE_SIZE + const.TILE_SIZE / 2
    )
    self.particle:emit(10)
    self.activateParticles = true
    self.particleTimer = 0
end

return apple
