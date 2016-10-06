--[[
-- This file is part of chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Player = class('Player')

function Player:initialize(name, targets)
    self.__name = name
    self.__targets = targets
end

function Player:has_color(color)
    for k, v in pairs(self.__targets) do
        if v:get_color() == color then
            return true
        end
    end
    return false
end

function Player:get_name()
    return self.__name
end

function Player:get_targets()
    return self.__targets
end

return Player
