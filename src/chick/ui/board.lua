--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

Board = {}

function Board.new()
    return setmetatable({
        -- attributes
        board = love.graphics.newImage('assets/board.png'),
        light = love.graphics.newImage('assets/light.png'),
        marbles = {
            blue = love.graphics.newImage('assets/blue.png'),
            green = love.graphics.newImage('assets/green.png'),
            purple = love.graphics.newImage('assets/purple.png'),
            red = love.graphics.newImage('assets/red.png'),
            white = love.graphics.newImage('assets/white.png'),
            yellow = love.graphics.newImage('assets/yellow.png')
        },

        tiles = require 'tiles',

        highlights = {},
        marble_map = {},

        radius = 22,
        radius2 = 484,
        board_offset = {x = 132, y = 20},
        tile_offset = {x = 380, y = 30}

    }, {__index = Board})
end

function Board:on_mousedown(x, y)
    local xx, yy
    for k, v in pairs(self.tiles) do
        xx = x - v.x - self.board_offset.x - self.tile_offset.x
        yy = y - v.y - self.board_offset.y - self.tile_offset.y
        if (math.abs(xx) <= self.radius) and (math.abs(yy) <= self.radius) then
            if (xx * xx + yy * yy <= self.radius2) then
                self:_highlight(k)
            end
            break
        end
    end
end

function Board:draw()
    -- draw plain board
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.board, self.board_offset.x, self.board_offset.y)

    -- draw marbles
    for t, c in pairs(self.marble_map) do
        self:_draw_marble(t, c)
    end

    -- draw highlighted tiles
    for t, _ in pairs(self.highlights) do
        self:_highlight_tile(t)
    end
end

function Board:place_marble(t, color)
    assert(Board.colors[color] ~= nil, "invalid marble color.")
    self.marble_map[t] = color
end

function Board:remove_marble(t)
    self.marble_map[t] = nil
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

function Board:_highlight_tile(t)
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.light,
        self.tiles[t].x + self.tile_offset.x + self.board_offset.x,
        self.tiles[t].y + self.tile_offset.y + self.board_offset.y,
        0, 1, 1, self.radius, self.radius)
end

Board.colors =
{
    blue = 1,
    green = 2,
    purple = 3,
    red = 4,
    white = 5,
    yellow = 6
}
