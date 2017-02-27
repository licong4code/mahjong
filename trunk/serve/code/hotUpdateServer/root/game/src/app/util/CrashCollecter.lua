--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 2015/07/16.
//
//  lua错误、c++ crush收集并上传到服务器
]]
CrashCollecter = {}
local data = {}
data["app_name"] 		= "coldblade"
data["chanel_name"] 	= "none"
data["lua_ver"] 		= "1.0.0"
data["engine"] 		    = "qucik-cococs2dx-3.3"


local SAVE_KEY  = "CRUSH_ERROR" 		--存储错误信息到本地
local URL 		= "127.0.0.0" 			--服务器地址


--上传结果
function uploadResult(event)
	if event.name == "failed" then
		cc.UserDefault:getInstance():setStringForKey(SAVE_KEY, json.encode(data))
	elseif event.name == "complete" then 
		cc.UserDefault:getInstance():setStringForKey(SAVE_KEY, "")
	end
end

--上传错误信息
local function upload(errMsg)
	if errMsg ~= nil then
		-- local request = network.createHTTPRequest(uploadResult,URL,'POST')
		-- -- request:setPOSTData(errMsg)
		-- request:setTimeout(2)
		-- request:start()
	end
end


--检查本地是否有未上传的错误信息
function CrashCollecter.check()
end

--获得运行环境
function CrashCollecter.getRunTimeEnvironment()
	if device.platform == "android" then
		local reslut,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getRuntimeEnvironment", nil,"()Ljava/lang/String;")
		if reslut then
			return ret
		end
	elseif device.platform == "ios" then

	end
	
	return "unknow"
end

--压入错误信息
function CrashCollecter.push(err)
	local env = CrashCollecter.getRunTimeEnvironment()
	data["env"] = env
	data["error"] = err
	upload(json.encode(data))
	print("-------->>>",json.encode(data))
end

function crush_test(args)
	print("-------->>>>_>java call lua:"..args)
end
