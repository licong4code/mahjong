--
-- Author: Alex
-- Date: 2015-05-05 14:37:45
--
local UIUtil = {}
local scheduler = require("framework.scheduler")

function UIUtil.bindWidgetByAlias(sf,target,name,alias)
	sf[alias] = sf[target]:getChildByName(name)
	return sf[alias]
end

function UIUtil.bindWidget(target,name)
    target[name] = target.rootNode:getChildByName(name)
    return target[name]
end

function UIUtil.bindTouchEvent(target,name)
	local t = UIUtil.bindWidget(target,name)
	t:addTouchEventListener(handler(target, target['on'..name..'touched']))
	return t
end

function UIUtil.parseAttr(info)
    local attrs = {}
    if info["gj"] > 0 then
        table.insert(attrs,{name="伤害",val=info["gj"]})
    end
    if info["fx"] > 0 then
        table.insert(attrs,{name="防御",val=info["fx"]})
    end
    if info["bj"] > 0 then
        table.insert(attrs,{name="暴击",val=info["bj"]})
    end
    if info["qx"] > 0 then
        table.insert(attrs,{name="生命",val=info["qx"]})
    end
    return attrs
end

--滚动Label
function UIUtil.rollLabel(target,to,time,onFinished)
    if target == nil then return end
    local t = 0

    local removeFromParent_ = target.removeFromParent
    target.removeFromParent = function()
        if target.actionHandle then scheduler.unscheduleGlobal(target.actionHandle) end
        removeFromParent_(target)
        --print('~~~~~~remove')
    end

    time = time or 0.5
    if target.actionHandle then scheduler.unscheduleGlobal(target.actionHandle) end
    local from = checknumber(target:getString())
    target.actionHandle = scheduler.scheduleGlobal(function(dt)
        t = t + dt 
        target:setString(from + checkint((to - from)*math.min(1,t/math.max(time,0.00000001))))
        if t >= time and target.actionHandle then
            scheduler.unscheduleGlobal(target.actionHandle)
            target.actionHandle = nil
            if onFinished then onFinished() end 
        end
    end, 1/60)
end

--进度条动画
function UIUtil.progressTo(target,time,to,onFinished)
    if target == nil then return end
	local t = 0

    local removeFromParent_ = target.removeFromParent
    target.removeFromParent = function()
        if target.actionHandle then scheduler.unscheduleGlobal(target.actionHandle) end
        removeFromParent_(target)
        --print('~~~~~~remove')
    end

	if target.actionHandle then scheduler.unscheduleGlobal(target.actionHandle) end
    local from = target:getPercent()
    target.actionHandle = scheduler.scheduleGlobal(function(dt)
        t = t + dt 
        target:setPercent(from + (to - from)*math.min(1,t/math.max(time,0.00000001)))
        if t >= time and target.actionHandle then
            scheduler.unscheduleGlobal(target.actionHandle)
            target.actionHandle = nil
            if onFinished then onFinished() end 
        end
    end, 1/60)
end

