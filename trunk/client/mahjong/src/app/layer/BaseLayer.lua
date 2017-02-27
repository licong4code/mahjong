--[[
//
//  Created by licong on 2016/12/08.
//
]]

local BaseLayer = class("BaseLayer",function() return display.newLayer() end)

function BaseLayer:ctor()
    self:setNodeEventEnabled(true)
	EventMgr.registerAll(self)
end

function BaseLayer:onExit()
	EventMgr.removeAllEvent(self)
end

return BaseLayer