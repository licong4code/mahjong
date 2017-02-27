--[[
//
//  Created by licong on 2016/12/08.
//
]]

local GameLayer = class("GameLayer",require("app.layer.BaseLayer"))

function GameLayer:ctor(data)
	local room = data["room"]
	local users = room["users"]
	local selfdata = globalUserData
	GameLayer.super.ctor(self)

	self.data = globalUserData.owndata
	self.wait = selfdata.wait
	-- 牌面数据
	self.users = {}
	for i=1,#users do
		local userdata = users[i]
		local id = userdata["id"]
		if id == globalUserData["id"] then
			self.users[id] = globalUserData
		else
			self.users[id] = require("app.util.UserData").new(userdata)
		end
		
	end

	-- self.users[globalUserData["id"]] = globalUserData


    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function() return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
    self.curMh = nil

    local room = data["room"]
    local txt_room_id = cc.ui.UILabel.new({UILabelType = 2, text = "RID:"..room["id"], size = 32})
        :addTo(self)
        :pos(20,display.height - 30)
    txt_room_id:setColor(cc.c3b(255,0,0))
    txt_room_id:setAnchorPoint(cc.p(0,0.5))

    -- local txt_user_id = cc.ui.UILabel.new({UILabelType = 2, text = "UID:"..globalUserData.id, size = 32})
    -- :addTo(self)
    -- :pos(20,display.height - 30 - 40)
    -- txt_user_id:setColor(cc.c3b(0,255,0))
    -- txt_user_id:setAnchorPoint(cc.p(0,0.5))


    local users = room["users"]
    for i=1,#users do 
    	local user = users[i]
    	local id = user["id"]
    	local online = user["online"] == 1 and "" or "(断线)"
	    local txt_user_id = cc.ui.UILabel.new({UILabelType = 2, text = "UID:"..user["id"] ..online, size = 32})
        :addTo(self)
        :pos(20,display.height - 30 - (i)*40)
	    txt_user_id:setColor(globalUserData.id == id and cc.c3b(0,255,0) or cc.c3b(255,255,255))
	    txt_user_id:setAnchorPoint(cc.p(0,0.5))
	    self.users[id].idView = txt_user_id
    end


	local btn = cc.ui.UIPushButton.new()
	:setButtonLabel(cc.ui.UILabel.new({text = "申请解散",size = 30}))  
    :onButtonClicked(function() EventMgr.doAction(1006) end)
    :pos(display.cx,display.cy)
    :addTo(self)

    if selfdata["group"] then
    	require("app.layer.ChooseLayer").new(selfdata["group"]):addTo(self)
    end
end

function GameLayer:onEnter()
	
	self:updateView()
end

function GameLayer:onOtherUserLostConnect(data)
	for i=1,#self.others do 
		local user = self.others[i]
		if user.id == data["id"] then
			user:setString("UID:"..user["id"] .."(离线)")
		end
	end
end


function GameLayer:onTouchEnded(touch, event)
	local mhs = globalUserData["ownview"]
	for i=1,#mhs do 
		local mh = mhs[i]
		
		if mh:hitTest(touch:getLocation(),false) and self.wait == 0 then
			
			if self.curMh ~= mh then
				if self.curMh then
					self.curMh:setPositionY(self.curMh:getPositionY() - 50)
				end
				mh:setPositionY(mh:getPositionY() + 50)
				self.curMh = mh
			else
				self.wait = 1
				EventMgr.doAction(1009,{type = 1,data = self.curMh.data})
				self.curMh = nil
			end
			break
		end
	end
end

function GameLayer:outOK(data)
	dump(data,"out")
	local user = globalUserData
	local out = data["data"]

	table.removebyvalue(user.owndata,out)
	table.insert(user.outdata,out)
	table.sort(user.owndata)
	self:updateView()
end

function getCardView(data)
	local sp = display.newSprite(string.format("#p4b%d_%d.png",math.floor(data/9)+1,data%9+1))
	sp.data = data
	sp:setAnchorPoint(cc.p(0,0.5))
	-- return display.newSprite(string.format("tiles/p4b%d_%d.png",math.floor(data/9)+1,data%9+1))
	return sp
end

