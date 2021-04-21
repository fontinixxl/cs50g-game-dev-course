--[[
    GD50
    Pokemon

    Author: Gerard Cuello
    gerard.cuello@protonmail.com
]]

StatsMenuState = Class{__includes = BaseState}

function StatsMenuState:init(battleState, stats, onClose)

    -- function to be called once this message is popped
    self.onClose = onClose or function() end

    self.statsMenu = Menu {
        x = battleState.playerHealthBar.x,
        y = 10,
        width = math.abs(battleState.playerHealthBar.x - VIRTUAL_WIDTH),
        height = battleState.playerHealthBar.y - 10 - 10,
        font = gFonts['medium'],
        align = 'left',
        items = {
            {
                text = self:prepareTextForItem(
                    ' HP', battleState.playerPokemon.HP - stats['HPIncrease'], stats['HPIncrease']
                ),
                onSelect = function() end
            },
            {
                text = self:prepareTextForItem(
                    ' Attack', battleState.playerPokemon.attack - stats['attackIncrease'], stats['attackIncrease']
                ),
                onSelect = function() end
            },
            {
                text = self:prepareTextForItem(
                    ' Defense',
                    battleState.playerPokemon.defense - stats['defenseIncrease'], stats['defenseIncrease']
                ),
                onSelect = function() end
            },
            {
                text = self:prepareTextForItem(
                    ' Speed', battleState.playerPokemon.speed - stats['defenseIncrease'], stats['speedIncrease']
                ),
                onSelect = function() end
            },
        }
    }
    -- turn off selection so all the items are gonna display like a list without selection or cursor
    self.statsMenu.selection:turnOffSelection()
end

function StatsMenuState:update(dt)
    self.statsMenu:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateStack:pop()
        self.onClose()
    end
end

function StatsMenuState:render()
    self.statsMenu:render()
end

function StatsMenuState:prepareTextForItem(stateLabel, currentValue, increase)
    return stateLabel .. ': ' .. tostring(currentValue) .. '+' .. tostring(increase)
        .. '=' .. tostring(currentValue + increase)
end