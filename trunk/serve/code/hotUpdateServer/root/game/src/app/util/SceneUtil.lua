--[[
2015-03-10
Copyright (c) 2014-2015 mars

场景解析工具类

]]

local spine = sp

local function move(node,cameraNode)
	node:setPosition(cc.p(node.loc[1]-cameraNode.x*node.sx,node.loc[2]-cameraNode.y*node.sy))
end

local function spriteInScreen(parent,size,position,anchor,scale)
	anchor = anchor or {0.5,0.5}
	scale = scale or {1.0,1.0}
    local pos = parent:convertToWorldSpace(cc.p(position[1],position[2]))
    local lx,rx,ty,by = ((0-anchor[1])*size.width*scale[1] + pos.x),((1-anchor[1])*size.width*scale[1] + pos.x),((1-anchor[2])*size.height*scale[2] + pos.y),((0-anchor[2])*size.height*scale[2] + pos.y)
    return (not (lx>display.size.width or rx < 0 or by > display.size.height or ty < 0))
end

--加入场景特效
function addRainEffect(parent,userdata)
	local loadFinish = function()
		local count = 14
		if userdata == "rain1" then
		    -- disp
		    for i=1,count do
			    local animate = display.newAnimate("rain%04d.png",0,5,0.1)
			    local effect = display.newSprite("#rain0000.png")
			 	local size = effect:getContentSize()
			    effect:setPosition(size.width/2+size.width*2.0*(i-1),display.cy)
			    effect:setScale(2.0)
			    effect:runAction(cc.RepeatForever:create(animate))
			    parent:addChild(effect)
		    end
		elseif userdata == "rain2" then
		    for i=1,count do
			    local animate = display.newAnimate("rain%04d.png",5,5,0.1)
			    local effect = display.newSprite("#rain0005.png")
			 	local size = effect:getContentSize()
			    effect:setPosition(size.width/2+size.width*2.0*(i-1),size.height)
			    effect:setScale(2.0)
			    effect:runAction(cc.RepeatForever:create(animate))
			    parent:addChild(effect)
		    end
		end
	end
	ResourceMgr.loadFramesAsync({{plist = "animateframes/rain.plist",texture = "animateframes/rain.pvr.ccz"}},loadFinish)
end

