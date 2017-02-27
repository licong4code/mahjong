# !usr/bin/python
# coding:utf8
# 
# Created by licong on 2016/11/05.
# 

from twisted.internet import defer,threads

from firefly.server.globalobject import netserviceHandle
from firefly.server.globalobject import GlobalObject


class User:
	def __init__(self,uid,conn):
		conn.user = self
		self.id = uid
		self.conn = conn
		self.name = ""
		self.icon = ""
		self.ip = ""
		self.online = 1
		self.reset()
		self.totaloutgang = 0 #放杠总数
		self.totalingang = 0 #捡杠总数
		self.totalangang = 0 #暗杠总数
		self.totalminggang = 0 #明杠总数

	def reset(self):
		self.owndata = [] #当前牌
		self.touchdata = []  #已出牌（碰/杠/吃）
		self.outdata = [] #已打牌
		self.backlog = [] #待处理行为
		self.place = -1 #座位号
		self.power = 0
		self.applyDissolve = False
		# 是否已经响应解散申请
		self.responeDissolve = True

		self.room = None	
		self.totalscore = 1000 #玩家总分数
		self.roundscore = 0 #本轮得分
		self.ischoose = True #玩家已经做出选择
		self.master = False #房主
		self.banker = False #庄家
		self.wait = True #是否处于等待状态
		self.group = None #可以操作的组合
		self.ready = False

		self.otherdata = None #其他玩家出的牌
		# 庄家
		self.banker = 0
		self.handvaule = 0 #当前操作的权值（1吃 2(碰/杠）3胡）

		self.outgang = 0 #放杠
		self.ingang = 0 #捡杠
		self.angang = 0 #暗杠
		self.minggang = 0 #明杠

	def calc(self):
		self.totaloutgang = self.totaloutgang + self.outgang #放杠总数
		self.totalingang = self.totalingang + self.ingang #捡杠总数
		self.totalangang = self.totalangang + self.angang #暗杠总数
		self.totalminggang = self.totalminggang + self.minggang #明杠总数

	def getID(self):
		return self.uid

	def initCard(self,data):
		self.owndata = data
		self.owndata.sort()
	
	def inCard(self,value,sort = True):
		self.owndata.append(value)
		if sort:
			self.owndata.sort()
		self.wait = False
	# 
	def outCard(self,value):
		try:
			self.owndata.remove(value)
		except Exception,e:
			print e
		self.owndata.sort()
		self.outdata.append(value)
		self.wait = True

	def peng(self,value):
		self.owndata.remove(value)
		self.owndata.remove(value)
		self.touchdata.append({"type":1,"value":value})
		self.wait = False
		self.handvaule = 1
		self.group = None
		
	def gang(self,value,status):
		game = self.room.game
		room = self.room
		if status == 1: #暗杠
			self.angang = self.angang + 1
			self.touchdata.append({"type":2,"value":value})
			if game.gangneedscore:
				self.addRoundScore(2*room.getCount())
				for usr in room.getOtherUsers(self):
					usr.addRoundScore(-2)
			for i in xrange(4):
				self.owndata.remove(value)
		elif status == 2: #捡杠
			self.ingang = self.ingang + 1
			self.touchdata.append({"type":3,"value":value})
			if game.gangneedscore:
				self.addRoundScore(3)
			for i in xrange(3):
				self.owndata.remove(value)
		else: #明杠
			self.minggang = self.minggang + 1
			self.touchdata.append({"type":4,"value":value})
			self.owndata.remove(value)
			for touch in self.touchdata:
				if touch["type"] == 1 and touch["value"] == value:
					self.touchdata.remove(touch)
					break
				if game.gangneedscore:
					self.addRoundScore(3)
					for usr in room.getOtherUsers(self):
						usr.addRoundScore(-1)

		self.wait = False
		self.handvaule = 1
		self.group = None

	def showCard(self):
		print "name:",self.name
		print "card:"

	def getStatus(self):
		'''
		获得玩家当前状态 
		0 无任何状态
		1 等待
		2 游戏中
		'''
		if self.room == None:
			return 0
		elif not self.room.isFull():
			return 1 
		else:
			return 2

	def getStatusData(self):
		data = {}
		data["status"] = self.status
		if self.status == 3:
			data["id"] = self.room.getID()
			data["owner"] = self.room.getOwner() == self
		return data

	# 进入房间
	def setRoom(self,room):
		self.status = 1 if room != None else 0
		self.room = room

	# 退出房间
	def removeFromRoom(self):
		if self.room:
			self.room.removeUser(self)
		self.reset()

	# 异地登录
	def offline(self):
		self.sendMessageToClient({"msg":1002},2100)
		self.conn.transport.loseConnection()

	def getRoom(self):
		return self.room

	# 获得牌面数据
	def getGameData(self,full):
		info = {"out":self.outdata,"touch":self.touchdata,"id":self.id}
		info["wait"] = 1 if self.wait else 0
		if full: #获得自己信息，可以知道牌面信息
			info["own"] = self.owndata
		else:#只需知道有多少张牌
			info["own"] = len(self.owndata)
		return info

	def getUserInfo(self,full = False):
		'''
			full:是否获得全部信息
		'''
		info = {"id":self.id,"name":self.name,"icon":self.icon,"online":self.online}
		if self.room and self.room.isFull(): #游戏开始
			info.update(self.getGameData(full))
			info["score"] = self.totalscore
			info["banker"] = 1 if self.banker else 0
			info["master"] = 1 if self.master else 0
			group = self.room.game.getHandleGroup(self)
			if len(group) > 0:
				info["group"] = group
		return info

	def getRoomInfo(self):
		data = {"id":self.room.id}


	def sendMessageToClient(self,data,command):
		GlobalObject().netfactory.service.sendMessage(self.conn,data,command)

	def addRoundScore(self,score):
		self.roundscore = self.roundscore + score
		self.totalscore = self.totalscore + score