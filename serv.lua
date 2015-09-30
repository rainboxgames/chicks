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

core = Chick.new(2)
peers = {}

local function handle(sock)
    local addr, port = sock:getpeername()
    local peer = addr .. ':' .. port
    print("(debug) in sock handler", peer)

    -- first is room admin
    if peers == {} then
        peers = {
            turn = true,
            admin = true
        }
    else
        peers[peer] = {
            turn = false,
            admin = false
        }
    end


    while true do
        repeat
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
                    if (core:move(from, to)) then
                        print("(debug) [" .. peer .. "] ! move " .. from .. ' -> ' .. to)
                    else
                        print("(debug) [" .. peer .. "] illegal move.")
                    end
                elseif verb == 'PLY' then
                    if #pieces ~= 1 then
                        print("(debug) [" .. peer .. "] illegal command received.")
                        break
                    end
                    if (core:play()) then
                        print("(debug) [" .. peer .. "] ! play")
                    end
                else
                    print("(debug) [" .. peer .. "] something else.")
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
    local host, port = '127.0.0.1', 44444
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
