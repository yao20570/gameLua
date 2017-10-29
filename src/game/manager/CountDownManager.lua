
--倒计时管理器
CountDownManager = {}

function CountDownManager:init()
    GameConfig.serverTime = os.time()
    self._countMap = {}
    
    self._curCountTime = 0
    self._isRunning = false
end

function CountDownManager:finalize()
    TimerManager:remove(self.update, self)
    self._isRunning = false
end

function CountDownManager:startCountDown()
    self._isRunning = true
    TimerManager:add(1000,self.update,self,-1)
end

function CountDownManager:stopCountDown()
    TimerManager:remove(self.update, self)
    self._isRunning = false
end

function CountDownManager:add(remainTime, onTick, obj)
    if self._isRunning == false then
        self:startCountDown()
    end
    local key = self:getKey(onTick,obj)
    self._countMap[key] = {remainTime = remainTime, obj = obj, onTick = onTick, addTime = GameConfig.serverTime}
end

function CountDownManager:remove(onTick, obj)
    local key = self:getKey(onTick,obj)
    self._countMap[key] = nil
end

function CountDownManager:update(dt)
    dt = 1 / cc.Director:getInstance():getScheduler():getTimeScale()
    if table.size(self._countMap) == 0 then
        self:stopCountDown()
        return
    end
    if self._curCountTime + dt < 1  then
        self._curCountTime = self._curCountTime + dt
        return
    end
    self._curCountTime = 0
    local removeKeyList = {}
    for key, value in pairs(self._countMap) do
    	local curRemainTime = self:getFixRemainTime(value)
    	local onTick = value.onTick
    	local obj = value.obj
    	onTick(obj, curRemainTime, dt)
    	if curRemainTime <= 0 then
            table.insert(removeKeyList, key)
    	end
    end
    
    for _, key in pairs(removeKeyList) do
    	self._countMap[key] = nil
    end
    
    GameConfig.serverTime = GameConfig.serverTime + dt
end

--通过添加时间 更新次数 返回剩余的时间 修复时间差
function CountDownManager:getFixRemainTime(value)
    local remainTime = value.remainTime
    local addTime = value.addTime
    
    local curTime = GameConfig.serverTime
    
    local updateCount = curTime - addTime
    local curRemainTime = remainTime - updateCount
    
    return math.ceil(curRemainTime)
    
end

function CountDownManager:getKey(func, obj)
    return tostring(func) .. tostring(obj)
end

--TODO
