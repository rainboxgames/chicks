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
        board = Chick._generate_board()
    }, {__index = Chick})
end

function Chick:move(chain)
    local axis = require 'axis'

    -- check current turn
    local player = self.board[chain[1]]
    if player ~= self.current then return 0 end

    -- make sure the chain is valid
    for _, v in chain do
        if v < 1 or v > 121 then return 0 end
    end

    -- special case simple move


    -- execute each step of the turn
    for i = 2, #chain do
        -- get source and target vectors
        local from = axis.map[chain[i-1]]
        local to = axis.map[chain[i]]

        -- make sure the jump is symmetric
        if from.x == to.x then
            local ydelta = math.abs(from.y - to.y)
            -- even number of nodes between source and target
            if ydelta % 2 == 1 then return 0 end
            -- calc center
            local yc = (from.y + to.y) / 2
            local center = axis.intersect({x = from.x, y = yc})[1]
            -- center node must not be void
            if self.board[axis.intersect(center)[1]] == 0 then return 0 end
            -- make sure the rest of the path is clear
            local upordown = if from.y < to.y then 1 else -1 end
            for j = from.y, yc - upordown, upordown do
                if self.board[axis.intersect({x = from.x, y = j})[1]] ~= 0 then return 0 end
            end
            for j = yc + upordown, to.y, upordown do
                if self.board[axis.intersect({x = from.x, y = j})[1]] ~= 0 then return 0 end
            end
        elseif from.y == to.y then
            local xdelta = math.abs(from.x - to.x)
            -- even number of nodes between source and target
            if xdelta % 2 == 1 then return 0 end
            -- calc center
            local xc = (from.x + to.x) / 2
            local center = axis.intersect({x = xc, y = from.y})[1]
            -- center node must not be void
            if self.board[axis.intersect(center)[1]] == 0 then return 0 end
            -- make sure the rest of the path is clear
            local upordown = if from.x < to.x then 1 else -1 end
            for j = from.x, xc - upordown, upordown do
                if self.board[axis.intersect({x = j, y = from.y})[1]] ~= 0 then return 0 end
            end
            for j = xc + upordown, to.x, upordown do
                if self.board[axis.intersect({x = j, y = from.y})[1]] ~= 0 then return 0 end
            end
        elseif from.z == to.z then
            local ydelta = math.abs(from.y - to.y)
            -- even number of nodes between source and target
            if ydelta % 2 == 1 then return 0 end
            -- calc center
            local yc = (from.y + to.y) / 2
            local center = axis.intersect({y = yc, z = from.z})[1]
            -- center node must not be void
            if self.board[axis.intersect(center)[1]] == 0 then return 0 end
            -- make sure the rest of the path is clear
            local upordown = if from.y < to.y then 1 else -1 end
            for j = from.y, yc - upordown, upordown do
                if self.board[axis.intersect({y = j, z = from.z})[1]] ~= 0 then return 0 end
            end
            for j = yc + upordown, to.y, upordown do
                if self.board[axis.intersect({y = j, z = from.z})[1]] ~= 0 then return 0 end
            end
        else
            -- source and target not even aligned
            return 0
        end
    end

    -- look for win
    if self._win() then
        return -1 * self.current
    end

    -- next turn
    return self._next()
end

function Chick._generate_board()
    assert(self.players == 2 or self.players == 3 or self.players == 4 or self.players == 6, "illegal number of players")
    local board = require 'board'
    return board[p]
end

function Chick:_win()
    local triangles = require 'triangles'
    local t

    -- determine goal triangle
    if self.players == 2 then
        if self.current == 1 then
            t = triangles[d]
        else
            t = triangles[a]
        end
    elseif self.players == 3 then
        if self.current == 1 then
            t = triangles[d]
        elseif self.current == 2 then
            t = triangles[f]
        else
            t = triangles[b]
        end
    elseif self.players == 4 then
        if self.current == 1 then
            t = triangles[d]
        elseif self.current == 2 then
            t = triangles[e]
        elseif self.current == 3 then
            t = triangles[a]
        else
            t = triangles[b]
        end
    elseif self.players == 6 then
        if self.current == 1 then
            t = triangles[d]
        elseif self.current == 2 then
            t = triangles[e]
        elseif self.current == 3 then
            t = triangles[f]
        elseif self.current == 4 then
            t = triangles[a]
        elseif self.current == 5 then
            t = triangles[b]
        else
            t = triangles[c]
        end
    end

    for _, v in t do
        if self.board[v] ~= self.current then
            return false
        end
    end
    return true
end

function Chick:_next()
    return self.current = self.current % self.players + 1
end
