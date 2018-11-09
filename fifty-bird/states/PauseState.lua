
PauseState = Class{__includes = BaseState}

-- function PauseState:init()

-- end

function PauseState:enter()

end

function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
        gStateMachine:change('play')
    end
end

function PauseState:render()
    
end