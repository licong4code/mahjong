--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 15/7/23.
//
//	按钮
]]

local Button = class("Button",function() return display.newLayer() end)

function Button:ctor(...)
    self.mutex = false
	self.enabled = true
    local listener = cc.EventListenerTouchAllAtOnce:create()  
    listener:registerScriptHandler(handler(self,self.onTouchesBegan),cc.Handler.EVENT_TOUCHES_BEGAN )  
	listener:registerScriptHandler(handler(self,self.onTouchesMoved),cc.Handler.EVENT_TOUCHES_MOVED )  
    listener:registerScriptHandler(handler(self,self.onTouchesEnded),cc.Handler.EVENT_TOUCHES_ENDED )  
    listener:registerScriptHandler(handler(self,self.onTouchesCancelled),cc.Handler.EVENT_TOUCHES_CANCELLED)  

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    local args = {...}
    
    for k,v in pairs(args) do
    	self:addChild(v)
    end
     
end
--互斥，按下左键时不能按下右键
function Button:setMutext(bMutex)
    self.mutex = bMutex
end

function Button:setEnabled(enabled)
	self.enabled = enabled
end

function Button:onTouchesBegan(touches,event)
    if not self:canResponse() then
        return 
    end

	for i=1, #touches do
		local item = self:getTouchItem(touches[i]:getLocation())
		if item ~= nil then
            if item:isDirectionButton() then
                if not self.mutex then
                    self.mutex = true
                    item:selected()
                end
            else
                item = item:selected()
            end
		end
	end
end

function Button:onTouchesMoved(touches,event)

    if not self:canResponse() then
        return 
    end

    for i=1, #touches do
        local item = self:getTouchItem(touches[i]:getLocation())
        if item == nil then
            item = self:getTouchItem(touches[i]:getPreviousLocation())
            if item ~= nil and item.respone then
                item:unSelected()
                if item:isDirectionButton() then
                    self.mutex = false
                end
            end
        elseif item then --捕捉移动时响应按下事件
            local preitem = self:getTouchItem(touches[i]:getPreviousLocation())
            if preitem ~= item and preitem ~= nil then
                if preitem.respone then
                    preitem:unSelected()
                    if preitem:isDirectionButton() then
                        self.mutex = false
                    end
                end
            end
            if item:isDirectionButton() and not self.mutex then
                self.mutex = true
                item:selected()
            end
        end
    end
end

function Button:onTouchesEnded(touches,event)
    
    if not self:canResponse() then
        return 
    end
    
    for i=1, #touches do
        local item = self:getTouchItem(touches[i]:getLocation())
        if item ~= nil and item.respone then
            if item:isDirectionButton() then
                self.mutex = false
            end
            item = item:unSelected()
        end          
    end
end

function Button:onTouchesCancelled(touches,event)
    self:onTouchesEnded(touches,event)
end

function Button:getTouchItem(location)
	local children = self:getChildren()
	-- print("-->x,y:",location.x,location.y)
	local item = nil
	for i=1,#children do
		local child = children[i]
		if (child and child:isVisible() and child:getEnabled()) then
            local point = child:convertToNodeSpace(location)
            local r = child:getBoundingBox()  
            r.x,r.y = 0,0
            if cc.rectContainsPoint(r,point) then
                return child
            end
       end
    end   		
	return nil
end


function Button:canResponse()

    if not self.enabled or not self:isVisible() then
        return false
    end
    local parent = self:getParent()
    while parent do
        if not parent:isVisible() then
            return false
        end
        parent = parent:getParent()
    end
    return true
end

function Button:cancel()
    local children = self:getChildren()
    self.mutex = false
    for i=1,#children do
        children[i]:unSelected()
    end
end
return Button