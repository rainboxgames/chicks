--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

package.path = package.path .. ';lib/?/?.lua;src/chicks/?.lua'

class           = require 'middleclass'
print_r         = require 'print_r'
explode         = require 'explode'
log             = require 'log'

local function main()
    log.info([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __  ______
    /    \  \/|  |  \|  |/ ___\|  |/ / /  ___/
    \     \___|   Y  \  \  \___|    <  \___ \
     \______  /___|  /__|\___  >__|_ \/____  >
            \/     \/        \/     \/     \/

    ]])
end

main()
