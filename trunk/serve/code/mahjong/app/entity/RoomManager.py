# !/usr/bin/python
# coding:utf-8
# Created by licong on 2016/11/25.
#  
import random

from firefly.utils.singleton import Singleton

from Room import Room 

class RoomManager:
	__metaclass__ = Singleton
	
	def __init__(self):
		self.room = {}
		self.indexs = [n for n in range(100000, 999999)]

	def getRoom(self,id):
		if self.room.has_key(id):
			return self.room[id]
		return None

	# 创建房间
	def createRoom(self,user,data):
		# roomid = "%06d"%(len(self.room)+1)
		remain = len(self.indexs)
		index = random.randint(0, remain)
		print index,remain
		id = str(self.indexs[index])
		room = Room(user,size = 2,id = id)
		self.room[id] = room
		self.indexs.pop(index)
		return {"code":1,"room":room.getRoomInfo(user)}
	

	def enterRoom(self,user,data):
		# 房间号
		roomid = data["id"]
		room = self.getRoom(roomid)
		# 找不到该房间
		if not room: 
			return {"code":0,"msg":1001}

		room.onUserEnter(user)

	def exitRoom(self,user):
		if user.room.isPlaying():
			return {"code":0}
		else:
			self.destoryRoom(user.room)
			user.removeFromRoom()
			return {"code":1}

	def destoryRoom(self,room):
		roomid = room.id
		if self.room.has_key(roomid):
			del self.room[roomid]

	# 解散
	def dissolveRoom(self,user):
		room = user.getRoom()
		# if room.isFull():
		if False:
			return {"code":0}
		else:
			for usr in room.users:
				usr.sendMessageToClient({"code":1},1006)
			self.destoryRoom(room)
			room.removeAllUser()
			del room

	# 申请解散
	def applyDissolveRoom(self,user):
		user.room.applyDissolveRoom(user)





