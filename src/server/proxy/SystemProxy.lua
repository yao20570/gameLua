-------------
----系统相关处理代理
-------------
module("server", package.seeall)

SystemProxy = class("SystemProxy", BasicProxy)


-----------M3.M30000.S2C
--List<M3.TimeInfo> m3info, PlayerReward reward, List<PlayerTask> playerTasks
function SystemProxy:getTimerNotify(m3infos, reward, playerTasks)
    local infoList = {}

--    self:checkResource() --TODO 有问题

    --checkOutLineAuto
    self:checkBuildingLeveUp(m3infos, playerTasks)
    --checkEnergyTimer
    --checkBoomTimer
    --checkArena

    --ItemBuffProxy


    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    timerdbProxy:checkBuildCreate(m3infos, reward, playerTasks)

    local tdbs = timerdbProxy:getTdbs()
    for _, tdb in pairs(tdbs) do
    	if tdb.lestime > 0 then
    		local info = {}
    		info.bigtype = tdb.type
    		info.smalltype = tdb.smallType
    		info.othertype = tdb.otherType
            info.remainTime = tdb.lestime --tdb.lasttime --
            table.insert(infoList, info)
    	end
    end

    local builder = {}

    builder.timeInfos = infoList

    return builder


end

--执行升级成功
function SystemProxy:doBuildingLevelUp(buildType, index)
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)

    --
    local level = resFunBuildProxy:getResFunBuildingLevelBySmallType(buildType, index)
    timerdbProxy:delTimer(TimerDefine.BUILDING_LEVEL_UP, buildType, index)

    --TODO 繁荣度
    -- playerProxy.upBuilderOrCreate(buildType, level)

    resFunBuildProxy:addResFunBuildLevel(buildType, index)
end

--资源时间检验
function SystemProxy:checkResource()
	local timerProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
	local stattime = timerProxy:getLastOperationTime(TimerDefine.TIMER_TYPE_RESOUCE, 0, 0)

	--TODO 
	--[[
	 if (falg == false) {
            startime = stattime;
            falg = true;
        }
        if (boomcheck == false) {
            tonormaltime = stattime + feixun2normalNeedTime();
        }
	]]

	--TODO ItemBuffProxy
	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
	--产量
	local addtale = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_taelyield)
	local addiron = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_ironyield)
	local addwood = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_woodyield)
	local addstone = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_stonesyield)
	local addfood = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_foodyield)
	
	--当前数量
	local tale = playerProxy:getPowerValue(PlayerPowerDefine.POWER_tael)
	local rion = playerProxy:getPowerValue(PlayerPowerDefine.POWER_iron)
	local wood = playerProxy:getPowerValue(PlayerPowerDefine.POWER_wood)
	local stones = playerProxy:getPowerValue(PlayerPowerDefine.POWER_stones)
	local food = playerProxy:getPowerValue(PlayerPowerDefine.POWER_food)

	--容量
	local talelimt = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_taelcontent)
	local rionlimt = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_ironcontent)
	local woodlimt = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_woodcontent)
	local stoneslimt = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_stonescontent)
	local foodlimt = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_foodcontent)

	local checktime = 0

	--TODO bufferTime
	--[[
	if (lastbufferTime == 0l ||stattime>=lastbufferTime) {
            lastbufferTime = itemBuffProxy.getWillBeOverdueBuff(stattime);
            checktime = lastbufferTime;
        }else {
            checktime=lastbufferTime;
        }
        if (feixun2normalNeedTime() != 0 && lastbufferTime > tonormaltime&&stattime<=tonormaltime&&boomcheck==false) {
            checktime = tonormaltime;
            boomcheck=true;
        }
    ]]

    local second = 0
    --[[
     if (checktime <= tonormaltime) {
            second = (checktime - stattime) / 1000 * 0.5;
        } else {
            second = (checktime - stattime) / 1000;
        }
    ]]

    second = second / 3600
    addtale = addtale * second
    addiron = addiron * second
    addwood = addwood * second
    addstone = addstone * second
    addfood = addfood * second

    if tale < talelimt then
    	local addt = addtale + tale
    	if addt > talelimt then
    		addt = addt - talelimt
    	else
    		addt = addtale
    	end

    	playerProxy:addPowerValue(ResourceDefine.POWER_tael, addt)
    end

    if rion < rionlimt then
    	local addr = addiron + tale
    	if addr > rionlimt then
    		addr = addr - talelimt
    	else
    		addr = addiron
    	end

    	playerProxy:addPowerValue(ResourceDefine.POWER_iron, addr)
    end

    if wood < woodlimt then
    	local addw = addwood + tale
    	if addw > woodlimt then
    		addw = addw - woodlimt
    	else
    		addw = addwood
    	end

    	playerProxy:addPowerValue(ResourceDefine.POWER_wood, addw)
    end

    if stones < stoneslimt then
    	local adds = addstone + tale
    	if adds > stoneslimt then
    		adds = adds - stoneslimt
    	else
    		adds = addstone
    	end

    	playerProxy:addPowerValue(ResourceDefine.POWER_stones, adds)
    end

    if food < foodlimt then
    	local addf = addfood + food
    	if addf > foodlimt then
    		addf = addf - foodlimt
    	else
    		addf = addfood
    	end

    	playerProxy:addPowerValue(ResourceDefine.POWER_food, addf)
    end

    timerProxy:setLesTime(TimerDefine.TIMER_TYPE_RESOUCE, 0, 0, TimerDefine.DEFAULT_TIME_RESOUCE)
    timerProxy:setLastOperationTime(TimerDefine.TIMER_TYPE_RESOUCE, 0, 0, GameConfig.serverTime)


