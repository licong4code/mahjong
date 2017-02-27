#coding:utf8

import time
import sys
# sys.path.append("")
from encrypt import Cryptor
from socket import AF_INET,SOCK_STREAM,socket
from thread import start_new
import struct,json

HOST='localhost'
PORT=1000
BUFSIZE=1024
ADDR=(HOST , PORT)
client = socket(AF_INET,SOCK_STREAM)
client.connect(ADDR)

def sendData(sendstr,commandId):
    HEAD_0 = chr(0)
    HEAD_1 = chr(0)
    HEAD_2 = chr(0)
    HEAD_3 = chr(0)
    ProtoVersion = chr(0)
    ServerVersion = 0
    sendstr = sendstr
    data = struct.pack('!sssss3I',HEAD_0,HEAD_1,HEAD_2,\
                       HEAD_3,ProtoVersion,ServerVersion,\
                       len(sendstr)+4,commandId)
    senddata = data+sendstr
    return senddata

def resolveRecvdata(data):
    head = struct.unpack('!sssss3I',data[:17])
    length = head[6]
    data = data[17:17+length]
    print(len(data))
    return Cryptor.decode(data)

s1 = time.time()

def login():
    data = {}
    data["uid"] = "12390"
    strings = json.dumps(Cryptor.encode(data))
    client.sendall(sendData(strings,10001))
        

def recv():
    while True:
        print resolveRecvdata(client.recv(1024))

start_new(recv,())
login()
while True:
    pass

client.close()

