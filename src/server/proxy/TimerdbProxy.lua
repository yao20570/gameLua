-------------
----定时器处理代理
-------------
module("server", package.seeall)

TimerdbProxy = class("TimerdbProxy", BasicProxy)

function TimerdbProxy:ctor(m30000)
    self._tdbs = {}
    self._idIndex = 0
    self:initTimer(m30000)
end

function TimerdbProxy:initTimer(m30000)
    self._tdbs = {}  --TODO timeInfos 这里还需要有attr相关的数据，不然下线后，相关的处理会有问题，比如取消生产
    local timeInfos = m30000.timeInfos
    for _, timeInfo in pairs(timeInfos) do
        --TODO num refershType
        local id = self:addTimer(timeInfo.bigtype, 0, timeInfo.lestime, 0, timeInfo.smalltype, timeInfo.othertype)
        local tdb = self:getTimerByLongId(id)
        tdb.lestime = timeInfo.lestime
        tdb.lasttime = timeInfo.lasttime
        tdb.num = timeInfo.num
        tdb.attr1 = timeInfo.attr1
        tdb.attr2 = timeInfo.attr2
        tdb.attr3 = timeInfo.attr3
        tdb.begintime = timeInfo.begintime
    end

    self:addTimer(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, TimerDefine.TIMER_REFRESH_NONE, 0, 0)
    
end

--直接刷新定时器数据
function TimerdbProxy:updateTimer(timeInfos)
    self._idIndex = 0
    self._tdbs = {}
    local map = self:getBuildingLevelUpTimer()
    for _, timeInfo in pairs(timeInfos) do
        local id = self:addTimer(timeInfo.bigtype, 0, timeInfo.lestime, 0, timeInfo.smalltype, timeInfo.othertype)
        local tdb = self:getTimerByLongId(id)
        if tdb ~= nil then
            tdb.lestime = timeInfo.lestime
            tdb.lasttime = timeInfo.lasttime
            tdb.num = timeInfo.num
            tdb.attr1 = timeInfo.attr1
            tdb.attr2 = timeInfo.attr2
            tdb.attr3 = timeInfo.attr3
            tdb.begintime = timeInfo.begintime
        end
        
        map[timeInfo.bigtype .. "," .. timeInfo.othertype] = nil
    end
    
    self:addTimer(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, TimerDefine.TIMER_REFRESH_NONE, 0, 0)
    
    local notUpList = {} --出现不同步的建筑任务了，需要更新对应的建筑数据
    for key, _ in pairs(map) do
        table.insert(notUpList, key)
    end
    return notUpList
end

function TimerdbProxy:getTdbs()
    return self._tdbs
end

--获得定时器，没有的参数填0
function TimerdbProxy:getTimerByType(bigType, smallType, otherType)
	for _, tdb in pairs(self._tdbs) do
		if tdb.type == bigType and tdb.smallType == smallType and 
			tdb.otherType == otherType then
			return tdb
		end
	end
	return nil
end

function TimerdbProxy:isHasTypeId(bigType, smallType, otherType)
    for _, tdb in pairs(self._tdbs) do
		if tdb.type == bigType and tdb.smallType == smallType and 
			tdb.otherType == otherType then
			return true
		end
	end
	return false
end

--[[
/**
* 添加定时器
* type 定时器大类
* smallType 定时器小类
* otherType 定时器其他类    type  smallType otherType 确定一个定时器
* num 定时器初始数据
* lestime  倒计时时间秒 0的话不发送给客户端 每次请求处理都会重新设置
* refershType 每天刷新时间点  按小时算
* *
*/
]]
function TimerdbProxy:addTimer(type, num, lesTime, refershType, smallType, otherType)
    if self:isHasTypeId(type, smallType, otherType) then
    	return 0
    else
    	return self:createTimer(type, num, lesTime, refershType, smallType, otherType)
    end
end

