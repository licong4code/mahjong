


local MainScene = class("MainScene",require("app.scenes.BaseScene"))

function MainScene:ctor()
	MainScene.super.ctor(self)
	require("app.layer.HomeLayer").new():addTo(self)
end

-- function MainScene:onEnter()
-- 	EventMgr.registerAll(self)
-- 	globalSock:connect()
-- end

-- function MainScene:onExit()
-- 	EventMgr.removeAllEvent()
-- end

-- function MainScene:connectSuccess()
	
-- end

-- function MainScene:createGameLayer( )
-- 	self.gamelayer = require("app.layer.GameLayer").new(data):addTo(self,10)
-- 	self.homeLayer:removeFromParent()
-- end

-- function MainScene:onDissolveSuccess()
-- 	self.gamelayer:removeFromParent()
-- 	self:connectSuccess()
-- end
return MainScene
