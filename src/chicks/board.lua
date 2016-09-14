--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Board = class('Board')

Board.MARBLES = {
    blue = 1,
    green = 2,
    yellow = 3,
    purple = 4,
    white = 5,
    red = 6
}

Board.MAX_TILES = 121

function Board:initialize(map)
    self.__map = map
end

function Board:place(position, marble)
    assert(1 <= position and position <= MAX_TILES,
        "Invalid position")
    assert(marble == self.MARBLES.blue
        or marble == self.MARBLES.green
        or marble == self.MARBLES.yellow
        or marble == self.MARBLES.purple
        or marble == self.MARBLES.white
        or marble == self.MARBLES.red,
        "Invalid marble")
end

function Board:remove(position)
    assert(1 <= position and position <= MAX_TILES,
        "Invalid position")
end

return Board
