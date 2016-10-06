--[[
-- This file is part of chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

CHICKS_VERSION = '1.0-dev'

package.path = package.path .. ';src/?.lua;lib/?.lua;lib/?/?.lua;lib/?/init.lua'

-- LIBS
class           = require 'middleclass'
suit            = require 'suit'
copas           = require 'copas'
socket          = require 'socket'

-- CLASSES
App             = require 'ui.app'
Engine          = require 'core.engine'
Board           = require 'core.board'
Player          = require 'core.player'
Target          = require 'core.target'

-- HELPERS
print_r         = require 'helpers.print_r'
explode         = require 'helpers.explode'
log             = require 'helpers.log'

local app = App()

function love.load()
    app:load()
end

function love.update(dt)
    app:update(dt)
end

function love.draw()
    app:draw()
end

function love.textinput(t)
    app:textinput(t)
end

function love.keypressed(key)
    app:keypressed(key)
end

function love.mousepressed(x, y, button)
    app:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    app:mousereleased(x, y, button)
end

function love.conf(t)
    app:conf(t)
end

function love.quit()
    return app:quit()
end
