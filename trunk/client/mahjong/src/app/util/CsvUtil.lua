--[[
Copyright (c) 2014-2015 Mars
Created by 徐翔 on 2015-07-31.
解析csv
]]

CsvUtil = class("CsvUtil")

--加载CSV数据
function CsvUtil.load(path)
	local strings = cc.FileUtils:getInstance():getStringFromFile(path)
	local lines = Util.splitWidthEmpty(strings, "\r\n")

	--Key列表
	local keys = Util.splitWidthEmpty(lines[2], ",")
    local kn = table.getn(keys) 			--字段数量		
	local types = Util.splitWidthEmpty(lines[3], ",")

	--加载数据
	local n = table.getn(lines) - 1   --最后有个\r\n结尾 所以拆分出来最后一行是空行
	local data = {}
	for i=4,n do 		--数据是从第四行开始
		local record = {}
		local recordstr = Util.splitWidthEmpty(lines[i], ",")
		for j=1,kn do 		--逐个解析字段
			local t = types[j]
			local v = recordstr[j]
			if t == "bool" then
				v = v ~= "" and v ~= "0"
			elseif t == "int" or t == "float" then
				v = (v == "") and 0 or tonumber(v)
			end
            local k = keys[j]
			record[k] = v
		end
		local id = record[keys[1]]  --第一列数据作为id
        data[id] = record
	end

	--生成配置
	local cfg = {}
	cfg.keys = keys
	cfg.types = types
	cfg.data = data

	return cfg
end