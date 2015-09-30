--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

Client = {}

function Client.new()
    return setmetatable({



    }, {__index = Client})
end

function Client:create_room(room)
end

function Client:move(from, to)
end

function Client:leave()
end

function Client:info()
end

function Client:play()
end

function Client:toggle_ready()
end

function Client:set_color(color)
end

function Client:set_nickname(nickname)
end

function Client:enter_room(room)
end
