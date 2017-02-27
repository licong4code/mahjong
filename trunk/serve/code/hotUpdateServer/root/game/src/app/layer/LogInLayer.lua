--[[
//
//  Created by licong on 2016/11/25.
//
//  Copyright 2016-2018 Supernano, All Rights Reserved
//
]]


local LogInLayer = class("LogInLayer",require("app.layer.BaseLayer"))

function LogInLayer:ctor()

	LogInLayer.super.ctor(self)
	
	self.btns = {}
	self.nums = {}
	self.roomid = ""
	self.isjoin = false

	local y = 0
	for i = 0, 8 do 
		local sp = display.newSprite("join_room/btn_num_"..(i+1)..".png")
		sp.tag = i+1
		y = display.cy - math.floor(i/3)*88 + 100
		sp:addTo(self):pos((i%3-1)*250+display.cx,y)
		table.insert(self.btns,sp)
	end
	
	local name = {{"btn_reset","reset"},{"btn_num_0",0},{"btn_del","del"}}
	for i=1,3 do 
		local sp = display.newSprite("join_room/"..name[i][1]..".png"):addTo(self)
		sp:setPosition((i-2)*250+display.cx,y-88)
		sp.tag = name[i][2]
		table.insert(self.btns,sp)
	end

	for i=1,6 do 
		local sp = display.newSprite("join_room/btm_line.png"):addTo(self):pos((i-3)*70+display.cx,display.cy + 200)
		local num = cc.ui.UILabel.new({font = "fonts/DFYuanW7-GB2312.ttf",size = 30,text = ""}):addTo(self):pos(sp:getPositionX(),sp:getPositionY()+30)
		table.insert(self.nums,num)
	end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function() return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(handler(self,self.onTouchMoved),cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)

    cc.ui.UILabel.new({UILabelType = 2, text = "login", size = 32}):addTo(self):pos(display.cx,display.height - 40)
end

function LogInLayer:onTouchEnded(touch,event)
	for i=1,#self.btns do 
		local btn = self.btns[i]
		if btn:hitTest(touch:getLocation(),false) then
			local tag = btn.tag
			if tag == "reset" then
				self.roomid = ""
				for i=1,#self.nums do 
					self.nums[i]:setVisible(false)
				end
			elseif tag == "del" then
				if string.len(self.roomid) > 0 then
					self.nums[string.len(self.roomid)]:setVisible(false)
					self.roomid = string.sub(self.roomid,1,string.len(self.roomid)-1)
				end
				
			else 
				if string.len(self.roomid) < 6 then
					self.roomid = self.roomid .. tag
					self.nums[string.len(self.roomid)]:setString(tag)
					self.nums[string.len(self.roomid)]:setVisible(true)
				end

				if string.len(self.roomid) == 6 then
					if self.isjoin == false then
						self.isjoin = true
						EventMgr.doAction(1001,{uid = self.roomid})
					end
				end
			end
		end
	end
end

return LogInLayer