--[[
//
//  Created by licong on 2016/11/11.
//
//  Copyright 2016-2018 Supernano, All Rights Reserved
//
]]
local NetData = class("NetData")

local net = require("framework.cc.net.init")
local ByteArray = require("framework.cc.utils.ByteArray")

function NetData:ctor(data)
	local ba = ByteArray.new()
	ba:setEndian(ByteArray.ENDIAN_BIG)
	self.ba = ba
end

function NetData.encode(data,command)
	local string = json.encode(data)
	return string.pack(">b5i3A",0,0,0,0,0,0,#string+4,command,string)
end

local headsize = 5
local version_size = 4
local command_size = 4

function NetData:decode(bytes)
	local ba = self.ba
	local isremain = ba:getAvailable() > 0
	self.ba:writeBuf(bytes)

	-- 可能存在bug
	if not isremain then
		ba:setPos(1)
	end

	local ba = self.ba
	local list = {}
	local unpackage = nil

	unpackage = function()
		if ba:getAvailable() >= headsize + version_size then
			ba:setPos(ba:getPos() + headsize + version_size)
		end
		local messagesize = ba:readInt() - command_size
		local command = ba:readInt()
		if ba:getAvailable() >= messagesize then
			local message = ba:readString(messagesize) 
			table.insert(list,{command = command,msg = message})
			if ba:getAvailable() > 0 then
				unpackage()
			else-- 可能存在bug
				ba._buf = {}
				ba._pos = 1
			end
		end
	end
	unpackage()
	-- for i=1,#list do
	-- 	print(list[1]["command"],list[1]["msg"])
	-- end
	return list
end
return NetData