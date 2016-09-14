--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Engine = class('Engine')

function Engine:initialize(board, number_of_players, number_of_colors, current_player)
    assert(number_of_players == 2
        or number_of_players == 3
        or number_of_players == 4
        or number_of_players == 6,
        "Illegal number of players: must be 2, 3, 4, or 6")
    assert(number_of_colors == number_of_players
        or number_of_colors == 4 and number_of_players == 2
        or number_of_colors == 6 and number_of_players == 2
        or number_of_colors == 6 and number_of_players == 3,
        "Illegal number of colors")
    assert(1 <= current_player and current_player <= number_of_players,
        "Illegal current player")

    self.__board = board
    self.__number_of_players = number_of_players
    self.__number_of_colors = number_of_colors
    self.__current_player = current_player
end

function Engine:move(from, to)
end

function Engine:finish()
end

return Engine
