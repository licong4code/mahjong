--[[
//
//  Created by licong on 2016/12/28.
//
//
]]

local UpdateScene = class("UpdateScene", require("app.scenes.BaseScene"))

function UpdateScene:onEnter()


	local callback = function(event)
		if event["name"] == "success" then
			
			if event["type"] == 1 then --重新加载模块
				-- print("update success")
				-- 判断系统位数
				local bit,result = os.execute("getconf LONG_BIT")
				if bit ~= 64 or device.platform == "ios" then
					bit = 32
				end
		        cc.LuaLoadChunksFromZIP("framework"..bit..".zip");
			    cc.LuaLoadChunksFromZIP("game"..bit..".zip");
				for name,v in pairs(package.loaded) do 
					-- if string.find(name,"app.") or string.find(name,"cocos.") or string.find(name,"framework.") then
					if string.find(name,"app.") then
						package.loaded[name] = nil
						require(name)
					end
				end

				MessageBox.new({button = {{name = "OK"}},text = require("app.version")})
			end
			display.replaceScene(require("app.scenes.MainScene").new())

		else
			display.replaceScene(require("app.scenes.MainScene").new())
		end
	end
   local hot = require("app.util.HotUpdate").new(callback)
end

return UpdateScene
