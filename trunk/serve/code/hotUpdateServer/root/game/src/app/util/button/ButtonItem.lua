--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 15/7/23.
//
//	按钮
]]

local ButtonItem = class("ButtonItem", function() --return cc.LayerColor:create(cc.c4b(0,0,200,255),252,200)
	local ret = display.newLayer()
	ret._getContentSize = ret.getContentSize
	ret._getPosition = ret.getPosition
	return ret
end)

-- ButtonItem.TYPE_NORMAL  = 
--[[

	normal = 正常(string)
	selected = 选中(string)
	disbaled = 不可用(string)
	node =  传入为一个节点
	scale = 缩放系数
	cd = cd时间
	
	press = 按下回调 ==         function callback (ButtonItem)
	upCallback = 弹起回调
	direction = 方向键  
]]


function ButtonItem:ctor(cfg)
	self.pushScale = cfg.scale
	self.orginScale = 1.0 --原始缩放系数
	self.enabled = true
	self.respone = false
	self.direction = cfg.direction or false
	if cfg.normal ~= nil then
		self.normalImg = display.newSprite(cfg.normal):addTo(self):pos(0,0)
		self.normalImg:setAnchorPoint(cc.p(0,0))
		self:setContentSize(self.normalImg:getContentSize())
	end

	if cfg.selected ~= nil then
		self.selectedImg = display.newSprite(cfg.selected):addTo(self)
		self.selectedImg:setAnchorPoint(cc.p(0,0))
		self.selectedImg:setVisible(false)
	end

	if cfg.disbaled ~= nil then
		self.disbaledImg = display.newSprite(cfg.selected):addTo(self)
		self.disbaledImg:setAnchorPoint(cc.p(0,0))
		self.disbaledImg:setVisible(false)
	end

	if cfg.press ~= nil then
		self.pressCallBack = cfg.press
	end

	if cfg.upCallback ~= nil then
		self.releaseCallBack = cfg.upCallback
	end

	self:setAnchorPoint(cc.p(0.5,0.5))
	self:ignoreAnchorPointForPosition(false)
end

--选中
function ButtonItem:selected()
	if self.respone == false then
		self.respone = true
		self.isPressing = true
		self:_selected()
		if self.pressCallBack ~= nil then
			self:retain()
			self.pressCallBack(self)
			self:release()
		end
	end
end

--弹起
function ButtonItem:unSelected()
	if self.respone then
		self.respone = false
		self.isPressing = false
		self:_normal()
		if self.releaseCallBack ~= nil then
			self:retain()
			self.releaseCallBack(self)
			self:release()
		end
	end
end

function ButtonItem:cancel()
	self:_normal()
end

--清除CD
function ButtonItem:clearCD()
	self:setEnabled(true)
end

--是否可用
function ButtonItem:getEnabled()
	return self.enabled
end

function ButtonItem:setEnabled(enabled)
	
	if enabled ~= self.enabled then
		self.enabled = enabled
		if enabled == true then
			self:_normal()
		else
			self:_disbaled()
		end
	end
end

function ButtonItem:_normal()
	if self.pushScale ~= nil then
		self:setScale(self.originScale)
	else
		if self.normalImg ~= nil then
			self.normalImg:setVisible(true)
		end

		if self.selectedImg ~= nil then
			self.selectedImg:setVisible(false)
		end

		if self.disabledImg ~= nil then
			self.disabledImg:setVisible(false)
		end
	end
end

function ButtonItem:_selected()
	if self.pushScale ~= nil then --缩放按钮
		self.originScale = self:getScale() --获得原始缩放系数
		self:setScale(self.pushScale)
	else --切换图片
		if self.normalImg ~= nil then
			self.normalImg:setVisible(false)
		end

		if self.selectedImg ~= nil then
			self.selectedImg:setVisible(true)
		end

		if self.disabledImg ~= nil then
			self.disabledImg:setVisible(false)
		end
	end
end

function ButtonItem:_disbaled()
	if self.pushScale == nil then --换图片
		if self.normalImg ~= nil then
			self.normalImg:setVisible(false)
		end
		if self.selectedImg ~= nil then
			self.normalImg:setVisible(false)
		end

		if self.disabledImg ~= nil then
			self.disabledImg:setVisible(true)
		end
	end
end

function ButtonItem:isDirectionButton()
	return self.direction
end

function ButtonItem:isPressing()
	return self.isPressing
end

function ButtonItem:setFlippedX(flipped)
	if self.normalImg then
		self.normalImg:setFlippedX(flipped)
	end

	if self.selectedImg then
		self.selectedImg:setFlippedX(flipped)
	end

	if self.disabledImg then
		self.disabledImg:setFlippedX(flipped)
	end
end

function ButtonItem:getContentSize()
	return self.normalImg:getContentSize()
end

function ButtonItem:getPosition()
	-- print("self--->:",self)
	local x,y = self:_getPosition()
	local size = self:_getContentSize()
	local imgSize = self:getContentSize()
	-- print(size.width,size.height)
	x,y = x-size.width/2,y-size.height/2
	return x+imgSize.width/2,y+imgSize.height/2
end

function ButtonItem:getPositionX()
	local x,y = self:getPosition()
	return x
end

function ButtonItem:getPositionY()
	local x,y = self:getPosition()
	return y
end

return ButtonItem
