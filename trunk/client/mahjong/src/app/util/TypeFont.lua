--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 15/10/15.
//
//	打字机效果
]]

local TypeFont = class("TypeFont",function () return display.newLayer() end)

--[[
cfg = {
	text = 文本
	time = 每个字之间间隔时间
	color = 字体颜色
	size = 字体大小
	name = 字体名称
	dimensions = 文字框大小
	callback = 文字全部显示完毕回调
}
]]
function TypeFont:ctor(cfg)
	self.finnalText = cfg.text or ""
	self.currentTextIndex = 0
	self.finnalTextIndex = string.len(cfg.text)
	self.time = cfg.time or 0.05
	self.callback = cfg.callback
	self.text = display.newTTFLabel({
                text = "",
                size = cfg.size or 32,
                font = cfg.name or "fonts/lcz-zhongwen-max.ttf",
                color = cfg.color or cc.c3b(255, 255, 255),
                dimensions = cfg.dimensions or cc.size(1200,100)
                }):addTo(self)

	if cfg.dimensions then
		self:setContentSize(cfg.dimensions)
		self:setAnchorPoint(cc.p(0.5,0.5))
		self:ignoreAnchorPointForPosition(false)
		self.text:setPosition(cc.p(cfg.dimensions.width/2,cfg.dimensions.height/2))
	end

	self:start()
end

function TypeFont:start()
	local func = function ()
		self.currentTextIndex = self.currentTextIndex + 1
		if self.currentTextIndex <= self.finnalTextIndex then
			self.text:setString(string.sub(self.finnalText,1,self.currentTextIndex))
		else
			if self.callback then 
				self:retain()
				self.callback()
				self:release()
			end

			self:stopAllActions()
		end
	end

	self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(func),cc.DelayTime:create(self.time))))
end


function TypeFont:stop()
	self:stopAllActions()
	self.text:setString(self.finnalText)
end

function TypeFont:setString(str)
	self.finnalText = str or ""
	self.currentTextIndex = 0
	self.finnalTextIndex = string.len(self.finnalText)
	self:stopAllActions()
	self:start()
end
return TypeFont