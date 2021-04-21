--[[
    GD50
    Legend of Zelda

    Author: Gerard Cuello
]]

PlayerWalkPotState = Class{__includes = EntityWalkState}

function PlayerWalkPotState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.pot = nil

    self.entity:changeAnimation('walk-pot-' .. self.entity.direction)
end

function PlayerWalkPotState:enter(params)
    self.pot = params.pot
end

function PlayerWalkPotState:update(dt)

    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('walk-pot-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('walk-pot-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('walk-pot-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('walk-pot-down')
    else
        self.entity:changeState('idle-pot', {pot = self.pot})
    end

    -- Pressing 'return' carrying a pot will make the player throwing it
    if love.keyboard.wasPressed('return') then
        self.entity:changeState('throw-pot', {pot = self.pot})
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    EntityWalkState.checkObjectsCollision(self, self.dungeon.currentRoom.objects)

    -- update pot's coordinates based on player's
    self.pot.x = self.entity.x
    self.pot.y = self.entity.y - self.pot.height + 8

end
