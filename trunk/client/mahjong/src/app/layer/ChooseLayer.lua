--[[
//
//  Created by licong on 2016/12/14.
//	胡牌等选择
]]


local ChooseLayer = class("ChooseLayer",function() return display.newLayer() end)

function ChooseLayer:ctor(data)
	
	self.data = data
	local menu = require("app.util.button.Button").new():addTo(self)
	local name = {p =  "#btn_peng_cs.png", h = "#btn_win_cs.png" , g = "#btn_gang_cs.png", pass = "#btn_pass_cs.png"}
	local keys = table.keys(data)
	table.insert(keys,"pass")
	local count = #keys
	for i=1,#keys do 
		local btn = require("app.util.button.ButtonItem").new({normal = name[keys[i]],upCallback = handler(self,self.onButtonClicked),scale = 0.9}):addTo(menu):pos(display.cx + (i - count/2)*150,display.cy)
		btn.type = keys[i]
	end
end

function ChooseLayer:onButtonClicked(sender)
	local command = {p = 1010,g = 1011,h = 1012,pass = 1013}
	if sender.type == "p" then
		EventMgr.doAction(command[sender.type],self.data[sender.type])
	else
		EventMgr.doAction(command[sender.type],self.data[sender.type][1])
	end
	self:removeFromParent()
end
return ChooseLayer

