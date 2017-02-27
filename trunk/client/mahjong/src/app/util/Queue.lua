--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 2015/12/07.
//	
//  队列
]]

Queue = class("Queue")

function Queue:ctor()
	
	self.array = {}
	self.first = 0
	self.last = 0
end

function Queue:push(value)

	self.last = self.last + 1
	if self.first == 0 then
		self.first = self.last 
	end
	self.array[self.last] = value
end

function Queue:pop()
	if self.first == 0 then return nil end
	if self.first <= self.last then
		local value = self.array[self.first]
		self.first = self.first + 1
		return value
	end
	return nil
end

function Queue:size()
	return self.last - self.first
end