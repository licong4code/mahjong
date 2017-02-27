--[[
//
//  Created by licong on 2016/12/09.
//
]]

local ApplyDissolve = class("ApplyDissolve",require("app.layer.BaseLayer"))

function ApplyDissolve:ctor()
	ApplyDissolve.super.ctor(self)

	local button = {"YES","NO"}
	local index = 1
	for _,name in pairs(button) do
		local btn = cc.ui.UIPushButton.new()
		:setButtonLabel(cc.ui.UILabel.new({text = name,size = 30})) 
	    :onButtonClicked(function() 
	    	EventMgr.doAction(1008,name == "YES" and 1 or 0)
	    	end)
	    :pos(display.cx,display.cy - (i-1.5)*60)
	    :addTo(self)
	    index = index + 1
	end
end

return ApplyDissolve