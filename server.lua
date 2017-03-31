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
socket          = require 'socket'
copas           = require 'copas'
Engine          = require 'core.Engine'
Board           = require 'core.Board'
Player          = require 'core.Player'
Target          = require 'core.Target'
log             = require 'util.log'
tablextra       = require 'util.tablextra'
table.print     = tablextra.print
table.explode   = tablextra.explode
table.contains  = tablextra.contains
table.append    = tablextra.append

local peers = {}
local cnx_count = 0

local players = {}
local rooms = {}

local ROOM_STATUS = {
    open = 1,
    ingame = 2
}

local function broadcast(payload)
    for _, s in pairs(sockets) do
        send(s, payload)
    end
end

local function send(sock, payload)
    copas.send(sock, payload .. "\r\n")
end

local function create_room(peer, room, number_of_players)
    if rooms[room] then
        return false
    end
    rooms[room] = {
        status = ROOM_STATUS.open,
        number_of_players = number_of_players,
        players = {},
        engine = nil
    }
    log.debug("Created room " .. room)
    return true
end

local function enter_room(peer, room)
    if not rooms[room] and rooms[room].status ~= ROOM_STATUS.open then
        return false
    end

    rooms[room].players[peer] = peers[peer].player
    peers[peer].player.room = room
    log.debug("Joined room " .. room)
    return true
end

-- DEBUG this is still just test code
local function set_home(peer, home)
    log.debug("Change home triangle to ".. home)
    peers[peer].player.home = home
    return true
end

-- DEBUG this is still just test code
local function set_away(peer, away)
    log.debug("Change away triangle to ".. away)
    peers[peer].player.away = away
    return true
end


local function change_nick(peer, nick)
    log.debug("Change nick to ".. nick)
    peers[peer].player.nick = nick
    return true
end

local function change_color(peer, color)
    color = tonumber(color)
    if not Board.REVERSE_MARBLES[color] then
        return false
    end
    log.debug("Change color to " .. Board.REVERSE_MARBLES[color])
    peers[peer].player.color = color
    return true
end

local function toggle_ready(peer)
    -- make sure the player has joined a room and the game is open
    if peers[peer].player.room == "" or rooms[peers[peer].player.room].status ~= ROOM_STATUS.open then
        return false
    end

    peers[peer].player.ready = not peers[peer].player.ready
    return true
end

local function move(peer, from, to)
    -- make sure the player has joined a room and the game is ongoing
    if peers[peer].player.room == "" or rooms[peers[peer].player.room].status ~= ROOM_STATUS.ingame then
        return false
    end

    return rooms[peers[peer].player.room].engine:move(from, to)
end

local function finish_move(peer)
    -- make sure the player has joined a room and the game is ongoing
    if peers[peer].player.room == "" or rooms[peers[peer].player.room].status ~= ROOM_STATUS.ingame then
        return false
    end

    return rooms[peers[peer].player.room].engine:finish()
end

local function list_rooms(peer)
end

local function start_game(peer)
    local p = {}
    for k, v in pairs(rooms[peers[peer].player.room].players) do
        table.append(p, Player(v.nick, {Target(Board.TRIANGLES[v.home], Board.TRIANGLES[v.away], v.color)}))
    end

    local e = Engine(Board(), p)
    e:reset_board()
    rooms[peers[peer].player.room].engine = e
    return true
end

local function react(sock, ret)
    if ret then send(sock, "SUC") else send(sock, "ERR") end
end

local function handle(sock)
    local addr, port = sock:getpeername()
    local peer = addr .. ':' .. port
    log.debug("Hello, " .. peer)

    cnx_count = cnx_count + 1

    -- save socket
    peers[peer] = {}
    peers[peer].socket = sock
    peers[peer].player = {
        nick = "UnnamedPlayer",
        color = Board.MARBLES.green,
        room = "",
        ready = false,
        home = "",
        away = ""
    }

    -- this is a trick to use "break" as "continue" in lua
    while true do while true do

        local data = copas.receive(sock)

        if data then
            local pieces = table.explode(' ', data)

            if pieces[1] == "NEW" and pieces[2] and pieces[3] then
                react(sock, create_room(peer, pieces[2], pieces[3]))

            elseif pieces[1] == "ETR" and pieces[2] then
                react(sock, enter_room(peer, pieces[2]))

            elseif pieces[1] == "HOM" and pieces[2] then
                react(sock, set_home(peer, pieces[2]))

            elseif pieces[1] == "AWY" and pieces[2] then
                react(sock, set_away(peer, pieces[2]))

            elseif pieces[1] == "NIC" and pieces[2] then
                react(sock, change_nick(peer, pieces[2]))

            elseif pieces[1] == "COL" and pieces[2] then
                react(sock, change_color(peer, pieces[2]))

            elseif pieces[1] == "MOV" and pieces[2] and pieces[3] then
                react(sock, move(peer, pieces[2], pieces[3]))

            elseif pieces[1] == "RDY" then
                react(sock, toggle_ready(peer))

            elseif pieces[1] == "PLY" then
                react(sock, finish_move(peer))

            elseif pieces[1] == "LST" then
                react(sock, list_rooms(peer))

            elseif pieces[1] == "LOS" then
                react(sock, start_game(peer))

            else
                log.debug("Invalid command.")
                send(sock, "ERR")
            end
        end

    end end
end

local function serve()
    log.info([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __  ______
    /    \  \/|  |  \|  |/ ___\|  |/ / /  ___/
    \     \___|   Y  \  \  \___|    <  \___ \
     \______  /___|  /__|\___  >__|_ \/____  >
            \/     \/        \/     \/     \/

    ]])
    log.info("Server version " .. _VERSION)

    local host, port = arg[1] or "*", tonumber(arg[2]) or 44444
    local sock = socket.bind(host, port)
    if sock then
        log.info("Listening on " .. host .. ":" .. port)

        -- register handler callback
        copas.addserver(sock, handle)

        -- dispatch
        copas.loop()
    else
        log.error("Failed to bind socket.")
    end
end

serve()
