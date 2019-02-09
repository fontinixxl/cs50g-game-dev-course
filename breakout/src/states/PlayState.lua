--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

EXTRA_BALLS = 2
PU_MULT_BALL = 9
PU_KEY = 10

function PlayState:init()
    self.numBricksHit = 0
    self.powerUpBallLock = false
    self.powerUps = {}
    -- keep tracking of all the balls in case we catch a PowerUp
    self.balls = {}
    -- timer to controll when to spawn a keyPowerUp
    self.timer = 0
    -- flag to controll if the player has picked the key PowerUP
    self.powerUpKeyFlag = false
    -- flag to controll whether the KeyBlock is in play
    self.lockedBrickRemoved = false
    -- starting value in seconds to spawn a keyPowerUp
    self.keySpawnTimer = 10
end

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level

    self.recoverPoints = params.recoverPoints

    -- give ball random starting velocity
    params.ball.dx = math.random(-200, 200)
    params.ball.dy = -100
    -- params.ball.dy = math.random(-50, -60)
    table.insert(self.balls, params.ball)

    -- we use this to controll if we are in a level where there is a LockedBrick
    self.lockedBrickLevel = self.level % 5 == 0 and true or false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    if self.lockedBrickLevel and not self.powerUpKeyFlag then
        self.timer = self.timer + dt
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    -- Update powerUp and check if there is collision with the paddle
    for unused, powerUp in pairs(self.powerUps) do
        powerUp:update(dt)
        if powerUp:collides(self.paddle) then
            gSounds['powerup_balls']:play()
            powerUp.ingame = false

            if powerUp.tier == PU_MULT_BALL then
                -- add two new more balls based on the main ball:
                -- tweak the angle in different direction every new ball
                local ballone = self.balls[1]
                for i = 1, EXTRA_BALLS do
                    -- TODO: create a constructor for the Ball class
                    newball = Ball()
                    newball.skin = ballone.skin
                    newball.x = ballone.x
                    newball.y = ballone.y
                    variation = math.random(30, 50)
                    if i % 2 == 0 then
                        -- even
                        newball.dx = ballone.dx - variation
                    else
                        -- odd
                        newball.dx = ballone.dx + variation
                    end

                    newball.dy = ballone.dy

                    table.insert(self.balls, newball)
                end
            else
                -- flag to unlock the keyBlock
                self.powerUpKeyFlag = true
            end
        end
    end

    for k, ball in pairs(self.balls) do
        -- update balls position based on velocity
        ball:update(dt)

        if ball:collides(self.paddle) then

            -- Unlock for another powerUp and restart the counter of hit blocks.
            self.powerUpBallLock = false
            self.numBricksHit = 0

            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = math.max(-200, -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x)))

            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = math.min(200, 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x)))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with each ball
        for k, brick in pairs(self.bricks) do

            -- Unlock the LockedBrick once we picked up the correct PowerUp
            -- changing the sprite and making it breakable
            if not brick.breakable and self.powerUpKeyFlag then
                brick.tier = 0
                brick.breakable = true
            end

            -- check if the locked brick has been eliminated
            if brick.color == 6 and not brick.inPlay then
                self.lockedBrickRemoved = true
            end

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score if the brick is breakable
                if brick.breakable then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end


                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    -- self.health = math.min(3, self.health + 1)
                    self.paddle:grow()

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(500000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --[[
                    Spawn PowerUp once the ball hit enought briks consecutively
                    before collide with paddle again.
                ]]
                -- TODO: Improve it!
                -- It shows unexpected behaviour, like releasing new PowerUp when we have multiballs.
                -- This may lead to have more than the maximum amount of balls
                self.numBricksHit = self.numBricksHit + 1
                if (not self.powerUpBallLock and table.getn(self.balls) == 1 and self.numBricksHit >= 2) then
                    -- Spawn new power up
                    table.insert(self.powerUps, Powerup(
                        brick.x + (brick.width/2) - 16/2,
                        brick.y + brick.height,
                        PU_MULT_BALL) -- index of the tile to use
                    )
                    -- Lock Power Up untill the ball hits the paddle again
                    self.powerUpBallLock = true
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- If ball goes below bounds remove from screen.
        -- If it's the last ball revert to serve state and decrease health
        if ball.y >= VIRTUAL_HEIGHT then

            ball.ingame = false
            -- if it's the last ball
            if table.getn(self.balls) == 1 then
                -- if it's the last ball and the smallest paddle size
                -- decrease health and get the paddle to the starting size
                if (self.paddle.size == 1) then
                    self.health = self.health - 1
                    self.paddle:grow()
                else
                    self.paddle:shrink()
                end
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- if we haven't picked up the key powerUp and the lockedBrick is still in game
    -- generate a new key powerUP
    -- Increment the spawn timer twice every time we miss
    if self.timer >= self.keySpawnTimer and not self.powerUpKeyFlag and not self.lockedBrickRemoved then
        table.insert(self.powerUps, Powerup(math.random(8, 392), 16, PU_KEY))
        print(self.timer)
        self.timer = 0
        self.keySpawnTimer = self.keySpawnTimer * 2
    end

    -- remove powerUps not ingame
    for i, powerUp in pairs(self.powerUps) do
        if powerUp.ingame == false then
            table.remove(self.powerUps, i)
        end
    end

    -- remove gone balls
    for i, ball in pairs(self.balls) do
        if ball.ingame == false then
            table.remove(self.balls, i)
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    -- render all the balls
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    -- render powerUps
    for unused, powerUp in pairs(self.powerUps) do
        if powerUp.ingame then
            powerUp:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end