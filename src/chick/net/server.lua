--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

Server = {}

function Server.new()
    return setmetatable({



    }, {__index = Server})
end

function Client:success()
end

function Client:error(reason)
end

function Client:move(from, to)
end

function Client:win(player)
end
