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
        players = p,
        current = 1,
        board = Chick._generate_board(p)
    }, {__index = Chick})
end

function Chick:move(chain)
    -- make sure the chain is valid
    if chain[1] == chain[#chain] then
        print("(debug) move chain is a cycle.")
        return 0
    end
    for _, v in pairs(chain) do
        if v < 1 or v > 121 then
            print("(debug) invalid move chain.")
            return 0
        end
    end

    -- check current turn
    local player = self.board[chain[1]]
    if player == 0 then
        print("(debug) there is no marble.")
        return 0
    end
    if player ~= self.current then
        print("(debug) you can't touch that marble.")
        return 0
    end

    local axis = require 'axis'

    -- special case simple move
    if #chain == 2 then
        local delta = {
            x = axis.map[chain[2]].x - axis.map[chain[1]].x,
            y = axis.map[chain[2]].y - axis.map[chain[1]].y,
            z = axis.map[chain[2]].z - axis.map[chain[1]].z
        }

        if math.abs(delta.x) + math.abs(delta.y) + math.abs(delta.z) == 2 then
            -- simple move detected
            print("(debug) simple move.")
            -- make sure target is clear
            if self.board[chain[2]] ~= 0 then
                print("(debug) adjacent target node is not clear.")
                return 0
            end

            -- save move to board
            self.board[chain[1]] = 0
            self.board[chain[2]] = self.current
            print("(debug) move " .. chain[1] .. " -> " .. chain[2] .. " simple")

            -- look for win
            if self:_win() then
                return -1 * self.current
            end

            -- next turn
            return self:_next()
        end
    end

    -- execute each step of the turn
    for i = 2, #chain do
        -- get source and target vectors
        local from = axis.map[chain[i-1]]
        local to = axis.map[chain[i]]

        -- make sure the jump is symmetric
        if from.x == to.x then

            print("(debug) x direction")
            local ydelta = math.abs(from.y - to.y)
            -- even number of nodes between source and target
            if ydelta % 2 == 1 then
                print("(debug) even number of nodes between source and target.")
                print("(debug) ydelta = " .. ydelta)
                return 0
            end

            -- calc center
            local yc = (from.y + to.y) / 2
            local center = axis.intersect({x = from.x, y = yc})[1]
            print("(debug) center : x = " .. from.x .. ", y = " .. yc .. ", node = " .. center)
            -- center node must not be void
            if self.board[axis.intersect(axis.map[center])[1]] == 0 then
                print("(debug) center node is void.")
                return 0
            end

            -- make sure the rest of the path is clear
            local upordown = from.y > to.y and -1 or 1
            print("(debug) upordown = " .. upordown)
            for j = from.y + upordown, yc - upordown, upordown do
                local intersection = axis.intersect({x = from.x, y = j})[1]
                print("(debug) checking node " .. intersection)
                if self.board[intersection] ~= 0 then
                    print("(debug) y-direction jump segment is not clear. [1]")
                    return 0
                end
            end
            for j = yc + upordown, to.y, upordown do
                local intersection = axis.intersect({x = from.x, y = j})[1]
                print("(debug) checking node " .. intersection)
                if self.board[intersection] ~= 0 then
                    print("(debug) y-direction jump segment is not clear. [2]")
                    return 0
                end
            end
        elseif from.y == to.y then

            print("(debug) y direction")
            local xdelta = math.abs(from.x - to.x)
            -- even number of nodes between source and target
            if xdelta % 2 == 1 then
                print("(debug) even number of nodes between source and target.")
                print("(debug) xdelta = " .. xdelta)
                return 0
            end

            -- calc center
            local xc = (from.x + to.x) / 2
            local center = axis.intersect({x = xc, y = from.y})[1]
            print("(debug) center : x = " .. xc .. ", y = " .. from.y .. ", node = " .. center)
            -- center node must not be void
            if self.board[axis.intersect(axis.map[center])[1]] == 0 then
                print("(debug) center node is void.")
                return 0
            end

            -- make sure the rest of the path is clear
            local upordown = from.x > to.x and -1 or 1
            print("(debug) upordown = " .. upordown)
            for j = from.x + upordown, xc - upordown, upordown do
                local intersection = axis.intersect({x = j, y = from.y})[1]
                print("(debug) checking node " .. intersection)
                if self.board[intersection] ~= 0 then
                    print("(debug) x-direction jump segment is not clear. [3]")
                    return 0
                end
            end
            for j = xc + upordown, to.x, upordown do
                local intersection = axis.intersect({x = j, y = from.y})[1]
                print("(debug) checking node " .. intersection)
                if self.board[intersection] ~= 0 then
                    print("(debug) x-direction jump segment is not clear. [4]")
                    return 0
                end
            end
        elseif from.z == to.z then

            print("(debug) z direction")
            local ydelta = math.abs(from.y - to.y)
            -- even number of nodes between source and target
            if ydelta % 2 == 1 then
                print("(debug) even number of nodes between source and target.")
                print("(debug) ydelta = " .. ydelta)
                return 0
            end

            -- calc center
            local yc = (from.y + to.y) / 2
            local center = axis.intersect({y = yc, z = from.z})[1]
            print("(debug) center : x = " .. from.x .. ", y = " .. yc .. ", node = " .. center)
            -- center node must not be void
            if self.board[axis.intersect(axis.map[center])[1]] == 0 then
                print("(debug) center node is void.")
                return 0
            end

            -- make sure the rest of the path is clear
            local upordown = from.y > to.y and -1 or 1
            print("(debug) upordown = " .. upordown)
            for j = from.y + upordown, yc - upordown, upordown do
                local intersection = axis.intersect({y = j, z = from.z})[1]
                print("(debug) checking node " .. intersection)
                if self.board[intersection] ~= 0 then
                    print("(debug) y-direction jump segment is not clear. [5]")
                    return 0
                end
            end
            for j = yc + upordown, to.y, upordown do
                local intersection = axis.intersect({y = j, z = from.z})[1]
                print("(debug) checking node " .. intersection)
                if self.board[intersection] ~= 0 then
                    print("(debug) y-direction jump segment is not clear. [6]")
                    return 0
                end
            end
        else
            -- source and target are not aligned
            print("(debug) source and target are not aligned.")
            return 0
        end

        -- save move to board
        self.board[chain[i-1]] = 0
        self.board[chain[i]] = self.current
        print("(debug) move " .. chain[i-1] .. " -> " .. chain[i] .. " jump")
    end

    -- look for win
    if self:_win() then
        return -1 * self.current
    end

    -- next turn
    return self:_next()
end

function Chick._generate_board(players)
    assert(players == 2 or players == 3 or players == 4 or players == 6, "illegal number of players.")
    local board = require 'board'
    return board[players]
end

function Chick:_win()
    local triangles = require 'triangles'
    local goal = {}

    -- determine goal triangle
    if self.players == 2 then
        if self.current == 1 then
            goal = triangles.d
        else
            goal = triangles.a
        end
    elseif self.players == 3 then
        if self.current == 1 then
            goal = triangles.d
        elseif self.current == 2 then
            goal = triangles.d
        else
            goal = triangles.b
        end
    elseif self.players == 4 then
        if self.current == 1 then
            goal = triangles.d
        elseif self.current == 2 then
            goal = triangles.e
        elseif self.current == 3 then
            goal = triangles.a
        else
            goal = triangles.b
        end
    elseif self.players == 6 then
        if self.current == 1 then
            goal = triangles.d
        elseif self.current == 2 then
            goal = triangles.e
        elseif self.current == 3 then
            goal = triangles.f
        elseif self.current == 4 then
            goal = triangles.a
        elseif self.current == 5 then
            goal = triangles.b
        else
            goal = triangles.c
        end
    end

    for _, v in pairs(goal) do
        if self.board[v] ~= self.current then
            return false
        end
    end
    print("(debug) we have a winner.")
    return true
end

function Chick:_next()
    self.current = self.current % self.players + 1
    return self.current
end
