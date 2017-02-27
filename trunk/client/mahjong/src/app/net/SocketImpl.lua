--[[
//
//  Created by licong on 2016/11/09.
//
//  Copyright 2016-2018 Supernano, All Rights Reserved
//
]]


local net = require("framework.cc.net.init")
local ByteArray = require("framework.cc.utils.ByteArray")
require("framework.cc.utils.bit")

local SocketImpl = class("SocketImpl")
local NetData = require("app.net.NetData")

local IP = HOST_IP

local PORT = 1000
-- 初始化网络   网络监听
function SocketImpl:ctor(view)
	local time = net.SocketTCP.getTime()
	local socket = net.SocketTCP.new(IP,PORT)
	socket:setName("SocketImpl")
	socket:setTickTime(1)
	socket:setReconnTime(6)
	socket:setConnFailTime(4)
	socket:addEventListener(net.SocketTCP.EVENT_DATA, handler(self,self.onRecv))
	socket:addEventListener(net.SocketTCP.EVENT_CLOSE, handler(self,self.onClose))
	socket:addEventListener(net.SocketTCP.EVENT_CLOSED, handler(self,self.onClosed))
	socket:addEventListener(net.SocketTCP.EVENT_CONNECTED, handler(self,self.onConnected))
	socket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onError))
	
	self.resolver = require("app.net.NetData").new()
	self.socket = socket
	self.view = view

	EventMgr.registerAll(self)
end

function SocketImpl:connect()
	if self.socket.isConnected then
		self:onConnected()
	else
		self.socket:connect(IP,PORT)
	end
end
function SocketImpl:getUID()
	local uid = cc.UserDefault:getInstance():getStringForKey("uid","")
	if #uid <= 0 then
		uid = os.date("%y%m%d%H%M%S",os.time())
		for i=1,10 do 
			uid = uid .. math.random(0,9)
		end
		cc.UserDefault:getInstance():setStringForKey("uid",uid)
	end
	return uid
end

function SocketImpl:login(message)
	local request = {uid = message["data"]["uid"]}
	self.socket:send(NetData.encode(request,message["code"]))
end

function SocketImpl:logout(message)
	local request = {uid = self:getUID()}
	self.socket:send(NetData.encode(request,message["code"]))
end

function SocketImpl:buildRoom(message)
	local request = {uid = self:getUID()}
	self.socket:send(NetData.encode(request,message["code"]))
end

function SocketImpl:enterRoom(message)
	local request = {uid = self:getUID(),id = message["data"]["id"]}
	self.socket:send(NetData.encode(request,message["code"]))
end

function SocketImpl:dissolveRoom(message) 
	local request = {uid = self:getUID()}
	self.socket:send(NetData.encode(request,message["code"]))
end

function SocketImpl:applyDissolveRoom(message)
	self.socket:send(NetData.encode({},message["code"]))
end

function SocketImpl:responseDissolve(message)
	self.socket:send(NetData.encode({code = message["data"]},message["code"]))
end

function SocketImpl:request(message)
	self.socket:send(NetData.encode(message["data"],message["code"]))
end

function SocketImpl:onRecv(event)
	
	local list = self.resolver:decode(event.data)
	for i=1,#list do 	
		local message,command = list[i]["msg"],list[i]["command"]
		-- print(message,command)
		local data = json.decode(message)
		EventMgr.postResult(data["code"],command,data)
	end
end

function SocketImpl:onClose()
end

function SocketImpl:onClosed()
end

function SocketImpl:onConnected()
	EventMgr.postResult(1,1000,{})
end

function SocketImpl:onError()
	print("----...",'链接失败')
end

-- 
function SocketImpl:onDropLine(data)
	self.socket:disconnect()
	MessageBox.show(data["msg"],{button = {{name = "OK",callback = function() display.replaceScene(require("app.scenes.MainScene").new()) end}}})
end

return SocketImpl