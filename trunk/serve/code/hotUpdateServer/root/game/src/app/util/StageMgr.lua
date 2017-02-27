--
-- Author: Alex
-- Date: 2015-05-12 17:10:37
--
StageMgr = {}

--大关卡 status 0 未解锁 1 解锁
--小关卡 status -1 无此关卡 0 未解锁 1 已解锁 3 已通过

--[[
current --当前玩的关卡
newest  --玩到的最新关卡
"1":{ -- 大关卡信息
	status = 
}

"101":{ --每个关卡信息
	status = 0 未解锁 1已解锁 2 已过关
	star --（int）星级
}
]]

local stage = nil

function StageMgr.init()
	if GlobalData.stage == nil then 
		GlobalData.stage = {} 
		GlobalData.stage["101"] = {status = 1,star = 0}
		GlobalData.stage["1"] = {status = 1}
	end

	stage = GlobalData.stage
end

function StageMgr.getStage(main)
	return GlobalData.Stage[main]
end


--0 未解锁 1 已解锁 2 已打开
function StageMgr.setMysteryShopStatus(main,status)
	local s = StageMgr.getStage(main)
	if s then
		s["mysteryShopStatus"] = status or 0
	end
	GameDataMgr.save()
end

--[[
强制返回正常模式下的最新关卡（主角选关界面说话有关）
]]
function StageMgr.getNewestStage(isforcenormal)
	if GameDataMgr.getGameMode() == 1 or isforcenormal then
		return stage["newest"] or 101
	else
		return stage["hardnewest"] or 1101
	end
end

--是否为最新关卡
function StageMgr.isNewest(main,sub)
	if GameDataMgr.getGameMode() == 1 then
		return stage["newest"] == main*100+sub
	else
		return stage["hardnewest"] == (10+main)*100+sub
	end
end

--获得当前在玩的关卡
function StageMgr.getCurrent()
	local current = stage["current"] or 101
	return math.floor(current/100),current%100
end

--设置当前在在玩关卡
function StageMgr.setCurrent(main,sub)
	if main and sub then
		stage["current"] = main*100+sub
	end
end

--主关卡是否解锁
function StageMgr.isMainLock(main)
	if GlobalData.stage[tostring(main)] then return GlobalData.stage[tostring(main)]["status"] == 0 end
	return true
end

--获得解锁大关卡数
function StageMgr.getMainsUnlock()
	local count = 0
	for i = 1, StageMgr.getMainTotal() do
		if StageMgr.isMainLock(i) then
			break
		end
		count = count + 1
	end
	return count
end

--解锁主关卡
function StageMgr.setMainUnlock(main)
	GlobalData.stage[tostring(main)] = {status = 1 }
end

--小关卡
function StageMgr.setSubUnLock( main,sub )
	GlobalData.stage[main.."0"..sub] = {status = 1}
	if GameDataMgr.getGameMode() == 1 and main <=8 then --大于10时则是困难模式
		stage["newest"] = main*100 + sub --当前最新关卡
	else
		stage["hardnewest"] = main*100 + sub --当前最新关卡
	end

	if stage["newest"] == 201 or stage["newest"]  == 301 then --通过第一二大关，可以弹出评论
		GameDataMgr.setCanPopupComment(true)
	end
end

function StageMgr.isSubLock(main,sub)
	if GlobalData.stage[main.."0"..sub] then return GlobalData.stage[main.."0"..sub]["status"] == 0 end
	return true
end

--获得大关卡数
function StageMgr.getMainTotal()
	return 8
end

--解锁下一关、返回true表示第一次玩
function StageMgr.unLockNext(main,sub)
	if StageMgr.getNewestStage() % 10 > 6 and GameDataMgr.getGameMode() == 2 then --修复老版本bug
		stage["hardnewest"] = math.floor(StageMgr.getNewestStage() / 100) * 100 + 6
	end

	if (StageMgr.getNewestStage() == main*100 + sub) then
		local data = CfgMgr.getWeapon()
		if stage[main.."0"..sub] == nil then return false end
		if stage[main.."0"..sub]["status"] ~= 2 then
			for k,v in pairs(data) do
				if v["getway"] == 2 and (main*100+sub) == v["unlock_lv"] then
				
					DataEye.event(k.."_unlock")
					GameDataMgr.setEquipMark(k)
					if v["type"] == 2 then 
						GameDataMgr.setEquipClothesMark(true)
					end
				end
			end
		end
		if main*100 + sub == 306 then --解锁千幻塔
			GameDataMgr.setTowerRemindStatus(true)
		end
		
		if main*100 + sub == 506 then --解锁武道会
			GameDataMgr.setJJCRemindStatus(true)
		end

		stage[main.."0"..sub]["status"] = 2 --已过关
		sub = sub + 1
		if sub > 6 then
			sub = 1 
			if GameDataMgr.getGameMode() == 1 then
				main = math.min(8,main+1)
			else
				main = 10 + math.min(18,main-10+1)
			end
			StageMgr.setMainUnlock(main)
		end

		StageMgr.setSubUnLock(main,sub)

		return true
	end
	return false
end

function StageMgr.getSubStatus(main,sub)
	if stage[main.."0"..sub] then
		return stage[main.."0"..sub]["status"]
	end
	return 0
end

----记录闯关起始点
function StageMgr.setStartNum(main,sub)
	StageMgr.start = main*100+sub
end

function StageMgr.getStartNum()
	return StageMgr.start or 101
end

--上次玩的大关卡
function StageMgr.setLastMainNum(main)
	stage["last"] = main
end

function StageMgr.getLastMainNum()
	return stage["last"] or 1
end

--获得解锁困难模式大关卡数
function StageMgr.getHardModeUnlockNum()
	if DEBUG_USER then 
		return 8
	end
	local total = 0
	for i=1,8 do
		if StageMgr.isSubLock(10+i,1) then
			break
		else
			total = total + 1
		end
	end
	return total
end
return StageMgr