--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

Chick = {}

function Chick.new(p)
    return setmetatable({
        players = p,
        current = 1,
        board = Chick._generate_board()
    }, {__index = Chick})
end

function Chick:move(chain)
    local axis = require "axis"

    -- check current turn
    marble = chain[1]
    player = axis.map[marble]
    if player ~= self.current then return 0 end

    -- look for win
    if self._win(player) then
        return -1 * player
    end

    -- next turn
    return self._next()
end

function Chick._generate_board()
    assert(p == 2 or p == 3 or p == 4 or p == 6, "illegal number of players")
    local board = require "board"
    return board[p]
end

function Chick:_win(p)
end

function Chick:_next()
    return self.current = self.current % self.players + 1
end
