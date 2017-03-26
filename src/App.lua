--[[
-- This file is part of chicks.
--
-- (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local App = class('App')

App.WINDOW = { w = 1200, h = 800 }

function App:initialize()
end

function App:load()
    log.info([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __  ______
    /    \  \/|  |  \|  |/ ___\|  |/ / /  ___/
    \     \___|   Y  \  \  \___|    <  \___ \
     \______  /___|  /__|\___  >__|_ \/____  >
            \/     \/        \/     \/     \/

    ]])
    log.info("Version " .. _VERSION)

    love.window.setMode(App.WINDOW.w, App.WINDOW.h)
    love.window.setTitle("Chicks " .. _VERSION)


    -- for testing purposes only
    log.debug("Let's test this crap...")
    self.__players = {
        Player("neo", {
            Target(Board.TRIANGLES.a, Board.TRIANGLES.d, Board.MARBLES.green)
        }),
        Player("sorakun", {
            Target(Board.TRIANGLES.e, Board.TRIANGLES.b, Board.MARBLES.red)
        }),
        Player("morpheus", {
            Target(Board.TRIANGLES.c, Board.TRIANGLES.f, Board.MARBLES.blue)
        })
    }

    local board = Board()

    self.__engine = Engine(board, self.__players)
    self.__engine:reset_board()

    self.__boardwidget = BoardWidget:new(board)
end

function App:update(dt)
    local x, y = love.mouse.getPosition()
    self.__boardwidget:update_drag(x, y)
end

function App:draw()
    self.__boardwidget:draw()
end

function App:textinput(t)
end

function App:keypressed(key)
end

function App:mousepressed(x, y, button)
    if (button == 1 or button == 'l') then

        local x, y = love.mouse.getPosition()
        self.__boardwidget:on_mousedown(x, y)

    end
end

function App:mousereleased(x, y, button)
    if (button == 1 or button == 'l') then
        local x, y = love.mouse.getPosition()
        local from, to = self.__boardwidget:on_mouserelease(x, y)

        -- pass move to core
        if from > 0 and to > 0 then
            self.__engine:move(from, to)
        end

    end
end

function App:conf(t)
    -- anti-aliasing
    t.window.fsaa = 4
end

function App:quit()
    log.info("Bye.")
    return false
end

return App