function TimerdbProxy:createTimer(type, num, lesTime, refershType, smallType, otherType)
    self._idIndex = self._idIndex + 1
    local tdb = Timerdb.new()
    tdb.id = self._idIndex
    tdb.type = type
    tdb.num = num
    tdb.lasttime = GameConfig.serverTime
    tdb.refreshType = refershType
    tdb.smallType = smallType
    tdb.otherType = otherType
    tdb.begintime = GameConfig.serverTime
    tdb.lestime = lesTime
    table.insert(self._tdbs, tdb )

    
    return tdb.id
end

function TimerdbProxy:getTimerByLongId(id)
    for _,tdb in pairs(self._tdbs) do
        if tdb.id == id then
            return tdb
        end
    end
    return nil
end

function TimerdbProxy:setAttrValue(id, type, value)
    local tdb = self:getTimerByLongId(id)
    if tdb ~= nil then
        tdb["attr" .. type] = value
    end
end

--加时间
function TimerdbProxy:addLesTime(type, smallType, otherType, add)
	local tdb = self:getTimerByType(type, smallType, otherType)
	if tdb ~= nil then
		local lesTime = tdb.lestime
		tdb.lestime = lesTime + 1
	end
end

function TimerdbProxy:setLesTime(type, smallType, otherType, lesTime)
    local tdb = self:getTimerByType(type, smallType, otherType)
	if tdb ~= nil then
		tdb.lestime = lesTime
	end
end

function TimerdbProxy:getAttr1(type, smallType, otherType)
    local tdb = self:getTimerByType(type, smallType, otherType)
    if tdb == nil then
        return 0
    end
    return tdb.attr1
end

--上次操作时间
function TimerdbProxy:getLastOperationTime(type, smallType, otherType)
    local tdb = self:getTimerByType(type, smallType, otherType)
    if tdb == nil then
    	return -1
    end
    return tdb.lasttime or -1
end

--设置操作时间
function TimerdbProxy:setLastOperationTime(type, smallType, otherType, time)
    local tdb = self:getTimerByType(type, smallType, otherType)
    if tdb ~= nil then
    	tdb.lasttime = time
    end
end

function TimerdbProxy:setTimerNum(type, smallType, otherType, num)
    local tdb = self:getTimerByType(type, smallType, otherType)
    if tdb ~= nil then
        tdb.num = num
    end
end

function TimerdbProxy:getTimerNum(type, smallType, otherType)
    local tdb = self:getTimerByType(type, smallType, otherType)
    if tdb == nil then
        return 0
    end
    return tdb.num or 0
end


--获取刷新时间
function TimerdbProxy:getTimerRefreshTime(type, smallType, otherType)
	local tdb = self:getTimerByType(type, smallType, otherType)
	----- reFreshTimer(tdb);
	if tdb == nil then
		return 0
	end
	return tdb.refreshType
end

function TimerdbProxy:setTimerRefreshTime(type, smallType, otherType, time)
	local tdb = self:getTimerByType(type, smallType, otherType)
	if tdb ~= nil then
		tdb.refreshType = time
	end
end

function TimerdbProxy:getTimerlesTime(type, smallType, otherType)
    local tdb = self:getTimerByType(type, smallType, otherType)
    if tdb == nil then
    	return 0
    end
    local les = tdb.lestime
    if les < 0 then
    	les = 0
    end
    return les
end

--根据bigtype获得
function TimerdbProxy:getTimerdbListByType(type)
	local list = {}
	for _,tdb in pairs(self._tdbs) do
		if tdb.type == type then
			table.insert(list, tdb)
		end
	end
	return list
end

--列表是否有smallType类型
function TimerdbProxy:bigTypeHasSmallType(list, smallType)
	for _, tdb in pairs(list) do
		if tdb.smallType == smallType then
			return true
		end
	end
	return false
end

