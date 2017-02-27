--[[
//
//  Created by licong on 2016/12/08.
//
]]


local UserData = class("UserData")

function UserData:ctor(data)
	if data ~= nil then
		self:init(data)
	end
end

function UserData:init(data)

	self:initData(data)
	self.ownview = {}
	self.outview = {}
	self.touchview = {}
end

function UserData:initData(data)
	self.id = data["id"]
	self.owndata = data["own"]
	self.outdata = data["out"]
	self.touchdata = data["touch"]
	self.wait = data["wait"]
	self.group = data["group"]

end

function UserData:initFromRoom(room,userid)
	self:init(self:getDataFromRoom(room,userid))
end

function UserData:getDataFromRoom(room,userid)
	local users = room["users"]
	userid = userid or self.id
	if users then
		for i=1,#users do 
			local user = users[i]
			if user['id'] == userid then
				return user
			end
		end	
	end
end

function UserData:clearView()
	for i=1,#self.ownview do 
		self.ownview[i]:removeFromParent()
	end

	for i=1,#self.outview do 
		self.outview[i]:removeFromParent()
	end

	for i=1,#self.touchview do 
		self.touchview[i]:removeFromParent()
	end

	self.ownview = {}
	self.outview = {}
	self.touchview = {}
end

function UserData:getOwnSize()
	if type(self.data) == "table" then
		return #self.data
	else
		return self.data
	end
end
return UserData