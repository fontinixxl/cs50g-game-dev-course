--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

MAX_NUM_COLORS = 18
MIN_NUM_COLORS = 8

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    -- increment color variety every level up to 6 (max varieties)
    self.variety = level % 6 ~= 0 and (level % 6) or 6
    -- increment the number of colors by 1 every 6 levels
    self.numColorsLevel = math.min(MIN_NUM_COLORS + math.floor((level-1)/6), MAX_NUM_COLORS)

    self:initializeTiles()
    -- TODO: randomize number of shine tiles depending on the level
    -- self.tiles[math.random(8)][math.random(8)].shiny = true
    -- self.tiles[8][7].shiny = true
end

function Board:initializeTiles()
    self.tiles = {}
    local shinyTile = false
    local random = math.random(6)
    for tileY = 1, 8 do
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            local tile = Tile(tileX, tileY, math.random(self.numColorsLevel), math.random(1, self.variety))
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], tile)
        end
        self.tiles[tileY][math.random(8)].shiny = math.random(6) == random and true or false
    end

    while self:calculateMatches() or not self:matchesAvailable() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- whether there is a shiny tile in the match
    local shinyMatch = false
    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        -- save there is a shiny tile in this match
        shinyMatch = self.tiles[y][1].shiny

        matchNum = 1

        -- every horizontal tile
        for x = 2, 8 do

            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                -- Every time there is a color match we have to check
                -- whether the current tile is shiny and keep it only when it's so
                -- otherwise we would override if there was one shiny tile in the previous match
                shinyMatch = self.tiles[y][x].shiny and true or shinyMatch
            else

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    lastMatch = shinyMatch == true and 8 or (x - 1)
                    firstMatch = shinyMatch == true and 1 or (x - matchNum)

                    -- go backwards from here by matchNum
                    for x2 = lastMatch, firstMatch, -1 do

                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                matchNum = 1
                shinyMatch = self.tiles[y][x].shiny

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            firstMatch = shinyMatch == true and 1 or (8 - matchNum + 1)
            for x = 8, firstMatch, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        shinyMatch = self.tiles[1][x].shiny
        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                shinyMatch = self.tiles[y][x].shiny and true or shinyMatch
            else

                if matchNum >= 3 then
                    local match = {}

                    lastMatch = shinyMatch == true and 8 or (y - 1)
                    firstMatch = shinyMatch == true and 1 or (y - matchNum)

                    for y2 = lastMatch, firstMatch, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                colorToMatch = self.tiles[y][x].color
                shinyMatch = self.tiles[y][x].shiny
                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            firstMatch = shinyMatch == true and 1 or (8 - matchNum + 1)
            for y = 8, firstMatch, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do

            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then

                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then

                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(self.numColorsLevel), math.random(1, self.variety))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

--[[
    Check if there are matches available to perform on the board swaping
    everything up-down and then left-right. Return either true or false.
]]
function Board:matchesAvailable()
    local match = false
    local i = 1
    local tileA, tileB, tempX, tempY = nil
    -- swap every tile down for each column
    while (not match and i < 8) do
        local j = 1
        while (not match and j < 8) do
            tileA = self.tiles[j][i]
            tileB = self.tiles[j + 1][i]

            tempY = tileA.gridY
            tempX = tileA.gridX

            tileA.gridY = tileB.gridY
            tileA.gridX = tileB.gridX
            tileB.gridY = tempY
            tileB.gridX = tempX

            self.tiles[tileA.gridY][tileA.gridX] = tileA
            self.tiles[tileB.gridY][tileB.gridX] = tileB

            if self:calculateMatches() then
                match = true
                -- print('DEBUG: match down in: [ ' .. j ..' ] [ ' .. i .. ' ]' )
            end

            tileB.gridY = tileA.gridY
            tileB.gridX = tileA.gridX

            tileA.gridY = tempY
            tileA.gridX = tempX

            self.tiles[tileA.gridY][tileA.gridX] = tileA
            self.tiles[tileB.gridY][tileB.gridX] = tileB

            j = j + 1
        end

        i = i + 1
    end

    -- swap every tile right for each row
    j = 1
    while not match and j < 8 do
        i = 1
        while not match and i < 8 do
            tileA = self.tiles[j][i]
            tileB = self.tiles[j][i + 1]

            tempY = tileA.gridY
            tempX = tileA.gridX

            tileA.gridY = tileB.gridY
            tileA.gridX = tileB.gridX
            tileB.gridY = tempY
            tileB.gridX = tempX

            self.tiles[tileA.gridY][tileA.gridX] = tileA
            self.tiles[tileB.gridY][tileB.gridX] = tileB

            if self:calculateMatches() then
                match = true
                -- print('DEBUG: match right in: [ ' .. j ..' ] [ ' .. i .. ' ]' )
            end

            tileB.gridY = tileA.gridY
            tileB.gridX = tileA.gridX

            tileA.gridY = tempY
            tileA.gridX = tempX

            self.tiles[tileA.gridY][tileA.gridX] = tileA
            self.tiles[tileB.gridY][tileB.gridX] = tileB

            i = i + 1
        end

        j = j + 1
    end

    -- return whether there is a match available to perform
    return match
end

-- see if the given coordinates are pointing in the board
function Board:pointingIn(x, y)
    return x >= 1 and x <= 8 and y >= 1 and y <= 8
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end