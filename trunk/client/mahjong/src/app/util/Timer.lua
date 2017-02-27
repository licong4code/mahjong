--[[
计时器类
以秒为单位
]]

SceneTimeCount = "SceneTimeCount"       --当前场景的时间
PlayGameTimeCount = "PlayGameTimeCount" --游戏的总时间
TireTimeCount = "TireTimeCount"         --疲劳值时间统计

local Timer = {
    _scheduler = cc.Director:getInstance():getScheduler(),
    _timers = {},
    time = {},
    run = {}
}
--开始计时
function Timer:start(key,callback)
    if not self._timers[key] then
        self.time[key] = 0
        local timerId
        local onTick = function(dt)
            self.time[key] =  self.time[key]+1
        end
        timerId = self._scheduler:scheduleScriptFunc(onTick, 1, false)
        self._timers[key] = timerId
    end
end

--重新开始计时
function Timer:restart(key)
    if self.time[key] then
        self.time[key] = 0
    end
    self:start(key)
end

--停止指定计时器
function Timer:stop(key)
    self:kill(self._timers[key])
    self._timers[key] = nil
end

function Timer:getTime(key)
    return self.time[key]
end

function Timer:kill(timerId)
    if timerId then
         self._scheduler:unscheduleScriptEntry(timerId)
    end
end

--停止所有所有定时器
function Timer:stopAll()
    for key, timerId in pairs(self._timers) do
        self:kill(timerId)
    end
end

function Timer:countdown(key,cd,callback)
    if not self._timers[key] then
        self.time[key] = cd
        self.run[key] = true
        local onTick = function(dt)
            if self.run[key] then
                self.time[key] = self.time[key] - 1
                if callback then callback(self.time[key]) end
            end
        end
        local timerId = self._scheduler:scheduleScriptFunc(onTick, 1, false)
        self._timers[key] = timerId
    end
end

function Timer:pause(key)
    self.run[key] = false
end

function Timer:resume(key)
     self.run[key] = true
end
return Timer
