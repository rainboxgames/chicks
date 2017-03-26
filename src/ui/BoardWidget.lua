--[[
-- This file is part of chicks.
--
-- (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local BoardWidget = class('BoardWidget')

function BoardWidget:initialize(board)
    -- load assets
    self.__assets = {
        board   = love.graphics.newImage('assets/images/board.png'),
        empty   = love.graphics.newImage('assets/images/empty.png'),
        blue    = love.graphics.newImage('assets/images/blue.png'),
        green   = love.graphics.newImage('assets/images/green.png'),
        purple  = love.graphics.newImage('assets/images/purple.png'),
        red     = love.graphics.newImage('assets/images/red.png'),
        white   = love.graphics.newImage('assets/images/white.png'),
        yellow  = love.graphics.newImage('assets/images/yellow.png')
    }

    self.__board = board

    self.__drag = {
        active = false,
        tile = 0,
        x = 0,
        y = 0,
        color = 0
    }

    -- TODO this sucks
    self.__radius = 22
    self.__radius2 = 484
end

function BoardWidget:update_drag(x, y)
    self.__drag.x = x
    self.__drag.y = y
end

function BoardWidget:is_dragging()
    return self.__drag.active
end

function BoardWidget:on_mousedown(x, y)
    local xx, yy
    -- for each marble on the board
    for i = 1, Board.MAX_TILES do
        xx = x - self.__board:get_color_by_pos(i).x - BoardWidget.OFFSETS.board.x - BoardWidget.OFFSETS.tile.x
        yy = y - self.__board:get_color_by_pos(i).y - BoardWidget.OFFSETS.board.y - BoardWidget.OFFSETS.tile.y

        if (math.abs(xx) <= self.__radius) and (math.abs(yy) <= self.__radius) then
            if (xx * xx + yy * yy <= self.__radius2) then

                -- enable drag
                self.__drag.active = true
                self.__drag.tile = k
                self.__drag.x = self.__board:get_color_by_pos(i).x
                self.__drag.y = self.__board:get_color_by_pos(i).y
                self.__drag.color = v

                -- strip the original marble
                self:__remove_marble(k)

            end
            -- no need to look further
            break
        end
    end
end

function BoardWidget:on_mouserelease(x, y)
    local xx, yy
    -- for each tile on the board
    for k, v in pairs(self.tiles) do
        xx = x - v.x - BoardWidget.OFFSETS.board.x - BoardWidget.OFFSETS.tile.x
        yy = y - v.y - BoardWidget.OFFSETS.board.y - BoardWidget.OFFSETS.tile.y

        if (math.abs(xx) <= self.__radius) and (math.abs(yy) <= self.__radius) then
            if (xx * xx + yy * yy <= self.__radius2) then

                -- disable drag
                self.__drag.active = false

                -- drop marble to initial position
                self:__place_marble(self.__drag.tile, self.__drag.color)

                -- if source and target are equal just ignore it
                if self.__drag.tile == k then
                    return 0, 0
                end

                return self.__drag.tile, k

            end
            break
        end
    end
    return 0, 0
end

function BoardWidget:draw()
    -- draw plain board
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.__assets.board, BoardWidget.OFFSETS.board.x, BoardWidget.OFFSETS.board.y)

    -- draw marbles and empty tiles
    for i = 1, Board.MAX_TILES do
        color = self.__board:get_color_by_pos(i)
        love.graphics.draw(self.__assets[Board.REVERSE_MARBLES[color]],
            BoardWidget.OFFSETS.tiles[i].x + BoardWidget.OFFSETS.tile.x + BoardWidget.OFFSETS.board.x,
            BoardWidget.OFFSETS.tiles[i].y + BoardWidget.OFFSETS.tile.y + BoardWidget.OFFSETS.board.y,
            0, 1, 1, self.__radius, self.__radius)
    end

    -- draw drag'n'drop marble
    if self.__drag.active then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(self.__assets[Board.REVERSE_MARBLES[self.__drag.color]],
            self.__drag.x,
            self.__drag.y,
            0, 1, 1, self.__radius, self.__radius)
    end

    -- draw highlighted tiles
    -- for t, _ in pairs(self.highlights) do
    --     self:_draw_highlight(t)
    -- end
end

function BoardWidget:__place_marble(t, color)
    self.__board:place(t, color)
end

function BoardWidget:__remove_marble(t)
    self.__board:remove(t)
end

function BoardWidget:__move_marble(from, to)
    self:__place_marble(to, self.marble_map[from])
    self:__remove_marble(from)
end

function BoardWidget:__draw_marble(t, c)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.__assets[Board.REVERSE_MARBLES[c]],
        self.tiles[t].x + BoardWidget.OFFSETS.tile.x + BoardWidget.OFFSETS.board.x,
        self.tiles[t].y + BoardWidget.OFFSETS.tile.y + BoardWidget.OFFSETS.board.y,
        0, 1, 1, self.__radius, self.__radius)
end

function BoardWidget:__draw_highlight(t)
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.light,
        self.tiles[t].x + BoardWidget.OFFSETS.tile.x + BoardWidget.OFFSETS.board.x,
        self.tiles[t].y + BoardWidget.OFFSETS.tile.y + BoardWidget.OFFSETS.board.y,
        0, 1, 1, self.__radius, self.__radius)
