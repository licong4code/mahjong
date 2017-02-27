# !/usr/bin/python
# coding:utf-8
# Created by licong on 2016/11/23.
# 
# 麻将基类
# 

import sys,random

reload(sys)
sys.setdefaultencoding("utf-8")

def isAAA(a,b,c):
	return a==b and b==c

def isABC(a,b,c):
	if (a/9==b/9) and (b/9==c/9):
		return (a-b) == (b-c) and (a-b) == -1
	return False

def remove(aList,bList):
	for b in bList:
		aList.remove(b)

class MahJongBase(object):
	
	pattern = {'W':[0,9],'D':[9,18],'T':[18,27],'Z':[27,34]}
	def __init__(self, group):
		self.data = []
		self.user = {}
		self.gangstatus = 0 #杠的状态（1暗杠2捡杠3明杠）
		self.winbyself = False #是否需要自摸
		self.gangnow = True #需要马上杠
		self.gangneedscore = True #杠算分
		for v in group:
			patt = MahJongBase.pattern[v]
			for i in xrange(patt[0],patt[1]):
				self.data = self.data + [i,]*4
		random.shuffle(self.data)

	def getSize(self):
		return len(self.data)

	def addUser(self,user):
		self.user.append(user)
	
	def pop(self,size = 1):
		if size != 1:
			out = self.data[:size]
			# del self.data[:size]
			# return out
			if size == 14:
				return [0,1,2,3,3]
			else:
				return [0,0,0,3,4,5,6,7,8,9,10,11,12]
		else:
			return self.data.pop()

	# def front(self.size=1):

	def front(self,size = 1):
		if size == 1:
			return self.data.pop(0)
		else:
			out = self.data[0:size]
			self.data = self.data[size:]
			return out
	
	def getEatGroup(self,data,one):
		return []

	def getHandleGroup(self,user):
		group = {}
		one = user.otherdata
		if one == None: #自己拿牌
			win,__ = self.checkWin(user.owndata)
			if win: #自摸
				group["h"] = {"type":1}

			gang = []
			for value in set(user.owndata):
				if user.owndata.count(value) == 4: #暗杠
					gang.append({"type":1,"value":value})

			for value in set(user.owndata):
				for touch in user.touchdata:
					if touch["type"] == 1 and touch["value"] == value: #明杠
						gang.append({"type":3,"value":value})
			if len(gang)>0:
				group["g"] = gang
		else:
			data = user.owndata
			if self.isPeng(data,one):
				group["p"] = one

			if self.isGang(data,one): #捡杠
				group["g"] = [{"type":2,"value":one}] #

			if not self.winbyself and self.isWin(data,one):
				group["h"] = {"type":0,"value":one}

			eat = self.getEatGroup(data, one)
			if len(eat):
				group["c"] = eat

		return group

	@staticmethod
	def tanslate(data):
		mh_name = (u'一万',u'二万',u'三万',u'四万',u'五万',u'六万',u'七万',u'八万',u'九万',u'一筒',u'二筒',u'三筒',u'四筒',u'五筒',u'六筒',u'七筒',u'八筒',u'九筒',\
		u'一条',u'二条',u'三条',u'四条',u'五条',u'六条',u'七条',u'八条',u'九条',u'东风',u'南风',u'西风',u'北风',u'红中',u'白板')
		string = ""
		for value in data:
			string = string + mh_name[value] + " "
		return string
	# 发牌
	def deal(self):
		pass

	@staticmethod
	def isQingYiSe(data):
		value_type = data[0]/9
		for value in data[1:]:
			if value_type != value/9:
				return False
		return True

	@staticmethod
	def isQiXiaoDui(data):
		'''
		是否为七小对，返回1普通 2豪华 3双豪华
		'''
		if len(data) == 14:
			temp = set(data)
			group = ((7,1),(6,2),(5,3))
			for value in group:
				if value[0] == len(temp):
					return value[1]
		return 0

	def isPengpengHu(self,data):
		'''
		碰碰胡
		'''
		for x in set(data):
			count = data.count(x)
			if count == 1 or count == 4:
				return False
		return True
		
	def isJiangJiangHu(self,data):
		'''
		将将胡
		'''
		return False

	@staticmethod
	def isWin(data,one):
		'''
		是否胡牌
		'''
		temp = data[:]
		temp.append(one)
		temp.sort()
		result,__ = MahJongBase.checkWin(temp)
		return result

	@staticmethod
	def isReadyWin(data):
		# 单吊
		if len(data) == 1:
			return True
		minValue = max(0,min(data)-1)
		maxValue = min(33,max(data)+1)+1
		win_group = []
		for i in xrange(minValue,maxValue):
			temp = data[:]
			temp.append(i)
			if MahJongBase.checkWin(temp)[0] == True:
				win_group.append(i)
		return win_group

	def getAllABC(self,data,one):
		pass

	# 可以碰
	@staticmethod
	def isPeng(data,one):
		return data.count(one) >= 2

	# 可以杠
	@staticmethod
	def isGang(data,one):
		return data.count(one) == 3

	@staticmethod
	def isABC(data):
		if len(data) == 3:
			return isABC(data[0],data[1],data[2])
		return False

	@staticmethod
	def isAAA(data):
		return isAAA(data[0],data[1],data[2])

	@staticmethod
	def check(src,data):
		# print "before",src
		isok = False
		for i in xrange(0,len(data),3):
			if MahJongBase.isABC(data[i:i+3]):
				remove(src,data[i:i+3])
				isok = True
			else:
				break
		if isok :
			MahJongBase.check(src,list(set(src)))

	@staticmethod
	def removeAAA(data):
		returnVale = data[:]
		for value in set(data[:]):
			if data.count(value) >= 3:
				for i in xrange(3):
					returnVale.remove(value)
		return returnVale

	@staticmethod
	def isAAAorABC(data):
		if len(data) == 0:
			return False,data
		
		temp = data[:]
		# 出现次数最多的值
		value = max(data,key=data.count)
		value_count = data.count(value)

		if value_count == 1:
			MahJongBase.check(temp,list(set(temp)))
		elif value_count == 2:
			temp = data[:]
			MahJongBase.check(temp,list(set(temp)))
		elif value_count == 3:	
			temp = MahJongBase.removeAAA(data)

			MahJongBase.check(temp,list(set(temp)))
			if len(temp) == 0:
				return (True,None)
			else:
				temp = data[:]
				MahJongBase.check(temp,list(set(temp)))
		else: #存在杠
			for i in xrange(3):
				temp.remove(value)
			return MahJongBase.isAAAorABC(temp)

		if len(temp) == 0:
			return (True,None)
		return False,temp


	@staticmethod
	def checkWin(data):
		jiang = []
		win_group = []

		# 单吊
		if len(data) == 2 and data[0] == data[1]:
			return True,[data[0]]

		for value in set(data[:]):
			if data.count(value) >= 2:
				jiang.append(value)

		for value in jiang:
			temp = data[:]
			temp.remove(value)
			temp.remove(value)
			result,__ = MahJongBase.isAAAorABC(temp)
			if result:
				win_group.append(value)
		return len(win_group)>=1,win_group

	# 可用牌数
	def getAvailableLen(self):
		return len(self.data)
	#
	# @winner 胡牌对象
	# @curuser 当前出牌对象
	# @alldata owndata + touchdata
	# @owndata 手中牌
	# @touchdata 吃、碰、杠的牌
	def getWinType(self,winner,curuser,alldata,owndata,touchdata):
		'''
		0自摸 1清一色 2碰碰胡 3七小对 4豪七 5霜豪七 6三豪七 7杠上开花 8抢杠胡 9全球人 10将将胡 11海底胡
		'''
		wintype = 0
		if winner == curuser: #自摸
			wintype = wintype & 1

		if self.isQingYiSe(alldata): #清一色
			wintype = wintype & 1 << 1

		if self.isPengpengHu(alldata):#碰碰胡
			wintype = wintype & 1 << 2

		# 七小对
		if len(owndata) == 14:
			qxd_count = self.isQiXiaoDui(alldata)
			if qxd_count:
				for i in xrange(qxd_count):
					wintype = wintype & 1 << (3 + i)

		if winner.ingang:
			wintype = wintype & 1 << 7

		if winner.ingang and winner != curuser and self.gangstatus == 3:
			wintype = wintype & 1 << 8

		return wintype

	def caclResult(self,winner,curuser,allusers):
		wintype = 0
		alldata = []
		alldata.extend(winner.owndata)
		alldata.extend(winner.touchdata)
		wintype = self.getWinType(winner, curuser, alldata, winner.owndata, winner.touchdata)
		self.calcScore(winner,curuser,allusers,wintype)

	def getResult(self,user):
		return []
