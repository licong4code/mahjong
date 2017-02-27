--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 2016/03/24.
//
//  排行榜数据中心
]]

local LeaderBoardUtil = {}

--获得要上传数据
function LeaderBoardUtil.getUploadData()
    local data = {}
    local uuid = Util.getUUID()
    do  --武器
        local life,damage,defense,crit,attr = GameDataMgr.getEquipAttr(GameDataMgr.getFirstWeaponId()) --获得当前武器属性
        table.insert(data,{gid = Util.getAppId(),uid = uuid, platform = device.platform,rankName = "sword",isMore = true,score = math.floor(GameDataMgr.getCurWeaponFight()),propid = GameDataMgr.getCurWeaponName(),gj = damage,bj = crit})
    end
    do --衣服       
        local life,damage,defense,crit,attr = GameDataMgr.getEquipAttr(GameDataMgr.getCurClothes()) --获得当前衣服属性
        -- 真实气血=气血/（1-0.01*防御/（0.01*防御+1））
        local realvalue = life/(1-0.01*defense/(0.01*defense+1))
        table.insert(data,{gid = Util.getAppId(),uid = uuid,platform = device.platform,rankName = "clothes",isMore = true,score = math.floor(realvalue),propid = GameDataMgr.getCurClothesName(),qx = life,fy = defense})
    end

    do --淬炼次数
        local cid = GameDataMgr.getCurClothes()
        local wid = GameDataMgr.getFirstWeaponId()
        local ccl = GameDataMgr.getWeaponCLInfo(cid)
        local wcl = GameDataMgr.getWeaponCLInfo(wid)
       table.insert(data,{gid = Util.getAppId(),uid = uuid, platform = device.platform,rankName = "cl",isMore = false,score = ccl["count"],propid = CfgMgr.getWeapon()[cid]["name"]}) --衣服
       table.insert(data,{gid = Util.getAppId(),uid = uuid, platform = device.platform,rankName = "cl",isMore = false,score = wcl["count"],propid = CfgMgr.getWeapon()[wid]["name"]}) --武器
    end

    do --比武
        table.insert(data,{gid = Util.getAppId(),uid = uuid, platform = device.platform,rankName = "jjc",isMore = false,score = GameDataMgr.getJJCTopDamage()})
    end

    do --挑战
        table.insert(data,{gid = Util.getAppId(),uid = uuid, platform = device.platform,rankName = "tower",isMore = false,score = (GameDataMgr.getTowerTopHistory() or 0)})
    end

    do --成就
        local count = GameDataMgr.getAchievementCompleteCount()
        table.insert(data,{gid = Util.getAppId(),uid = uuid, platform = device.platform,rankName = "achieve",isMore = false,score = count})
    end
    return data
end

--[[上传排行榜数据
callback (code,event)
code: ok or error --网络请求结果
event 请求成功是返回{
	code = 0上传失败 1上传成功
}
]]
function LeaderBoardUtil.applyUpload(callback)
    local data = LeaderBoardUtil.getUploadData()
    local requestcallback = function (event) 
        if event.name == "completed" then
            local responsedata = json.decode(event.request:getResponseData())
            if callback then callback("ok",{code = responsedata["addRankDataRes"]["isAdd"] == true and 1 or 0}) end
        elseif event.name == "failed" then
			if callback then callback("error",event.request:getErrorMessage()) end
        end
    end
    Util.requestHttp(Util.getLeadBoardURL(),requestcallback,"POST",json.encode({addRankData = {dataArray = data}}))
end

function LeaderBoardUtil.applyDownload()
end

--[[检测玩家是否已经注册
callback (code,event)
code: ok or error --网络请求结果
event 请求成功是返回{
	code = -1服务器未知错误 0未注册 1已注册
	nickname 昵称
}
]]
function LeaderBoardUtil.checkRegister(callback)	
    local data = { selectUser = {gid = Util.getAppId(),uid = Util.getUUID(), platform = device.platform}}
    local requestcallback = function(event)
        if event.name == "completed" then
            local responsedata = json.decode(event.request:getResponseData())
            if responsedata["selectUserRes"]["code"] == 1 then
                if responsedata["selectUserRes"]["isAdd"] == false then --未注册
                    if callback then callback("ok",{code = 0}) end
                else --已经注册
                    if callback then callback("ok",{code = 1,nickname = responsedata["selectUserRes"]["userName"]}) end
                end
            else
               if callback then callback("ok",{code = -1}) end
            end
            
        elseif event.name == "failed" then
            if callback then callback("error",event.request:getErrorMessage()) end
        end
    end
    Util.requestHttp(Util.getLeadBoardURL(),requestcallback,"POST",json.encode(data))
end

return LeaderBoardUtil