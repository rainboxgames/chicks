--[[
-- This file is part of rainboxgames/chicks.
--
-- (c) 2015-2016 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Engine = class('Engine')

function Engine:initialize(board, number_of_players, number_of_colors, current_player)
    assert(number_of_players == 2
        or number_of_players == 3
        or number_of_players == 4
        or number_of_players == 6,
        "Illegal number of players: must be 2, 3, 4, or 6")
    assert(number_of_colors == number_of_players
        or number_of_colors == 4 and number_of_players == 2
        or number_of_colors == 6 and number_of_players == 2
        or number_of_colors == 6 and number_of_players == 3,
        "Illegal number of colors")
    assert(1 <= current_player and current_player <= number_of_players,
        "Illegal current player")

    self.__board = board
    self.__number_of_players = number_of_players
    self.__number_of_colors = number_of_colors
    self.__current_player = current_player
    self.__current_move = {
        source = 0,
        target = 0,
        simple = false
    }
end

function Engine:move(from, to)
    -- valid nodes
    if from < 1 or from > self.__board.MAX_TILES or to < 1 or to > self.__board.MAX_TILES then
        log.debug("Move has invalid nodes.")
        return false
    end

    -- detect null move
    if from == to then
        log.debug("Null move.")
        return false
    end

    -- check if player is allowed to move that marble
    -- initial source node is empty or occupied by another player
    if self.__board[from] == self.__board.MARBLES.empty then
        log.debug("There is no marble.")
        return false
    end
    if self.__board[from] ~= self.__player_to_color(self.__current_player) then
        log.debug("You can't touch that marble.")
        return false
    end

    -- source node is not last target node and source and target are not equal (null)
    -- i.e., you can't touch two marbles in the same move sequence
    if self.__current_move.source ~= self.__current_move.target and self.__current_move.target ~= from then
        log.debug("Moving two marbles at a time is risky.")
        return false
    end

    -- special case: simple move
    -- make sure simple move is still allowed (i.e., first move)
    if self.__current_move.source == self.__current_move.target then
        local delta = {
            x = self.__board.REVERSE_AXIS_MAP[to].x - self.__board.REVERSE_AXIS_MAP[from].x,
            y = self.__board.REVERSE_AXIS_MAP[to].y - self.__board.REVERSE_AXIS_MAP[from].y,
            z = self.__board.REVERSE_AXIS_MAP[to].z - self.__board.REVERSE_AXIS_MAP[from].z
        }

        if math.abs(delta.x) + math.abs(delta.y) + math.abs(delta.z) == 2 then
            -- simple move detected
            log.debug("Simple move detected.")
            -- make sure target node is clear
            if self.__board[to] ~= 0 then
                log.debug("Adjacent target node is not clear.")
                return false
            end

            -- save current move to actual board map
            self.__board[from] = self.__board.MARBLES.empty
            self.__board[to] = self.__player_to_color(self.__current_player)
            log.debug("Save move: " .. from .. " --> " .. to)

            -- update current move source and target
            if self.__current_move.source == self.__current_move.target then
                -- new source
                self.__current_move.source = from
                log.debug("Update source: " .. from)
            end
            -- new target
            self.__current_move.target = to
            log.debug("Update target: " .. to)

            -- set simple move flag
            self.__current_move.simple = true

            return true
        end
    end

    -- also handle the case where a simple move is taken back
    if self.__current_move.simple and from == self.__current_move.target and to == self.__current_move.source then
        log.debug("Take back simple move.")

        -- save current move to actual board map
        self.__board[from] = self.__board.MARBLES.empty
        self.__board[to] = self.__player_to_color(self.__current_player)
        log.debug("Save move: " .. from .. " --> " .. to)

        -- update current move target and unset the simple move flag
        self.__current_move.target = self.__current_move.source
        self.__current_move.simple = false

        return true
    end

    -- jump move
    -- get source and target vectors
    local src_vec = self.__board.REVERSE_AXIS_MAP[from]
    local tar_vec = self.__board.REVERSE_AXIS_MAP[to]

    -- make sure the jump is symmetric
    if src_vec.x == tar_vec.x then

        -- jump in x direction
        log.debug("X jump.")
        local ydelta = math.abs(src_vec.y - tar_vec.y)

        -- number of nodes between source and target must be odd
        if ydelta % 2 == 1 then
            log.debug("Even number of nodes between source and target.")
            return false
        end

        -- calc center node
        local yc = (src_vec.y + tar_vec.y) / 2
        local center = self.__board.axis_intersect({x = src_vec.x, y = yc})[1]
        log.debug("center = " .. center)

        -- center node must not be void
        if self.__board[self.__board.axis_intersect(self.__board.REVERSE_AXIS_MAP[center])[1]] == self.__board.MARBLES.empty then
            log.debug("Center node is void.")
            return false
        end

        -- up or down flag
        local upordown = src_vec.y > tar_vec.y and -1 or 1
        log.debug("upordown = " .. upordown)
        -- check if path is clear
        for j = src_vec.y + upordown, yc - upordown, upordown do
            local intersection = self.__board.axis_intersect({x = src_vec.x, y = j})[1]
            log.debug("Checking node " .. intersection)
            if self.__board[intersection] ~= 0 then
                log.debug("X segment is not clear.")
                return false
            end
        end
        for j = yc + upordown, tar_vec.y, upordown do
            local intersection = self.__board.axis_intersect({x = src_vec.x, y = j})[1]
            log.debug("Checking node " .. intersection)
            if self.__board[intersection] ~= 0 then
                log.debug("X segment is not clear.")
                return false
            end
        end

    elseif src_vec.y == tar_vec.y then

        -- jump in y direction
        log.debug("Y jump.")
        local xdelta = math.abs(src_vec.x - tar_vec.x)

        -- number of nodes between source and target must be odd
        if xdelta % 2 == 1 then
            log.debug("Even number of nodes between source and target.")
            return false
        end

        -- calc center node
        local xc = (src_vec.x + tar_vec.x) / 2
        local center = self.__board.axis_intersect({x = xc, y = src_vec.y})[1]
        log.debug("center = " .. center)

        -- center node must not be void
        if self.__board[self.__board.axis_intersect(self.__board.REVERSE_AXIS_MAP[center])[1]] == self.__board.MARBLES.empty then
            log.debug("Center node is void.")
            return false
        end

        -- up or down flag
        local upordown = src_vec.x > tar_vec.x and -1 or 1
        log.debug("upordown = " .. upordown)
        -- check if path is clear
        for j = src_vec.x + upordown, xc - upordown, upordown do
            local intersection = self.__board.axis_intersect({x = j, y = src_vec.y})[1]
            log.debug("Checking node " .. intersection)
            if self.__board[intersection] ~= 0 then
                log.debug("Y segment is not clear.")
                return false
            end
        end
        for j = xc + upordown, tar_vec.x, upordown do
            local intersection = self.__board.axis_intersect({x = j, y = src_vec.y})[1]
            log.debug("Checking node " .. intersection)
            if self.__board[intersection] ~= 0 then
                log.debug("Y segment is not clear.")
                return false
            end
        end

    elseif src_vec.z == tar_vec.z then

        -- jump in z direction
        log.debug("Z jump")
        local ydelta = math.abs(src_vec.y - tar_vec.y)

        -- number of nodes between source and target must be odd
        if ydelta % 2 == 1 then
            log.debug("Even number of nodes between source and target.")
            return false
        end

        -- calc center node
        local yc = (src_vec.y + tar_vec.y) / 2
        local center = self.__board.axis_intersect({y = yc, z = src_vec.z})[1]
        log.debug("center = " .. center)

        -- center node must not be void
        if self.__board[self.__board.axis_intersect(self.__board.REVERSE_AXIS_MAP[center])[1]] == self.__board.MARBLES.empty then
            log.debug("Center node is void.")
            return false
        end

        -- up or down flag
        local upordown = src_vec.y > tar_vec.y and -1 or 1
        log.debug("upordown = " .. upordown)
        -- check if path is clear
        for j = src_vec.y + upordown, yc - upordown, upordown do
            local intersection = self.__board.axis_intersect({y = j, z = src_vec.z})[1]
            log.debug("Checking node " .. intersection)
            if self.__board[intersection] ~= 0 then
                log.debug("Z segment is not clear.")
                return false
            end
        end
        for j = yc + upordown, tar_vec.y, upordown do
            local intersection = self.__board.axis_intersect({y = j, z = src_vec.z})[1]
            log.debug("Checking node " .. intersection)
            if self.__board[intersection] ~= 0 then
                log.debug("Z segment is not clear.")
                return false
            end
        end

    else

        -- source and target are not aligned
        log.debug("Source and target are not aligned.")
        return false

    end

    self.__board[from] = self.__board.MARBLES.empty
    self.__board[to] = self.__player_to_color(self.__current_player)
    log.debug("Save move: " .. from .. " --> " .. to)

    -- update current move source and target
    if self.__current_move.source == self.__current_move.target then
        -- new source
        self.__current_move.source = from
        log.debug("Update source: " .. from)
    end
    -- new target
    self.__current_move.target = to
    log.debug("Update target: " .. to)

    return true
end

function Engine:finish()
end

return Engine
