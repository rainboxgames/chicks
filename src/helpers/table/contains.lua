--[[
-- This file is part of chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local function contains(t, v)
    for _, j in pairs(t) do
        if j == v then
            return true
        end
    end
    return false
end

return contains
