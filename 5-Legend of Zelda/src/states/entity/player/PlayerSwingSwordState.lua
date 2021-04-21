--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerSwingSwordState = Class{__includes = BaseState}

function PlayerSwingSwordState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 8

    -- create hitbox based on where the player is and facing
    local direction = self.player.direction
    
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight

    if direction == 'left' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x - hitboxWidth
        hitboxY = self.player.y + 2
    elseif direction == 'right' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x + self.player.width
        hitboxY = self.player.y + 2
    elseif direction == 'up' then
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y - hitboxHeight
    else
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y + self.player.height
    end

    self.swordHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
    self.player:changeAnimation('sword-' .. self.player.direction)
end

function PlayerSwingSwordState:enter(params)
    gSounds['sword']:stop()
    gSounds['sword']:play()

    -- restart sword swing animation
    self.player.currentAnimation:refresh()
end

function PlayerSwingSwordState:update(dt)
    -- check if hitbox collides with any entities in the scene
    for k, entity in pairs(self.dungeon.currentRoom.entities) do
        if entity:collides(self.swordHitbox) and not entity.dead then
            entity:damage(1)
            gSounds['hit-enemy']:play()

            if entity.health == 0 and self:spawnHeart(CHANCE_SPAWN_HEART) then
                gSounds['powerup-reveal']:play()
                local heart = GameObject(
                    GAME_OBJECT_DEFS['hearts'],
                    -- hearts are half of the size of entities so we want to place the heart
                    -- on the middle of the entity (that's the math below)
                    entity.x + (entity.width * 0.5) * 0.5,
                    entity.y + (entity.height * 0.5) * 0.5
                )
                heart.onConsume = function(player)
                    gSounds['pickup']:play()
                    player.health = math.min(player.health + 2, 6)
                end

                table.insert(self.dungeon.currentRoom.objects, heart)
            end
        end
    end

    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    end

    if love.keyboard.wasPressed('space') then
        self.player:changeState('swing-sword')
    end
end

function PlayerSwingSwordState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

    -- debug for player and hurtbox collision rects
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    -- love.graphics.rectangle('line', self.swordHitbox.x, self.swordHitbox.y,
    --     self.swordHitbox.width, self.swordHitbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end

function PlayerSwingSwordState:spawnHeart(chance)
    return math.random(chance) == 1
end