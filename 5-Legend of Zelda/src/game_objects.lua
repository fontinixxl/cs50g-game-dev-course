--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        collidable = true,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['hearts'] = {
        type = 'hearts',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        collidable = false,
        consumable = true,
        -- scale heart tile to half of the size
        scaleFactor = 0.5,
        defaultState = 'default',
        states = {
            ['default'] = {
                frame = 5
            },
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        --frame = 5,
        width = 16,
        height = 16,
        solid = true,
        collidable = true,
        consumable = false,
        scaleFactor = 1,
        defaultState = 'ground',
        states = {
            ['ground'] = {
                frame = false,
            },
            ['lifted'] = {
                frame = false,
            },
            ['thrown'] = {
                frame = false,
            },
            ['destroyed'] = {
                frame = false,
            },
        }
    }
}