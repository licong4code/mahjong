
require("config")
require("cocos.init")
require("framework.init")

require("app.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    if device.platform ~= "ios" and device.platform ~= "android" then
    	cc.FileUtils:getInstance():addSearchPath(device.writablePath .. "update/")
	    cc.FileUtils:getInstance():addSearchPath("res/")
	end
end

function MyApp:run()
    self:enterScene("UpdateScene")
end

return MyApp
