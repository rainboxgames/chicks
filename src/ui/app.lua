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
    self.__state_machine = StateMachine('main_menu', {
        'main_menu',
        'credits',
        'play_menu',
        'local_game_menu',
        'online_game_menu',
        'ingame',
        'abort_game_confirm_menu',
        'quit_confirm_menu'})

    self.__state_machine:map('main_menu', 'play_button', 'play_menu')
    self.__state_machine:map('main_menu', 'credits_button', 'credits')
    self.__state_machine:map('main_menu', 'quit_button', 'quit_confirm_menu')
    self.__state_machine:map('credits', 'back_button', 'main_menu')
    self.__state_machine:map('play_menu', 'back_button', 'main_menu')
    self.__state_machine:map('play_menu', 'online_button', 'online_game_menu')
    self.__state_machine:map('play_menu', 'local_button', 'local_game_menu')
    self.__state_machine:map('local_game_menu', 'back_button', 'play_menu')
    self.__state_machine:map('local_game_menu', 'start_button', 'ingame')
    self.__state_machine:map('online_game_menu', 'back_button', 'play_menu')
    self.__state_machine:map('ingame', 'abort_button', 'abort_game_confirm_menu')
    self.__state_machine:map('abort_game_confirm_menu', 'yes_button', 'main_menu')
    self.__state_machine:map('abort_game_confirm_menu', 'no_button', 'ingame')
    self.__state_machine:map('quit_confirm_menu', 'no_button', 'main_menu')
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
    local s = self.__state_machine:get_state()
    if     s == 'main_menu'                 then self:__display_main_menu()
    elseif s == 'credits'                   then self:__display_credits()
    elseif s == 'play_menu'                 then self:__display_play_menu()
    elseif s == 'local_game_menu'           then self:__display_local_game_menu()
    elseif s == 'online_game_menu'          then self:__display_online_game_menu()
    elseif s == 'ingame'                    then self:__display_ingame()
    elseif s == 'abort_game_confirm_menu'   then self:__display_abort_game_confirm_menu()
    elseif s == 'quit_confirm_menu'         then self:__display_quit_confirm_menu()
    end
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

function App:__display_main_menu()
    suit.layout:reset()
    suit.Label("Chicks", suit.layout:row(400, 100))
    if suit.Button("Play", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('play_button')
    end
    if suit.Button("Credits", suit.layout:row()).hit then
        self.__state_machine:delta('credits_button')
    end
    if suit.Button("Quit", suit.layout:row()).hit then
        self.__state_machine:delta('quit_button')
    end
end

function App:__display_play_menu()
    suit.layout:reset()
    suit.Label("Chicks > Play", suit.layout:row(400, 100))
    if suit.Button("Local", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('local_button')
    end
    if suit.Button("Online", suit.layout:row()).hit then
        self.__state_machine:delta('online_button')
    end
    if suit.Button("Back", suit.layout:row()).hit then
        self.__state_machine:delta('back_button')
    end
end

function App:__display_local_game_menu()
    suit.layout:reset()
    suit.Label("Chicks > Play > Local", suit.layout:row(400, 100))
    if suit.Button("Start Game", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('start_button')
    end
    if suit.Button("Back", suit.layout:row()).hit then
        self.__state_machine:delta('back_button')
    end
end

function App:__display_online_game_menu()
    suit.layout:reset()
    suit.Label("Chicks > Play > Online", suit.layout:row(400, 100))
    if suit.Button("Back", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('back_button')
    end
end

function App:__display_ingame()
    suit.layout:reset()
    if suit.Button("Abort Game", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('abort_button')
    end
end

function App:__display_abort_game_confirm_menu()
    suit.layout:reset()
    suit.Label("Are you sure you want to abort this game?", suit.layout:row(400, 100))
    if suit.Button("Yes", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('yes_button')
    end
    if suit.Button("No", suit.layout:col()).hit then
        self.__state_machine:delta('no_button')
    end
end

function App:__display_quit_confirm_menu()
    suit.layout:reset()
    suit.Label("Are you sure you want to quit?", suit.layout:row(400, 100))
    if suit.Button("Yes", suit.layout:row(100, 30)).hit then
        love.event.quit()
    end
    if suit.Button("No", suit.layout:col()).hit then
        self.__state_machine:delta('no_button')
    end
end

function App:__display_credits()
    suit.layout:reset()
    suit.Label("(c) 2015-2016 YouniS Bensalah (younishd)", suit.layout:row(400, 100))
    if suit.Button("Back", suit.layout:row(100, 30)).hit then
        self.__state_machine:delta('back_button')
    end
end

return App
