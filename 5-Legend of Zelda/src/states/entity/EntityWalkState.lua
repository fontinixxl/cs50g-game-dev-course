--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity, dungeon)
    self.entity = entity
    self.entity:changeAnimation('walk-down')

    self.dungeon = dungeon

    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

    -- keeps track of whether we just hit a wall
    self.bumped = false
end

function EntityWalkState:update(dt)
    
    -- assume we didn't hit a wall
    self.bumped = false

    if self.entity.direction == 'left' then
        self.entity.x = self.entity.x - self.entity.walkSpeed * dt
        
        if self.entity.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.entity.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
    elseif self.entity.direction == 'right' then
        self.entity.x = self.entity.x + self.entity.walkSpeed * dt

        if self.entity.x + self.entity.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.entity.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.entity.width
            self.bumped = true
        end
    elseif self.entity.direction == 'up' then
        self.entity.y = self.entity.y - self.entity.walkSpeed * dt

        if self.entity.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2 then 
            self.entity.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2
            self.bumped = true
        end
    elseif self.entity.direction == 'down' then
        self.entity.y = self.entity.y + self.entity.walkSpeed * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.entity.y + self.entity.height >= bottomEdge then
            self.entity.y = bottomEdge - self.entity.height
            self.bumped = true
        end
    end
end

function EntityWalkState:processAI(params, dt)
    local room = params.room

    -- check whether the entity collides with a solid object
    -- and mark it as bumped to change it's direction
    self:checkObjectsCollision(room.objects)

    local directions = {'left', 'right', 'up', 'down'}

    if self.movDeuration == 0 or self.bumped then

        -- set an initial move duration and direction
        self.moveDuration = math.random(5)
        self.entity.direction = directions[math.random(#directions)]
        self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0

        -- chance to go idle
        if math.random(3) == 1 then
            self.entity:changeState('idle')
        else
            self.moveDuration = math.random(5)
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
        end
    end

    self.movementTimer = self.movementTimer + dt

end

--[[
    Check collisions with solid objects and adjust entity position
    according to the direction they collide with the object.

    When there is a collision with a solid object, for each direction
    ensure the object is in fact blocking.
]]
function EntityWalkState:checkObjectsCollision(objects)

    for k, object in pairs(objects) do
        if self.entity:collides(object) and object.solid and object.state == 'ground' then
            if self.entity.direction == 'left' then
                if self.entity.x < object.x + object.width
                    and object.y + object.height > self.entity.y + self.entity.height / 2
                    and (object.y < self.entity.y + self.entity.height)
                then
                    self.entity.x = object.x + object.width
                    self.bumped = true
                end
            elseif self.entity.direction == 'right' then
                if self.entity.x + self.entity.width > object.x
                    and object.y + object.height > self.entity.y + self.entity.height / 2
                    and object.y < self.entity.y + self.entity.height
                then
                    self.entity.x = object.x - self.entity.width
                    self.bumped = true
                end
            elseif self.entity.direction == 'up' then
                if self.entity.y + self.entity.height / 2 < object.y + object.height
                    and object.x + object.width > self.entity.x
                    and object.x < self.entity.x + self.entity.width
                then
                    self.entity.y = object.y + object.height - self.entity.height / 2
                    self.bumped = true
                end
            elseif self.entity.direction == 'down' then
                if self.entity.y + self.entity.height > object.y and self.entity.y < object.y
                    and self.entity.x < object.x + object.width
                    and self.entity.x + self.entity.width > object.x
                then
                    self.entity.y = object.y - self.entity.height
                    self.bumped = true
                end
            end
        end
    end
end

function EntityWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end