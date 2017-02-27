


local HomeLayer = class("HomeLayer", require("app.layer.BaseLayer"))

function HomeLayer:ctor()
	HomeLayer.super.ctor(self)

    self.roomid = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 32})
        :addTo(self)
        :pos(20,display.height - 30)
    self.roomid:setColor(cc.c3b(255,0,0))
    self.roomid:setAnchorPoint(cc.p(0,0.5))

    self.uid = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 32})
        :pos(20, display.height-70)
        :addTo(self)
	self.uid:setAnchorPoint(cc.p(0,0.5))
	self.uid:setColor(cc.c3b(0,200,0))

	self.others = {}

	globalSock:connect()
end

function HomeLayer:onEnter()
	display.addSpriteFrames("mahjong_tiles.plist","mahjong_tiles.pvr.ccz")
	display.addSpriteFrames("changshamjbtn.plist","changshamjbtn.pvr.ccz")
	self.buttons = {}
-- -- print(socket._VERSION)
-- 	local parent = display.newNode():addTo(self):pos(0,-20)
-- 	local point = cc.p(display.cx,display.cy)
-- 	local layer = cc.LayerColor:create(cc.c4b(200,0,0,255)):addTo(parent):pos(display.cx,display.cy)
-- 	layer:setContentSize(cc.size(60,60))
-- 	dump(layer:convertToNodeSpace(point))

	local button = {
			-- login = 10001,
					logout = 1002,
					build = 1003,
					enter = 1004,
					exit = 1005,
					dissolve = 1006
				}
	local index = 1
	for k,code in pairs(button) do
		self.buttons[k] = cc.ui.UIPushButton.new()
		:setButtonLabel(cc.ui.UILabel.new({text = k,size = 30}))  
	    :onButtonClicked(function() 
	    	if code == 1004 then
	    		self.enterLayer = require("app.layer.EnterRoom").new():addTo(self)
		    -- elseif code == 10003 then
		    else
		    	EventMgr.doAction(code) 
	    	end
	    	end)
	    :pos(200,display.height - index*80)
	    :addTo(self)
	    index = index + 1
	    self.buttons[k]:setVisible(false)
	end
end

function HomeLayer:connectSuccess()
	self.loginLayer = require("app.layer.LogInLayer").new():addTo(self)
end

function HomeLayer:loginSuccess(data)
	local room = data["room"]
	local id = data["id"]
	local status = data["status"] 
	

	for k,v in pairs(self.buttons) do 
		v:setVisible(false)
	end
	dump(room,"room")
	if status == 0 then
		globalUserData:init(data["info"])
	else
		globalUserData:initFromRoom(room,id)
	end

	if status == 0 then --无状态
		self.buttons["build"]:setVisible(true)
		self.buttons["enter"]:setVisible(true)

	elseif status == 1 then --等待]
		self.roomid:setString("RID:"..room["id"])
		self.buttons["dissolve"]:setVisible(room["owner"])
		self.buttons["exit"]:setVisible(not room["owner"])

	else --游戏中
		self.gameLayer = require("app.layer.GameLayer").new(data):addTo(self,10)
		self.uid:setVisible(false)
		-- display.getRunningScene():createGameLayer()
	end

	self.uid:setString("UID:"..globalUserData.id)
	if self.loginLayer then
		self.loginLayer:removeFromParent()
		self.loginLayer = nil
	end

end


function HomeLayer:buildRoomSuccess(data)
	for k,v in pairs(self.buttons) do 
		v:setVisible(false)
	end
	self.buttons["exit"]:setVisible(true)
	self.roomid:setString("ID:"..data["room"]["id"])
end



function HomeLayer:dissolveRoomSuccess()
	for k,v in pairs(self.buttons) do 
		v:setVisible(k == "build")
	end
	-- self.text:setString("Welcome")
end

function HomeLayer:onUserEnter(data)
	local room = data["room"]
	dump(data,"data")
	if data["status"] == 2 then
		if self.enterLayer then
			self.enterLayer:removeFromParent()
			self.enterLayer = nil
		end
		globalUserData:initFromRoom(room,data["id"])
		self.gameLayer = require("app.layer.GameLayer").new(data):addTo(self,10)
	end
	self.roomid:setVisible(false)
end

function HomeLayer:responseDissolve(data)
	
end

function HomeLayer:exitRoomSuccess()
	for k,v in pairs(self.buttons) do 
		v:setVisible(false)
	end
	self.buttons["build"]:setVisible(true)
	self.buttons["enter"]:setVisible(true)
	self.roomid:setString("")
end
-- 申请解散
function HomeLayer:onApplyDissolve(data)
	require("app.layer.ApplyDissolve").new(data):addTo(self,1)
end

function HomeLayer:onDisssolveSuccess()
	self.gameLayer:removeFromParent()
end
return HomeLayer
