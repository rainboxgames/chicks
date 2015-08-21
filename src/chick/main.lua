--
-- This file is part of chick.
--
-- (c) 2015 YouniS Bensalah <younis.bensalah@riseup.net>
--
-- For the full copyright and license information, please view the LICENSE
-- file that was distributed with this source code.
--

function love.load()
    print([[

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __
    /    \  \/|  |  \|  |/ ___\|  |/ /
    \     \___|   Y  \  \  \___|    <
     \______  /___|  /__|\___  >__|_ \
            \/     \/        \/     \/ 0.1

    ]])

    love.window.setMode(1024, 800)
    love.window.setTitle('chick')

    -- add module directories to lua path
    package.path = "src/chick/core/?.lua;src/chick/net/?.lua;src/chick/net/?.lua;" .. package.path

    test()
end

function love.update(dt)
end

function love.draw()
end

function love.conf(t)
    -- anti-aliasing
    t.window.fsaa = 4
end

function test()
    require 'chick'
    local c = Chick.new(2)

    -- local moves =
    -- {
    --     {4,17},
    --     {117,106},
    --     {9,29},
    --     {120,91},
    --     {5,16,41},
    --     {115,93},
    --     {3,28,30,51},
    --     {121,107,105,82}
    -- }
    --
    -- for _, i in pairs(moves) do
    --     print(c:move(i))
    -- end

    -- c.board =
    -- {
    --                     2,
    --                    2, 2,
    --                   2, 2, 2,
    --                  2, 0, 2, 2,
    --     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --         0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,
    --           0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --             0, 0, 0, 0, 0, 0, 0, 0, 0,
    --            0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --         0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
    --                       1, 1, 0, 1,
    --                         1, 1, 1,
    --                           1, 1,
    --                             1
    -- }

    local result = 1
    while (result >= 0) do
        local chain = io.read()
        local chaintab = explode(' ', chain)
        for i = 1, #chaintab do
            chaintab[i] = tonumber(chaintab[i])
        end
        result = c:move(chaintab)
        print('move ' .. chain)
        print(result)
    end
end

-- explode(seperator, string)
-- Lance Li
function explode(d,p)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end
