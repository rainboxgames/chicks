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
    package.path = "src/chick/core/?.lua;src/chick/net/?.lua;src/chick/ui/?.lua;src/chick/utils/?.lua;" .. package.path

    -- load ui components
    require 'board'
    board = Board.new()

    -- load core module
    require 'chick'
    core = Chick.new(2)

    -- luasocket
    socket = require 'socket'

    -- utils
    require 'explode'

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

    print("(debug) test")
    local host, port = 'chix', 44444
    client = socket.connect(host, port)
    local peer = host .. ':' .. port

    -- set block timeout
    client:settimeout(0.01)

    if client then
        print("(debug) connected to server " .. peer)

        -- receive player id
        repeat
            id = client:receive()
        until id
        print("(debug) id: " .. id)

    else
        error("(debug) could not connect to server " .. peer)
    end
end

function love.mousepressed(x, y, button)
    if button == 'l' then

        local x, y = love.mouse.getPosition()
        board:on_mousedown(x, y)

    end
end

function love.mousereleased(x, y, button)
    if button == 'l' and board:is_dragging() then

        local x, y = love.mouse.getPosition()
        local from, to = board:on_mouserelease(x, y)

        -- pass move to core
        if from > 0 and to > 0 then
            if (core:move(from, to)) then
                -- pass move to ui
                board:move_marble(from, to)

                -- test network
                client:send('MOV ' .. from .. ' ' .. to .. "\r\n")
            else
                print("(debug) core: illegal move.")
            end
        end

    elseif button == 'r' then

        if core:play() ~= 0 then
            client:send('PLY' .. "\r\n")
        end

    end
end

function love.update(dt)
    if board:is_dragging() then
        local x, y = love.mouse.getPosition()
        board:update_drag(x, y)
    end

    -- receive data
    data = client:receive()
    -- process received data
    if data then
        print("(debug) recv data: " .. data)

        local pieces = explode(' ', data)
        local verb = pieces[1]

        if verb == 'MOV' then
            if #pieces ~= 3 then
                print("(debug) illegal command from server.")
                return
            end
            local from, to = tonumber(pieces[2]), tonumber(pieces[3])
            if (core:move(from, to)) then
                board:move_marble(from, to)
            else
                print("(debug) core: illegal move.")
                return
            end
        elseif verb == 'PLY' then
            if #pieces ~= 1 then
                print("(debug) illegal command from server.")
                return
            end
            core:play()
        else
            print("(debug) server is high.")
            return
        end
    end
end

function love.draw()
    board:draw()
end

function love.conf(t)
    -- anti-aliasing
    t.window.fsaa = 4
end
