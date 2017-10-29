
TimerManager = {}

function TimerManager:init()
    self._timerDic = {}
    self._funcToTimerDic = {}
    self._funcListDic = {}
    self._paramsDic = {}
    self._countDic = {}
end

function TimerManager:finalize()
    for _, timer in pairs(self._timerDic) do
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer.schedule)
    end
    
    self._timerDic = {}
    self._funcToTimerDic = {}
    self._funcListDic = {}
    self._paramsDic = {}
    self._countDic = {}
end

--
--         * @param delay 延时ms
--         * @param func  方法
--        * @param count 执行次数，默认-1代表无限次
--        * @param args  参数列表
--

function TimerManager:getKey(func, obj)
    return tostring(func) .. tostring(obj)
end

function TimerManager:addOnce(delay, func, obj, ...)
    if self._funcToTimerDic == nil then --还没有初始化，直接执行了
        func(obj, ...)
        return
    end
    self:add(delay, func, obj, 1, ...)
end

function TimerManager:add(delay, func, obj, count, ...)
    if func == nil then
        return
    end
    count = count or -1
    local key = self:getKey(func,obj)
    self:remove(func, obj)
    if count == 0 then
        return
    end

    self._funcToTimerDic[key] = self:createTimer(delay, func, obj)
    self._paramsDic[key] = {...}
    self._countDic[key] = {0, count}
    table.insert(self._funcListDic[key], {func = func, obj = obj})
end

function TimerManager:remove(func, obj)
    if func == nil then
        return
    end
    
    local key = self:getKey(func,obj)
    if self._funcToTimerDic[key] == nil then
        return
    end

    local timer = self._funcToTimerDic[key]
    self._funcToTimerDic[key] = nil
    self._paramsDic[key] = nil
    self._countDic[key] = nil
    
    local funcList = self._funcListDic[key]
    
    local index = -1
    for i, var in pairs(funcList) do
        if var.func == func and var.obj == obj then
    	    index = i
    	    break
    	end
    end
    
--    local index = table.indexOf(funcList, func)
    if index > -1 then
        table.remove(funcList, index)
    end
    if #funcList == 0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer.schedule)
        
        self._funcListDic[key] = nil
        self._timerDic[key] = nil
    end
end

function TimerManager:createTimer(delay,func, obj)

    local function update(dt)
        self:timerHandler(delay,func, obj)
    end

    local key = self:getKey(func,obj)
    if self._timerDic[key] == nil then
        local schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, delay / 1000 ,false)
        self._timerDic[key] = {schedule = schedule, delay = delay}
    end

    if self._funcListDic[key] == nil then
        self._funcListDic[key] = {}
    end

    return self._timerDic[key]
end

function TimerManager:timerHandler(delay,func, obj)
    local key = self:getKey(func,obj)
    local funcList = self._funcListDic[key]
    local len = #funcList
    for i=len, 1, -1 do
    	local var = funcList[i]
        local func = var.func
        local obj = var.obj
        
        local key = self:getKey(func,obj)
        local params = self._paramsDic[key]
        local count = self._countDic[key]
        
        if func ~= nil and params ~= nil 
            and count ~= nil and obj ~= nil then
            
            if count[2] ~= -1 then
                count[1] = count[1] + 1
                if count[1] >= count[2] then
                    self:remove(func, obj) --先移除 再回调
                end
            end
            
            local maxKey = table.maxKey(params)
            func(obj, unpack(params, 1, maxKey))
    	end
    end
end
















