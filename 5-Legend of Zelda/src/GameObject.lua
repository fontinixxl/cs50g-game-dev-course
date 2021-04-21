--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.collidable = def.collidable

    self.consumable = def.consumable or false

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    self.direction = def.direction or false
    self.originX, self.originY = 0

    -- scale Factor
    self.scaleFactor = def.scaleFactor or 1

    -- default empty collision callback
    self.onCollide = function() end

    self.traveledDistance = 0
end

--[[
    Update Object's coordinates in case it has been thrown by the player.
    If hits a wall or travels more than four tiles, mark it as to be destroyed.
]]
function GameObject:update(dt)

    if self.state == 'thrown' then

        if self.direction == 'left' then

            self.x = self.x - POT_THROW_SPEED * dt

            self.traveledDistance = self.originX - self.x

            if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE
                or self.traveledDistance > MAX_POT_DISTANCE then

                self.state = 'destroyed'
            end
        elseif self.direction == 'right' then

            self.x = self.x + POT_THROW_SPEED * dt
            self.traveledDistance = self.x - self.originX

            if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2
                or self.traveledDistance > MAX_POT_DISTANCE then

                self.state = 'destroyed'
            end
        elseif self.direction == 'up' then

            self.y = self.y - POT_THROW_SPEED * dt
            self.traveledDistance = self.originY - self.y

            if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
                or self.traveledDistance > MAX_POT_DISTANCE then
                self.state = 'destroyed'
            end
        elseif self.direction == 'down' then

            self.y = self.y + POT_THROW_SPEED * dt
            self.traveledDistance = self.y - self.originY

            local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

            if self.y + self.height >= bottomEdge or self.traveledDistance > MAX_POT_DISTANCE then
                self.state = 'destroyed'
            end
        end
    end
end

function GameObject:fire(player)
    self.direction = player.direction
    self.solid = true
    self.originX = self.x
    self.originY = self.y
    self.state = 'thrown'
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)

    -- draw sprite slightly transparent before it disapear after being thrown
    if self.traveledDistance >=  MAX_POT_DISTANCE * 0.85 then
        love.graphics.setColor(255, 255, 255, 64)
    end
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY, 0, self.scaleFactor, self.scaleFactor)

    love.graphics.setColor(255, 255, 255, 255)
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end