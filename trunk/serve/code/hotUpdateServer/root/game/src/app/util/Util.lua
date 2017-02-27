local Util = {}


function Util.getCurTime()
    return require("framework.cc.net.SocketTCP").getTime()
end

function Util.randomF(n,m)
    if n > m then n,m = m,n end
    return n + math.random()*(m - n)
end

--给对象增加发消息功能
function Util.addEventDispatcher(target)
    cc(target):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function Util.fadeInCascade(target,time)
    return cc.CallFunc:create(function()
        for _,v in pairs(target:getChildren()) do
            v:runAction(cc.FadeIn:create(time))
            Util.fadeInCascade(v,time)
        end
    end)
end


function Util.setColorCascade(parent,color)
    parent:setColor(color)
    for k,v in pairs(parent:getChildren()) do
        Util.setColor(v,color)
    end
end

--sprite cc.Sprite 变灰节点
--filter function(v) return v.name == "1" end v为当前节点，返回值决定是否过滤
function Util.grayCascade(sprite,filter)
    if sprite then
        if filter and filter(sprite) then       
        else
            Util.graySprite(sprite)
        end
        for k,v in pairs(sprite:getChildren()) do
            Util.grayCascade(v,filter)
        end
    end 
end

function Util.unGrayCascade(sp)
    if sp then
        Util.removeShader(sp)
    end
    for k,v in pairs(sp:getChildren()) do
        Util.unGrayCascade(v)
    end
end

local function getGLProgramStateFromCache(vsh,fsh)
    local cachename = "my"..vsh..fsh
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(cachename)
    if glProgram == nil then
        glProgram = cc.GLProgram:createWithFilenames(vsh,fsh)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram,cachename)
    end
    return cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
    -- return cc.GLProgramState:create(glProgram)
end

function Util.bloomEffect(s)
    if s and s:isVisible() then
        local glProgramState = getGLProgramStateFromCache("Shaders/ptc_no_mvp.vsh","Shaders/bloom.fsh")
        s:setGLProgramState(glProgramState)
    end
end

function Util.graySprite(s,mvp)
    if s and s:isVisible() then
        local vshfilename = mvp and "Shaders/ptc_mvp.vsh" or "Shaders/ptc_no_mvp.vsh"
        local glProgramState = getGLProgramStateFromCache(vshfilename,"Shaders/gray.fsh")
        s:setGLProgramState(glProgramState)
    end
end

function Util.frozenShader(s)
    if s and s:isVisible() then
        s:setGLProgramState(getGLProgramStateFromCache("Shaders/ptc_mvp.vsh","Shaders/ice.fsh"))
    end
end

function Util.fireShader(s)
    if s and s:isVisible() then
        s:setGLProgramState(getGLProgramStateFromCache("Shaders/ptc_mvp.vsh","Shaders/fire.fsh"))
    end
end

function Util.eleShader(s)
    if s and s:isVisible() then
        s:setGLProgramState(getGLProgramStateFromCache("Shaders/ptc_mvp.vsh","Shaders/purple.fsh"))
    end
end

function Util.removeShader(s,mvp)
    if s and s:isVisible() then
        local state = cc.GLProgramState:getOrCreateWithGLProgramName(mvp and "ShaderPositionTextureColor" or "ShaderPositionTextureColor_noMVP")
        s:setGLProgramState(state)
    end
end

--sprite cc.Sprite 还原节点
--filter function(v) return v.name == "1" end v为当前节点，返回值决定是否过滤
function Util.normalCascade(sprite,filter)
    if filter and filter(sprite) then
    else
        Util.removeShader(sprite)
    end
    for _,v in pairs(sprite:getChildren()) do
        Util.normalCascade(v,filter)
    end
end

function Util.fadeOutCascade(target,time)
    return cc.CallFunc:create(function()
        for _,v in pairs(target:getChildren()) do
            v:runAction(cc.FadeOut:create(time))
            Util.fadeOutCascade(v,time)
        end
    end)
end


function Util.fadeOutCascade1(target,time)
    target:runAction(cc.FadeOut:create(time))
    for _,v in pairs(target:getChildren()) do
        v:runAction(cc.FadeOut:create(time))
        Util.fadeOutCascade1(v,time)
    end
end

