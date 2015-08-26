--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

Chick = {}

function Chick.new(p)
    return setmetatable({
        -- attributes
        players = p,
        current_player = 1,

        -- board map
        -- 0 : empty node
        -- p>0 : marble of player p
        board = Chick._generate_board(p),

        -- keep track of current move
        current_move = {source = 0, target = 0, simple = false}
    }, {__index = Chick})
end

function Chick:move(from, to)
    -- valid nodes
    if from < 1 or from > 121 or to < 1 or to > 121 then
        print("(debug) move has invalid nodes.")
        return false
    end

    -- detect null move
    if from == to then
        print("(debug) null move.")
        return false
    end

    -- check if player is allowed to move that marble
    -- source node is empty
    if self.board[from] == 0 then
        print("(debug) there is no marble.")
        return false
    end

    -- source node is occupied by another player
    if self.board[from] ~= self.current_player then
        print("(debug) you can't touch that marble.")
        return false
    end

    -- source node is not last target node and source and target are not equal (null)
    -- i.e., you can't touch two marbles in the same move sequence
    if self.current_move.source ~= self.current_move.target and self.current_move.target ~= from then
        print("(debug) moving two marbles at a time is risky.")
        return false
    end

    -- lookup xyz coordinates in axis map
    local axis = require 'axis'

    -- special case: simple move
    -- make sure simple move is still allowed (i.e., first move)
    if self.current_move.source == self.current_move.target then
        local delta =
        {
            x = axis.map[to].x - axis.map[from].x,
            y = axis.map[to].y - axis.map[from].y,
            z = axis.map[to].z - axis.map[from].z
        }

        if math.abs(delta.x) + math.abs(delta.y) + math.abs(delta.z) == 2 then
            -- simple move detected
            print("(debug) simple move.")
            -- make sure target node is clear
            if self.board[to] ~= 0 then
                print("(debug) adjacent target node is not clear.")
                return false
            end

            -- update current move source and target
            if self.current_move.source == self.current_move.target then
                -- new source
                self.current_move.source = from
                print("(debug) new source.")
            end
            -- new target
            self.current_move.target = to
            print("(debug) new target.")

            return true
        end
    end

    -- also handle the case where a simple move is taken back
    if self.current_move.simple and from == self.current_move.target and to == self.current_move.source then
        print("(debug) take back simple move.")
        self.current_move.target = self.current_move.source
        self.current_move.simple = false

        return true
    end

    -- jump move
    -- get source and target vectors
    local src_vec = axis.map[from]
    local tar_vec = axis.map[to]

    -- make sure the jump is symmetric
    if src_vec.x == tar_vec.x then

        -- jump in x direction
        print("(debug) x-dir jump.")
        local ydelta = math.abs(src_vec.y - tar_vec.y)

        -- number of nodes between source and target must be odd
        if ydelta % 2 == 1 then
            print("(debug) even number of nodes between source and target.")
            return false
        end

        -- calc center node
        local yc = (src_vec.y + tar_vec.y) / 2
        local center = axis.intersect({x = src_vec.x, y = yc})[1]
        print("(debug) center : " .. center)

        -- center node must not be void
        if self.board[axis.intersect(axis.map[center])[1]] == 0 then
            print("(debug) center node is void.")
            return false
        end

        -- up or down flag
        local upordown = src_vec.y > tar_vec.y and -1 or 1
        print("(debug) upordown = " .. upordown)
        -- check if path is clear
        for j = src_vec.y + upordown, yc - upordown, upordown do
            local intersection = axis.intersect({x = src_vec.x, y = j})[1]
            print("(debug) checking node " .. intersection)
            if self.board[intersection] ~= 0 then
                print("(debug) y-dir segment is not clear.")
                return false
            end
        end
        for j = yc + upordown, tar_vec.y, upordown do
            local intersection = axis.intersect({x = src_vec.x, y = j})[1]
            print("(debug) checking node " .. intersection)
            if self.board[intersection] ~= 0 then
                print("(debug) y-dir segment is not clear.")
                return false
            end
        end

    elseif src_vec.y == tar_vec.y then

        -- jump in y direction
        print("(debug) y-dir jump.")
        local xdelta = math.abs(src_vec.x - tar_vec.x)

        -- number of nodes between source and target must be odd
        if xdelta % 2 == 1 then
            print("(debug) even number of nodes between source and target.")
            return false
        end

        -- calc center node
        local xc = (src_vec.x + tar_vec.x) / 2
        local center = axis.intersect({x = xc, y = src_vec.y})[1]
        print("(debug) center : " .. center)

        -- center node must not be void
        if self.board[axis.intersect(axis.map[center])[1]] == 0 then
            print("(debug) center node is void.")
            return false
        end

        -- up or down flag
        local upordown = src_vec.x > tar_vec.x and -1 or 1
        print("(debug) upordown = " .. upordown)
        -- check if path is clear
        for j = src_vec.x + upordown, xc - upordown, upordown do
            local intersection = axis.intersect({x = j, y = src_vec.y})[1]
            print("(debug) checking node " .. intersection)
            if self.board[intersection] ~= 0 then
                print("(debug) y-dir segment is not clear.")
                return false
            end
        end
        for j = xc + upordown, tar_vec.x, upordown do
            local intersection = axis.intersect({x = j, y = src_vec.y})[1]
            print("(debug) checking node " .. intersection)
            if self.board[intersection] ~= 0 then
                print("(debug) y-dir segment is not clear.")
                return false
            end
        end

    elseif src_vec.z == tar_vec.z then

        -- jump in z direction
        print("(debug) z-dir jump")
        local ydelta = math.abs(src_vec.y - tar_vec.y)

        -- number of nodes between source and target must be odd
        if ydelta % 2 == 1 then
            print("(debug) even number of nodes between source and target.")
            return false
        end

        -- calc center node
        local yc = (src_vec.y + tar_vec.y) / 2
        local center = axis.intersect({y = yc, z = src_vec.z})[1]
        print("(debug) center : " .. center)

        -- center node must not be void
        if self.board[axis.intersect(axis.map[center])[1]] == 0 then
            print("(debug) center node is void.")
            return false
        end

        -- up or down flag
        local upordown = src_vec.y > tar_vec.y and -1 or 1
        print("(debug) upordown = " .. upordown)
        -- check if path is clear
        for j = src_vec.y + upordown, yc - upordown, upordown do
            local intersection = axis.intersect({y = j, z = src_vec.z})[1]
            print("(debug) checking node " .. intersection)
            if self.board[intersection] ~= 0 then
                print("(debug) z-dir segment is not clear.")
                return false
            end
        end
        for j = yc + upordown, tar_vec.y, upordown do
            local intersection = axis.intersect({y = j, z = src_vec.z})[1]
            print("(debug) checking node " .. intersection)
            if self.board[intersection] ~= 0 then
                print("(debug) z-dir segment is not clear.")
                return false
            end
        end

    else

        -- source and target are not aligned
        print("(debug) source and target are not aligned.")
        return false

    end

    -- update current move source and target
    if self.current_move.source == self.current_move.target then
        -- new source
        self.current_move.source = from
        print("(debug) new source.")
    end
    -- new target
    self.current_move.target = to
    print("(debug) new target.")

    print("(debug) current move : " .. self.current_move.source .. " -> " .. self.current_move.target)

    return true
