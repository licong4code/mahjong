-----------------------------------------------------------------------------
-- Network Time Protocal
-- Author: ani_di
-----------------------------------------------------------------------------

local socket = require "socket.core"
local TimeUtil = {} 
server_ip = {
    "132.163.4.102",
    "132.163.4.103",
    "128.138.140.44",
    "192.43.244.18",
    "131.107.1.10",
    "66.243.43.21",
    "216.200.93.8",
    "208.184.49.9",
    "207.126.98.204",
    "207.200.81.113",
    "205.188.185.33"
  }
 
function nstol(str)
  assert(str and #str == 4)
  local t = {str:byte(1,-1)}
  local n = 0
  for k = 1, #t do
    n= n*256 + t[k]
  end
  return n
end
 
-- get time from a ip address, use tcp protocl
local function gettime(ip)
  -- print('connect ', ip)
  local tcp = socket.tcp()
  tcp:settimeout(3)
  tcp:connect(ip, 37)
  success, time = pcall(nstol, tcp:receive(4))
  tcp:close()
  return success and time or nil
end
 
local function nettime()
  for _, ip in pairs(server_ip) do
    time = gettime(ip)
    if time then 

      return time
    end
  end
end

function TimeUtil.isLegalTime()
  local localtime = os.time()
  local nettime = nettime()-2208988800
  -- local date = os.date("*t",time)
  -- if localdate["year"] == date["year"] and localdate["month"] == date["month"] and localdate["day"] == date["day"] then 
  --   return true
  -- end
  return math.abs(localtime - nettime) < 3600 --误差不超过一小时
end

function TimeUtil.checkServerTime(callback)
    local requestcallback = function (event) 
        if event.name == "completed" then
            local responsedata = json.decode(event.request:getResponseData())
            if responsedata["getServerTimeRes"]["code"] == 1 then
              local nettime = math.floor(responsedata["getServerTimeRes"]["serverTime"]/1000)
              local localtime = os.time()
              if callback then callback("ok",{code = 1,time = nettime,islegal = math.abs(localtime-nettime) < 3600}) end
            else
              if callback then callback("ok",{code = 0}) end
            end
        elseif event.name == "failed" then
            if callback then callback("error",event.request:getErrorMessage()) end
        end
    end
    Util.requestHttp(Util.getLeadBoardURL(),requestcallback,"POST",json.encode({getServerTime = {}}))
end

return TimeUtil
