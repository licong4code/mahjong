--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 15/7/28.
//
//	竖版文字
]]

local VText = class("VText",function() return display.newLayer() end)

VText.LEFT_TO_RIGHT = 1
VText.RIGHT_TO_LEFT = 2

--[[
 content = 
 fontsize = 
 fontname = 
 color = 
 sep = 分隔符
 gap = 每列之间的距离
 framesize = 框大小
 direction = LEFT_TO_RIGHT or RIGHT_TO_LEFT 默认从左到右
]]
function VText:ctor(cfg)
	local fontSize = cfg.fontsize or 20
	local fontName = cfg.fontname or ""
	self.contents = Util.split(cfg.content,cfg.sep or "#")
	local width = #self.contents*fontSize + (#self.contents-1)*(cfg.gap-fontSize)
	local beginx = cfg.direction == LEFT_TO_RIGHT and 0 or width
	local anchor = cc.p(0.0,1.0)
	local gap = cfg.gap or fontSize
	if cfg.direction == self.RIGHT_TO_LEFT then
		anchor = cc.p(1.0,1.0)
		gap = -gap
 	end 

	local framesize = cc.size(width,cfg.framesize.height)
	-- local bg = cc.LayerColor:create(cc.c4b(0,0,200,255),width,framesize.height)
	-- self:addChild(bg)
	
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:ignoreAnchorPointForPosition(false)
	self:setContentSize(framesize)
	local label = nil 
	for i=1,#self.contents do
		local text = self.contents[i]
		if cc.FileUtils:getInstance():isFileExist(fontName) then
			label = cc.Label:createWithTTF(text, fontName, fontSize, cc.size(fontSize,framesize.height))
			label:setLineHeight(fontSize)
		else
			label = cc.Label:createWithSystemFont(text,fontName,fontSize,cc.size(fontSize,framesize.height))
		end
		label:setContentSize(cc.size(fontSize,framesize.height))
		label:setAnchorPoint(anchor)
		
		label:setPosition(beginx,framesize.height)
		label:setColor(cfg.color or cc.c3b(255,255,255))
		self:addChild(label)
		beginx = beginx + gap
	end
end


function VText:layout()
end


return VText