if __name__ == '__main__':
	# mh = MahJongBase(["W","D","T"])
	# data = mh.pop(14)
	# data.sort()
	# print mh.tanslate(data)
	# print MahJongBase.isAAAorABC([1,1,1,2,3,4])
	# print MahJongBase.isAAAorABC([1,2,2,3,3,3,4,4,5,6])
	# print MahJongBase.isAAAorABC([1,1,2,2,3,3,])

	# print MahJongBase.isAAAorABC([6,6,6,7,8,9,10,11,])

	# print MahJongBase.isAAAorABC([6,6,6,6,7,8,9,10,11,])

	# print MahJongBase.isAAAorABC([0,1,1,2,2,3,3,3,3])

	# print MahJongBase.isAAAorABC([0,0,0,0,1,2,3,4,4])

	# print MahJongBase.isAAAorABC([2, 4, 6, 7,7,7])

	# print MahJongBase.checkWin([1,1,2,2,3,3,4,4])
	# 听牌
	# print MahJongBase.isReadyWin([2,2,3,3,4,5,8])
	# print MahJongBase.isReadyWin([2,4,5,6,7,7,7])
	# print MahJongBase.isReadyWin([2,3,4,5,6,6,6])


	# print MahJongBase.checkWin([2,4,5,5,6,7,7,7])
	# print MahJongBase.checkWin([1,2,3,3,4,5,6])
	# win = 0 
	# lose = 0
	# for k in xrange(1000):
	# 	# pai = []
	# 	# for i in xrange(0,32):
	# 	# 	for j in xrange(4):
	# 	# 		pai.append(i)
	# 	# random.shuffle(pai)
	# 	# data = []

	# 	# for m in xrange(14):
	# 		# data.append(pai.pop())
	# 	# print data,MahJongBase.isAAAorABC(data)

	# 	# if MahJongBase.checkWin([0,0,0,1,2,3,4,4,11,12,13,14,14,14])[0]:
	# 	# 	win = win +1
	# 	# else:
	# 	# 	print data
	# 	# 	lose = lose + 1 

	# 	for data in [[0,0,0,1,2,3,4,4],[1,1,2,2,3,3,5,5],[3,3,3,2,2,2,1,1],[1,2,3,4,4],[1,1,1,1,2,3,4,4],[0,1,1,2,2,3,3,3],[11,22,33,44]]:
	# 		# print MahJongBase.isAAAorABC(data)
	# 		if MahJongBase.checkWin(data)[0]:
	# 			win = win +1
	# 		else:
	# 			print data
	# 			lose = lose + 1 

	# print win,lose
	# data = set({1,4,5})
	# print data[0]
	# data = [1,3,4,2,3,3,3].remove([3,3,3])
	# data = [1,1,2,2,3,3]
	
	# print MahJongBase.check(data)
	# print data.count(max(data,key=data.count)) == 4
	# print mh.tanslate(0)
	# print MahJongBase.isQingYiSe((1,2,3,4,5,6,7,8))

	# # 
	# print MahJongBase.isQiXiaoDui((1,1,2,2,3,3,4,4,5,5,6,6,7,7))

	# print MahJongBase.isQiXiaoDui((1,1,1,1,3,3,4,4,5,5,6,6,7,7))

	# print MahJongBase.isQiXiaoDui((1,1,1,1,3,3,3,3,5,5,6,6,7,7))

	# print MahJongBase.isQiXiaoDui((1,1,1,1,3,3,3,3,5,5,5,5,7,7))

	# print MahJongBase.isGang((1,1,12,42,),1)
	# print MahJongBase.isWin([1],1)
	data = [1,2,3,4]
	print data[0:2]
	print data[2:]
	# print data.pop(0,3),data