function Util.fadeInCascade1(target,time)
    target:runAction(cc.FadeIn:create(time))
    for _,v in pairs(target:getChildren()) do
        v:runAction(cc.FadeIn:create(time))
        Util.fadeInCascade1(v,time)
    end
end

function Util.calcAngle(first,second)
	local curd = 0
	if second.y == first.y and second.x>first.x then
		curd = 0
	elseif second.x == first.x and second.y>first.y then
		curd =90
	elseif second.y == first.y and second.x<first.x then
		curd = 180
	elseif second.x == first.x and second.y<first.y then
		curd =270
	elseif second.x>first.x and second.y>first.y then
		curd = math.atan((second.y-first.y)/(second.x-first.x))/math.pi*180
		--print("curd",curd)
	elseif(second.x<first.x and second.y>first.y) then
		curd = 90 + math.atan((first.x-second.x)/(second.y-first.y))/math.pi*180
	elseif(second.x<first.x and second.y<first.y) then
		curd = 180 + math.atan((first.y-second.y)/(first.x-second.x))/math.pi*180
	elseif(second.x>first.x and second.y<first.y) then
		curd = 270 + math.atan((second.x-first.x)/(first.y-second.y))/math.pi*180
	end
	return curd
 end

--## 获取模糊节点之后的精灵 
--#1 需要模糊的节点
function Util.getBlurSpriteByNodes(nodes)
    if #nodes == 0 then return nil end
    -- local beginTime = Util.getCurTime()
    local rt = cc.RenderTexture:create(display.width,display.height)
    rt:begin()
    for _,n in pairs(nodes) do
        n:visit()
    end
    rt:endToLua()
    
    local sprite = display.newFilteredSprite(rt:getSprite():getTexture(),
        {"GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"},{{3.0}, {3.0}})
    sprite:setScaleY(-1)
    local endTime = Util.getCurTime()
    -- print("cost:",endTime-beginTime)
    return sprite
end

--## 对滤镜精灵进行模糊渐变
--#1 滤镜精灵
--#2 时间
--#3 初始模糊系数
--#4 最终模糊系数
--#5 完成时的回调
function Util.blurAction(filteredSprite,time,from,to,onFinished)
    local scheduler = require("framework.scheduler")
    local t = 0   
    filteredSprite.handle = scheduler.scheduleGlobal(function(dt)
        t = t + dt
        local delta = math.min(t/time,1.0)
        local blur = cc.pLerp(cc.p(from,from),cc.p(to,to),delta)
        local f = filter.newFilters({"GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"},{{blur.y}, {blur.x}})
        filteredSprite:setFilters(f)
        if t >= time and filteredSprite.handle then
            scheduler.unscheduleGlobal(filteredSprite.handle)
            if onFinished then onFinished() end 
        end
    end, 1/25)
end

function Util.setAllCascadeOpacityEnabled(node,enabled)
    node:setCascadeOpacityEnabled(enabled)
    local children = node:getChildren()
    for i=1,#children do
        Util.setAllCascadeOpacityEnabled(children[i],enabled)
    end
end

function Util.fadeInAll(node,time)
    Util.setAllCascadeOpacityEnabled(node,true)
    local action = cc.FadeIn:create(time)
    node:runAction(action)
end

function Util.fadeOutAll(node,time)
    Util.setAllCascadeOpacityEnabled(node,true)
    local action = cc.FadeOut:create(time)
    node:runAction(action)
end

function xRotateMat(rs,rc)
    return {{1.0,0.0,0.0,0.0},
        {0.0,rc,rs,0.0},
        {0.0,-rs,rc,0.0},
        {0.0,0.0,0.0,1.0}}
end

function yRotateMat(rs,rc)
    return {{rc,0.0,-rs,0.0},
        {0.0,1.0,0.0,0.0},
        {rs,0.0,rc,0.0},
        {0.0,0.0,0.0,1.0}}
end

function zRotateMat(rs,rc) 
    return {{rc,rs,0.0,0.0},
        {-rs,rc,0.0,0.0},
        {0.0,0.0,1.0,0.0},
        {0.0,0.0,0.0,1.0}}
end

