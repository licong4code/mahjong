# !/usr/bin/python
# coding:utf-8
# Created by licong on 2016/11/25.
#  

from User import User

from firefly.utils.singleton import Singleton

class UserManager:
	__metaclass__ = Singleton
	'''
	管理用户的登录、退出
	'''
	def __init__(self):
		self.users = {}

	def login(self,conn,data):
		user = self.getUser(conn,data)
		status = user.getStatus()
		data = {"code":1,"status":status,"id":user.id}

		if status != 0:
			data["room"] = user.room.getRoomInfo(user)
		else:
			data["info"] = user.getUserInfo(True)
	
		return data

	def logout(self,conn,data):
		pass

	def lostConnection(self,conn):
		for (uid,user) in self.users.items():
			if user.room:
				user.room.onUserLost(user)
			# user.onUserLost(conn.user)

	def getUser(self,conn,data):
		uid = data["uid"]
		user = None
		if self.users.has_key(uid):
			user = self.users[uid]
			if user.online:
				user.offline()
		else:
			print u"找不到用户：",uid
			user = User(uid,conn)
		user.conn = conn	
		conn.user = user
		self.users[uid] = user
		return user

