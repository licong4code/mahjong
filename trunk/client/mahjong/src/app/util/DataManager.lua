--[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 2015/07/10.
//
//  数据中心
]]

DataManager = {}
DataManager.enemy_data_node = nil

--[[
	--怪物id
]]
function DataManager.getEnemyAttr(id)
	return CfgMgr.getEnemyInfo()[tostring(id)]
end

--根据模型id获得属性
function DataManager.getEnemyAttrByModelId(id)
	for k,v in pairs(CfgMgr.getEnemyInfo()) do
		if v.id == id then
			return v.attr
		end
	end
end

--模型id
function DataManager.getEnemySkill(id)
	for k,v in pairs(CfgMgr.getEnemyInfo()) do
		if v.id == id then
			return v.skill
		end
	end
end

--怪物id
function DataManager.getEnemyName(id)
	for k,v in pairs(CfgMgr.getEnemyInfo()) do
		if v.id == id then
			return v.name
		end
	end
end

--节点数据
function DataManager.getEnemyNode(id)
	if CfgMgr.getEnemyNodeInfo()[tostring(id)] then
		return CfgMgr.getEnemyNodeInfo()[tostring(id)].data
	end
	return nil
end

function DataManager.getMissionData(main,sub)
    local cfg = CfgMgr.getScene(main,sub)
	if cfg["enemy"] then
   		return cfg["enemy"]["data"]
   	end
	return {}
end

--根据怪物id获得模型id
function DataManager.getEnemyModelId(enemyID)
	local attr = DataManager.getEnemyAttr(enemyID)
	if attr then
		return attr.id
	end
	return nil
end

--不重复插入
local function no_repeat_insert(dst,src)
	local enable = true
	for k,v in pairs(dst or {}) do
		if v == src then
			enable = false
			break
		end
	end
	if enable then
		table.insert(dst,src)
	end
end

--根据节点id获得模型id
local function getAllEnemys(nodeID)
	local ids = {}
	local data = DataManager.getEnemyNode(nodeID)
	if data then
    	for i=1,#data do
		    for j=1,#data[i] do
				local id  = DataManager.getEnemyModelId(data[i][j].id)
				no_repeat_insert(ids,id)
			end
   		end 
	end
	return ids
end

--本关卡内将会出现的怪物id
--返回模型id
-- key模型id,
-- nodeid 节点id
--[key] = {nodeid}
function DataManager.getEnemysIdInMission(main,sub)
	if main == 0 and sub == 0 then
		return {}
	end

	local nodes = DataManager.getEnemys(main,sub)
	local data = CfgMgr.getEnemyInfo()
	local ids = {}
	for i=1, #nodes do
		local id = data[tostring(nodes[i])].id
		local modelid = tostring(id)
		ids[modelid] = tostring(nodes[i])
	end
	return ids
end

--获得当前关卡boss
--返回怪物id
function DataManager.getMissionBoss(main,sub)
	-- local data = DataManager.getMissionData(main,sub)
	local ids = DataManager.getEnemys(main,sub or 6)
	local data = CfgMgr.getEnemyInfo()

	for k,v in pairs(ids) do
		local id = tostring(v)
		if data[id].type == 3 then
			return id
		end
	end
	return nil
end

--是否为boss
function DataManager.isBoss(enemyId)
	for k,v in pairs(CfgMgr.getEnemyInfo()) do
		if v.id == enemyId then
			return (v.type or 1) == 3
		end
	end
	return false
end

function DataManager.init()
	DataManager.enemy_data_node = CfgMgr.getEnemyNodeInfo()
end

--获得当前关卡的所有怪物id
function DataManager.getEnemys(main,sub)
	local cfg = CfgMgr.getScene(main,sub)

	if cfg == nil then return {} end
	local data = {}
	if cfg["enemy"] and cfg["enemy"]["data"] then
		data = cfg["enemy"]["data"]
	end	
	if CfgMgr.getStage()[main.."0"..sub] == nil then return {} end
	local npc = {} --所有npc触发怪节点id,包括开始对话、触碰对话
	
	local did = CfgMgr.getStage()[main.."0"..sub].bdlg 	--获得当前关卡开场对话id
	if did then table.insert(npc, did) end

	for k,v in pairs(cfg.npc or {}) do --碰撞触发对话时，刷出的怪
		table.insert(npc, v.id)
	end

	local ids = {}
	for i=1, #data do
		local pre = data[i].children
		local item = data[i].item
		local nodeid = data[i].id
		if item then
			for k = 1,#item do
				no_repeat_insert(ids,item[k].id)
			end

		elseif pre then
			for k = 1,#pre do
				local children = pre[k]
				for m = 1,#children do
					no_repeat_insert(ids,children[m].id)
				end
			end
		end
		
		if nodeid then
			DataManager.getEnemysByNodeId(ids,nodeid)
		end
	end

	for i=1,#npc do
		local npcdata = CfgMgr.getSession(npc[i])
		if npcdata then
			DataManager.getEnemysByNodeId(ids,tostring(npcdata.enemy))
		end
	end
	return ids
end

function DataManager.getEnemysByNodeId(arr,id)
	if id == nil then return end
	local nodedata = DataManager.getEnemyNode(id) or {}
    for m=1,#nodedata do
	    for n=1,#nodedata[m] do
			no_repeat_insert(arr,nodedata[m][n].id)
		end
   	end 
end

--获得所有boss
function DataManager.getAllBoss()
	local ids = {}
	local data = CfgMgr.getEnemyInfo()
	for k,v in pairs(data) do
		if v.type == 3 then
			table.sort(ids,k)
		end
	end
	return ids
end