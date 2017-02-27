# !/usr/bin/python
# coding:utf-8
# Created by licong on 2016/11/19.
#  
# 

from app.mahjong import factory

class Room:
	def __init__(self,user,**kv):
		self.size = kv["size"]
		self.users = [None] * self.size
		self.id = kv["id"]
		self.canDeal = False #是否可以发牌
		self.hangup = False #是否挂起（玩家没有做出决策）

		self.game = factory.build({"name":"RuCheng"})
		# 申请解散的玩家
		self.applicant = None
		self.times = 8
		self.addUser(user)
		self.curuser = user #当前出牌的玩家
		self.reset()

	def reset(self):
		self.curuser.master = True
		self.curuser.banker = True
		self.curuser.wait = False
		self.curuser.ready = True
		self.curoutdata = None
		self.curhanduser = None #当前操作的玩家

	def getID(self):
		return self.id

	def addUser(self,user):
		if self.isFull():
			return False
		user.setRoom(self)

		for index in xrange(self.size):
			if self.users[index] == None:
				user.place = index
				self.users[index] = user
				break


		
		for usr in self.users:
			if usr != None and usr != user:
				usr.otherUserEnter(user)

		return True

	def removeUser(self,user):
		self.users[user.place] = None
		user.room = None

	def removeAllUser(self):
		for user in self.users:
			if user != None:
				self.removeUser(user)

	def isOK(self):
		return self.size == len(self.users)

	def sendMessageToUsers(self,filterUser,data,command):
		for user in self.users:
			if user != filterUser:
				user.sendMessageToClient(data,command)

	def applyDissolveRoom(self,user):
		if user.applyDissolve == False:
			self.applicant = user
			user.applyDissolve = True
			for other in self.users:
				if other != None and other != user:
					other.responeDissolve = False

			user.room.sendMessageToUsers(user,{"id":user.id},2003)

	def getOtherUsers(self,user):
		users = self.users[:]
		users.remove(user)
		return users

	# 出牌
	def outCard(self,user,data):	
		self.hangup = False
		self.curuser = user

		out = data["data"]
		self.curoutdata = out
		user.outCard(out)
		for usr in self.getOtherUsers(user):
			usr.ischoose = False #玩家没有做出选择
			usr.otherdata = out
			group = self.game.getHandleGroup(usr)
			message = {"id":user.id,"data":out}
			if len(group) > 0:
				self.hangup = True
				message["group"] = group
				usr.group = group
			usr.sendMessageToClient(message,2009)

		# 下玩家拿牌
		if not self.hangup:
			self.dispatchCard()

		return {"code":1,"data":data["data"]}

	# 执行碰
	def dopeng(self):
		self.curhanduser.peng(self.curoutdata)
		self.curuser.outdata.remove(self.curoutdata)

		for user in self.users:
			user.otherdata = None
			user.sendMessageToClient({"id":self.curhanduser.id,"data":self.curoutdata,"room":self.getRoomInfo(user)},2010)

		self.curuser = self.curhanduser
		self.curhanduser = None
	# 碰牌
	def peng(self,user,data):
		self.curhanduser = user

		#校验数据真实性
		if self.curoutdata != data:
			return None

		if self.game.winbyself:
			self.dopeng()
		else:
			pass


	def dogang(self,data):
	
		gangtype = data["type"]
		self.curhanduser.gang(data["value"],gangtype)
		if gangtype == 2:#捡杠
			self.curuser.outdata.remove(self.curoutdata)
			self.curuser.outgang = self.curuser.outgang + 1
			if self.game.gangneedscore:
				self.curuser.addRoundScore(-3)
		self.curhanduser.inCard(self.game.pop(),False)
		
		for user in self.users:
			user.sendMessageToClient({"id":self.curhanduser.id,"data":self.curoutdata,"room":self.getRoomInfo(user)},2011)

		self.curuser = self.curhanduser
		self.curhanduser = None

	# 杠牌
	def gang(self,user,data):
		self.curhanduser = user

		# #校验数据真实性
		# if self.curoutdata != value:
		# 	print "data wrong",self.curoutdata,value
		# 	return None

		if self.game.winbyself:
			self.dogang(data)
		else:
			pass

	# 胡牌
	def hu(self,user,data):
		if self.curoutdata != None:
			user.owndata.append(self.curoutdata)
		# 计算结果
		self.game.caclResult(user,self.curuser,self.users)
		# 投递游戏结果
		result = []
		for user in self.users:
			result.append({"id":user.id,"data":self.game.getResult(user)})
		for user in self.users:
			user.sendMessageToClient({"users":result},2012)

	# 询问
	def userPass(self,user,data):
		user.group = None
		user.otherdata = None
		self.check()

	# 检查是否要发牌
	def check(self):
		hangup = False
		for usr in self.users:
			if usr.group != None:
				hangup = True
				break

		if hangup == False:
			self.hangup = False
			self.dispatchCard()

	# 发牌
	def dispatchCard(self):
		curUser = self.getNextUser()
		data = self.game.pop()
		curUser.inCard(data)
		group = self.game.getHandleGroup(curUser)
		message = {"data":data}
		if len(group) > 0:
			message["group"] = group
			curUser.group = group
		print message
		curUser.sendMessageToClient(message,2008)

		for usr in self.users:
			if usr != curUser:
				usr.sendMessageToClient({"id":curUser.id},2007)

	def getRoomInfo(self,caller):
		'''
		获得房间信息
		caller 排除自身数据
		'''
		data = {}
		users = []
		full = self.isFull()
		for usr in self.users:
			if usr != None:
				users.append(usr.getUserInfo(caller == usr))
		data["users"] = users
		data["id"] = self.id
		data["full"] = full
		return data

	def show(self):
		for usr in self.users:
			print "player:",usr.uid,"card:",self.game.tanslate(usr.owndata)

	def getOwner(self):
		return self.users[0]

	def isFull(self):
		return self.users.count(None) == 0

	def isPlaying(self):
		return self.isFull()

	# 获得下一个玩家
	def getNextUser(self):
		nextplaceid = (self.curuser.place + 1)%self.size
		self.curuser = self.users[nextplaceid]
		return self.curuser

	# 玩家进入房间
	def onUserEnter(self,user):
		if self.isFull():
			return {"code":0,"msg":1000}

		user.ready = True
		user.reset()
		user.setRoom(self)
		for index in xrange(self.size):
			if self.users[index] == None:
				user.place = index
				self.users[index] = user
				break
		# 游戏开始
		if self.isFull():
			for user in self.users:
				user.initCard(self.game.pop(14 if user.banker else 13))
				
		# 通知其他玩家
		status = user.getStatus()
		for usr in self.users:
			if usr != None:
				data = {"status":status,"id":usr.id,"room":self.getRoomInfo(usr)}
				usr.sendMessageToClient(data,2000)
		# return {"code":1,"status":status, "room":self.getRoomInfo(user)}

	# 玩家离开房间
	def onUserExit(self,user):
		user.setRoom(None)

		pass

	# 玩家断线
	def onUserLost(self,user):
		pass

	def getCount(self):
		return len(self.users) - self.users.count(None)

	def __del__(self):
		for user in self.users:
			if user != None:
				user.removeFromRoom()
		del self.users


			