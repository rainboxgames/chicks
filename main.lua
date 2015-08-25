--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

function love.load()
    print([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __
    /    \  \/|  |  \|  |/ ___\|  |/ /
    \     \___|   Y  \  \  \___|    <
     \______  /___|  /__|\___  >__|_ \
            \/     \/        \/     \/ 0.1

    ]])

    -- window settings
    love.window.setMode(1024, 800)
    love.window.setTitle('chick')

    -- add module directories to lua path
    package.path = "src/chick/core/?.lua;src/chick/net/?.lua;src/chick/ui/?.lua;" .. package.path

    -- load ui components
    require 'board'
    ui = Board.new()
end

function love.mousepressed(x, y, button)
    if button == 'l' then
        x, y = love.mouse.getPosition()
        ui:on_mousedown(x, y)
    end
end

function love.update(dt)

end

function love.draw()
    -- just random testing lel
    ui:place_marble(1, 'blue')
    ui:place_marble(32, 'red')
    ui:place_marble(117, 'yellow')
    ui:place_marble(78, 'white')
    ui:place_marble(40, 'green')
    ui:place_marble(97, 'purple')
    ui:draw()
end

function love.conf(t)
    -- anti-aliasing
    t.window.fsaa = 4
end
