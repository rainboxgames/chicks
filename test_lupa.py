import lupa
import logging

logging.basicConfig(format='[%(asctime)s] [%(levelname)s] %(message)s', level=logging.DEBUG, datefmt='%H:%M:%S')

lua = lupa.LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
    package.path = package.path .. ';src/?.lua;lib/?.lua;lib/?/?.lua;lib/?/init.lua'

    class           = require 'middleclass'
    Engine          = require 'core.Engine'
    Board           = require 'core.Board'
    Player          = require 'core.Player'
    Target          = require 'core.Target'
    log             = python.eval('logging')
    tablextra       = require 'util.tablextra'
    table.print     = tablextra.print
    table.explode   = tablextra.explode
    table.contains  = tablextra.contains
    table.append    = tablextra.append
""")

engine = lua.eval("""
    Engine(Board(), {
        Player("neo", {Target(Board.TRIANGLES.a, Board.TRIANGLES.d, Board.MARBLES.green)}),
        Player("sorakun", {Target(Board.TRIANGLES.e, Board.TRIANGLES.b, Board.MARBLES.red)}),
        Player("morpheus", {Target(Board.TRIANGLES.c, Board.TRIANGLES.f, Board.MARBLES.blue)})
    })
""")

engine.reset_board(engine)

engine.move(engine, 5, 18)
engine.finish(engine)
engine.move(engine, 97, 95)
engine.finish(engine)
engine.move(engine, 88, 90)
engine.finish(engine)
engine.move(engine, 3, 28)
engine.finish(engine)
engine.move(engine, 86, 84)
engine.finish(engine)
engine.move(engine, 101, 78)
engine.finish(engine)