--跟踪
function UIUtil.follow(target,dest,time,onFinished)
    if target == nil then return end
    local t = 0

    local removeFromParent_ = target.removeFromParent
    target.removeFromParent = function()
        if target.actionHandle then scheduler.unscheduleGlobal(target.actionHandle) end
        removeFromParent_(target)
        --print('~~~~~~remove')
    end

    if target.actionHandle then scheduler.unscheduleGlobal(target.actionHandle) end
    local from = cc.p(target:getPositionX(),target:getPositionY())
    local d1 = 1
    local d2 = 1
    local d3 = 1
    local d4 = 1
    if math.random(1,10) <= 5 then
        d1 = -1 
    end
    if math.random(1,10) <= 5 then
        d2 = -1 
    end
    if math.random(1,10) <= 5 then
        d3 = -1 
    end
    if math.random(1,10) <= 5 then
        d4 = -1 
    end
                                        --400 600 800 -600
    c1 = cc.p(from.x+d1*(math.random(400,1000)),from.y+d2*(math.random(500,1000)))
    c2 = cc.p(from.x+d3*(math.random(600,1000)),from.y+d4*(math.random(500,1000)))

    local prePos = from

    target.actionHandle = scheduler.scheduleGlobal(function(dt)
        local tt = cc.p(dest:getPositionX(),dest:getPositionY()+dest.mHeight/2)
        local to = target:getParent():convertToNodeSpace(dest:getParent():convertToWorldSpace(tt))
        t = t + dt
        local bezier = {
        startP = from,
        controlP1 = c1,
        controlP2 = c2,
        endP = to
        }

        local r = math.min(1,t/math.max(time,0.00000001))
        local dr = 1 - r
        local pos = {}
        pos.x = bezier.startP.x*dr*dr*dr + 3*bezier.controlP1.x*r*dr*dr + 3*bezier.controlP2.x*r*r*dr + bezier.endP.x*r*r*r
        pos.y = bezier.startP.y*dr*dr*dr + 3*bezier.controlP1.y*r*dr*dr + 3*bezier.controlP2.y*r*r*dr + bezier.endP.y*r*r*r
        target:setPosition(pos)

        local deg = math.deg(-cc.pToAngleSelf(cc.pSub(pos,prePos))) - 90
        target:setRotation(deg)

        prePos = pos
        if t>=time and target.actionHandle then
            scheduler.unscheduleGlobal(target.actionHandle)
            target.actionHandle = nil
            if onFinished then onFinished() end 
        end

    end, 1/60)
end

function UIUtil.mid2Node(node1,node2,mid)
    local midX = mid:getPositionX()
    local c1 = node1:getContentSize().width
    local c2 = node2:getContentSize().width
    local c = (c1+c2)/2
    node1:setAnchorPoint(0,0.5)
    node2:setAnchorPoint(1,0.5)
    node1:setPositionX(midX-c)
    node2:setPositionX(midX+c)
end

function UIUtil.left2Node(node1,node2,p)
    local midX = p:getPositionX()
    local c1 = node1:getContentSize().width
    node1:setAnchorPoint(0,0.5)
    node2:setAnchorPoint(0,0.5)
    node1:setPositionX(midX)
    node2:setPositionX(midX+c1+2)
end

function UIUtil.toast(msg,exitCallback)
	local s = cc.Director:getInstance():getRunningScene()
    if _G.toastObj and _G.toastObj.getString and _G.toastObj:getString() == msg then return end
	_G.toastObj = require("app.item.Toast").new(msg,exitCallback):pos(display.cx,display.height*0.8):addTo(s,9999999)
    audio.playSound(AudioUtil.soundEffect[19])
end


local popAchievementList = {}
function UIUtil.pushAchievement(id)
    if id then
        local norepeat = true --是否有类型重复
        local type = CfgMgr.getAchievement()[id]["type"]
        
        for i=1,#popAchievementList do
            if CfgMgr.getAchievement()[popAchievementList[i]]["type"] == type then
                norepeat = false
                break
            end
        end
        if norepeat then
            table.insert(popAchievementList,id)
        end
    end
end

--返回true表示有成就弹出
function UIUtil.popAchievement(onFinished)
    local runningScene = display.getRunningScene()
    if runningScene then
        if #popAchievementList > 0 then
            local first = popAchievementList[1]
            table.remove(popAchievementList,1)
            local ObtainLayer = require("app.layer.ObtainLayer")
            local a = ObtainLayer.new({type = ObtainLayer.DLG_TYPE_ACHIEVE,data = first,onFinished = onFinished})
            runningScene:addChild(a,9999999)
            return true
        else
            if onFinished then
                onFinished()
            end
        end
    end
    return false
end

--创建一个用于吞噬触摸的层
function UIUtil.createSwallowTouchLayer(parent)
    local l = display.newLayer():addTo(parent)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch,event) return true end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = parent:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, l)
    return l
end

