--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local log = {}

local c27 = string.char(27)
local reset = c27 .. '[' .. tostring(0) .. 'm'
local red = c27 .. '[' .. tostring(31) .. 'm'
local green = c27 .. '[' .. tostring(32) .. 'm'
local yellow = c27 .. '[' .. tostring(33) .. 'm'

function log.info(msg)
    msg = explode("\n", msg)
    for _, v in pairs(msg) do
        print(green .. "[info ]  " .. v .. reset)
    end
end

function log.error(msg)
    msg = explode("\n", msg)
    for _, v in pairs(msg) do
        print(red .. "[error]  " .. v .. reset)
    end
end

function log.debug(msg)
    msg = explode("\n", msg)
    for _, v in pairs(msg) do
        print(yellow .. "[debug]  " .. v .. reset)
    end
end

return log
