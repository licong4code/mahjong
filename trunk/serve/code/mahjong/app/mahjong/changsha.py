# !/usr/bin/python
# coding:utf-8
# Created by licong on 2016/11/24.
# 
# 长沙麻将
# 

from base import MahJongBase

class ChangSha(MahJongBase):
	'''长沙麻将'''
	def __init__(self):
		super(ChangSha, self).__init__(["W","D","T"])

	def getEatGroup(self,data,one):
		def iscontain(alist,blist):
			for b in blist:
				if b not in alist:
					return False
			return True
		tmp = data[:]
		tmp.append(one)
		all_group = [[one-2,one-1,one],[one-1,one,one+1],[one,one+1,one+2]]
		group = []
		for g in all_group:
			if iscontain(tmp,g) and MahJongBase.isABC(g):
				group.append(g)
		return group

	def isJiangJiangHu(self,data):
		'''
		将将胡
		'''
		for value in data:
			if value % 9 not in [1,4,7]:
				return False
		return True

	def getWinType(self,winner,curuser,alldata,owndata,touchdata):
		wintype = super(ChangSha,self).getWinType()

		if len(owndata) == 2 :
			wintype = wintype & 1 << 9

		if self.isJiangJiangHu(alldata):
			wintype = wintype & 1 << 10			

		if self.getAvailableLen() == 0:
			wintype = wintype & 1 << 11
		return wintype
# ChangSha.getEatGrounp([1,2,3],4)
# print ChangSha.getEatGrounp([1,2,3,4,5,6,7],5)
# print [1,2] in [1,3,2]