function matrixMult(a,b)
    local temp={{0.0,0.0,0.0,0.0},{0.0,0.0,0.0,0.0},{0.0,0.0,0.0,0.0},{0.0,0.0,0.0,1.0}}

    for y=1,4 do 
        for x=1,4 do
            temp[y][x] = b[y][1] * a[1][x] + b[y][2] * a[2][x] + b[y][3] * a[3][x] + b[y][4] * a[4][x]
        end
    end
    return temp
end

function premultiplyAlpha(mat,alpha)
    for i = 1,4 do
        for j = 1,4 do
            mat[i][j] = mat[i][j] * alpha
        end
    end
    return mat
end

--根据角度算出颜色转换矩阵
--angle 0-2PI
function hueMatrix(angle)
    local mat,rot
    local SQRT_2 = math.sqrt(2.0)
    local SQRT_3 = math.sqrt(3.0)

    local mag
    local xrs, xrc
    local yrs, yrc
    local zrs, zrc

    --Rotate the grey vector into positive Z
    mag = SQRT_2
    xrs = 1.0/mag
    xrc = 1.0/mag
    mat = xRotateMat(xrs, xrc)
    mag = SQRT_3
    yrs = -1.0/mag
    yrc = SQRT_2/mag
    rot = yRotateMat(yrs, yrc)
    mat = matrixMult(rot, mat)
    --Rotate the hue
    zrs = math.sin(angle)
    zrc = math.cos(angle)
    rot = zRotateMat(zrs, zrc)
    mat = matrixMult(rot, mat)

    --Rotate the grey vector back into place
    rot = yRotateMat(-yrs, yrc)
    mat = matrixMult(rot, mat)
    rot = xRotateMat(-xrs, xrc)
    mat = matrixMult(rot, mat)
    return mat
end

function mat44To16(mat)
    local result = {}
    for i=1,4 do
        for j=1,4 do
            table.insert(result,mat[i][j])
        end
    end
    return result
end

--targe Node
--args table[ 
--angle number 色调值 0~2PI
--alpha number 透明度 0~1.0
--mask  string 遮罩通道图（黑色部分变色其他部分不变色）
--spriteOrSpine int 是否是精灵
--]
function Util.changeSpriteHue(target,args)
    
    local args = args or {}
    local alpha = args.alpha or 1.0
    local angle = args.angle or 0
    local spriteOrSpine = args.spriteOrSpine or 1
    local vsh = "Shaders/ptc_mvp.vsh"
    if spriteOrSpine == 1 then
        vsh = "Shaders/ptc_no_mvp.vsh"
    end
    local fshName = "Shaders/hue_mask.fsh"
    if not args.mask then
        fshName = "Shaders/hue_no_mask.fsh"
    end
    local glprogramstate = getGLProgramStateFromCache(vsh,fshName)
    if glprogramstate then
        local hueMatrix1 = hueMatrix(angle)
        local mat = mat44To16(premultiplyAlpha(hueMatrix1,1.0))
        glprogramstate:setUniformMat4("u_hue",mat)
        glprogramstate:setUniformFloat("u_alpha",alpha)
        if args.mask then --通道图
            local mask = cc.Director:getInstance():getTextureCache():addImage(args.mask)
            glprogramstate:setUniformTexture("u_mask",mask)
        end
        target:setGLProgramState(glprogramstate)
    end
end

function Util.insertToSet(t,value)
    local canInsert = true
    for i=1,#t do
        if t[i] == value then
            canInsert = false
            break
        end
    end
    if canInsert then
        table.insert(t, value)
    end
    return t
end

