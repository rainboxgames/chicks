--[[
-- This file is part of chicks.
--
-- (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Engine = class('Engine')

function Engine:initialize(board, players, current_player_id)
    current_player_id = current_player_id or 1

    local number_of_players = #players
    assert(number_of_players == 2
        or number_of_players == 3
        or number_of_players == 4
        or number_of_players == 6,
        "Illegal number of players: must be 2, 3, 4, or 6.")

    assert(1 <= current_player_id and current_player_id <= number_of_players, "Illegal current player.")

    self.__board = board
    self.__players = players
    self.__current_player_id = current_player_id
    self.__number_of_players = number_of_players
    self.__current_move = {
        source = 0,
        target = 0,
        simple = false
    }
    self.__winner = 0
end

function Engine:reset_board()
    for i, player in pairs(self.__players) do
        for j, target in pairs(player:get_targets()) do
            local color = target:get_color()
            for k, tile in pairs(target:get_home()) do
                self.__board:place(tile, color)
            end
        end
    end
end

function Engine:move(from, to)
    -- fetch marble color
    local marble = self.__board:get_color_by_pos(from)
    log.debug("marble = " .. marble)

    -- detect null move
    if from == to then
        log.debug("Null move.")
        return false
    end

    -- check if player is allowed to move that marble
    if not self:__get_current_player():has_color(marble) then
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
        local src_vec = Board:pos_to_xyz(from)
        local tar_vec = Board:pos_to_xyz(to)
        local delta = {
            x = tar_vec.x - src_vec.x,
            y = tar_vec.y - src_vec.y,
            z = tar_vec.z - src_vec.z
        }

        -- detect simple move
        if math.abs(delta.x) + math.abs(delta.y) + math.abs(delta.z) == 2 then
            log.debug("Simple move detected.")

            -- save move to board
            if not self:__save_to_board(from, to, marble) then return false end

            -- update current move source and target and set simple move flag
            self:__update_current_move(from, to, true)

            return true
        end
    end

    -- also handle the case where a simple move is taken back
    if self.__current_move.simple and from == self.__current_move.target and to == self.__current_move.source then
        log.debug("Take back simple move.")

        -- save move to board
        if not self:__save_to_board(from, to, marble) then return false end

        -- update current move source and target and unset simple move flag
        self:__update_current_move(from, to, false)

        return true
    end

    -- regular jump move

    -- get source and target vectors
    local src_vec = Board:pos_to_xyz(from)
    local tar_vec = Board:pos_to_xyz(to)

    -- these are needed later
    local jump_dir
    local pivot_dir

    -- determine jump direction and pivot direction
    if src_vec.x == tar_vec.x then
        jump_dir = 'x'
        pivot_dir = 'y'
    elseif src_vec.y == tar_vec.y then
        jump_dir = 'y'
        pivot_dir = 'x'
    elseif src_vec.z == tar_vec.z then
        jump_dir = 'z'
        pivot_dir = 'y'
    else
        log.debug("Source and target are not aligned.")
        return false
    end
    log.debug("jump_dir = " .. jump_dir)
    log.debug("pivot_dir = " .. pivot_dir)

    -- calc pivot delta
    delta = math.abs(src_vec[pivot_dir] - tar_vec[pivot_dir])
    log.debug("delta = " .. delta)

    -- number of nodes between source and target must be odd
    if delta % 2 == 1 then
        log.debug("Even number of nodes between source and target.")
        return false
    end

    -- calc up or down flag
    local upordown = src_vec[pivot_dir] > tar_vec[pivot_dir] and -1 or 1
    log.debug("upordown = " .. upordown)

    -- calc center
    local center_xyz = {}
    center_xyz[jump_dir] = src_vec[jump_dir]
    center_xyz[pivot_dir] = (src_vec[pivot_dir] + tar_vec[pivot_dir]) / 2
    local center = Board:xyz_to_pos(center_xyz)
    assert(center)
    log.debug("center = " .. center)

    -- check center is occupied
    if self.__board:get_color_by_pos(center) == Board.MARBLES.empty then
        log.debug("Center tile is void.")
        return false
    end

    -- check if segment is clear otherwise
    for j = src_vec[pivot_dir] + upordown, center_xyz[pivot_dir] - upordown, upordown do
        local intersection_xyz = {}
        intersection_xyz[jump_dir] = src_vec[jump_dir]
        intersection_xyz[pivot_dir] = j
        local intersection = Board:xyz_to_pos(intersection_xyz)
        if self.__board:get_color_by_pos(intersection) ~= Board.MARBLES.empty then
            log.debug(jump_dir .. " segment is not clear.")
            return false
        end
    end
    for j = center_xyz[pivot_dir] + upordown, tar_vec[pivot_dir], upordown do
        local intersection_xyz = {}
        intersection_xyz[jump_dir] = src_vec[jump_dir]
        intersection_xyz[pivot_dir] = j
        local intersection = Board:xyz_to_pos(intersection_xyz)
        if self.__board:get_color_by_pos(intersection) ~= Board.MARBLES.empty then
            log.debug(jump_dir .. " segment is not clear.")
            return false
        end
    end

    -- save move to board
    if not self:__save_to_board(from, to, marble) then return false end

    -- update current move source and target and unset simple move flag
    self:__update_current_move(from, to, false)

    return true
end

function Engine:finish()
    -- make sure current move chain is not null or a cycle
    if self.__current_move.source == self.__current_move.target then
        log.debug("Null or cyclic move chain.")
        return false
    end

    log.debug("Finish " .. self.__current_move.source .. " --> " .. self.__current_move.target)

    -- reset current move cursors
    self.__current_move.source = 0
    self.__current_move.target = 0
    self.__current_move.simple = false

    -- look for a win
    self:__look_for_win()

    -- go to next turn
    self:__next()

    return true
end

function Engine:get_winner()
    if self.__winner == 0 then
        return false
    else
        return self.__players[self.__winner]
    end
end

function Engine:__get_current_player()
    return self.__players[self.__current_player_id]
end

function Engine:__look_for_win()
    for i, player in pairs(self.__players) do
        local win = true
        for j, target in pairs(player:get_targets()) do
            local color = target:get_color()
            for k, tile in pairs(target:get_away()) do
                if self.__board:get_color_by_pos(tile) ~= color then
                    win = false
                    break
                end
            end
            -- player needs to finish all targets to win
            if not win then break end
        end
        -- we found a winner
        if win then break end
    end
    return win
end

function Engine:__next()
    self.__current_player_id = self.__current_player_id % self.__number_of_players + 1
end

function Engine:__update_current_move(from, to, simple_move_flag)
    if self.__current_move.source == self.__current_move.target then
        -- new source
        self.__current_move.source = from
        log.debug("Update current source: " .. from)
    end
    -- new target
    self.__current_move.target = to
    log.debug("Update current target: " .. to)

    -- set simple move flag
    self.__current_move.simple = simple_move_flag
    log.debug("Update simple move flag: " .. tostring(simple_move_flag))
end

function Engine:__save_to_board(from, to, marble)
    -- grab marble
    if not self.__board:remove(from) then
        log.debug("Board says no.")
        return false
    end

    -- place marble
    if not self.__board:place(to, marble) then
        log.debug("Board says no.")
        return false
    end

    log.debug("Move " .. from .. " --> " .. to)
    return true
end

return Engine
