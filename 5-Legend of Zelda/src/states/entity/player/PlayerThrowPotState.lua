--[[
    GD50
    Legend of Zelda

    Author: Gerard Cuello
]]

--[[ TODO:
    - PLay audio sound when throwing the pot
]]
PlayerThrowPotState = Class{__includes = BaseState}

function PlayerThrowPotState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
    self.pot = nil

    self.player:changeAnimation('throw-' .. self.player.direction)
end

function PlayerThrowPotState:enter(params)
    self.pot = params.pot
    self.player.currentAnimation.timesPlayed = 0
end

function PlayerThrowPotState:update(dt)

    if self.player.currentAnimation.timesPlayed > 0 then
        self.pot:fire(self.player)
        self.player:changeState('idle')
    end

end

function PlayerThrowPotState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end