function getOutCardView(data,direction)
	local sp = nil
	if direction == nil then
		sp = display.newSprite(string.format("#p4s%d_%d.png",math.floor(data/9)+1,data%9+1))
	elseif direction == "top" then
		sp = display.newSprite(string.format("#p2s%d_%d.png",math.floor(data/9)+1,data%9+1))
	end
	sp:setAnchorPoint(cc.p(0,0.5))
	sp.data = data
	-- return display.newSprite(string.format("tiles/p4b%d_%d.png",math.floor(data/9)+1,data%9+1))
	return sp
end

function getTouchCardView(data,direction)
	local sp = display.newSprite(string.format("#p2s%d_%d.png",math.floor(data/9)+1,data%9+1))
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setFlippedY(true)
	return sp
end

function GameLayer:updateView()
	for id,user in pairs(self.users) do 
		
		user:clearView()

		local id = user["id"]
		local data = user["owndata"]
		local touchdata = user["touchdata"]
		local outdata = user["outdata"]

		if id == globalUserData["id"] then
			
			local beginx = 10
			for i=1,#touchdata do 
				local group = touchdata[i]

				for j = 1,3 do 
					local value = group[i]
					local sp = getTouchCardView(value):addTo(self)
					sp:pos(beginx + sp:getContentSize().width*j,50)
					if i ==2 and #group == 4 then
						local sp = getTouchCardView(value):addTo(self)
						sp:pos(beginx + sp:getContentSize().width*j,100)
					end
					
					if j == #group then
						beginx = beginx + 10 + sp:getContentSize().width*3
					end
				end
			end

			for i =1,#data do 
				local pai = getCardView(data[i]):addTo(self)
				local size = pai:getContentSize()
				pai:setPosition((size.width-3)*(i-1) + display.cx - (size.width-3)*#data/2,100)
				table.insert(user.ownview,pai)
			end
			
			for i = 1, #outdata do 
				local pai = getOutCardView(outdata[i]):addTo(self)
				local size = pai:getContentSize()
				pai:setPosition(80 + (size.width-3)*(i-1),240)
				table.insert(user.outview,pai)
			end

			if #data % 3 == 2 then
				local size = #user.ownview
				user.ownview[size]:setPositionX(user.ownview[size]:getPositionX() + 20)
			end
			

		else
			for i = 1,data do 
				local sp = display.newSprite("#tbgs_2.png"):addTo(self)
				sp:setAnchorPoint(cc.p(0,0.5))
				local size = sp:getContentSize()
				sp:setPosition(300 + (size.width-3)*(i-1),display.height-40)
				table.insert(user.ownview,sp)
			end

			for i = 1, #outdata do 
				local pai = getOutCardView(outdata[i],"top"):addTo(self)
				local size = pai:getContentSize()
				pai:setPosition(300 + (size.width-3)*(i-1),display.height-120)
				table.insert(user.outview,pai)
			end
		end
	end

end

function GameLayer:onUserIn(data)
	self.wait = 0
	local value = data["data"]
	table.insert(globalUserData.owndata,value)
	self:updateView()
	local group = data["group"]
	if group then
		require("app.layer.ChooseLayer").new(group):addTo(self)
	end
end

function GameLayer:onUserOut(data)
	local id = data["id"]
	local user = self.users[id]
	local value = data["data"]
	local group = data["group"]
	if group then
		require("app.layer.ChooseLayer").new(group):addTo(self)
	end
	table.insert(user.outdata,value)
	self:updateView()
end

function GameLayer:onUserPeng(data)
	if data["id"] ~= globalUserData["id"] then
		local peng = display.newSprite("#btn_peng_cs.png"):addTo(self):pos(display.cx,display.cy)
		peng:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeOut:create(0.8),cc.RemoveSelf:create()))
	end
	local users = data["room"]["users"]
	for i=1,#users do
		local user = users[i]
		self.users[user["id"]]:initData(user)
	end

	globalUserData = self.users[globalUserData["id"]]
	self:updateView()
	self.wait = 0
end

function GameLayer:onUserGang(data)
	if data["id"] ~= globalUserData["id"] then
		local peng = display.newSprite("#btn_gang_cs.png"):addTo(self):pos(display.cx,display.cy)
		peng:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeOut:create(0.8),cc.RemoveSelf:create()))
	end
	local users = data["room"]["users"]
	for i=1,#users do
		local user = users[i]
		self.users[user["id"]]:initData(user)
	end

	globalUserData = self.users[globalUserData["id"]]
	self:updateView()
	self.wait = 0
end
return GameLayer
-- 