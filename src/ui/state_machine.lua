--[[
-- This file is part of chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local StateMachine = class('StateMachine')

function StateMachine:initialize(initial_state, states)
    assert(table.contains(states, initial_state))
    self.__current_state = initial_state
    self.__states = states
    self.__mapping = {}
end

function StateMachine:delta(event)
    if self.__mapping[self.__current_state] and self.__mapping[self.__current_state][event] then
        local t = self.__mapping[self.__current_state][event]
        -- update current state
        self.__current_state = t.state
        -- run callback if any
        if t.callback then t.callback() end
    else
        self.__current_state = 'error_state'
    end
end

function StateMachine:map(old_state, event, new_state, callback)
    assert(table.contains(self.__states, old_state))
    assert(table.contains(self.__states, new_state))
    if not self.__mapping[old_state] then self.__mapping[old_state] = {} end
    self.__mapping[old_state][event] = { state = new_state, callback = callback }
end

function StateMachine:get_state()
    return self.__current_state
end

return StateMachine