end

BoardWidget.OFFSETS = {
    board = { x = 132, y = 20 },
    tile = { x = 380, y = 28 },
    tiles = {
        {y = 704, x = 0},
        {y = 660, x = 25},
        {y = 660, x = -25},
        {y = 616, x = 50},
        {y = 616, x = 0},
        {y = 616, x = -50},
        {y = 572, x = 75},
        {y = 572, x = 25},
        {y = 572, x = -25},
        {y = 572, x = -75},
        {y = 528, x = 300},
        {y = 528, x = 250},
        {y = 528, x = 200},
        {y = 528, x = 150},
        {y = 528, x = 100},
        {y = 528, x = 50},
        {y = 528, x = 0},
        {y = 528, x = -50},
        {y = 528, x = -100},
        {y = 528, x = -150},
        {y = 528, x = -200},
        {y = 528, x = -250},
        {y = 528, x = -300},
        {y = 484, x = 275},
        {y = 484, x = 225},
        {y = 484, x = 175},
        {y = 484, x = 125},
        {y = 484, x = 75},
        {y = 484, x = 25},
        {y = 484, x = -25},
        {y = 484, x = -75},
        {y = 484, x = -125},
        {y = 484, x = -175},
        {y = 484, x = -225},
        {y = 484, x = -275},
        {y = 440, x = 250},
        {y = 440, x = 200},
        {y = 440, x = 150},
        {y = 440, x = 100},
        {y = 440, x = 50},
        {y = 440, x = 0},
        {y = 440, x = -50},
        {y = 440, x = -100},
        {y = 440, x = -150},
        {y = 440, x = -200},
        {y = 440, x = -250},
        {y = 396, x = 225},
        {y = 396, x = 175},
        {y = 396, x = 125},
        {y = 396, x = 75},
        {y = 396, x = 25},
        {y = 396, x = -25},
        {y = 396, x = -75},
        {y = 396, x = -125},
        {y = 396, x = -175},
        {y = 396, x = -225},
        {y = 352, x = 200},
        {y = 352, x = 150},
        {y = 352, x = 100},
        {y = 352, x = 50},
        {y = 352, x = 0},
        {y = 352, x = -50},
        {y = 352, x = -100},
        {y = 352, x = -150},
        {y = 352, x = -200},
        {y = 308, x = 225},
        {y = 308, x = 175},
        {y = 308, x = 125},
        {y = 308, x = 75},
        {y = 308, x = 25},
        {y = 308, x = -25},
        {y = 308, x = -75},
        {y = 308, x = -125},
        {y = 308, x = -175},
        {y = 308, x = -225},
        {y = 264, x = 250},
        {y = 264, x = 200},
        {y = 264, x = 150},
        {y = 264, x = 100},
        {y = 264, x = 50},
        {y = 264, x = 0},
        {y = 264, x = -50},
        {y = 264, x = -100},
        {y = 264, x = -150},
        {y = 264, x = -200},
        {y = 264, x = -250},
        {y = 220, x = 275},
        {y = 220, x = 225},
        {y = 220, x = 175},
        {y = 220, x = 125},
        {y = 220, x = 75},
        {y = 220, x = 25},
        {y = 220, x = -25},
        {y = 220, x = -75},
        {y = 220, x = -125},
        {y = 220, x = -175},
        {y = 220, x = -225},
        {y = 220, x = -275},
        {y = 176, x = 300},
        {y = 176, x = 250},
        {y = 176, x = 200},
        {y = 176, x = 150},
        {y = 176, x = 100},
        {y = 176, x = 50},
        {y = 176, x = 0},
        {y = 176, x = -50},
        {y = 176, x = -100},
        {y = 176, x = -150},
        {y = 176, x = -200},
        {y = 176, x = -250},
        {y = 176, x = -300},
        {y = 132, x = 75},
        {y = 132, x = 25},
        {y = 132, x = -25},
        {y = 132, x = -75},
        {y = 88, x = 50},
        {y = 88, x = 0},
        {y = 88, x = -50},
        {y = 44, x = 25},
        {y = 44, x = -25},
        {y = 0, x = 0}
    }
}

return BoardWidget
