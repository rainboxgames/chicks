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
    log.info("Client version " .. _VERSION)

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

    -- register callbacks
    self.__boardwidget:register_callback_move(self.__callback_move, self)
    self.__boardwidget:register_callback_finish(self.__callback_finish, self)

    -- debug complete game
    --complete_game(self.__engine)

    -- connect to game server
    local host, port = "localhost", 44444
    self.__socket = socket.connect(host, port)

    if self.__socket == nil then
        log.error("Failed to connect to server.")
        os.exit(-1)
    end
    log.info("Connected to " .. host .. ":" .. port)

    -- set block timeout
    self.__socket:settimeout(0.01)

    -- receive id

    -- debug only
    self:__send("NEW foo 2")
    self:__send("ETR foo")
    self:__send("LOS")
end

function App:update(dt)
    local x, y = love.mouse.getPosition()
    self.__boardwidget:update_mouse(x, y)

    local data = self.__socket:receive()

    if data then
        local pieces = table.explode(' ', data)

        if pieces[1] == "MOV" and pieces[2] and pieces[3] then
            self.__engine:move(tonumber(pieces[2]), tonumber(pieces[3]))
        elseif pieces[1] == "PLY" then
            self.__engine:finish()
        else
            log.debug("Invalid command from server.")
        end
    end
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
        self.__boardwidget:mousepressed(x, y, 1)
    elseif (button == 2 or button == 'r') then
        self.__boardwidget:mousepressed(x, y, 2)
    end
end

function App:mousereleased(x, y, button)
    if (button == 1 or button == 'l') then
        self.__boardwidget:mousereleased(x, y, 1)
    elseif (button == 2 or button == 'r') then
        self.__boardwidget:mousereleased(x, y, 2)
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

function App:__callback_move(from, to)
    log.debug("App:__callback_move()")
    if self.__engine:move(from, to) then
        self:__send("MOV " .. from .. " " .. to)
    end
end

function App:__callback_finish()
    log.debug("App:__callback_finish()")

    if self.__engine:finish() then
        self:__send("PLY")
    end
end

function App:__send(payload)
    self.__socket:send(struct.pack('>H', string.len(payload)) .. payload)
end

function App:__recv()
end

return App
