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
end

function App:update(dt)
end

function App:draw()
    b = Board:new()
    bw = BoardWidget:new(b)
    bw:draw()
end

function App:textinput(t)
end

function App:keypressed(key)
end

function App:mousepressed(x, y, button)
end

function App:mousereleased(x, y, button)
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
