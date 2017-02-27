--
-- Author: Alex
-- Date: 2015-05-11 15:28:55
--
EVENT_KEY_TIRE = 'EVENT_KEY_TIRE'
GB_EVENT_GAME_WIN = 'GB_EVENT_GAME_WIN'
GB_EVENT_GAME_LOSE = 'GB_EVENT_GAME_LOSE'
GB_EVENT_BATTLE_START = 'GB_EVENT_BATTLE_START'
GB_EVENT_LIFE_GAS_QTE_FINISHED = 'GB_EVENT_LIFE_GAS_QTE_FINISHED'
GB_EVENT_ON_BUY_BEGIN = "ON_BUY_BEGIN"
GB_EVENT_ON_BUY_END = "ON_BUY_END"
GB_EVENT_ON_BUY_SUCCESS = "ON_BUY_SUCCESS"
GB_EVENT_ON_BUY_FAIL = "ON_BUY_FAIL"

local swallowlayer = nil

function onAdsVideoComplete()

	local reward = SDKUmeng.getPlayVideoReward()
	local extra = SDKUmeng.getPlayVideoExtraReward()
	local text = "" --额外信息
	GameDataMgr.addPlayVideoTimes()
	if GameDataMgr.getPlayVideoTimes() >= SDKUmeng.getPlayVideoExtraTimes() and extra > 0 then--达到额外奖励次数
		GameDataMgr.clearPlayVideoTimes()
		reward = reward + extra
		text = "(额外奖励"..extra.."元宝)"
	end
	
	GameDataMgr.countAchievementByType("33")
	-- 观看视频任务
	GameDataMgr.recordDailyTask("7009001")
	
	GameDataMgr.addMoney(reward)
	DataEye.coinGain(reward,"元宝",GameDataMgr.getMoney(),"观看视频")
	local okfunc = function(event)
		if event["buttonIndex"] == 1 then --ok
			UIUtil.popAchievement()
		end
	end
	device.showAlert("温馨提示","恭喜您获得"..reward.."元宝"..text,"OK",okfunc)

	--更新UI
	Notification.postNotification("UPDATE_CURRENCY")
end

function onAdsVideoOpen()
	audio.pauseMusic()
end

function onAdsVideoClose()
	audio.resumeMusic()
end

local paycode = {
	{code = "com.xianyu.hanren.600yb", itemid = "28"},
	{code = "com.xianyu.hanren.3000yb", itemid = "29"},
	{code = "com.xianyu.hanren.9800yb", itemid = "30"},
	{code = "com.xianyu.hanren.19800yb", itemid = "31"},
	{code = "com.xianyu.hanren.32800yb", itemid = "32"},

	{code = "com.xianyu.hanren.xslb", itemid = "42"}, --新手礼包
	{code = "com.xianyu.hanren.szlb", itemid = "43"}, --神装礼包
	{code = "com.xianyu.hanren.viplb", itemid = "44"},--VIP大礼包
	{code = "com.xianyu.hanren.cjlb", itemid = "45"}, --超级礼包
}
--根据商品id获得支付码
function getPayCodeByItemId(itemid)
	for i = 1, #paycode do
		if paycode[i]["itemid"] == itemid then
			return paycode[i]["code"]
		end
	end
end

function getItemIdByPayCode(code)
	for i = 1, #paycode do
		if paycode[i]["code"] == code then
			return paycode[i]["itemid"]
		end
	end
end

local function addSwallowLayer()

	if swallowlayer == nil then
		swallowlayer = cc.Layer:create():addTo(display.getRunningScene(),1000000000)
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(function() return true end,cc.Handler.EVENT_TOUCH_BEGAN )
		local eventDispatcher = swallowlayer:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, swallowlayer)
	end
end

local function removeSwallowLayer()
	if swallowlayer then
		swallowlayer:removeFromParent()
		swallowlayer = nil
	end
end

--开始购买
function onBuyBegin()
	-- Notification.postNotification(GB_EVENT_ON_BUY_BEGIN)
	addSwallowLayer()
end

