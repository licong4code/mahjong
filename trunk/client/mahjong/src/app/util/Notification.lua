--[[
//
//  Created by licong on 2015/09/16.
//
//  观察者
]]

local Notification = {}
Notification.events = {}

--[[

	listener = {
	[eventName] = handler
	}
]]
function Notification.addListener(listener,eventName,handler)
	if Notification.events[listener] == nil then
		Notification.events[listener] = {}
	end
	Notification.events[listener][eventName] = handler
end

function Notification.removeObserver(listener,eventName)

	if Notification.events[listener] then
		Notification.events[listener][eventName] = nil
	end
end

function Notification.removeAllObservers(listener)
	Notification.events[listener] = nil
end

function Notification.postNotification(eventName,args)
	-- 必须先获得所有key,因为在执行回调是可能改变Notification.events结构
	local keys = table.keys(Notification.events)
	for i=1,#keys do
		local instance = Notification.events[keys[i]]
		if instance and instance[eventName] then
			instance[eventName](args)
		end
	end
end

return Notification