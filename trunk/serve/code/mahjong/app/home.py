#coding:utf8
# 
# Created by licong on 2016/11/05.
# 

import sys
sys.path.append("..")

from firefly.server.globalobject import netserviceHandle,rootserviceHandle
from firefly.server.globalobject import GlobalObject,remoteserviceHandle

from entity.UserManager import UserManager
from entity.RoomManager import RoomManager

from tool.localservice import LocalService

def doConnectionLost(conn):
	UserManager().lostConnection(conn)
	
def doConnectionMade(conn):
	print u"客户端连接成功"
	# print GlobalObject().netfactory.service


localservice = LocalService('localservice')

def localserviceHandle(target):
    '''服务处理
    @param target: func Object
    '''
    localservice.mapTarget(target)

# def doCon
GlobalObject().netfactory.doConnectionLost = doConnectionLost
GlobalObject().netfactory.doConnectionMade = doConnectionMade
GlobalObject().netfactory.addServiceChannel(localservice)
# 登录
@localserviceHandle
def login_1001(conn,data):
	return UserManager().login(conn,data)

# 退出
@localserviceHandle
def logout_1002(conn,data):
	UserManager().logout(conn,data)

# 创建房间
@localserviceHandle
def createRoom_1003(conn,data):
	return RoomManager().createRoom(conn.user,data)

# 进入房间
@localserviceHandle
def enterRoom_1004(conn,data):
	return RoomManager().enterRoom(conn.user,data)

# 退出房间
@localserviceHandle
def exitRoom_1005(conn,data):
	return RoomManager().exitRoom(conn.user)

# 解散房间
@localserviceHandle
def dissolveRoom_1006(conn,data):
	return RoomManager().dissolveRoom(conn.user)

# 申请解散房间
@localserviceHandle
def applyDissolveRoom_1007(conn,data):
	RoomManager().applyDissolveRoom(conn.user)

# 出牌
@localserviceHandle
def userOutCard_1009(conn,data):
	return conn.user.room.outCard(conn.user,data)	

# 碰牌
@localserviceHandle
def userPeng_1010(conn,data):
	return conn.user.room.peng(conn.user,data)

# 杠
@localserviceHandle
def userGang_1011(conn,data):
	return conn.user.room.gang(conn.user,data)	

# 出牌
@localserviceHandle
def userHu_1012(conn,data):
	return conn.user.room.hu(conn.user,data)

# 过
@localserviceHandle
def userPass_1013(conn,data):
	return conn.user.room.userPass(conn.user,data)

