--[[
给字体加黑边
space 字体间距
width 黑边大小
color 变的颜色
]] 
function UIUtil.outline(target,space,width,color)
    target:enableOutline(color or cc.c4b(0,0,0,255),width or 2)
    local renderer = target
    if target.getVirtualRenderer then
        renderer = target:getVirtualRenderer()
    end
    renderer:setAdditionalKerning(space or 0)
    return renderer
end

--通用显示钱币和元宝
function UIUtil.addCoinMoney(target,pos)
    local moneyInfo = require("app.item.MoneyInfo").new():addTo(target)
    moneyInfo:setPosition(pos)
    return moneyInfo
end

--弹出购买体力对话框
function UIUtil.promptBuyTire(target)
    local prompt = require("app.layer.DialogSureLayer").new({
        content="体力不足，是否补满体力",
        type = "BUY_VIT",
        message={type=4100,num=100}}):addTo(target)
    return prompt
end

--弹出解锁镶嵌对话框
function UIUtil.promptUnlockXQ(target,param)
    local prompt = require("app.layer.DialogSureLayer").new({
        content="是否花费"..param.cost.."元宝解锁？",
        type = "UNLOCK_XQ",
        message={type=4100,num=param.cost,id=param.id,index=param.index},
        surefunc=param.sureFunc
        }):addTo(target)
    prompt:setLocalZOrder(1)
    return prompt
end

--弹出购买参赛次数对话框
function UIUtil.promptBuyCompetitionCount(target,param)
    local prompt = require("app.layer.DialogSureLayer").new({
        content="是否花费100元宝购买参赛次数？",
        type = "BUY_COMPETITION_COUNT",
        message={type=4100,num=100},
        surefunc=param.sureFunc
        }):addTo(target)
    prompt:setLocalZOrder(99999)
    return prompt
end

--弹出确认镶嵌对话框
function UIUtil.promptSureXQ(target,param)
    local prompt = require("app.layer.DialogSureLayer").new({
        content="镶嵌后不可取下\n是否镶嵌？",
        type = "SURE_XQ",
        surefunc=param.sureFunc,
        nofunc=param.noFunc
        }):addTo(target)
    prompt:setLocalZOrder(99999)
    return prompt
end

--弹出确认退出对话框
function UIUtil.promptExit(target)
    local func = function ( )
        cc.Director:getInstance():endToLua()
    end
    local prompt = require("app.layer.DialogSureLayer").new({
        content="是否退出游戏？",
        type = "EXIT",
        surefunc=func}):addTo(target)
    return prompt
end

--提示是否充值
function UIUtil.askCharge(chargetype,func)
    local needpoppackgift = false --是否弹出新手礼包
    if chargetype == "4100" then --统计提醒充值
        DataEye.event("remind_charge")
        needpoppackgift = GameDataMgr.isFirstBuy("42") --是否购买过新手礼包
    end
    local runningscene = display.getRunningScene()
    if not needpoppackgift then
        runningscene:addChild(require("app.layer.DialogSureLayer").new({type = "CHARGE",chargetype = chargetype,surefunc = func,content = "余额不足，是否充值？"}),999999)
    else
        if _G.giftdlg == nil then
            UIUtil.toast("元宝数量不足")
            local closeFunc = function()
                _G.giftdlg = nil
            end
            local func = function()
                local dlg = require("app.layer.GiftPackLayer").new("42",nil,closeFunc):addTo(runningscene,1000000000)
                UIUtil.dlgPopupAnimation(dlg)
            end
            _G.giftdlg = true
            Util.doNextFrame(func, 1.0)
        end
    end
end

--[[
变黑时处理回调
]]
function UIUtil.transitionFade(callback,time)
    local actionTime = 1.0 or time
    if callback == nil then
        callback = function () end
    end
    local blackLayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    UIUtil.createSwallowTouchLayer(blackLayer)
    display.getRunningScene():addChild(blackLayer,10000000)
    blackLayer:runAction(cc.Sequence:create(cc.FadeIn:create(actionTime/2),cc.CallFunc:create(callback)
    ,cc.FadeOut:create(actionTime*3/4),cc.RemoveSelf:create()))