--处理购买数据/或者恢复购买
local function deliveryItem(paycode,isbuy,isdebug)
	
	local itemid = _G.getItemIdByPayCode(paycode)
	local firstbuy = GameDataMgr.isFirstBuy(itemid)
	local isgiftpack = false
	local items,price = nil,nil
	if itemid >= "42" then
		isgiftpack = true
		items,price = GameDataMgr.getGiftPackData(itemid)
	else
		items,price = GameDataMgr.getGoodsData(itemid,true,firstbuy)
	end
	
	GameDataMgr.recordBuy(itemid)
	GameDataMgr.handleRewards(items,true)

	-- print("购买成功:"..itemid)
	Notification.postNotification("UPDATE_CURRENCY")
	Notification.postNotification(GB_EVENT_ON_BUY_SUCCESS,{data = items,id = itemid})
	--充钱成就
	GameDataMgr.setAchievementProgByType("18",GameDataMgr.getAchievementProgByType("18") + price,true)

	if isgiftpack then --礼包购买
		GameDataMgr.setAchievementProgByType("17",GameDataMgr.getAchievementProgByType("17") + 1) --礼包成就
		GameDataMgr.countAchievementByType(tostring(25 + (itemid - "42")))
		
		--购买礼包任务
		GameDataMgr.recordDailyTask("7007001")
	end
	--充值任务
	GameDataMgr.recordDailyTask("7008001")

	if isbuy and not isdebug then
		--umeng 统计
		DataEye.charge(orderid,"1",price,isgiftpack and 1 or items[1]["num"],"RMB","在线购买")
		--统计购买次数
		DataEye.event("buy_"..itemid)
	end
end

function doOnlinePay(orderid,price,desc)
	
	if DEBUG_USER then
		deliveryItem(orderid)
	else

		if device.platform == "ios" then
			luaoc.callStaticMethod("PayHelper","onBuy",{order = orderid,price = price,desc = desc})
		elseif device.platform == "android" then
			luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","applyPay",{ orderid,price ,desc},"(Ljava/lang/String;ILjava/lang/String;)V")
		else
			onBuySuccess(orderid)
		end
	end
end

--购买成功
function onBuySuccess(orderid)
	deliveryItem(orderid,true)
	removeSwallowLayer()
end

--恢复购买
function onResumeBuy(orderid)
	if GameDataMgr.isFirstBuy(_G.getItemIdByPayCode(orderid)) then
		deliveryItem(orderid,false)
	end
	removeSwallowLayer()
end

--[[购买失败
0 支付失败 1 支付取消
]]
function onBuyFail(errcode)
	-- print("购买成功:"..orderid)
	-- Notification.postNotification(GB_EVENT_ON_BUY_FAIL,errcode)
	removeSwallowLayer()
end

function onBuyEnd()
	-- Notification.postNotification(GB_EVENT_ON_BUY_END)
	removeSwallowLayer()
end

function onShareSuccess()
	local loadinglayer = require("app.layer.Loading").new():addTo(display.getRunningScene(),100)
	local verifycallback = function()
		if GameDataMgr.isUnShareToday() then
			GameDataMgr.recordShare()
			local num = SDKUmeng.getShareReward()
			GameDataMgr.handleRewards({{id = "4100",num = num}},true)
			
			GameDataMgr.countAchievementByType("34")
			UIUtil.popAchievement()
			
			Notification.postNotification("UPDATE_CURRENCY")
			Notification.postNotification("SHARE_SUCCESS")
			Notification.postNotification(GB_EVENT_ON_BUY_SUCCESS,{data = items,id = nil})
			UIUtil.toast("分享成功，恭喜获得"..num.."元宝")
		end
	end

	local callback = function(code,event)
		if code == "ok" then
			if event["code"] == 1 then
				if event["islegal"] then
					verifycallback()
				else
					device.showAlert("提示","骚年！改时间是没有用的",{"OK"})
				end
			else 
				device.showAlert("提示","未知错误",{"OK"})
			end
		else
			device.showAlert("网络错误",event,{"OK"})
		end
		loadinglayer:removeFromParent()
	end
	require("app.util.TimeUtil").checkServerTime(callback)
end

--评论成功
function onCommentSuccess()
	GameDataMgr.recordComment()
	local num = SDKUmeng.getCommentReward()
	GameDataMgr.handleRewards({{id = "4100",num = num}},true)
	-- print("购买成功:"..itemid)
	Notification.postNotification("UPDATE_CURRENCY")
	UIUtil.toast("评论成功，恭喜获得"..num.."元宝")
end

-- 内存警告
function onMemoryWarning()
	collectgarbage("collect")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end