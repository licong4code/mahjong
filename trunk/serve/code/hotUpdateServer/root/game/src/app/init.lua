--[[
//
//  Created by licong on 2016/12/03.
//
]]



if init_all_var == nil then
	init_all_var = true
	require("app.util.EventMgr")
	MessageBox = require("app.util.MessageBox")
	Notification = require("app.util.Notification")
	globalUserData = require("app.util.UserData").new()
	globalSock = require("app.net.SocketImpl").new()
end