end
--[[
显示战斗力
]]
function UIUtil.showFighting(num,isup)
    do return end
   local text = display.newTTFLabel({
        text = "战斗力 "..tostring(num),
        size = 50,
        font = "fonts/lcz-zhongwen-max.ttf"
        })
   text:setColor(isup and cc.c3b(0,255,0) or cc.c3b(255,0,0))
   text:setPosition(display.cx,display.cy)
   display.getRunningScene():addChild(text,99999)
   UIUtil.outline(text)
   text:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.Spawn:create(cc.MoveBy:create(0.6,cc.p(0,50)),cc.FadeOut:create(0.6)),cc.RemoveSelf:create()))
end

--显示饰品描述
function UIUtil.showDecDes(id,position)
    local tip = require("app.item.ItemTip").new(position):addTo(display.getRunningScene(),1000000)
    local ds = CfgMgr.getDecoration()
    local dData = ds[id]

    local bSet = GameDataMgr.getDecorationSetBelong(id)
    local curSet = CfgMgr.getDecorationSet()[bSet]
    local attrs = UIUtil.parseAttr(curSet)
    local prog = GameDataMgr.getDecortationSetProgress(bSet)*5

    local desc = display.newTTFLabel({
        text = dData["desc"],
        font = "fonts/lcz-zhongwen-max.ttf",
        size = 20,
        color = cc.c3b(255, 255, 255), 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    --dimensions = cc.size(400, 0)
    })
    desc:setDimensions(math.min(desc:getContentSize().width,200), 0)
    tip:addItem(desc)
    UIUtil.outline(desc,-2)
    desc:setLineHeight(18)
    
    local setInfoC = cc.c3b(148,148,148)
    if prog == 5 then
        setInfoC = cc.c3b(120,233,63)
    end
    local setInfo = display.newTTFLabel({
        text = curSet.name.."("..prog.."/5)",
        font = "fonts/lcz-zhongwen-max.ttf",
        size = 26,
        color = setInfoC, 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    --dimensions = cc.size(400, 0)
    })
    tip:addItem(setInfo,{vPadding=15})
    UIUtil.outline(setInfo,-2)
    setInfo:setLineHeight(28)
    
    for k,v in pairs(curSet.items) do
        local dD = ds[v]
        local c = cc.c3b(148,148,148)
        if GameDataMgr.getItem(v) > 0 then
            if v ~= id then
                c = cc.c3b(120,233,63)
            else
                c = cc.c3b(255,102,0)
            end
        end
        local d1 = display.newTTFLabel({
            text = dD["name"],
            font = "fonts/lcz-zhongwen-max.ttf",
            size = 20,
            color = c, 
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
        --dimensions = cc.size(400, 0)
        })
        tip:addItem(d1)
        UIUtil.outline(d1,-2)
        d1:setLineHeight(18)
    end
    
    local setAttr = display.newTTFLabel({
        text = "套装属性",
        font = "fonts/lcz-zhongwen-max.ttf",
        size = 26,
        color = cc.c3b(255, 255, 255), 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    --dimensions = cc.size(400, 0)
    })
    tip:addItem(setAttr,{vPadding=15})
    UIUtil.outline(setAttr,-2)
    setAttr:setLineHeight(28)
    

    for k,v in pairs(attrs) do
        local attr = display.newTTFLabel({
            text = v.name.."+"..v.val,
            font = "fonts/lcz-zhongwen-max.ttf",
            size = 20,
            color = setInfoC, 
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
        --dimensions = cc.size(400, 0)
        })
        tip:addItem(attr)
        UIUtil.outline(attr,-2)
        attr:setLineHeight(18)
    end
    
    local setEffect = display.newTTFLabel({
        text = "套装效果",
        font = "fonts/lcz-zhongwen-max.ttf",
        size = 26,
        color = cc.c3b(255, 255, 255), 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    --dimensions = cc.size(400, 0)
    })
    tip:addItem(setEffect,{vPadding=15})
    UIUtil.outline(setEffect,-2)
    setEffect:setLineHeight(28)
    
    local e1 = display.newTTFLabel({
        text = curSet["desc"],
        font = "fonts/lcz-zhongwen-max.ttf",
        size = 20,
        color = setInfoC, 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    --dimensions = cc.size(400, 0)
    })
    e1:setDimensions(math.min(desc:getContentSize().width,200), 0)
    tip:addItem(e1)
    UIUtil.outline(e1,-2)
    e1:setLineHeight(18)

    tip:doLayout()

    return tip
