##
## This file is part of chicks.
##
## (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
##
## For the full copyright and license information, please view the LICENSE
## file that was distributed with this source code.
##

import logging
import socketserver
from struct import *
from binascii import *
from hashlib import *

class ClientHandler(socketserver.BaseRequestHandler):

    def setup(self):
        addr, port = self.request.getpeername()
        self.__id = sha256(addr.encode() + str(port).encode()).hexdigest()
        # alias
        self.__lobby = self.server.lobby

    def handle(self):
        logging.info("Client {} connected.".format(self.request.getpeername()))
        while True:
            msg = self.__recvmsg()
            msgparts = msg.split(' ')
            if msgparts[0] == 'NEWROOM':
                if msgparts[1]:
                    self.__new_room(msgparts[1])
            elif msgparts[0] == 'JOINROOM':
                if msgparts[1]:
                    self.__join_room(msgparts[1])
            elif msgparts[0] == 'SETNICK':
                if msgparts[1]:
                    self.__set_nick(msgparts[1])
            elif msgparts[0] == 'SETCOLOR':
                if msgparts[1]:
                    self.__set_color(msgparts[1])
            elif msgparts[0] == 'MOVE':
                if msgparts[1] and msgparts[2]:
                    self.__move(msgparts[1], msgparts[2])
            elif msgparts[0] == 'READY':
                self.__ready()
            elif msgparts[0] == 'FIN':
                self.__finalize()
            elif msgparts[0] == 'LISTROOMS':
                self.__list_rooms()
            elif msgparts[0] == 'BYE':
                self.__bye()
            else:
                logging.debug("Unknown command.")

    def finish(self):
        logging.info("Client {} disconnected.".format(self.request.getpeername()))

    def __new_room(self, room):
        self.__lobby.add_room(self.__id, room)

    def __join_room(self, room):
        pass

    def __set_nick(self, nick):
        pass

    def __set_color(self, color):
        pass

    def __move(self, fromtile, totile):
        pass

    def __ready(self):
        pass

    def __finalize(self):
        pass

    def __list_rooms(self):
        pass

    def __bye(self):
        pass

    def __recvmsg(self):
        header = b""
        headersize = 2
        while len(header) < headersize:
            header += self.request.recv(headersize - len(header))
        buf = b""
        bufsize, = unpack('>H', header)
        while len(buf) < bufsize:
            buf += self.request.recv(bufsize - len(buf))
        logging.debug('\033[91m> {} {}\033[0m'.format(hexlify(header).decode(), buf))
        return buf.decode()

    def __sendmsg(self, msg):
        buf = msg.encode()
        header = pack('>H', len(buf))
        logging.debug('\033[92m< {} {}\033[0m'.format(hexlify(header).decode(), buf))
        self.request.sendall(header + buf)
