##
## This file is part of chicks.
##
## (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
##
## For the full copyright and license information, please view the LICENSE
## file that was distributed with this source code.
##

import logging
import threading

class Lobby:
    def __init__(self):
        self.__locks = {}
        self.__locks['rooms'] = threading.Lock()
        self.__locks['players'] = threading.Lock()
        self.__locks['callbacks'] = threading.Lock()

        self.__callbacks = {}
        self.__players = {}
        self.__rooms = {}

    def add_room(self, player, room):
        with self.__locks['rooms']:
            if room in self.__rooms:
                return False

            self.__rooms[room] = Room(player, room)

    def join_room(self, player, room):
        pass

    def set_nick(self, player, nick):
        pass

    def set_color(self, player, color):
        pass

    def register_callback(self, event, callback):
        logging.debug("Lobby register_callback({})".format(event))

        with self.__locks.callbacks:
            self.__callbacks[event].append(callback)

    def remove_callback(self, event, callback):
        logging.debug("Lobby remove_callback({})".format(event))

        with self.__locks.callbacks:
            self.__callbacks[event].remove(callback)

    def __notify_all(self, event, params = {}):
        logging.debug("Lobby __notify_all({})".format(event))

        with self.__locks.callbacks:
            for cb in self.__callbacks[event]:
                cb(**params)