--去掉字符
function Util.removeChar(str,remove)  
    local lcSubStrTab = {} 

    while true do  
        local lcPos = string.find(str,remove)  
        if not lcPos then  
            lcSubStrTab[#lcSubStrTab+1] =  str      
            break  
        end  

        local lcSubStr  = string.sub(str,1,lcPos-1)  
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr  
        str = string.sub(str,lcPos+1,#str)  
    end  
    local lcMergeStr =""  
    local lci = 1  
    while true do  
        if lcSubStrTab[lci] then  
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]   
            lci = lci + 1  
        else   
            break  
        end  
    end  
    return lcMergeStr  
end  

--字符串分割(空字符串忽略)
function Util.split(src,sep)
    local resultStrsList = {}
    string.gsub(src, '[^'..sep..']+', function(w) table.insert(resultStrsList, w) end )
    return resultStrsList  
end

--分割字符串(不忽略空字符串)
function Util.splitWidthEmpty(str, split_char)
    --nil或空字符串
    if not str or str == "" then
        return {}
    end
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + string.len(split_char), #str);
    end
    return sub_str_tab;
end

--将角度调整到0-360度
function Util.adjustAngle0To360(a)
    while a < 0 do
        a = a + 360
    end
    while a >= 360 do
        a = a - 360
    end
    return a
end

--复制表格
function Util.copyTable(tb)
    local tab = {}
    for k, v in pairs(tb or {}) do
        if type(v) == "table" then
            tab[k] = Util.copyTable(v)            
        else
            tab[k] = v
        end
    end
    return tab
end


function Util.shakeMobile(layer)
    local fun = function ()
        if device.platform == "android" then
            luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","openKTPlay")
        elseif device.platform == "ios" then
            luaoc.callStaticMethod("KTPlayImpl","openKTPlay")
        end
    end
    layer:addChild(require("app.layer.HandShakeLayer").new(fun))
end


function Util.playBackMusic(main,sub)
    local musicname = nil
    local step = false
    if main == 0 and sub == 0 then  --竞技场背景音乐
        musicname = 'sound/bg/9006'
    else
        step = true
        if main then  
            local stagecfg = CfgMgr.getStage()
            local nsd
            if stagecfg[main.."0"..sub] then
                nsd = stagecfg[main.."0"..sub].nsd
            end
            if nsd then musicname = "sound/bg/"..nsd end
        else --选关场景背景音乐
            musicname = 'sound/bg/9001'
        end
    end
    if musicname then
        return audio.playMusic(musicname,true,step)
    end
end

--跳动提示
function Util.JumpPrompt()
    return cc.RepeatForever:create(cc.Sequence:create(cc.JumpBy:create(1, cc.p(0,0), 20, 4),cc.DelayTime:create(1),nil))
end

--[[生成订单号
时间+6位随机数（20位）
20151211104252xxxxxx
]]
function Util.createOrderId()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local randomstr = ""
    for i=1,6 do
        randomstr = randomstr..math.random(0,10)
    end
    return os.date("%Y%m%d%H%M%S")..randomstr
end

--暂时不支持超过100的转换
function Util.getCNNumber(num)
    local words = {'一','二','三','四','五','六','七','八','九','十'}
    local origin = num
    if num <=#words then return words[num] end
    local strings = ""
    local b = math.modf(num/100)
    
    if b >=1 and num >= 100 then
        strings = words[b].."百"
    end

    num = num % 100
    local s = math.modf(num/10)
    
    if s >= 1 and num >= 10 then
        if origin > 10 and origin < 20 then --[11 - 19]
            strings = "十"
        else
            strings = strings..words[s].."十"
        end
    end

    num = num % 10
    local g = num%10

    if b > 0 and s == 0 and g ~=0 then
        strings = strings .. "零"
    end

    if g ~=0 then
        strings = strings..words[g]
    end
    return strings
end

--高配机型
function Util.isHighDevice()
    if device.platform == "ios" then
        local result,size = luaoc.callStaticMethod("AppController","getMemorySize")
        return size > 512
    else
        return true
    end
end

function Util.readUUID()
    if device.platform == "ios" then
        local result,uuid = luaoc.callStaticMethod("RootViewController","readUUID")
        return uuid
    elseif device.platform == "android" then
        -- device.showAlert("提示","unfinish getuuid",{"OK"})
        return "android"
    else
        return "licong's MacBook"
    end
end

function Util.getUUID()
    if device.platform == "ios" then
        local result,uuid = luaoc.callStaticMethod("RootViewController","getUUID")
        return uuid
    elseif device.platform == "android" then
        -- device.showAlert("提示","unfinish getuuid",{"OK"})
        return "android"
    else
        return "licong's MacBook"
    end
end
--获得日期
--("20160105")
function Util.getDateString()
    return  os.date("%Y%m%d")
end

--获得渠道
function Util.getChannel()
    if device.platform == "ios" then
        local result,value = luaoc.callStaticMethod("PayHelper","getChannel")
        return value
    elseif device.platform == "android" then
        -- device.showAlert("提示","unfinish getChannel",{"OK"})
    end
    return "unknow"
end

--应用id，用于排行榜
function Util.getAppId()
    if Util.getChannel() == "appstore" then
        return "appstore_hanren"
    else
        return "hanren"
    end
end

function Util.doNextFrame(func,delay)
    local action = cc.Sequence:create(cc.DelayTime:create(delay or 1.0/60),cc.CallFunc:create(func))
    display.getRunningScene():runAction(action)
end

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        -- print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end
--[[utf字符数
第一个返回值表示字符数
第二个返回值表示ascii数,(中文算作两个字符)
]]
function string.utf8len(str)
    local len = 0
    local ascii = 0 --ascii数量
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local size = chsize(char)
        currentIndex = currentIndex + size
        len = len +1
        if size == 1 then
            ascii = ascii + 1
        end
    end
    return len,2*len-ascii
end
-- 截取utf8 字符串
-- str:         要截取的字符串
-- startChar:   开始字符下标,从1开始
-- numChars:    要截取的字符长度
function string.utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

--[[截取utf字符串（大小为字节）
中文算两个字节
返回值<=(len+1)个字节
]]
function Util.stringsub(str,len)
    local utflen = math.ceil(len/2)
    local len1,len2 = string.utf8len(str)
    if len2 < len then
        return str
    end
    local substr = string.utf8sub(str,1,utflen)
    en1,len2 = string.utf8len(substr)
    while len2 < len do
        utflen = utflen + 1
        substr = string.utf8sub(str,1,utflen)
        len1,len2 = string.utf8len(substr)
    end
    return substr
end
--[[去掉首尾空格
]]
function string.trim(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function Util.requestHttp(url,callback,method,data,timeout)
    local request = network.createHTTPRequest(callback,url,method)
    request:setTimeout(timeout or 10)
    if data then
        request:addRequestHeader("Content-Type:application/json;charset=utf-8")
        request:setPOSTData(data)
    end
    request:start()
end

function Util.getVersion()
    if device.platform == "ios" then
        local result,value = luaoc.callStaticMethod("RootViewController","getVersion")
        return value
    elseif device.platform == "android" then
        local result,value = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity","getVersionName",{},"()Ljava/lang/String;")
        return value
    end
    return "unkown"
end

function Util.getLeadBoardURL()
    -- return "120.55.167.14:28055"
    return "http://gamerank.ugmars.com:28055"
end
--[[--返回扩大倍数
0.01 --->100,0.1 -->10
]]
function Util.getFloat2IntRate(fvalue)
    local rate = 1
    while true do
        if fvalue*rate > 0 and fvalue*rate - math.ceil(fvalue*rate) == 0 then
            return rate
        end
        rate = rate*10
    end
end

function Util.getEnemySpineFiles(enemys,containner)
    local files = containner or {}
    for k,v in pairs(enemys) do
        local mid = CfgMgr.getEnemyInfo()[tostring(v)].id
        local name,txname= RoleBuilder.getSpineName(tonumber(mid))
        if name ~= "" then
            table.insert(files, {name..".json",{body = name..".atlas"},{"body"}})
        end
        
        if txname ~= "" then
            table.insert(files, {txname..".json",{body = txname..".atlas"},{"body"}})
        end
    end
    return files
end

function Util.getPlayerSpineFiles(containner)
    local files = containner or {}
    local curWeapons = GameDataMgr.getCurWeapons()
    local curClothes = GameDataMgr.getCurClothes()
    local data = CfgMgr.getClothes()[curClothes]

    table.insert(files, {data.json..".json",{body = "hero/shenti.atlas",clothes = data.png..".atlas",weapon = "hero/"..curWeapons[1]..".atlas"},{"body","clothes","weapon"}})
    table.insert(files, {"hero/TX.json",{body = "hero/TX.atlas"},{"body"}})
    return files
end
--根据怪物id获得技能所需文件名
function Util.getEnemySkillFiles(enemys)
    local filenames = {}
    local skills = {}
    local enemyInfo = CfgMgr.getEnemyInfo()
    for k,v in pairs(enemys) do
        --普通攻击
        local ats = enemyInfo[v].attack
        if ats then
            for j = 1,#ats do
                table.insert(skills, ats[j])
            end
        end

        --技能攻击
        local sks = enemyInfo[v].skill
        if sks then
            for j = 1,#sks do
                table.insert(skills, sks[j])
            end
        end

        --爬起反击
        local sats = enemyInfo[v].standattack
        if sats then table.insert(skills, sats) end
    end
    -- print("---_>"..nil)
    local sks = GameDataMgr.getCurSkills()
    for i=1,#sks do
        table.insert(skills, sks[i])
    end

    for i=1,#skills do
        local files = CfgMgr.getSkillConfig(skills[i]).res
        if files then
            for j=1,#files do
                if files[j] ~= "" then
                    table.insert(filenames,{plist = "animateframes/"..files[j]..".plist",texture = "animateframes/"..files[j]..".png"})
                end
            end
        end
    end
    return filenames
end
-- 游戏中必须资源
function Util.getNeedFrames(frames)
    local container = frames or {}
    table.insert(container, {plist = 'control/controlUI.plist',texture = 'control/controlUI.png'})
    table.insert(container, {plist = "animateframes/qtePower.plist",texture = "animateframes/qtePower.png"})
    table.insert(container, {plist = "animateframes/qtebg.plist",texture = "animateframes/qtebg.png"})
    table.insert(container, {plist = "animateframes/lgqte.plist",texture = "animateframes/lgqte.png"})
    table.insert(container, {plist = "animateframes/player_dust.plist",texture = "animateframes/player_dust.png"}) 
    table.insert(container, {plist = "animateframes/jianqi.plist",texture = "animateframes/jianqi.png"})
    table.insert(container, {plist = "animateframes/hurt_ice.plist",texture = "animateframes/hurt_ice.png"})
    table.insert(container, {plist = "animateframes/hurt_burn.plist",texture = "animateframes/hurt_burn.png"})
    table.insert(container, {plist = "animateframes/hurt_ele.plist",texture = "animateframes/hurt_ele.png"})
    -- local x,g,f,b,attr = GameDataMgr.getPlayerAttr()
    -- local hurtAttr = {{plist = "animateframes/hurt_ice.plist",texture = "animateframes/hurt_ice.png"},{plist = "animateframes/hurt_burn.plist",texture = "animateframes/hurt_burn.png"},{plist = "animateframes/hurt_ele.plist",texture = "animateframes/hurt_ele.png"}}
    -- table.insert(container, hurtAttr[attr])

    --战斗通用特效
    table.insert(container, {plist = "animateframes/enemy_enter.plist",texture = "animateframes/enemy_enter.png" })                    --敌人入场
    table.insert(container, {plist = "animateframes/enemy_die.plist",texture = "animateframes/enemy_die.png" })                      --敌人死亡
    table.insert(container, {plist = "animateframes/die_blast.plist",texture = "animateframes/die_blast.png" })                      --死亡爆炸 

    table.insert(container, {plist = "animateframes/skillname.plist",texture = "animateframes/skillname.png"})
    
    table.insert(container, {plist = "animateframes/skill_light.plist",texture = "animateframes/skill_light.png" })                    --放技能通用特效光
    table.insert(container, {plist = "animateframes/skill_line.plist",texture = "animateframes/skill_line.png" })                     --放技能通用特效线条
    table.insert(container, {plist = "animateframes/attack_light.plist",texture = "animateframes/attack_light.png" })                   --受击光效
    table.insert(container, {plist = "animateframes/blood_splash.plist",texture = "animateframes/blood_splash.png" })                   --受击血溅
    table.insert(container, {plist = "animateframes/blood_mark.plist",texture = "animateframes/blood_mark.png" })                     --受击血痕

    table.insert(container, {plist = "animateframes/land_dust.plist",texture = "animateframes/land_dust.png"})                      --着地灰尘

    table.insert(container, {plist = "animateframes/enemyFaintAnim.plist",texture = "animateframes/enemyFaintAnim.png"})                 --眩晕星星

    table.insert(container, {plist = "animateframes/hiddenweapon_hitfly.plist",texture = "animateframes/hiddenweapon_hitfly.png"})            --暗器击飞特效

    table.insert(container, {plist = "animateframes/sword_light_1.plist",texture = "animateframes/sword_light_1.png"})                  --剑光1
    table.insert(container, {plist = "animateframes/sword_light_2.plist",texture = "animateframes/sword_light_2.png"})                  --剑光2
    table.insert(container, {plist = "animateframes/sword_light_3.plist",texture = "animateframes/sword_light_3.png"})                  --剑光3
    table.insert(container, {plist = "animateframes/sword_light_4.plist",texture = "animateframes/sword_light_4.png"})                  --剑光4 
    table.insert(container, {plist = "animateframes/sword_light_5.plist",texture = "animateframes/sword_light_5.png"})                  --剑光5
    table.insert(container, {plist = "animateframes/sword_light_air_1.plist",texture = "animateframes/sword_light_air_1.png"})              --剑光空中1 
    table.insert(container, {plist = "animateframes/sword_light_air_2.plist",texture = "animateframes/sword_light_air_2.png"})              --剑光空中2
    table.insert(container, {plist = "animateframes/sword_light_air_4.plist",texture = "animateframes/sword_light_air_4.png"})              --剑光空中3 4
    table.insert(container, {plist = "animateframes/sword_light_air_5.plist",texture = "animateframes/sword_light_air_5.png"})              --剑光空中5
    table.insert(container, {plist = "animateframes/jianqi_splash.plist",texture = "animateframes/jianqi_splash.png"})                  --剑气洒
    table.insert(container, {plist = "animateframes/backblood.plist",texture = "animateframes/backblood.png"})                      --回血
    table.insert(container, {plist = "animateframes/speed_line.plist",texture = "animateframes/speed_line.png"})                     --速度线
    
    table.insert(container, {plist = "animateframes/bigbox.plist", texture = "animateframes/bigbox.png"})                         --结算打开宝箱动画
    table.insert(container, {plist = "animateframes/mysterbox.plist", texture = "animateframes/mysterbox.png"})                      --结算打开宝箱动画
    table.insert(container, {plist = "animateframes/openbox.plist", texture = "animateframes/openbox.png"})                        --结算打开宝箱动画
    table.insert(container, {plist = "animateframes/smallbox.plist", texture = "animateframes/smallbox.png"})                       --结算打开宝箱动画

    -- --战斗技能特有缓存特效
    table.insert(container, {plist = "animateframes/ghost_fire.plist", texture = "animateframes/ghost_fire.png"}) --冤魂的鬼火
    table.insert(container, {plist = "animateframes/ef_hero_jump.plist", texture = "animateframes/ef_hero_jump.png"})
    table.insert(container, {plist = "animateframes/hunpo.plist", texture = "animateframes/hunpo.png"})
    return container
end

function Util.luaMemorySnapshot()
    if _G.snapshotInfo == nil then
        -- _G.globalTable = {}
        -- for k,v in pairs(_G) do 
        --      _G.globalTable[k] = v
        -- end
        _G.snapshotInfo = snapshot()
    else
        local S2 = snapshot()
        local outstrings = ""
        for k,v in pairs(S2) do
            if _G.snapshotInfo[k] == nil then
                outstrings = outstrings..tostring(k).."\t"..tostring(v).."\r\n"
            end
        end
        local file = io.open("C:/Users/Administrator/Desktop/snapshot.txt","wb")
        file:write(outstrings)
        file:close()
       --  -- _G.snapshotInfo = snapshot()
       -- local t = {}
       --  for k,v in pairs(_G) do 
       --       if _G.globalTable[k] == nil then
       --          t[k] = v
       --       end
       --  end
       --  local outstrings = ""
       --  for k,v in pairs(t) do
       --      outstrings = outstrings..tostring(k).."\t"..tostring(v).."\r\n"
       --  end
       --  local file = io.open("C:/Users/Administrator/Desktop/global.txt","wb")
       --  file:write(outstrings)
       --  file:close()
       --  -- for k,v in pairs(_G) do 
       --  --      _G.globalTable[k] = v
       --  -- end
    end
end

function Util.debug()
    collectgarbage()
    for k1,v1 in pairs(_G.weakTable) do 
        print(k1,v1,type(k1))
    end
end

function table.containsValue(arr,value)
    local ret = false
    for k,v in pairs(arr) do 
        if v == value then return true end
    end
    return false
end
return Util

