--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- whether the key is placed in the level
    local keySpawned = false
    local keyColor = math.random(#KEYS)
    local lockSpawned = false

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- Randomly position for the key between 1/4 and 4/5 map's width
    local keyPosition = math.random(math.floor(width*0.25), math.floor(width*0.80))
    -- Randomly choose where to place the lock, not further 80% of the map's width
    local lockPosition = math.random(math.floor(width*0.80))

    -- Random zone covers 95% of the map; the 5% left is for spawning the goal post
    local randomZoneArea = math.floor(width*0.95)

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, randomZoneArea do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            if (not lockSpawned) and (x >= lockPosition) then
                table.insert(objects,
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- Offset to get the same lock color as the key, as both sprites
                        -- are located in the same quad
                        frame = keyColor + 4,
                        collidable = true,
                        consumable = false,
                        solid = true,

                        onCollide = function(obj)
                            gSounds['empty-block']:play()
                        end,

                        -- collision function takes itself
                        onConsume = function(player, obj)
                            gSounds['powerup-reveal']:play()

                            for k, obj in pairs(player.level.objects) do
                                if obj.texture == 'flags' then
                                    obj.visible = true
                                    obj.consumable = true
                                 end
                             end
                        end
                    }
                )
                lockSpawned = true
            -- chance to spawn a block
            elseif math.random(10) == 1 then
                table.insert(objects,
                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }

                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            elseif not keySpawned and  x >= keyPosition then
                -- if the key hasn't been spawned yet and it has already passed 1/4 of the map,
                -- there is a chance to spawn the key
                table.insert(objects,
                    -- maintain reference so we can set it to nil
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE - 4,
                        width = 16,
                        height = 16,
                        frame = keyColor,
                        collidable = true,
                        consumable = true,
                        solid = false,

                        -- once the player gets the key, make the lock-block consumable
                        onConsume = function(player, object)
                            gSounds['pickup']:play()

                            for k, obj in pairs(player.level.objects) do
                                if obj.texture == 'keys-locks' and obj.solid then
                                    obj.solid = false
                                    obj.consumable = true
                                    break
                                end
                            end
                        end
                    }
                )
                keySpawned = true
            end

        end
    end

    -- Create a plain terrain (no blocks, chasms or pilars) to spawn the flag in.
    for x = (randomZoneArea + 1), width do
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, TILE_ID_EMPTY, nil, tileset, topperset))
        end
        for y = 7, height do
            table.insert(tiles[y],
                Tile(x, y, TILE_ID_GROUND, y == 7 and topper or nil, tileset, topperset))
        end
    end

    local flagVariant = FLAGPOLE_ID[math.random(#FLAGPOLE_ID)]
    local flagCol = randomZoneArea + ((width - randomZoneArea) / 2)
    for i = 1, 3 do
        table.insert(objects,
            GameObject {
                texture = 'flags',
                x = (flagCol - 1) * TILE_SIZE,
                y = ((3 + i) - 1) * TILE_SIZE,
                width = 16,
                height = 16,
                frame = flagVariant + ((i - 1) * 9),
                collidable = false,
                visible = false,
                solid = false,

                onConsume = function(player, obj)
                    gStateMachine:change('play', {score = player.score, width = width})
                end
            }
        )
    end

    table.insert(objects,
        GameObject {
            texture = 'flags',
            x = ((flagCol - 1) * TILE_SIZE ) + 7.5,
            y = ((4 - 1) * TILE_SIZE) + 7,
            width = 16,
            height = 16,
            frame = 7 + ((math.random(4) - 1) * 9),
            collidable = false,
            solid = false,
            visible = false,
        }
    )

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end
