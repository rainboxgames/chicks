--[[
-- This file is part of chicks.
--
-- (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--]]

local Board = class('Board')

function Board:initialize()
    self.__map = {
                        0,
                       0, 0,
                      0, 0, 0,
                     0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0,
                            0, 0, 0,
                              0, 0,
                                0
    }
end

function Board:place(pos, color)
    assert(Board:pos_is_valid(pos), "Invalid position.")
    assert(color == Board.MARBLES.green
        or color == Board.MARBLES.blue
        or color == Board.MARBLES.yellow
        or color == Board.MARBLES.purple
        or color == Board.MARBLES.white
        or color == Board.MARBLES.red,
        "Invalid or empty marble.")

    if self.__map[pos] ~= Board.MARBLES.empty then
        log.debug("There is already another marble.")
        return false
    end

    self.__map[pos] = color

    log.debug("Place color " .. color .. " at " .. pos .. ".")
    return true
end

function Board:remove(pos)
    assert(Board:pos_is_valid(pos), "Invalid position.")

    local color = self.__map[pos]

    if self.__map[pos] == Board.MARBLES.empty then
        log.debug("There is no marble.")
        return false
    end

    self.__map[pos] = Board.MARBLES.empty

    log.debug("Remove color " .. color .. " at " .. pos .. ".")
    return true
end

function Board:get_color_by_pos(pos)
    assert(Board:pos_is_valid(pos), "Invalid position.")
    return self.__map[pos]
end

function Board:get_color_by_xyz(xyz)
    return self:get_color_by_pos(Board:xyz_to_pos(xyz))
end

function Board.static:xyz_rotate_cw(xyz)
    return {
        x = xyz.z,
        y = xyz.x,
        z = Board.ROTATION_OFFSET - xyz.y
    }
end

function Board.static:xyz_rotate_ccw(xyz)
    return {
        x = xyz.y,
        y = Board.ROTATION_OFFSET - xyz.z,
        z = xyz.x
    }
end

function Board.static:xyz_to_pos(xyz)
    res = Board:xyz_axis_intersect(xyz)
    if res[1] ~= nil then
        return res[1]
    end
    return false
end

function Board.static:pos_to_xyz(pos)
    assert(Board:pos_is_valid(pos), "Invalid position.")

    return Board.REVERSE_AXIS_MAP[pos]
end

function Board.static:xyz_axis_intersect(xyz)
    local s = {}
    if xyz.x ~= nil and xyz.y ~= nil then
        local sx = {}
        for _, v in pairs(Board.AXIS_MAP.x[xyz.x]) do sx[v] = true end
        for _, v in pairs(Board.AXIS_MAP.y[xyz.y]) do
            if sx[v] then s[#s+1] = v end
        end
    elseif xyz.y ~= nil and xyz.z ~= nil then
        local sy = {}
        for _, v in pairs(Board.AXIS_MAP.y[xyz.y]) do sy[v] = true end
        for _, v in pairs(Board.AXIS_MAP.z[xyz.z]) do
            if sy[v] then s[#s+1] = v end
        end
    elseif xyz.z ~= nil and xyz.x ~= nil then
        local sz = {}
        for _, v in pairs(Board.AXIS_MAP.z[xyz.z]) do sz[v] = true end
        for _, v in pairs(Board.AXIS_MAP.x[xyz.x]) do
            if sz[v] then s[#s+1] = v end
        end
    end
    return s
end

function Board.static:pos_is_valid(pos)
    return pos ~= nil and 1 <= pos and pos <= Board.MAX_TILES
end

Board.MARBLES = {
    empty = 0,
    green = 1,
    blue = 2,
    yellow = 3,
    purple = 4,
    white = 5,
    red = 6
}
Board.REVERSE_MARBLES = {}
Board.REVERSE_MARBLES[0] = "empty"
Board.REVERSE_MARBLES[1] = "green"
Board.REVERSE_MARBLES[2] = "blue"
Board.REVERSE_MARBLES[3] = "yellow"
Board.REVERSE_MARBLES[4] = "purple"
Board.REVERSE_MARBLES[5] = "white"
Board.REVERSE_MARBLES[6] = "red"

Board.MAX_TILES = 121

Board.ROTATION_OFFSET = 18

Board.AXIS_MAP = {
    x = {
        {23},
        {22, 35},
        {21, 34, 46},
        {20, 33, 45, 56},
        {1, 3, 6, 10, 19, 32, 44, 55, 65, 75, 86, 98, 111},
        {2, 5, 9, 18, 31, 43, 54, 64, 74, 85, 97, 110},
        {4, 8, 17, 30, 42, 53, 63, 73, 84, 96, 109},
        {7, 16, 29, 41, 52, 62, 72, 83, 95, 108},
        {15, 28, 40, 51, 61, 71, 82, 94, 107},
        {14, 27, 39, 50, 60, 70, 81, 93, 106, 115},
        {13, 26, 38, 49, 59, 69, 80, 92, 105, 114, 118},
        {12, 25, 37, 48, 58, 68, 79, 91, 104, 113, 117, 120},
        {11, 24, 36, 47, 57, 67, 78, 90, 103, 112, 116, 119, 121},
        {66, 77, 89, 102},
        {76, 88, 101},
        {87, 100},
        {99}
    },

    y = {
        {111},
        {98, 110},
        {86, 97, 109},
        {75, 85, 96, 108},
        {23, 35, 46, 56, 65, 74, 84, 95, 107, 115, 118, 120, 121},
        {22, 34, 45, 55, 64, 73, 83, 94, 106, 114, 117, 119},
        {21, 33, 44, 54, 63, 72, 82, 93, 105, 113, 116},
        {20, 32, 43, 53, 62, 71, 81, 92, 104, 112},
        {19, 31, 42, 52, 61, 70, 80, 91, 103},
        {10, 18, 30, 41, 51, 60, 69, 79, 90, 102},
        {6, 9, 17, 29, 40, 50, 59, 68, 78, 89, 101},
        {3, 5, 8, 16, 28, 39, 49, 58, 67, 77, 88, 100},
        {1, 2, 4, 7, 15, 27, 38, 48, 57, 66, 78, 87, 99},
        {14, 26, 37, 47},
        {13, 25, 36},
        {12, 24},
        {11}
    },

    z = {
        {1},
        {2, 3},
        {4, 5, 6},
        {7, 8, 9, 10},
        {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23},
        {24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35},
        {36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46},
        {47, 48, 49, 50, 51, 52, 53, 54, 55, 56},
        {57, 58, 59, 60, 61, 62, 63, 64, 65},
        {66, 67, 68, 69, 70, 71, 72, 73, 74, 75},
        {76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86},
        {87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98},
        {99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111},
        {112, 113, 114, 115},
        {116, 117, 118},
        {119, 120},
        {121}
    }
}

Board.REVERSE_AXIS_MAP = {
    {x = 5,     y = 13,     z = 1},
    {x = 6,     y = 13,     z = 2},
    {x = 5,     y = 12,     z = 2},
    {x = 7,     y = 13,     z = 3},
    {x = 6,     y = 12,     z = 3},
    {x = 5,     y = 11,     z = 3},
    {x = 8,     y = 13,     z = 4},
    {x = 7,     y = 12,     z = 4},
    {x = 6,     y = 11,     z = 4},
    {x = 5,     y = 10,     z = 4},
    {x = 13,    y = 17,     z = 5},
    {x = 12,    y = 16,     z = 5},
    {x = 11,    y = 15,     z = 5},
    {x = 10,    y = 14,     z = 5},
    {x = 9,     y = 13,     z = 5},
    {x = 8,     y = 12,     z = 5},
    {x = 7,     y = 11,     z = 5},
    {x = 6,     y = 10,     z = 5},
    {x = 5,     y = 9,      z = 5},
    {x = 4,     y = 8,      z = 5},
    {x = 3,     y = 7,      z = 5},
    {x = 2,     y = 6,      z = 5},
    {x = 1,     y = 5,      z = 5},
    {x = 13,    y = 16,     z = 6},
    {x = 12,    y = 15,     z = 6},
    {x = 11,    y = 14,     z = 6},
    {x = 10,    y = 13,     z = 6},
    {x = 9,     y = 12,     z = 6},
    {x = 8,     y = 11,     z = 6},
    {x = 7,     y = 10,     z = 6},
    {x = 6,     y = 9,      z = 6},
    {x = 5,     y = 8,      z = 6},
    {x = 4,     y = 7,      z = 6},
    {x = 3,     y = 6,      z = 6},
    {x = 2,     y = 5,      z = 6},
    {x = 13,    y = 15,     z = 7},
    {x = 12,    y = 14,     z = 7},
    {x = 11,    y = 13,     z = 7},
    {x = 10,    y = 12,     z = 7},
    {x = 9,     y = 11,     z = 7},
    {x = 8,     y = 10,     z = 7},
    {x = 7,     y = 9,      z = 7},
    {x = 6,     y = 8,      z = 7},
    {x = 5,     y = 7,      z = 7},
    {x = 4,     y = 6,      z = 7},
    {x = 3,     y = 5,      z = 7},
    {x = 13,    y = 14,     z = 8},
    {x = 12,    y = 13,     z = 8},
    {x = 11,    y = 12,     z = 8},
    {x = 10,    y = 11,     z = 8},
    {x = 9,     y = 10,     z = 8},
    {x = 8,     y = 9,      z = 8},
    {x = 7,     y = 8,      z = 8},
    {x = 6,     y = 7,      z = 8},
    {x = 5,     y = 6,      z = 8},
    {x = 4,     y = 5,      z = 8},
    {x = 13,    y = 13,     z = 9},
    {x = 12,    y = 12,     z = 9},
    {x = 11,    y = 11,     z = 9},
    {x = 10,    y = 10,     z = 9},
    {x = 9,     y = 9,      z = 9},
    {x = 8,     y = 8,      z = 9},
    {x = 7,     y = 7,      z = 9},
    {x = 6,     y = 6,      z = 9},
    {x = 5,     y = 5,      z = 9},
    {x = 14,    y = 13,     z = 10},
    {x = 13,    y = 12,     z = 10},
    {x = 12,    y = 11,     z = 10},
    {x = 11,    y = 10,     z = 10},
    {x = 10,    y = 9,      z = 10},
    {x = 9,     y = 8,      z = 10},
    {x = 8,     y = 7,      z = 10},
    {x = 7,     y = 6,      z = 10},
    {x = 6,     y = 5,      z = 10},
    {x = 5,     y = 4,      z = 10},
    {x = 15,    y = 13,     z = 11},
    {x = 14,    y = 12,     z = 11},
    {x = 13,    y = 11,     z = 11},
    {x = 12,    y = 10,     z = 11},
    {x = 11,    y = 9,      z = 11},
    {x = 10,    y = 8,      z = 11},
    {x = 9,     y = 7,      z = 11},
    {x = 8,     y = 6,      z = 11},
    {x = 7,     y = 5,      z = 11},
    {x = 6,     y = 4,      z = 11},
    {x = 5,     y = 3,      z = 11},
    {x = 16,    y = 13,     z = 12},
    {x = 15,    y = 12,     z = 12},
    {x = 14,    y = 11,     z = 12},
    {x = 13,    y = 10,     z = 12},
    {x = 12,    y = 9,      z = 12},
    {x = 11,    y = 8,      z = 12},
    {x = 10,    y = 7,      z = 12},
    {x = 9,     y = 6,      z = 12},
    {x = 8,     y = 5,      z = 12},
    {x = 7,     y = 4,      z = 12},
    {x = 6,     y = 3,      z = 12},
    {x = 5,     y = 2,      z = 12},
    {x = 17,    y = 13,     z = 13},
    {x = 16,    y = 12,     z = 13},
    {x = 15,    y = 11,     z = 13},
    {x = 14,    y = 10,     z = 13},
    {x = 13,    y = 9,      z = 13},
    {x = 12,    y = 8,      z = 13},
    {x = 11,    y = 7,      z = 13},
    {x = 10,    y = 6,      z = 13},
    {x = 9,     y = 5,      z = 13},
    {x = 8,     y = 4,      z = 13},
    {x = 7,     y = 3,      z = 13},
    {x = 6,     y = 2,      z = 13},
    {x = 5,     y = 1,      z = 13},
    {x = 13,    y = 8,      z = 14},
    {x = 12,    y = 7,      z = 14},
    {x = 11,    y = 6,      z = 14},
    {x = 10,    y = 5,      z = 14},
    {x = 13,    y = 7,      z = 15},
    {x = 12,    y = 6,      z = 15},
    {x = 11,    y = 5,      z = 15},
    {x = 13,    y = 6,      z = 16},
    {x = 12,    y = 5,      z = 16},
    {x = 13,    y = 5,      z = 17}
}

Board.TRIANGLES = {
    a = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
    b = {11, 12, 13, 14, 24, 25, 26, 36, 37, 47},
    c = {66, 76, 77, 87, 88, 89, 99, 100, 101, 102},
    d = {112, 113, 114, 115, 116, 117, 118, 119, 120, 121},
    e = {75, 85, 86, 96, 97, 98, 108, 109, 110, 111},
    f = {20, 21, 22, 23, 33, 34, 35, 45, 46, 56}
}

return Board
