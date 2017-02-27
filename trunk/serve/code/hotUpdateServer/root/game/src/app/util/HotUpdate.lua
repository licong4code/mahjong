--[[
//
//  Created by licong on 2016/12/27.
//	热更新
//
]]

local URL = "http://192.168.37.60:1234/"
-- local URL =  "http://192.168.1.103:1234/"
local OUTPATH = device.writablePath .. "update/"
local HotUpdate = class("HotUpdate")
local zlib = require("zlib")

local encode = function(data)
	local retdata = zlib.deflate()(data,"finish")
	return retdata--(data,"finish")  --压缩
end

local decode = function(data)
	return zlib.inflate()(data)  --解压
end

--[[
callback    --下载回调
]]
function HotUpdate:ctor(callback)
	self.callback = callback
	self.all_file_name = {}
	self.all_file_info = {}
	self.curfile = nil
	self.loadsize = 0 --已下载数据大小
	local fileinfo = cc.FileUtils:getInstance():getStringFromFile("fileinfo.txt")
	self:request(URL .. "hotupdate/",handler(self,self.checkCallback),"POST",fileinfo,15)
end

--网络请求
function HotUpdate:request(url,callback,method,data,timeout)
	-- print(url,method)
	local request = network.createHTTPRequest(callback,url,method)
	request:setTimeout(timeout or 0)
	if data and method == "POST" then
		request:addRequestHeader("Content-Type:application/json;charset=utf-8")
		request:setPOSTData(encode(data))
	end
	request:start()
end

--向服务器请求下载
function HotUpdate:checkCallback(event)
	local request = event.request
	if event.name == "completed" then
		local data = json.decode(decode(request:getResponseData()))
		self:downloadBegin(data)
	elseif event.name == "failed" then
		self:onError(request:getErrorCode(),request:getErrorMessage())
	end
end

function HotUpdate:onError(code,message)
	self.callback({name = "fail",code = code,message = message})
end

--下载中
function HotUpdate:downloading(event)
	local request = event.request
	print(string.format("name:%s,%s    ",event.name,self.curfile))
	if event.name == "completed" then
		-- self.cfg.callback("progress",self.size) --进度
		self:localWriteRes(self.curfile,decode(request:getResponseData()))
		self:downloadFinish()
	elseif event.name == 'progress' then
		self.loadsize = event["dltotal"]
		-- self.cfg.callback("progress",self.loadsize) --进度
		self.callback("progress")
		print(self.loadsize)
	elseif event.name == "failed" then
		self:onError(request:getErrorCode(),request:getErrorMessage())
	end
end

function HotUpdate:localWriteRes(resName, resData)
	
    local fullpath = OUTPATH .. resName
    local maxLength = string.len(fullpath)
    local index1,index2 = string.find(fullpath,'/',string.len(device.writablePath)+1)
    
    while index1 do
        local dirname = string.sub(fullpath,1,index2)
        index1,index2 = string.find(fullpath,'/',index2+1)
        if not (cc.FileUtils:getInstance():isDirectoryExist(dirname)) then        
            cc.FileUtils:getInstance():createDirectory(dirname)  
        end
    end
   
    local fp = io.open(fullpath, 'w')
    if fp then
        fp:write(resData)
        io.close(fp)
    else
        print('downloadRes write error!!')
    end
end

function HotUpdate:down(name)
	self.curfile = name
	self:request(URL .. "download/" .. name,handler(self,self.downloading),"GET",nil,15)
	-- print("load file:",name)
end

--开始下载
function HotUpdate:downloadBegin(info)
	local code = info["code"]
	if code == 1 then
		local data = json.decode(info["files"])
		self.all_file_info = data
		self.all_file_name = table.keys(data)
		self:down(self.all_file_name[1])
	else
		self.callback({name = "success",type = 0})
	end
end

--下载成功
function HotUpdate:downloadFinish()
	table.removebyvalue(self.all_file_name,self.curfile)
	if #self.all_file_name > 0 then
		self:down(self.all_file_name[1])
	else
		self.callback({name = "success",type = 1})
	end
end
return HotUpdate