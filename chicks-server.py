#!/usr/bin/env python
##
## This file is part of chicks.
##
## (c) 2015-2017 YouniS Bensalah <younis.bensalah@gmail.com>
##
## For the full copyright and license information, please view the LICENSE
## file that was distributed with this source code.
##

import os
import sys
import logging
import argparse
import threading
import socket
import socketserver

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'src/server'))

from clienthandler import ClientHandler
from lobby import Lobby

__version__ = '1.0.0-dev'

class MyTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True

def main():
    logging.basicConfig(format='[%(asctime)s] [%(levelname)s] %(message)s', level=logging.DEBUG, datefmt='%H:%M:%S')

    parser = argparse.ArgumentParser(description="Chicks dedicated server")
    parser.add_argument('host')
    parser.add_argument('port', type=int)
    args = parser.parse_args()

    logging.info("""

    _________ .__    .__        __
    \_   ___ \|  |__ |__| ____ |  | __  ______
    /    \  \/|  |  \|  |/ ___\|  |/ / /  ___/
    \     \___|   Y  \  \  \___|    <  \___ \\
     \______  /___|  /__|\___  >__|_ \/____  >
            \/     \/        \/     \/     \/

    """)
    logging.info("Server version " + __version__)

    with MyTCPServer((args.host, args.port), ClientHandler) as server:
        host, port = server.server_address
        logging.info("Listening on {}:{}".format(host, port))

        server.lobby = Lobby()

        server_thread = threading.Thread(target=server.serve_forever)
        server_thread.daemon = True
        server_thread.start()
        logging.debug("Server loop running in thread: " + server_thread.name)

        # block until keyboard interrupt or system exit
        try:
            server_thread.join()
        except KeyboardInterrupt as e:
            logging.debug(repr(e))

        # gracefully kill the server
        logging.info("Shutting down...")
        server.shutdown()

    logging.info("Bye!")

if __name__ == '__main__':
    main()
