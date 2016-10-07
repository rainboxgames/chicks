--[[
-- This file is part of chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

--[[
-- explode( delimiter, string )
--
-- Thanks to: Lance Li
--]]
local function explode(d, p)
    local t, ll
    t = {}
    ll = 0
    if (#p == 1) then return {p} end
    while true do
        l = string.find(p, d, ll, true)
        if l ~= nil then
            table.insert(t, string.sub(p, ll, l - 1))
            ll = l + 1
        else
            table.insert(t, string.sub(p, ll))
            break
        end
    end
    return t
end

return explode
