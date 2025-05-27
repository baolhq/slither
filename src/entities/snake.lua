local vector = require("lib/hump/vector")
local array = require("src/utils/array")
local const = require("src/global/const")
local colors = require("src/global/colors")

local snake = {
    body = {},
    velocity = vector(1, 0),
    inputQueue = {},
    growMarkers = {},
    baseSpeed = 10,
    moveSpeed = 10,
    accelSpeed = 0.02,
    maxSpeed = 40,
    explosion = {},
    explosionTimer = 0,
    exploding = false,
    hasExploded = false
}

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

function snake:explode()
    self.explosions = {}
    self.explosionTimer = 0
    self.exploding = true

    for i, segment in ipairs(self.body) do
        table.insert(self.explosions, {
            time = (i - 1) * 0.2, -- delay in seconds
            pos = segment,
            triggered = false,
            ps = initParticle()
        })
    end
end

function snake:reset()
    self.body = {
        vector(5, 1),
        vector(4, 1),
        vector(3, 1),
        vector(2, 1),
        vector(1, 1),
    }
    self.velocity = vector(1, 0)
    self.inputQueue = {}
    self.growMarkers = {}
    self.baseSpeed = 10
    self.moveSpeed = 10

    self.explosion = {}
    self.explosionTimer = 0
    self.exploding = false
    self.hasExploded = false
end

function snake:update(dt)
    -- Input queue
    if #self.inputQueue > 0 then
        local nextDir = self.inputQueue[1]
        if not (nextDir.x == -self.velocity.x and nextDir.y == -self.velocity.y) then
            self.velocity = nextDir
        end
        table.remove(self.inputQueue, 1)
    end

    -- Explosion logics
    if self.exploding then
        self.explosionTimer = self.explosionTimer + dt
        for _, e in ipairs(self.explosions) do
            if not e.triggered and self.explosionTimer >= e.time then
                e.ps:setPosition(
                    e.pos.x * const.TILE_SIZE + const.TILE_SIZE / 2,
                    e.pos.y * const.TILE_SIZE + const.TILE_SIZE / 2
                )
                e.ps:emit(10)
                e.triggered = true
            end
            e.ps:update(dt)
        end
    else
        -- Move snake
        local newHead = self.body[1] + self.velocity
        table.insert(self.body, 1, newHead)

        -- Grow or trim tail
        if #self.growMarkers > 0 and self.body[#self.body] == self.growMarkers[1] then
            table.remove(self.growMarkers, 1)
        else
            table.remove(self.body)
        end
    end
end

function snake:handleApple(applePos)
    table.insert(self.growMarkers, applePos)
    self.moveSpeed = self.moveSpeed + self.accelSpeed * (self.maxSpeed - self.moveSpeed)
    self.baseSpeed = self.baseSpeed + self.accelSpeed * (self.maxSpeed - self.baseSpeed)
end

function snake:draw()
    love.graphics.setColor(colors.SNAKE)
    for i = 2, #self.body do
        local p = self.body[i]
        love.graphics.rectangle(
            "fill",
            p.x * const.TILE_SIZE,
            p.y * const.TILE_SIZE,
            const.TILE_SIZE, const.TILE_SIZE
        )
    end
    local head = self.body[1]
    love.graphics.setColor(colors.SNAKE_HEAD)
    love.graphics.rectangle(
        "fill",
        head.x * const.TILE_SIZE,
        head.y * const.TILE_SIZE,
        const.TILE_SIZE,
        const.TILE_SIZE
    )

    if self.exploding then
        love.graphics.setColor(1, 1, 1, 1)
        for _, e in ipairs(self.explosions) do
            love.graphics.draw(e.ps)
        end
    end
end

function snake:checkCollision(targetList)
    return array.contains(targetList, self.body[1])
end

function snake:getBodyTail()
    return array.slice(self.body, 2, #self.body)
end

return snake
