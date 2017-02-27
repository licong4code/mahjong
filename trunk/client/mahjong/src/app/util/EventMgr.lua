--[[
//
//  Created by licong on 2016/12/04.
//
]]

EventMgr = {}

local events = require("app.config.event")


function EventMgr.registerEvent(listener,code)
	-- print(listener)
	local event = events[tostring(code)]
	if event then
		for key,value in pairs(event) do
			if key ~= "id" and key ~= "desc" and listener[value] then
				Notification.addListener(listener,code..value,handler(listener,listener[value]))
			end
		end
	else
		print("注册事件失败：",code)
	end
end

function EventMgr.registerAll(listener)
	local keys = table.keys(events)
	for i =1,#keys do 
		EventMgr.registerEvent(listener,tonumber(keys[i]))
	end
end

function EventMgr.removeAllEvent(listener)
	Notification.removeAllObservers(listener)
end

function EventMgr.doAction(code,data)
	local event = events[tostring(code)]
	if event then
		-- print("do action:",code,event["action"])
		Notification.postNotification(code..event["action"],{code = code,data = data})
	else
		print("找不到指令：",code)
	end
end

function EventMgr.postResult(result,code,data)
	local event = events[tostring(code)]
	if event then
		local name = result ~= 0 and event["ok"] or event["no"]
		if name then
			-- dump(data, name)
			Notification.postNotification(code..name,data)	
		end
	else
		print("找不到事件：",code)
	end
end