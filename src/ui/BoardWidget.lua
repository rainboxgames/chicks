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

    -- keep track of mouse dragging
    self.__drag = {
        active = false,
        tile = 0,
        x = 0,
        y = 0,
        color = 0
    }

    -- callbacks
    self.__callbacks = {
        move = {},
        finish = {}
    }
end

function BoardWidget:register_callback_move(callback, selfref)
    table.append(self.__callbacks.move, {callback, selfref})
end

function BoardWidget:__notify_callback_move(from, to)
    for _,v in pairs(self.__callbacks.move) do
        v[1](v[2], from, to)
    end
end

function BoardWidget:register_callback_finish(callback, selfref)
    table.append(self.__callbacks.finish, {callback, selfref})
end

function BoardWidget:__notify_callback_finish()
    for _,v in pairs(self.__callbacks.finish) do
        v[1](v[2])
    end
end

function BoardWidget:update_mouse(x, y)
    if self.__drag.active then
        self.__drag.x = x
        self.__drag.y = y
    end
end

function BoardWidget:mousepressed(x, y, button)
    if button == 1 then
        local xx, yy
        -- for each tile on the board check which one is closest
        for i = 1, Board.MAX_TILES do
            local color = self.__board:get_color_by_pos(i)
            -- only if not an empty tile
            if color ~= Board.MARBLES.empty then
                xx = x - (BoardWidget.OFFSETS.tiles[i].x + BoardWidget.OFFSETS.board.x + BoardWidget.OFFSETS.tile.x)
                yy = y - (BoardWidget.OFFSETS.tiles[i].y + BoardWidget.OFFSETS.board.y + BoardWidget.OFFSETS.tile.y)
                if (math.abs(xx) <= BoardWidget.OFFSETS.radius) and (math.abs(yy) <= BoardWidget.OFFSETS.radius) then
                    if (xx * xx + yy * yy <= BoardWidget.OFFSETS.radius2) then
                        -- enable drag
                        log.debug("BoardWidget is dragging.")
                        self.__drag = {
                            active = true,
                            tile = i,
                            x = Board.REVERSE_AXIS_MAP[i].x,
                            y = Board.REVERSE_AXIS_MAP[i].y,
                            color = color
                        }
                    end
                    -- no need to look further
                    break
                end
            end
        end
    end
end

function BoardWidget:mousereleased(x, y, button)
    if button == 1 then
        -- if not dragging then do nothing
        if not self.__drag.active then return end

        local xx, yy
        -- for each tile on the board check which one is closest
        for i = 1, Board.MAX_TILES do
            xx = x - (BoardWidget.OFFSETS.tiles[i].x + BoardWidget.OFFSETS.board.x + BoardWidget.OFFSETS.tile.x)
            yy = y - (BoardWidget.OFFSETS.tiles[i].y + BoardWidget.OFFSETS.board.y + BoardWidget.OFFSETS.tile.y)
            if (math.abs(xx) <= BoardWidget.OFFSETS.radius) and (math.abs(yy) <= BoardWidget.OFFSETS.radius) then
                if (xx * xx + yy * yy <= BoardWidget.OFFSETS.radius2) then
                    -- disable drag
                    self.__drag.active = false

                    -- if source and target are equal just ignore it
                    if self.__drag.tile == i then return end

                    self:__notify_callback_move(self.__drag.tile, i)
                end
                -- no need to look further
                break
            end
        end

    -- right click to finish turn
    elseif button == 2 then
        self:__notify_callback_finish()
    end
end

function BoardWidget:draw()
    -- draw empty board
    self:__draw_board()


    -- draw resting tiles
    for i = 1, Board.MAX_TILES do
        if not (self.__drag.active and self.__drag.tile == i) then
            self:__draw_marble(i)
        end
    end

    -- draw drag'n'drop tile if any
    if self.__drag.active then
        self:__draw_marble_xy(self.__drag.tile, self.__drag.x, self.__drag.y)
    end
end

function BoardWidget:__draw_marble(t)
    self:__draw_marble_xy(t,
            BoardWidget.OFFSETS.tiles[t].x + BoardWidget.OFFSETS.tile.x + BoardWidget.OFFSETS.board.x,
            BoardWidget.OFFSETS.tiles[t].y + BoardWidget.OFFSETS.tile.y + BoardWidget.OFFSETS.board.y)
end

function BoardWidget:__draw_marble_xy(t, x, y)
    love.graphics.setColor(255, 255, 255, 255)
    color = self.__board:get_color_by_pos(t)
    love.graphics.draw(self.__assets[Board.REVERSE_MARBLES[color]], x, y,
            0, 1, 1, BoardWidget.OFFSETS.radius, BoardWidget.OFFSETS.radius)
end

function BoardWidget:__draw_board()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.__assets.board, BoardWidget.OFFSETS.board.x, BoardWidget.OFFSETS.board.y)

    -- draw empty tiles
    for i = 1, Board.MAX_TILES do
        love.graphics.draw(self.__assets.empty,
                BoardWidget.OFFSETS.tiles[i].x + BoardWidget.OFFSETS.tile.x + BoardWidget.OFFSETS.board.x,
                BoardWidget.OFFSETS.tiles[i].y + BoardWidget.OFFSETS.tile.y + BoardWidget.OFFSETS.board.y,
                0, 1, 1, BoardWidget.OFFSETS.radius, BoardWidget.OFFSETS.radius)
    end
end

BoardWidget.OFFSETS = {
    board = {x = 132, y = 20},
    radius = 22,
    radius2 = 484,
    tile = {x = 380, y = 28},
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