--删除定时器
function TimerdbProxy:delTimer(bigType, smallType, otherType)
    local list = self:getTimerdbListByType(bigType)
    for _, tdb in pairs(list) do
    	if tdb.smallType == smallType and tdb.otherType == otherType then
    		table.removeValue(self._tdbs, tdb)
    	end
    end
end


------建筑相关---------------
--获得建筑升级倒计时
function TimerdbProxy:getBuildingLevelUpTimer()
	local map = {}
	local list = self:getTimerdbListByType(TimerDefine.BUILDING_LEVEL_UP)
	for _, tdb in pairs(list) do
		map[tdb.smallType .. "," .. tdb.otherType] = tdb.lasttime
	end
    return map
end

--获取生产队列定时器执行中数量
function TimerdbProxy:getCreatingNum(smallType)
    local num = 0
    for _, tdb in pairs(self._tdbs) do
    	if tdb.type == TimerDefine.BUILD_CREATE and tdb.smallType == smallType and
    		tdb.lasttime > GameConfig.serverTime then
    		num = num + 1
    	end
    end
    return num
end

--获取佣兵定时器执行中最大orfer
function TimerdbProxy:getCreateBigNum(smallType)
    local num = 0
    for _, tdb in pairs(self._tdbs) do
        if tdb.type == TimerDefine.BUILD_CREATE and smallType == tdb.smallType 
            and tdb.lasttime > GameConfig.serverTime then
            if tdb.otherType > num then
                num = tdb.otherType
            end
        end
    end
    return num
end

--某种科技是否可以升级
function TimerdbProxy:scienceIsCanLevel(smallType, typeId)
    for _, tdb in pairs(self._tdbs) do
    	if tdb.type == TimerDefine.BUILD_CREATE and tdb.smallType == smallType and
    		tdb.lasttime > GameConfig.serverTime and tdb.attr1 == typeId then
    		return false
    	end
    end
    return true
end

function TimerdbProxy:getBuildIndexCreate(smallType)
    local list = {}
    for _, tdb in pairs(self._tdbs) do
    	if tdb.type == TimerDefine.BUILD_CREATE and tdb.smallType == smallType and
    		tdb.lasttime > GameConfig.serverTime then
            table.insert(list, tdb)
    	end
    end
    return list
end

--获得建筑生产队列 List<M10.ProductionInfo>
function TimerdbProxy:getProductionInfo(index, buildType)
	local list = {}
	if table.indexOf(ResFunBuildDefine.PRODUCTBUILD, buildType) < 0 then
		return list
	end

	local proList = self:getBuildIndexCreate(index)
	local now = GameConfig.serverTime

	--TODO 对otherType进行排序
	for _, tdb in pairs(proList) do
        local time = tdb.lasttime - now
		local lestime = tdb.attr2
		if time > 0 then
			local productionInfo = {}
			productionInfo.typeid = tdb.attr1
			productionInfo.num = tdb.num
			if time - 1 <= lestime then
				productionInfo.state = 1
				productionInfo.remainTime = time
			else
				productionInfo.state = 2
				productionInfo.remainTime = lestime
			end
			productionInfo.order = tdb.otherType
            table.insert(list, productionInfo)
		end
	end

	return list
end

function TimerdbProxy:getLastCreateTime(buildIndex, order)
    local tdb = self:getTimerByType(TimerDefine.BUILD_CREATE, buildIndex, order)
    if tdb == nil then
    	return GameConfig.serverTime
    end
    return tdb.lasttime
end

