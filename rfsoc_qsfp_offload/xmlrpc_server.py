__author__ = "Marius Siauciulis"

import threading
import netifaces as ni
from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler

class RequestHandler(SimpleXMLRPCRequestHandler):
            rpc_paths = ('/RPC2',)

class ServerThread(threading.Thread):
    def __init__(self, *functions, port=8080):
        threading.Thread.__init__(self)
        # Grab Eth IP address
        iface = ni.gateways()['default'][ni.AF_INET][1]
        ip_address = ni.ifaddresses(iface)[2][0]['addr']
        # Init RequestHandler
        self.localServer = SimpleXMLRPCServer((ip_address, port),
            requestHandler=RequestHandler)
        self.localServer.register_introspection_functions()
        # Register available functions
        print("XMLRPC server is registering the following functions:")
        for function in functions:
            print('\t' + function.__name__)
            self.localServer.register_function(function, function.__name__)

    def run(self):
        try:         
            self.localServer.serve_forever()
        except KeyboardInterrupt:
            print("\nKeyboard interrupt received, exiting.")
            sys.exit(0)