--[[
//
//  Created by licong on 2016/12/22.
//
]]

local MessageBox = class("MessageBox",function() return display.newLayer() end)

--[[
{name = ,callback = }
]]
function MessageBox:ctor(cfg)
	local size = cc.size(400,280)
	self:setContentSize(size)
	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(cc.p(0.5,0.5))
	
	display.getRunningScene():addChild(self,100)

    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function() return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:setSwallowTouches(true)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
    self:setPosition(display.cx,display.cy)

	self.text = cc.ui.UILabel.new({text = cfg["text"],size = 30}):addTo(self):pos(size.width/2,size.height/2)
	self.text:setAnchorPoint(cc.p(0.5,0.5))
	self.text:setColor(cc.c3b(255,0,0))
	
	local buttons = cfg["button"]
	
	for i=1,#buttons do 
		local button = buttons[i]
		local label = cc.ui.UILabel.new({text = button["name"],size = 30})
		label:setColor(cc.c3b(0,255,0))
		local btn = cc.ui.UIPushButton.new()
		:setButtonLabel(label)  
	    :onButtonClicked(function() 
		    	button["callback"]()
		    	self:removeFromParent()
	    	end)
	    :pos(size.width/2,50)
	    :addTo(self)
	end
end

function MessageBox.show(code,cfg)
	cfg["text"] = require("app.config.message")[tostring(code)]["msg"]
	MessageBox.new(cfg)
end

return MessageBox