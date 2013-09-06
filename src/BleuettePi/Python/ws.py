#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import threading
from tornado import websocket, web, ioloop
from operator import eq

import os, sys, time, copy, logging
sys.path.insert(0, os.path.abspath('lib'))

from Bleuette import Bleuette
from Data import Data
from Sequences import Sequences
import Drive

cl = []

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

'''
class PafHandler(logging.Handler):
    def __init__(self):
            logging.Handler.__init__(self)
    def emit(self, record):
        #print record
        for c in cl:
            c.write_message(json.dumps("paf"))
        
steam_handler = PafHandler()
steam_handler.setLevel(logging.DEBUG)
logger.addHandler(steam_handler)
'''

B = Bleuette()

speed = 16
import Define
def delay(index, sequence):
    global speed
    time.sleep(Define.DELAY_MIN * (16 - speed))
B.Sequencer.addCallback(delay)

class IndexHandler(web.RequestHandler):
    def get(self):
        self.render("www/index.html")

class SocketHandler(websocket.WebSocketHandler):

    last_message = None

    def livemode(self, values):
        data = {
            'type': 'position',
            'data': {
                'servos': values
            }
        }
        self.write(json.dumps(data))

    def open(self):
        if self not in cl:
            cl.append(self)

    def write(self, data):
        for c in cl:
            c.write_message(data)

    def on_message(self, message):
        global logger
        logger.info("Message : %s" % message)

        data = json.loads(message)

        import Servo

        if data['cmd'] == 'set':
            if data['type'] == 'trim':
                Servo.Servo_Trim.values[data['servo']] = data['value'];
                B.Sequencer.Servo.sendValues()
            elif data['type'] == 'limit':
                Servo.Servo_Limit.values[data['servo']] = [ data['min'], data['max'] ];
                B.Sequencer.Servo.sendValues()
            elif data['type'] == 'position':
                B.Sequencer.Servo.setValue(data['servo'], data['value'])
                B.Sequencer.Servo.sendValues()
            elif data['type'] == 'speed':
                global speed
                speed = data['value']
            elif data['type'] == 'livemode':
                if data['status']:
                    B.Sequencer.Servo.setCallback(self.livemode)
                else:
                    B.Sequencer.Servo.removeCallback()
            elif data['type'] == 'loglevel':
                if data['level'] == 'debug':
                    logger.setLevel(logging.DEBUG)
                elif data['level'] == 'info':
                    logger.setLevel(logging.INFO)
                elif data['level'] == 'warning':
                    logger.setLevel(logging.WARNING)
                elif data['level'] == 'error':
                    logger.setLevel(logging.ERROR)
                elif data['level'] == 'warning':
                    logger.setLevel(logging.CRITICAL)

            #print logger.getEffectiveLevel()

        elif data['cmd'] == 'drive':

            if data['status'] == 'begin':
                if data['direction'] == 'forward':
                    B.Drive.forward()
                elif data['direction'] == 'reverse':
                    B.Drive.reverse()
                elif data['direction']== 'left':
                    B.Drive.left()
                elif data['direction']== 'right':
                    B.Drive.right()
            elif data['status'] == 'end':
                B.Drive.end()

        elif data['cmd'] == 'config':
            if data['action'] == 'save':
                Data.Instance().set(['servo', 'trims'], Servo.Servo_Trim.values)
                Data.Instance().set(['servo', 'limits'], Servo.Servo_Limit.values)
                Data.Instance().save()
            elif data['action'] == 'get':
                config = {
                    'type': 'config',
                    'data': {
                        'trims':    Data.Instance().get(['servo', 'trims']),
                        'limits':   Data.Instance().get(['servo', 'limits'])
                    }
                }
                self.write(json.dumps(config))
        
        elif data['cmd'] == 'sequence':

            if data['name'] == 'middle':
                B.Sequencer.forward(Sequences['middle'], 1)
            elif data['name'] == 'pushup':
                B.Sequencer.forward(Sequences['pushup'], 1)
            elif data['name'] == 'standby':
                B.Sequencer.forward(Sequences['pushup'], 1)

        else:
            logger.warning("Message : %s" % message)

    def on_close(self):
        if self in cl:
            cl.remove(self)

class ApiHandler(web.RequestHandler):

    @web.asynchronous
    def get(self, *args):
        self.finish()

    @web.asynchronous
    def post(self):
        pass

app = web.Application([
    (r'/', IndexHandler),
    (r'/ws', SocketHandler),
    (r'/api', ApiHandler),
    (r'/static/(.*)', web.StaticFileHandler, {'path': './www/'}),
    #(r'/(favicon.ico)', web.StaticFileHandler, {'path': './www/'}),
])

if __name__ == '__main__':
    app.listen(8888)
    try:
        ioloop.IOLoop.instance().start()
    except KeyboardInterrupt:
        print "Stop!"
        ioloop.IOLoop.instance().stop()

