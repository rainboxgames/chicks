--[[
-- This file is part of chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local App = class('App')

App.WINDOW = { w = 1200, h = 800 }

function App:initialize()
    --[[
    -- these are sample players just for testing
    -- TODO set up players from user input
    -- init players
    self.__players = {
        Player("neo", {
            Target(Board.TRIANGLES.a, Board.TRIANGLES.d, Board.MARBLES.green)
        }),
        Player("akaisora", {
            Target(Board.TRIANGLES.d, Board.TRIANGLES.a, Board.MARBLES.red)
        })
    }

    -- init board
    self.__board = Board()

    -- init engine
    self.__engine = Engine(self.__board, self.__players)

    -- reset board to new game
    self.__engine:reset_board()

    -- load assets
    self.__assets = {
        board   = love.graphics.newImage('assets/images/board.png'),
        empty   = love.graphics.newImage('assets/images/empty.png'),
        blue    = love.graphics.newImage('assets/images/blue.png'),
        green   = love.graphics.newImage('assets/images/green.png'),
        purple  = love.graphics.newImage('assets/images/purple.png'),
        red     = love.graphics.newImage('assets/images/red.png'),
        white   = love.graphics.newImage('assets/images/white.png'),
        yellow  = love.graphics.newImage('assets/images/yellow.png')
    }

    -- testing
    log.debug("Testing...")

    self.__engine:move(6, 17)
    self.__engine:finish()
    self.__engine:move(115, 93)
    self.__engine:finish()
    --]]


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
    log.info("Version " .. CHICKS_VERSION)

    love.window.setMode(App.WINDOW.w, App.WINDOW.h)
    love.window.setTitle("Chicks " .. CHICKS_VERSION)
end

function App:update(dt)
    --[[
    suit.layout:reset(300, 100)
    suit.layout:padding(10, 10)

    suit.Button("Play", suit.layout:row(300, 60))
    suit.Button("Credits", suit.layout:row(300, 60))
    if suit.Button("Quit", suit.layout:row(300, 60)).hit then love.event.quit() end
    --]]


end

function App:draw()
    suit.draw()
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


--[[
App.TILES = {
    {y = 704,   x = 0},
    {y = 660,   x = 25},
    {y = 660,   x = -25},
    {y = 616,   x = 50},
    {y = 616,   x = 0},
    {y = 616,   x = -50},
    {y = 572,   x = 75},
    {y = 572,   x = 25},
    {y = 572,   x = -25},
    {y = 572,   x = -75},
    {y = 528,   x = 300},
    {y = 528,   x = 250},
    {y = 528,   x = 200},
    {y = 528,   x = 150},
    {y = 528,   x = 100},
    {y = 528,   x = 50},
    {y = 528,   x = 0},
    {y = 528,   x = -50},
    {y = 528,   x = -100},
    {y = 528,   x = -150},
    {y = 528,   x = -200},
    {y = 528,   x = -250},
    {y = 528,   x = -300},
    {y = 484,   x = 275},
    {y = 484,   x = 225},
    {y = 484,   x = 175},
    {y = 484,   x = 125},
    {y = 484,   x = 75},
    {y = 484,   x = 25},
    {y = 484,   x = -25},
    {y = 484,   x = -75},
    {y = 484,   x = -125},
    {y = 484,   x = -175},
    {y = 484,   x = -225},
    {y = 484,   x = -275},
    {y = 440,   x = 250},
    {y = 440,   x = 200},
    {y = 440,   x = 150},
    {y = 440,   x = 100},
    {y = 440,   x = 50},
    {y = 440,   x = 0},
    {y = 440,   x = -50},
    {y = 440,   x = -100},
    {y = 440,   x = -150},
    {y = 440,   x = -200},
    {y = 440,   x = -250},
    {y = 396,   x = 225},
    {y = 396,   x = 175},
    {y = 396,   x = 125},
    {y = 396,   x = 75},
    {y = 396,   x = 25},
    {y = 396,   x = -25},
    {y = 396,   x = -75},
    {y = 396,   x = -125},
    {y = 396,   x = -175},
    {y = 396,   x = -225},
    {y = 352,   x = 200},
    {y = 352,   x = 150},
    {y = 352,   x = 100},
    {y = 352,   x = 50},
    {y = 352,   x = 0},
    {y = 352,   x = -50},
    {y = 352,   x = -100},
    {y = 352,   x = -150},
    {y = 352,   x = -200},
    {y = 308,   x = 225},
    {y = 308,   x = 175},
    {y = 308,   x = 125},
    {y = 308,   x = 75},
    {y = 308,   x = 25},
    {y = 308,   x = -25},
    {y = 308,   x = -75},
    {y = 308,   x = -125},
    {y = 308,   x = -175},
    {y = 308,   x = -225},
    {y = 264,   x = 250},
    {y = 264,   x = 200},
    {y = 264,   x = 150},
    {y = 264,   x = 100},
    {y = 264,   x = 50},
    {y = 264,   x = 0},
    {y = 264,   x = -50},
    {y = 264,   x = -100},
    {y = 264,   x = -150},
    {y = 264,   x = -200},
    {y = 264,   x = -250},
    {y = 220,   x = 275},
    {y = 220,   x = 225},
    {y = 220,   x = 175},
    {y = 220,   x = 125},
    {y = 220,   x = 75},
    {y = 220,   x = 25},
    {y = 220,   x = -25},
    {y = 220,   x = -75},
    {y = 220,   x = -125},
    {y = 220,   x = -175},
    {y = 220,   x = -225},
    {y = 220,   x = -275},
    {y = 176,   x = 300},
    {y = 176,   x = 250},
    {y = 176,   x = 200},
    {y = 176,   x = 150},
    {y = 176,   x = 100},
    {y = 176,   x = 50},
    {y = 176,   x = 0},
    {y = 176,   x = -50},
    {y = 176,   x = -100},
    {y = 176,   x = -150},
    {y = 176,   x = -200},
    {y = 176,   x = -250},
    {y = 176,   x = -300},
    {y = 132,   x = 75},
    {y = 132,   x = 25},
    {y = 132,   x = -25},
    {y = 132,   x = -75},
    {y = 88,    x = 50},
    {y = 88,    x = 0},
    {y = 88,    x = -50},
    {y = 44,    x = 25},
    {y = 44,    x = -25},
    {y = 0,     x = 0}
}
]]

return App