--领取生产时 执行中数量
function TimerdbProxy:checkBuildCreate(m3info, reward, playerTasks)
    local soldierProxy = self:getProxy(ActorDefine.SOLDIER_PROXY_NAME)
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
    local systemProxy = self:getProxy(ActorDefine.SYSTEM_PROXY_NAME)
    local now = GameConfig.serverTime
    local tdbList = self:getTimerdbListByType(TimerDefine.BUILD_CREATE)
    for _, tdb in pairs(tdbList) do
        if now >= tdb.lasttime then -- 1秒误差  + 1
            --制造完成
            local num = tdb.num
            local typeId = tdb.attr1
            local buildType = resFunBuildProxy:getResFunBuildType(ResFunBuildDefine.BUILDE_TYPE_FUNTION, tdb.smallType)
            local index = resFunBuildProxy:getResFunBuildingByIndexSmallType(ResFunBuildDefine.BUILDE_TYPE_FUNTION, buildType)
            if buildType == ResFunBuildDefine.BUILDE_TYPE_TANK then
                soldierProxy:addSoldierNum(typeId, num)
                rewardProxy:addSoldierToReward(reward, typeId, num)
                --TODO add Task
            elseif buildType == ResFunBuildDefine.BUILDE_TYPE_SCIENCE then
                --TODO technologyProxy
                local technologyProxy = self:getProxy(ActorDefine.TECHNOLOGY_PROXY_NAME)
                technologyProxy:addTechnologyLevel(typeId)
                --TODO task
                technologyProxy:expandPowerTechnology()

            elseif buildType == ResFunBuildDefine.BUILDE_TYPE_RREFIT then
                soldierProxy:addSoldierNum(typeId, num)
                rewardProxy:addSoldierToReward(reward, typeId, num)
            end
            local timeInfo = {}
            timeInfo.bigtype = tdb.type
            timeInfo.smalltype = buildType
            timeInfo.othertype = tdb.smallType
            timeInfo.remainTime = 0
            table.insert(m3info, timeInfo)
            self:delTimer(tdb.type, tdb.smallType, tdb.otherType)
        else
            local time = tdb.lasttime - now
            local lestime = tdb.attr2
            if time > 0 then
                if time - 1 >= lestime then
                    tdb.lestime = 0
                else
                    tdb.lestime = time
                end
            end
        end
    end
end

--修改某个建筑的生产队列的完成时间
function TimerdbProxy:modifyBuildFinishTime(index, time, order)
    local time = time - self:getOtherTime(order, index)
    for _, tdb in pairs( self._tdbs ) do
    	if tdb.type == TimerDefine.BUILD_CREATE and tdb.smallType == index then
    		if tdb.otherType >= order then
    			tdb.lasttime = tdb.lasttime - time
    		end
    	end
    end
end

--获得上满几个的时间
function TimerdbProxy:getOtherTime(order, index)
    local time = 0
    for _, tdb in pairs(self._tdbs) do
    	if tdb.type == TimerDefine.BUILD_CREATE and 
    		tdb.smallType == index then
    		if tdb.otherType < order then
                time = time + self:getLastOperationTime(TimerDefine.BUILD_CREATE, index,
    				tdb.otherType) - GameConfig.serverTime
    		end
    	end
    end
    return time
end

--获得正在升级的建筑完成时间
function TimerdbProxy:getLevelUpEndTime()
	local set = {}
	local now = GameConfig.serverTime
	for _, tdb in pairs(self._tdbs) do
		if tdb.type == TimerDefine.BUILDING_LEVEL_UP then
			if now < tdb.lasttime  then
				table.insert(set, tdb.lasttime)
			end
		end
	end

	return set
end

--获得建筑剩余升级队列 --TODO 
function TimerdbProxy:getBuildLevelNum()
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    --TODO int expandBbuildSize = itemBuffProxy.getValidBuildSize();
    
    local hadbuildSize = playerProxy:getPowerValue(PlayerPowerDefine.POWER_buildsize)
    local times = hadbuildSize
    local hasnum = 0
    local now = GameConfig.serverTime
    for _, tdb in pairs(self._tdbs) do
        if tdb.type == TimerDefine.BUILDING_LEVEL_UP then
            if now < tdb.lasttime then
                hasnum = hasnum + 1
            end
        end
    end
    return times - hasnum
end




------------------