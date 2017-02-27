# !/usr/bin/python
# coding:utf-8
# Created by licong on 2016/12/20.
# 
# 汝城
# 

from base import MahJongBase

class RuCheng(MahJongBase):
	def __init__(self):
		super(RuCheng, self).__init__(["W","D","T"])
		self.winbyself = True

	def calcScore(self,winner,curuser,allusers,wintype):
		rate = 1
		while wintype > 0:
			if wintype & 1:
				rate = rate * 2
			wintype = wintype >> 1
		score = rate * 2
		winner.addRoundScore(score * (len(allusers)-1))
		for user in allusers:
			if user != winner:
				user.addRoundScore(-score)

	def getResult(self,user):
		result = {}
		result["rscore"] = user.roundscore
		result["tscore"] = user.totalscore
		result["ingang"] = user.ingang
		result["outgang"] = user.outgang
		result["angang"] = user.angang
		result["minggang"] = user.minggang
		return result
