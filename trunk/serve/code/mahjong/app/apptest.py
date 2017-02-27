#coding:utf8

from firefly.server.globalobject import netserviceHandle
import struct

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
@netserviceHandle
def echo_1(_conn,data):
	print data

@netserviceHandle
def echo_2(_conn,data):
	return sendData("hello world",2)

@netserviceHandle
def fun_3(_conn,data):
	return sendData("call_2 hello world",2)