end

--建筑升级校验  List<M3.TimeInfo> m3info
function SystemProxy:checkBuildingLeveUp(m3info, playerTasks)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local map = timerdbProxy:getBuildingLevelUpTimer()
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local now = TimerDefine.triggerTime --30000的检测时间，用触发时间，不然会有问题
    for str, time in pairs(map) do
        local strAry = string.split(str, ",")
        local smalltype = tonumber(strAry[1])
        local index = tonumber(strAry[2])
        if now >= time then
            local timeInfoBuilder = {}
            timeInfoBuilder.remainTime = 0
            timeInfoBuilder.bigtype = TimerDefine.BUILDING_LEVEL_UP
            timeInfoBuilder.smalltype = smalltype
            timeInfoBuilder.othertype = index
            table.insert(m3info, timeInfoBuilder)
            --TODO 升级成功执行操作并且删除timer ;
            self:doBuildingLevelUp(smalltype, index)
        else
            --重新给客户端发送新的校验时间
            local les = time - now
            timerdbProxy:setLesTime(TimerDefine.BUILDING_LEVEL_UP, smalltype, index, les)
        end
    end
    --TODO 自动升级建筑 交由服务器校验 同步
    if resFunBuildProxy:isAutoLeveling(GameConfig.serverTime) then
        resFunBuildProxy:buildAutoLevelUp(m3info)
    end
    local lastime = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
    local lestime = lastime - GameConfig.serverTime
    if lestime <= 0 then
        lestime = 0
        local num = timerdbProxy:getTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
        if num > 0 then
            lestime = num
        end
    end
    timerdbProxy:setLesTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, lestime)

end

function SystemProxy:doBuildingLevelUp(buildType, index)
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    --建筑附加
    local level = resFunBuildProxy:getResFunBuildingLevelBySmallType(buildType, index)
    timerdbProxy:delTimer(TimerDefine.BUILDING_LEVEL_UP, buildType, index)

    --TODO 繁荣度
    resFunBuildProxy:addResFunBuildLevel(buildType, index)
    resFunBuildProxy:setFinishLevelTime(buildType, index, GameConfig.serverTime)
end