--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

-- add module directories to lua path
package.path = "src/chick/core/?.lua;src/chick/net/?.lua;src/chick/ui/?.lua;src/chick/utils/?.lua;" .. package.path

-- import modules
socket = require 'socket'
copas = require 'copas'
require 'chick'
require 'explode'

local core = Chick.new(2)
local peers = {}
local connections = 0

local sockets = {}

local function broadcast(msg)
    for _, s in pairs(sockets) do
        copas.send(s, msg .. "\r\n")
    end
end

local function handle(sock)
    local addr, port = sock:getpeername()
    local peer = addr .. ':' .. port
    print("(debug) in sock handler", peer)

    -- save socket
    sockets[peer] = sock

    -- count connections
    connections = connections + 1
    -- peer specific info
    peers[peer] = {
        id = connections,
        outbox = {}
    }

    -- send player id
    copas.send(sock, peers[peer].id .. "\r\n")

    while true do
        repeat
            -- receive part
            local data = copas.receive(sock)
            if data then
                local pieces = explode(' ', data)
                local verb = pieces[1]
                if verb == 'MOV' then
                    if #pieces ~= 3 then
                        print("(debug) [" .. peer .. "] illegal command received.")
                        break
                    end
                    local from, to = tonumber(pieces[2]), tonumber(pieces[3])
                    if core.current_player ~= peers[peer].id then
                        print("(debug) [" .. peer .. "] not his turn.")
                        break
                    end
                    if (core:move(from, to)) then
                        print("(debug) [" .. peer .. "] ! move " .. from .. ' -> ' .. to)

                        broadcast(data)

                    else
                        print("(debug) [" .. peer .. "] illegal move.")
                        break
                    end
                elseif verb == 'PLY' then
                    if #pieces ~= 1 then
                        print("(debug) [" .. peer .. "] illegal command received.")
                        break
                    end
                    if (core:play()) then
                        print("(debug) [" .. peer .. "] ! play")

                        broadcast(data)
                    end
                else
                    print("(debug) [" .. peer .. "] something else.")
                    break
                end
            end

        until true
    end
end

local function serve()
    print([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __
    /    \  \/|  |  \|  |/ ___\|  |/ /
    \     \___|   Y  \  \  \___|    <
     \______  /___|  /__|\___  >__|_ \
            \/     \/        \/     \/ 0.1

    ]])
    -- create server socket
    local host, port = '*', 44444
    local server = socket.bind(host, port)
    if server then
        print("(debug) server listening on " .. host .. ':' .. port)

        -- register handler callback
        copas.addserver(server, handle)

        -- dispatcher loop
        copas.loop()
    else
        error("(error) failed to create server socket.")
    end
end

serve()
