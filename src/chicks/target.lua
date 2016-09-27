--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Target = class('Target')

function Target:initialize(home, away, color)
    self.__home = home
    self.__away = away
    self.__color = color
end

function Target:get_home()
    return self.__home
end

function Target:get_away()
    return self.__away
end

function Target:get_color()
    return self.__color
end

return Target
