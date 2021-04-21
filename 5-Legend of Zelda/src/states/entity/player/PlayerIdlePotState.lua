--[[
    GD50
    Legend of Zelda

    Author: Gerard Cuello
]]

PlayerIdlePotState = Class{__includes = BaseState}

function PlayerIdlePotState:init(entity)
    self.entity = entity
    self.pot = nil
    self.entity:changeAnimation('idle-pot-' .. self.entity.direction)
end


function PlayerIdlePotState:enter(params)
    self.pot = params.pot
end

function PlayerIdlePotState:update(dt)

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk-pot', {pot = self.pot})
    end

    -- Pressing 'return' carrying a pot will make the player throwing it
    if love.keyboard.wasPressed('return') then
        self.entity:changeState('throw-pot', {pot = self.pot})
    end
end

function PlayerIdlePotState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end