--更新场景
function updateScene(wrapLayer,layers,cameraNode,mapwidth)
	--print("cameraNode:",cameraNode.x,cameraNode.y)
	local previewWidth = display.width*4
	local previewHeight = display.height*2
	local previewrect = cc.rect(cameraNode.x-previewWidth,cameraNode.y-previewHeight,previewWidth*2,previewHeight*2)
	for i=1,table.maxn(layers) do
		--是否已经创建了layer
		if not layers[i].lay then
			layers[i].lay = display.newLayer():pos(layers[i].pos[1],layers[i].pos[2])
			wrapLayer:addChild(layers[i].lay, layers[i].zOrder)
			--更新位置-------begin
			if layers[i].so then-- speedOffset y 越大垂直移动速度越快 speedOffset x 越大水平移动速度越小
				layers[i].lay.sx,layers[i].lay.sy = layers[i].so[1],layers[i].so[2] 
				layers[i].lay.loc = layers[i].pos
				-- layers[i].so = nil
				-- layers[i].pos = nil
			else
				layers[i].lay.sx,layers[i].lay.sy = 1.0,1.0 
				layers[i].lay.loc = {0,0}
			end

			if layers[i].effect then --特效层
				addRainEffect(layers[i].lay,layers[i].userdata)
			end			
		end
		move(layers[i].lay,cameraNode)
		--设置当前层位置
		-- layers[i].lay:setPosition(cc.p(layers[i].pos[1]-cameraNode.x*sx,layers[i].pos[2]-cameraNode.y*sy))
		--更新位置-------end


		local layeritems = layers[i].items
		--遍历每一个layer中的item元素
		for j=1,table.maxn(layeritems) do
			local item  = layeritems[j]
			if cc.rectContainsPoint(previewrect, cc.p((item.pos[1]),(item.pos[2]))) then
				--在预加载区域内
				--print("add sp",item.src)
				if item.children then
				--item中包含子节点
					if not item.newNode then
						item.newNode = display.newNode():pos(item.pos[1], item.pos[2]):zorder(item.zOrder)
						for k = 1,table.maxn(item.children) do
							if item.children[k].animTag == 'leafshake' then
								--抖动的树叶子
								item.children[k].child = require("app.border.LeafShake").new(item.children[k])
							else
								item.children[k].child = display.newFilteredSprite('map/'..item.children[k].src):pos(item.children[k].pos[1],item.children[k].pos[2])
						
								-- item.children[k].child = display.newFilteredSprite('#'..item.children[k].src):pos(item.children[k].pos[1],item.children[k].pos[2])
							end
							item.children[k].child:setScale(item.children[k].scale[1],item.children[k].scale[2])
							item.children[k].child:setAnchorPoint(item.children[k].anchor[1],item.children[k].anchor[2])
							item.newNode:addChild(item.children[k].child)
						end
						layers[i].lay:addChild(item.newNode)
					end	
				else
					if not item.sp then
						local scene_animate_cfg = nil
						if item.id then
							scene_animate_cfg = CfgMgr.getSceneAnimate(item.id)
						end
						local sp
						if scene_animate_cfg then --是否有对应特效配置，暂时只针对spine动画
							
							local spinefile = scene_animate_cfg.filename
							local animatename = nil
							local delay = Util.randomF(0,1.5)
							sp = spine.ExSpine:create(spinefile..".json",spinefile..".atlas")
							if scene_animate_cfg.animate ~= "" then
								animatename = scene_animate_cfg.animate
							else
								animatename = item.userdata
							end
							sp:runAction(cc.Sequence:create(cc.DelayTime:create(delay),cc.CallFunc:create(function()
								sp:setAnimation(0,animatename,true)
							end)))
						elseif item.animTag == 'leafshake' then
							--抖动的树叶子
							sp = require("app.border.LeafShake").new(item)
						elseif item.id == 200008 then
							sp = cc.ParticleSystemQuad:create("particles/start.plist")
							sp:setPositionType(1)
							sp:setLife(math.random(7,10))
							sp.type = 0 --粒子
						elseif item.id == 200002 then  --樱花
							sp = cc.ParticleSystemQuad:create("particles/flower.plist")
							sp:setPositionType(1)
							sp:setBlendAdditive(false)
							sp.type = 0 --粒子
						elseif item.id == 200201 then
							sp = cc.ParticleSystemQuad:create("particles/dandelion.plist")
							sp.type = 0 --粒子
	
						elseif item.id == 200200 then
							sp = spine.SkeletonAnimation:create("spine/dayan.json","spine/dayan.atlas",1.0)
							sp:setAnimation(0,"fei",true)
							sp:setOpacity(200)
							sp:setTimeScale(Util.randomF(0.8,1.2))
							sp.type = 1 --精灵
						elseif item.id == 600606 then
							
							sp = spine.SkeletonAnimation:create("spine/yuzhongmohuagege.json","spine/yuzhongmohuagege.atlas",1.0)
							sp:setAnimation(0,"idle",true)
						else
							
							if item.src then
								if string.find(item.src,"#") then --打包资源
									sp = display.newFilteredSprite(item.src)
								else
									sp = display.newFilteredSprite('map/'..item.src)
								end
								sp.type = 1 --精灵
								if item.id == 300301 and globalDefend and globalDefend.setDoorImg then --城墙
									globalDefend:setDoorImg(sp)
								end
							end
						end

						if item.pos then
							sp:setPosition(checknumber(item.pos[1]),checknumber(item.pos[2]))
						end
						if item.scale then
							if sp.type ~= 0 then
								sp:setScale(checknumber(item.scale[1]), checknumber(item.scale[2]))
							end
						end
						if item.rotation then
							sp:setRotation(checknumber(item.rotation))
						end
                        
                        if item.alpha ~= nil then
                            sp:setOpacity(item.alpha)
                        end
                            --设置颜色
                        if item.color ~= nil then
                            sp:setColor(cc.c3b(item.color[1],item.color[2],item.color[3]))
                        end

                        if item.anchor ~= nil then
                        	sp:setAnchorPoint(cc.p(item.anchor[1],item.anchor[2]))
                        end

                        if item.flipx then sp:setFlippedX(true) end
                        if item.flipy then sp:setFlippedY(true) end

						if item.zOrder then
							sp:setLocalZOrder(checknumber(item.zOrder))
						end
						if item.id == 200001 then -- 水轮转到
							sp:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,10)))
						end

						if item.id then
							if  (item.id - item.id%100)/100 == 2001 then --摇动的草
								local args = string.split(item.animTag, ',')
								local s = checknumber(item.args[1])
								local b = checknumber(item.args[2])
								local filterData = {
		    							"CUSTOM",
		    							json.encode({frag = "Shaders/grass.fsh",
		    						         speed = s,
		    						         bendFactor= b,
		    						         active=1,
		    						         })
		    					} 

								local name,params = unpack(filterData)

		    					local ff = filter.newFilter(name,params)
		    					sp:setFilter(ff)
		    					sp.__grass = 1
							elseif item.id == 200007 then
								local anim = display.newAnimate("sceneDust%02d.png", 1, 10, 1/5,false)
								sp:setOpacity(0.3*255)
								sp:setScale(1.0)
								sp:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
								sp:runAction(cc.RepeatForever:create(anim))
								--local Util = require("app.util.Util")
								--[[
								sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(Util.randomF(2,3),math.random(180,255)),
									cc.FadeTo:create(Util.randomF(2,3),math.random(0,75)),
									nil)))
								]]
							elseif item.id == 200003 then
								-- local sp1 = display.newSprite("#sceneWater01.png"):addTo(sp):pos(179.49,15.67)
								-- local anim = display.newAnimate("sceneWater%02d.png", 1, 10, 1/5,false)
								-- sp1:setScale(0.5,0.5)
								-- sp1:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
								-- sp1:runAction(cc.RepeatForever:create(anim))
							elseif item.id == 200006 then
								-- local anim = display.newAnimate("thyWater%02d.png", 1, 10, 1/5,false)
								-- sp:runAction(cc.RepeatForever:create(anim))
							elseif item.id == 200009 then
								local lamp = display.newSprite("particles/lamp.png"):pos(94.95,187.5)
								:scale(1.8)
								:addTo(sp)

								lamp:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
								lamp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,0.5*255),
									cc.FadeTo:create(1,0.8*255),
									nil)))
							end
						end
						layers[i].lay:addChild(sp)
						item.sp = sp
					end
				end
			end

			if item.sp then --自运动

				if layers[i].ss and (layers[i].ss[1]~= 0 or layers[i].ss[2] ~= 0) then
					item.sp:setPosition(cc.p(item.sp:getPositionX()+layers[i].ss[1],item.sp:getPositionY()+layers[i].ss[2]))
					if item.sp:getPositionX() < -display.width/2 then
						item.sp:setPositionX(item.sp:getPositionX() + mapwidth)
					end
				end
			end
		end
	end
