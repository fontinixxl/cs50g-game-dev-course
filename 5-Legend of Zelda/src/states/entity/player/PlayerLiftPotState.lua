--[[
    GD50
    Legend of Zelda

    Author: Gerard Cuello
]]

--[[ TODO:
    - PLay audio sound when lifting the pot
]]
PlayerLiftPotState = Class{__includes = BaseState}

function PlayerLiftPotState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
    self.pot = nil

    self.player:changeAnimation('lift-' .. self.player.direction)
end

function PlayerLiftPotState:enter(params)
    self.pot = params.pot
    self.pot.state = 'lifted'
end

function PlayerLiftPotState:update(dt)

    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        -- update pot's coordinates based on player's once the animation is completed
        -- TODO: move logic to the GameObject class
        self.pot.x = self.player.x
        self.pot.y = self.player.y - self.pot.height + 8
        self.player:changeState('idle-pot', {pot = self.pot})
    end

end

function PlayerLiftPotState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end
