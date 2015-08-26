--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

Board = {}

Board.colors =
{
    blue = 1,
    green = 2,
    purple = 3,
    red = 4,
    white = 5,
    yellow = 6
}

function Board.new()
    return setmetatable({
        -- attributes
        board = love.graphics.newImage('assets/board.png'),
        light = love.graphics.newImage('assets/light.png'),
        empty = love.graphics.newImage('assets/empty.png'),
        marbles =
        {
            love.graphics.newImage('assets/blue.png'),
            love.graphics.newImage('assets/green.png'),
            love.graphics.newImage('assets/purple.png'),
            love.graphics.newImage('assets/red.png'),
            love.graphics.newImage('assets/white.png'),
            love.graphics.newImage('assets/yellow.png')
        },

        tiles = require 'tiles',

        highlights = {},
        marble_map = {},

        radius = 22,
        radius2 = 484,
        board_offset = {x = 132, y = 20},
        tile_offset = {x = 380, y = 28},

        drag =
        {
            active = false,
            tile = 0,
            x = 0,
            y = 0,
            color = 0
        }

    }, {__index = Board})
end

function Board:update_drag(x, y)
    self.drag.x = x
    self.drag.y = y
end

function Board:is_dragging()
    return self.drag.active
end

function Board:on_mousedown(x, y)
    local xx, yy
    -- for each marble on the board
    for k, v in pairs(self.marble_map) do
        xx = x - self.tiles[k].x - self.board_offset.x - self.tile_offset.x
        yy = y - self.tiles[k].y - self.board_offset.y - self.tile_offset.y

        if (math.abs(xx) <= self.radius) and (math.abs(yy) <= self.radius) then
            if (xx * xx + yy * yy <= self.radius2) then

                -- enable drag
                self.drag.active = true
                self.drag.tile = k
                self.drag.x = self.tiles[k].x
                self.drag.y = self.tiles[k].y
                self.drag.color = v

                -- strip the original marble
                self:remove_marble(k)

            end
            -- no need to look further
            break
        end
    end
end

function Board:on_mouserelease(x, y)
    local xx, yy
    -- for each tile on the board
    for k, v in pairs(self.tiles) do
        xx = x - v.x - self.board_offset.x - self.tile_offset.x
        yy = y - v.y - self.board_offset.y - self.tile_offset.y

        if (math.abs(xx) <= self.radius) and (math.abs(yy) <= self.radius) then
            if (xx * xx + yy * yy <= self.radius2) then

                -- disable drag
                self.drag.active = false

                -- drop marble to initial position
                self:place_marble(self.drag.tile, self.drag.color)

                -- if source and target are equal just ignore it
                if self.drag.tile == k then
                    return 0, 0
                end

                return self.drag.tile, k

            end
            break
        end
    end
    return 0, 0
end

function Board:draw()
    -- draw plain board
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.board, self.board_offset.x, self.board_offset.y)

    -- draw empty slots
    for t, _ in pairs(self.tiles) do
        love.graphics.draw(self.empty,
            self.tiles[t].x + self.tile_offset.x + self.board_offset.x,
            self.tiles[t].y + self.tile_offset.y + self.board_offset.y,
            0, 1, 1, self.radius, self.radius)
    end

    -- draw marbles
    for t, c in pairs(self.marble_map) do
        self:_draw_marble(t, c)
    end

    -- draw drag'n'drop marble
    if self.drag.active then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(self.marbles[self.drag.color],
            self.drag.x,
            self.drag.y,
            0, 1, 1, self.radius, self.radius)
    end

    -- draw highlighted tiles
    for t, _ in pairs(self.highlights) do
        self:_draw_highlight(t)
    end
end

function Board:place_marble(t, color)
    self.marble_map[t] = color
end

function Board:remove_marble(t)
    self.marble_map[t] = nil
end

function Board:move_marble(from, to)
    self:place_marble(to, self.marble_map[from])
    self:remove_marble(from)
end

function Board:_highlight(t)
    -- toggle highlight
    if self.highlights[t] then
        self.highlights[t] = nil
    else
        self.highlights[t] = true
    end
end

function Board:_draw_marble(t, c)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.marbles[c],
        self.tiles[t].x + self.tile_offset.x + self.board_offset.x,
        self.tiles[t].y + self.tile_offset.y + self.board_offset.y,
        0, 1, 1, self.radius, self.radius)
end

function Board:_draw_highlight(t)
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.light,
        self.tiles[t].x + self.tile_offset.x + self.board_offset.x,
        self.tiles[t].y + self.tile_offset.y + self.board_offset.y,
        0, 1, 1, self.radius, self.radius)
end
