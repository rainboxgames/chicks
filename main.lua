--[[
-- This file is part of chicks.
--
-- (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

_VERSION = '1.0.0-dev'

package.path = package.path .. ';src/?.lua;lib/?.lua;lib/?/?.lua;lib/?/init.lua'

class           = require 'middleclass'
struct          = require 'struct'
socket          = require 'socket'
gamestate       = require 'hump.gamestate'
App             = require 'App'
Engine          = require 'core.Engine'
Board           = require 'core.Board'
Player          = require 'core.Player'
Target          = require 'core.Target'
BoardWidget     = require 'ui.BoardWidget'
log             = require 'util.log'
tablextra       = require 'util.tablextra'
table.print     = tablextra.print
table.explode   = tablextra.explode
table.contains  = tablextra.contains
table.append    = tablextra.append

-- for debug purposes only
complete_game   = require 'complete_game'

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
