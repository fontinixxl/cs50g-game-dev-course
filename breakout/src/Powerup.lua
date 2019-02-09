
Powerup = Class{}

function Powerup:init(x, y, tier)
    self.x = x
    self.y = y
    self.tier = tier

    -- TODO: make velocity dependent on the game level we currently are (more level more speed)
    self.dy = 50

    self.width = 16
    self.height = 16

    self.ingame = true
    
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

-- TODO: inherit somehow from some general AABB collission method as it's used by more than one method.
function Powerup:collides(target)
    -- if the Power Up hasn't arrived to the paddle or it has passed, no collision
    if (self.y + self.height < target.y) or (self.y > target.y + target.height) then
        return false
    end
    -- if the PowerUp isn't inside the limits of the paddle
    if (self.x + self.width < target.x) or (self.x > target.x + target.width) then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true

end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.tier], self.x, self.y)
end