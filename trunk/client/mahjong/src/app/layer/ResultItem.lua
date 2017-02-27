--[[
//
//  Created by licong on 2017/01/19.
//
//  COPYRIGHT 2016 Supernano CO.LTD ALL RIGHTS RESERVED
//
]]
local ResultItem = class("ResultItem",function ( )
	return display.newLayer()
end)

function ResultItem:ctor(data)
	local size = cc.size(80,300)
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:ignoreAnchorPointForPosition(false)
	local index = 1
	local result = data["data"]
	result["id"] = data["id"]
	for k,v in pairs(result) do
	    local text = cc.ui.UILabel.new({UILabelType = 2, text = k .. "     " .. v, size = 32})
        :pos(size.width/2, size.height-index*45)
        :addTo(self)
        text:setColor(cc.c3b(0,255,20))
        index = index + 1
	end
end

return ResultItem




