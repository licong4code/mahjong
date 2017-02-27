 --[[
//
//  Copyright (c) 2016-2017 Mars
//
//  Created by licong on 16/01/22.
//
//	http请求
]]

local Http = {}

function Http.request(url,method,callback,data,timeout)
	-- Http.callback = callback
	local request = network.createHTTPRequest(callback,url,method)
	request:setTimeout(timeout or 0)
	if data then
		request:addRequestHeader("Content-Type:application/json;charset=utf-8")
		request:setPOSTData(data)
	end
	request:start()
end


--服务器响应
function Http.response(event)
	if event.name == "completed" then
		-- print (event.request:getResponseData())
		local data = json.decode(event.request:getResponseData())
		self:downloadBegin(data)
	elseif event.name == "failed" then
		self.cfg.callback("failed","code:"..event.request:getErrorCode()..",err:"..event.request:getErrorMessage())
	end
end

return Http