end

function Chick:play()
    -- make sure current move chain is not null or a cycle
    if self.current_move.source == self.current_move.target then
        print("(debug) null or cyclic move chain.")
        return 0
    end

    -- save current move to actual board map
    self.board[self.current_move.source] = 0
    self.board[self.current_move.target] = self.current_player
    print("(debug) exec move " .. self.current_move.source .. " -> " .. self.current_move.target)

    -- reset current move cursors
    self.current_move.source = 0
    self.current_move.target = 0
    self.current_move.simple = false

    -- look for a win
    if self:_win() then
        return -1 * self.current_player
    end

    -- go to next turn
    return self:_next()
end

function Chick._generate_board(players)
    assert(players == 2 or players == 3 or players == 4 or players == 6, "illegal number of players.")

    local setup = require 'setup'
    return setup[players]
end

function Chick:_win()
    local triangles = require 'triangles'
    local goal = {}

    -- determine goal triangle
    if self.players == 2 then
        if self.current_player == 1 then
            goal = triangles.d
        else
            goal = triangles.a
        end
    elseif self.players == 3 then
        if self.current_player == 1 then
            goal = triangles.d
        elseif self.current_player == 2 then
            goal = triangles.d
        else
            goal = triangles.b
        end
    elseif self.players == 4 then
        if self.current_player == 1 then
            goal = triangles.d
        elseif self.current_player == 2 then
            goal = triangles.e
        elseif self.current_player == 3 then
            goal = triangles.a
        else
            goal = triangles.b
        end
    elseif self.players == 6 then
        if self.current_player == 1 then
            goal = triangles.d
        elseif self.current_player == 2 then
            goal = triangles.e
        elseif self.current_player == 3 then
            goal = triangles.f
        elseif self.current_player == 4 then
            goal = triangles.a
        elseif self.current_player == 5 then
            goal = triangles.b
        else
            goal = triangles.c
        end
    end

    for _, v in pairs(goal) do
        if self.board[v] ~= self.current_player then
            return false
        end
    end
    print("(debug) we have a winner.")
    return true
end

function Chick:_next()
    self.current_player = self.current_player % self.players + 1
    return self.current_player
end
