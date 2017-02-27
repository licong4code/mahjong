--[[
//
//  Created by licong on 2017/01/03.
//
]]


local BaseScene = class("BaseScene", function()
    return display.newScene("BaseScene")
end)

function BaseScene:ctor()
	local showVersion = function ()
		local vernode = self.vernode
		if vernode == nil then
		    vernode = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 28})
	        :pos(display.width-20, 20)
	        vernode:setColor(cc.c3b(255,0,0))
	        vernode:setAnchorPoint(cc.p(1.0,0))
	    end
		self.vernode = vernode
		vernode:setString("ver:"..require("app.version"))
		self:addChild(vernode,100)
	end
	
	showVersion()
end

return BaseScene
