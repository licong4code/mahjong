 --[[
//
//  Copyright (c) 2014-2015 Mars
//
//  Created by licong on 16/03/15.
//
//	下载
]]

ResourceMgr = {}
--[[
]]
ResourceMgr.spines = {} --spine资源
ResourceMgr.frames = {} --打包后的图片
ResourceMgr.textures = {} --单张纹理
ResourceMgr.animation = {}

--[[压入需要加载的资源
removeunuse 是否未使用资源的计数减1
]]
function ResourceMgr.push(destination,src,type,removeunuse)
    if removeunuse then
        for k,v in pairs(destination) do 
            v["count"] = v["count"]-1
        end
    end

    for i=1,#src do
        local key = src[i]
        if type == "frame" then
            key = key["plist"]
        end
        if destination[key] then
            destination[key]["count"] = 1
        else
            destination[key] = {count = 1,res = src[i]}
        end
    end
end

function ResourceMgr.loadTextureAsync(textures,callback)

    ResourceMgr.push(ResourceMgr.textures,textures,"texture",true)
    for k,v in pairs(ResourceMgr.textures) do
        if v["count"] == 0 then --删掉未使用的资源
            -- cc.Director:getInstance():getTextureCache():removeTextureForKey(v["res"])
            table.removebyvalue(ResourceMgr.textures, v)
            -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end

    for i=1,#textures do
        display.addImageAsync(textures[i],function(texture) if callback then callback(texture) end end)
    end
end

function ResourceMgr.loadFramesAsync(frames,callback,removeunuse)
    ResourceMgr.push(ResourceMgr.frames,frames,"frame",removeunuse)
    if removeunuse then--释放所有帧动画缓存
        ResourceMgr.removeAllAnimationCache()
        -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
        -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end
    for k,v in pairs(ResourceMgr.frames) do
        if v["count"] == 0 then --删掉未使用的资源
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(v["res"]["plist"])
            -- cc.Director:getInstance():getTextureCache():removeTextureForKey(v["res"]["texture"])
            table.removebyvalue(ResourceMgr.frames, v)
        end
    end
    if removeunuse then
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end
    for i = 1,#frames do
        display.addSpriteFrames(frames[i]["plist"],frames[i]["texture"],function(plist,image)
            if callback then callback(plist,image) end
        end)
    end
end

function ResourceMgr.isCacheSpine(spinekey)
    return ResourceMgr.spines[spinekey] ~= nil
end

--[[ spine缓存结构 {key = {{},{}}}
key == jsonkey
value = {body = {res ,count},body = {res ,count},} ,count }
]]
function ResourceMgr.loadSpineAsync(spines,callback,removeunuse)
    if removeunuse then
        for k,v in pairs(ResourceMgr.spines) do 
            v["count"] = v["count"]-1
        end
    end

    for i=1,#spines do
        local jsonkey = spines[i][1]
        -- local atlasbody = 
        if ResourceMgr.spines[jsonkey] then
            ResourceMgr.spines[jsonkey]["count"] = 1
        else
            ResourceMgr.spines[jsonkey] = {count = 1,res = spines[i]}
        end
    end

    for k,v in pairs(ResourceMgr.spines) do
        if v["count"] == 0 then --删掉未使用的资源
            table.removebyvalue(ResourceMgr.spines, v)
            if v["res"][2]["clothes"] == nil then
                sp.SpineCache:getInstance():removeCache(v["res"][2]["body"] ,v["res"][1])
            else --换了衣服才会跑这
                sp.SpineCache:getInstance():removeCache(v["res"][2]["clothes"] ,v["res"][1])
            end
        end
    end

    if removeunuse then
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end

    for i = 1,#spines do
        local atlas = {}
        if spines[i][2]["body"] then table.insert(atlas,spines[i][2]["body"]) end
        if spines[i][2]["clothes"] then table.insert(atlas,spines[i][2]["clothes"]) end
        if spines[i][2]["weapon"] then table.insert(atlas,spines[i][2]["weapon"]) end

        sp.SpineCache:getInstance():addSpineFileInfoAsync(spines[i][1],atlas,function ( name )
            if callback then callback(name) end
        end, spines[i][3] or {})
    end
end

function ResourceMgr.loadTextFileAsync(filename,callback)
    sp.SpineCache:getInstance():loadFileStringAsync(filename,callback)
end

--[[获得从帧动画缓存中获得，如果没有则会新建并缓存
name 帧动画前缀 如：name01.png 命名务必为 01 02 03...
begin 开始索引 一般从1开始
length 帧动画的长度，
time 每帧时间
]]
function ResourceMgr.getAnimationFromCache(name,begin,length,time)
    local animation = display.getAnimationCache(name)
    if animation == nil then
        local frames = display.newFrames(name.."%02d.png", begin, length)
        animation = display.newAnimation(frames, time)
        display.setAnimationCache(name, animation)
    end
    ResourceMgr.animation[name] = 1
    return animation
end

--从缓存中生成帧动画
function ResourceMgr.getAnimate(name,begin,length,time)
    return cc.Animate:create(ResourceMgr.getAnimationFromCache(name,begin,length,time))
end

function ResourceMgr.removeAnimationFromCache(name)
    if ResourceMgr.animation[name] == 1 then
        ResourceMgr.animation[name] = 0
        display.removeAnimationCache(name)
    end
end

function ResourceMgr.removeAllAnimationCache()
    for k,v in pairs(ResourceMgr.animation) do 
        display.removeAnimationCache(k)
    end
    ResourceMgr.animation = {}
end