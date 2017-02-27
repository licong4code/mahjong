--[[
//
//  Created by licong on 2017/01/19.
//
//  COPYRIGHT 2016 Supernano CO.LTD ALL RIGHTS RESERVED
//
]]

local ResultLayer = class("ResultLayer",require("app.layer.BaseLayer"))

function ResultLayer:ctor(data)
	local users = data["users"]
	local half = (#users + 1)/2
	for i=1,#users do 
		require("app.layer.ResultItem").new(users[i]):addTo(self):pos((i-half)*350 + display.cx,display.cy)
	end
end
return ResultLayer