end

--更新box2d
function updatePlatform(parent,data,cameraNode)
	--print("updateBox2d")
	local PTM_RATIO = 32.0
	local previewWidth = display.width
	local previewHeight = display.height
	-- local previewrect = cc.rect(rolePos.x-previewWidth,rolePos.y-previewHeight,previewWidth*2,previewHeight*2)
	for i=1,#data do
		if data[i].layer == nil then
			data[i].layer = display.newLayer()
			data[i].layer:setLocalZOrder(data[i].zOrder)
			parent:addChild(data[i].layer)
			local sx,sy = 1,1
			if data[i].speedOffset then
				data[i].layer.sx,data[i].layer.sy = data[i].speedOffset[1],data[i].speedOffset[2]
				data[i].speedOffset = nil
				data[i].layer.loc = {0,0}
			else
				data[i].layer.sx,data[i].layer.sy = 1.0,1.0
				data[i].layer.loc = {0,0}
			end
		end
		move(data[i].layer,cameraNode)
		for j = 1,#data[i].children do
			local child  = data[i].children[j]
			if child.node == nil then
				child.node = require("app.border.GroundPlatform").new(data[i].layer,child)
			end
		end
	end
end

function addCollect(parent,data)

	if data ~= nil then
		local layer = display.newLayer()
		layer:setLocalZOrder(data.zOrder-1) --确保在敌人前一层
		parent:addChild(layer)

		for i=1,#data.children do
			
			local lg = require("app.prop.LifeGas").new(data.children[i],1):addTo(layer)
		end
		return layer
	end
	return nil
end

--掉落id
local function getBoxData(id)
	local data = GameDataMgr.getRewards(nil,nil,6)

	return data[1]["id"],data[1]["num"]
end

--掉落物品箱子
function addCollectBox(parent,data)
	if data ~= nil then
		for i=1,#data.children do
			local location = data.children[i]["pos"]
			local id,num = getBoxData(data.children[i]["id"])
			require("app.prop.Box").new(id,num,cc.p(location[1],location[2])):addTo(parent)
		end
	end
end

function addGrass(parent,data)

	if data ~= nil then
		local layer = display.newLayer()
		layer:setLocalZOrder(data.zOrder-1)--确保在敌人前一层
		parent:addChild(layer)

		for i=1,#data.children do
			if GameDataMgr.isFreshman() or GameDataMgr.getItem(data.children[i].id) == 0 then
				require("app.prop.Grass").new(data.children[i]):addTo(layer)
			end
		end
		return layer
	end
	return nil
end

--
function createGround(parent,extCollider)
	if extCollider ~= nil then
		for i=1,#extCollider do
			require("app.border.Ground").new(extCollider[i]):addTo(parent)
		end
	end
end

function addSceneEffect(parent,data)
	if data == nil then return end
	for i=1,#data do
		local layer = display.newLayer()
		layer:setLocalZOrder(data[i].zOrder)
		parent:addChild(layer)

		for j=1,#data[i].children do
			if data[i].children[j].id == 1 then --樱花
				local partical = cc.ParticleSystemQuad:create("particles/flower.plist")
				partical:setPosition(data[i].children[j].pos[1],data[i].children[j].pos[2])
				layer:addChild(partical)
			end
		end
	end
end