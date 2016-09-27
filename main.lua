--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

package.path = package.path .. ';lib/?/?.lua;src/chicks/?.lua'

--
-- LIBS
--
class           = require 'middleclass'

--
-- HELPERS
--
print_r         = require 'print_r'
explode         = require 'explode'
log             = require 'log'

--
-- CLASSES
--
App             = require 'app'
Board           = require 'board'
Engine          = require 'engine'
Player          = require 'player'
Target          = require 'target'

function love.load()
    log.info([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __  ______
    /    \  \/|  |  \|  |/ ___\|  |/ / /  ___/
    \     \___|   Y  \  \  \___|    <  \___ \
     \______  /___|  /__|\___  >__|_ \/____  >
            \/     \/        \/     \/     \/

    ]])

    -- window settings
    love.window.setMode(1024, 800)
    love.window.setTitle("Chicks - Rainboxgames")

    app = App()
end

function love.update(dt)
    app:update(dt)
end

function love.draw()
    app:draw()
end

function love.conf(t)
    -- anti-aliasing
    t.window.fsaa = 4
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end