end

--获得千幻塔奖励物节点
function UIUtil.getTowerRewardNode()
    -- local layer = cc.LayerColor:create(cc.c4b(100,0,0,255))
    local layer = cc.Layer:create()
    local rewards = GameDataMgr.getTowerReward()
    local count = #(rewards)
    local width = 0
    local distance = 10
    local scale = 0.8
    layer:setAnchorPoint(cc.p(0.5,0))
    layer:ignoreAnchorPointForPosition(false)
    local size = cc.size(10,10)
    for i=1,count do
        local item = require("app.item.IconItem").new(rewards[i]["id"],rewards[i]["num"]):addTo(layer)
        size = item:getContentSize()
        item:scaleChildren(scale)
        item:setPositionX(scale*size.width/2 + (scale*size.width+distance)*(i-1))
    end
    width = count*size.width*scale + (count-1)*distance
    layer:setContentSize(cc.size(width,size.height))
    return layer
end

--弹框动画
function UIUtil.dlgPopupAnimation( target )
    target:setScale(0)
    target:setAnchorPoint(cc.p(0.5,0.5))
    target:ignoreAnchorPointForPosition(false)
    target:setPosition(display.cx,display.cy)
    target:runAction(cc.EaseSineOut:create(cc.ScaleTo:create(0.3,1.0)))
end

--[[体力消耗
-- ture则表示体力充足
]]
function UIUtil.consumeVit()
    if not GameDataMgr.consumeVit(6) then
        UIUtil.promptBuyTire(display.getRunningScene()):zorder(10000)
        return false
    else
        UIUtil.toast("消耗体力 6")
    end
    return true
end

function UIUtil.addMark(node,position)
    local time = 1.0
    local t = display.newSprite("ui/main/lcz-tishihongdian.png"):addTo(node)
    t:setPosition(position)
    t:setTag(1)
    local func = function()
        t:runAction(Util.JumpPrompt())
    end
    t:runAction(cc.Sequence:create(cc.DelayTime:create(math.random()),cc.CallFunc:create(func)))
    return t
end
--全屏大剑动画
function UIUtil.showBigSwordAnimation()
    local black = cc.LayerColor:create(cc.c4b(0,0,0,255)):addTo(display.getRunningScene(),10)
    local lastqte = display.newSprite("#lggtedao01.png"):addTo(display.getRunningScene(),10):pos(display.cx,display.cy)
    local lastqteani = display.newAnimate("lggtedao%02d.png", 1, 10, 0.05, false)
    lastqte:setScale(3)
    lastqte:runAction(cc.Sequence:create(lastqteani,cc.RemoveSelf:create()))
    black:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.FadeOut:create(0.1),cc.RemoveSelf:create()))
end
--[[
id 模型id
]]
function UIUtil.createEnemyIcon(id)
    local bg = display.newSprite("ui/main/lcz-anniu-hei-1.png")
    local icon = display.newSprite("icons/"..id..".png"):addTo(bg):pos(bg:getContentSize().width/2,bg:getContentSize().height/2)
    return bg
end
    --竖方向文字
function UIUtil.addVerticalText(target,pos,cfg)
    local VText = require("app.util.VText")
    local text = VText.new({content = cfg["text"],
                gap = cfg["gap"],
                fontsize = cfg["fontsize"],
                fontname = "fonts/lcz-zhongwen-max.ttf",
                direction = VText.RIGHT_TO_LEFT,
                color = cfg["color"],
                framesize = cfg["framesize"]})
    text:setPosition(pos)
    target:addChild(text)
end
return UIUtil