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
    board = Board.new()

    -- load core module
    require 'chick'
    core = Chick.new(2)

    -- let's just copy initial board map to ui
    for k, v in pairs(core.board) do
        -- map players to colors
        if v == 1 then
            board:place_marble(k, Board.colors.green)
        elseif v == 2 then
            board:place_marble(k, Board.colors.blue)
        elseif v == 3 then
            board:place_marble(k, Board.colors.red)
        elseif v == 4 then
            board:place_marble(k, Board.colors.purple)
        elseif v == 5 then
            board:place_marble(k, Board.colors.yellow)
        elseif v == 6 then
            board:place_marble(k, Board.colors.white)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 'l' then
        x, y = love.mouse.getPosition()
        board:on_mousedown(x, y)
    end
end

function love.update(dt)

end

function love.draw()
    board:draw()
end

function love.conf(t)
    -- anti-aliasing
    t.window.fsaa = 4
end
