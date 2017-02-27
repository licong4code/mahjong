 --[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 15/12/08.
//
//	下载
]]

local URL = "http://dlc.ugmars.com:8888/gamedlc/controller"
local DL_URL = "http://dlc.ugmars.com:8888/gamedlc/d/"
local OUTPATH = device.writablePath

local DownLoad = class("DownLoad")

--[[
callback    --下载回调
url    		--下载地址
module 		--模块名称(string)
]]
function DownLoad:ctor(cfg)
	self.cfg 	  = cfg
	self.loadsize = 0 --已下载数据大小
	-- self:request(URL..cfg.url,handler(self,self.checkCallback),"GET")
	local data = {}
	-- data["queryDlc"] = {game = "hl",version = "1.1"}
	self:request(URL,handler(self,self.checkCallback),"POST","{\"queryDlc\":{\"game\":\"hl\",\"version\":\"1.1\"}}",15)
end

--网络请求
function DownLoad:request(url,callback,method,data,timeout)
	local request = network.createHTTPRequest(callback,url,method)
	request:setTimeout(timeout or 0)
	if data then
		request:addRequestHeader("Content-Type:application/json;charset=utf-8")
		request:setPOSTData(data)
	end
	request:start()
end

--向服务器请求下载
function DownLoad:checkCallback(event)
	if event.name == "completed" then
		-- print (event.request:getResponseData())
		local data = json.decode(event.request:getResponseData())
		self:downloadBegin(data)
	elseif event.name == "failed" then
		self.cfg.callback("failed","code:"..event.request:getErrorCode()..",err:"..event.request:getErrorMessage())
	end
end

--下载中
function DownLoad:downloading(event)
	local request = event.request
	if event.name == "completed" then
		self.cfg.callback("progress",self.size) --进度
		self:writeData(request:getResponseData())
		self:downloadFinish()
	elseif event.name == 'progress' then
		self.loadsize = event["dltotal"]
		self.cfg.callback("progress",self.loadsize) --进度
	elseif event.name == "failed" then
		self.cfg.callback("failed","code:"..request:getErrorCode()..",err:"..request:getErrorMessage())
	end
end

--写入数据
function DownLoad:writeData(data)
	local size = string.len(data)
	if size > 0 then
		self.filehandle:write(data)
	end
end

--开始下载
function DownLoad:downloadBegin(info)
	local code = info["code"]
	if code == 1 then
		local data = info["queryDlcResponse"]
		self.size  = data["fileSize"]
		self.name  = data["dlcFile"]
		self.md5   = data["md5"]
		self.unzip = true
		-- self.unzip = info["unzip"] --是否需要解压
		
		local start = function()
			self.filehandle = io.open(OUTPATH..self.name,'wb')
			self.cfg.callback("downloadbegin",self.size)
			self:request(DL_URL..self.name,handler(self,self.downloading),"GET")
		end
		local function bit2M(size)
			return size/(1024*1024)
		end
		self.cfg.callback("askfor",{start = start,size = bit2M(self.size),md5 = self.md5})
	end
end

--下载成功
function DownLoad:downloadFinish()
	if self.filehandle then self.filehandle:close() end

	if self:verification() then
		if self.unzip then
			self:uncompress()
		else
			self.cfg.callback("success",self.name.." download success!")
		end
	else
		self.cfg.callback("failed",self.name.." verification failed")
	end
end

--校验下载是否成功
function DownLoad:verification()
	return crypto.md5file(OUTPATH..self.name,false) == self.md5
end

function DownLoad:uncompress()
	local zipfilepath =  OUTPATH..self.name --待解压文件
	local outpath = OUTPATH..self.cfg.module.."/"
	if cc.FileUtils:getInstance():isDirectoryExist(outpath) then --删除之前存在的文件夹
		cc.FileUtils:getInstance():removeDirectory(outpath)
	end
	self.cfg.callback("unzipbegin")

	cc.uncompress(zipfilepath,OUTPATH,function( event )
			-- print(event.state)
			if event.state == 'begin' then --开始解压
				-- do something
			elseif event.state == 'end' then --解压完成
				cc.FileUtils:getInstance():removeFile(zipfilepath)
				self.cfg.callback("success",self.name.." download success!")
			elseif event.state == 'progress' then --解压中
			end

		end)
end

return DownLoad