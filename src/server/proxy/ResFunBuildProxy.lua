-------------
----建筑处理代理
-------------

module("server", package.seeall)

ResFunBuildProxy = class("ResFunBuildProxy", BasicProxy)

function ResFunBuildProxy:ctor(buildingInfos)
    self._rfbs = {}
--    self:initBuildings(buildingInfos)
end

function ResFunBuildProxy:initBuildings(buildingInfos)
    self._rfbs = {}
--    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    TimerDefine.triggerTime = os.time()
	for _, buildingInfo in pairs(buildingInfos) do
		local buildingType = buildingInfo.buildingType
--        local lesTime = self:getTimerlesTime(TimerDefine.BUILDING_LEVEL_UP, buildingType, buildingInfo.index)
		local rfb = ResFunBuilding.new()
		if table.indexOf(ResFunBuildDefine.BASEBUILDLIST, buildingType) >= 0 then  --功能建筑
			rfb.bigType = ResFunBuildDefine.BUILDE_TYPE_FUNTION
			rfb.smallType = buildingType
			rfb.index = buildingInfo.index
			rfb.level = buildingInfo.level
            rfb.nextLevelTime = GameConfig.serverTime + buildingInfo.levelTime
	    else
	    	rfb.bigType = ResFunBuildDefine.BUILDE_TYPE_RESOUCE
            rfb.smallType = buildingType
			rfb.index = buildingInfo.index
			rfb.level = buildingInfo.level
            rfb.nextLevelTime = GameConfig.serverTime + buildingInfo.levelTime
		end
        table.insert(self._rfbs, rfb)
	end
	
    logger:error("==========initBuildings==========serverTime:%s" , tostring(GameConfig.serverTime))
	
	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
	local isHasAutoLevel = self:isHasAutoLevel()
	if isHasAutoLevel == true then --正在自动升级，建筑状态 开
        playerProxy:setAutoBuildState(TimerDefine.BUILDAUTOLEVEL_OPEN)
	else
        playerProxy:setAutoBuildState(TimerDefine.BUILDAUTOLEVEL_OFF)
	end
end

function ResFunBuildProxy:updateAllBuilding(buildingInfos)
    self._rfbs = {}
    self:initBuildings(buildingInfos)
end

--同步更新服务器建筑数据
function ResFunBuildProxy:updateBuildings(buildingInfos)
    TimerDefine.triggerTime = os.time()
    for _, buildingInfo in pairs(buildingInfos) do
        local rfb = self:getResFunBuildingByIndexSmallType(buildingInfo.buildingType, buildingInfo.index)
        if rfb ~= nil then
            rfb.level = buildingInfo.level
            rfb.nextLevelTime = GameConfig.serverTime + buildingInfo.levelTime
        end
    end
    
end

--初始化建筑
function ResFunBuildProxy:initResFunBuild(getlist)
    --基地初始化
    local flist = ConfigDataManager:getConfigData(ConfigData.BuildOpenConfig)
    local combuild = self:getResFunBuildingByIndexSmallType(ResFunBuildDefine.BUILDE_TYPE_COMMOND, 1)
    if combuild == nil then --理论上不会执行到
        local json = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildOpenConfig, "type", ResFunBuildDefine.BUILDE_TYPE_COMMOND)
        self:addResFunBuild(ResFunBuildDefine.BUILDE_TYPE_FUNTION, json.type, json.ID, json.initlevel, 1)
        combuild = self:getResFunBuildingByIndexSmallType(ResFunBuildDefine.BUILDE_TYPE_COMMOND, 1)
    end

    local fblist = self:getResFunBuildingByBigType(ResFunBuildDefine.BUILDE_TYPE_FUNTION)
    for _, json in pairs(flist) do
        if combuild.level == json.condition then
            table.insert(getlist, {json.type, json.ID})
        end
    end

    if #fblist < #flist then
        for _, json in pairs(flist) do
            if self:getResFunBuildingByIndexBigType(ResFunBuildDefine.BUILDE_TYPE_FUNTION, json.ID) == nil then
                if combuild.level > json.condition then
                    self:addResFunBuild(ResFunBuildDefine.BUILDE_TYPE_FUNTION, json.type, json.ID, json.initlevel, 1)
                else
                    self:addResFunBuild(ResFunBuildDefine.BUILDE_TYPE_FUNTION, json.type, json.ID, json.initlevel, 0)
                end
            end
        end
        self:init()
    end

    --建筑资源初始化
    local rlist = ConfigDataManager:getConfigData(ConfigData.BuildBlankConfig)
    local rblist = self:getResFunBuildingByBigType(ResFunBuildDefine.BUILDE_TYPE_RESOUCE)
    for _, json in pairs(rlist) do
        if combuild.level == json.openlv then
            table.insert(getlist, {0, json.ID})
        end
    end

    --TODO 
    if #rblist < #rlist then
        for _, json in pairs(rlist) do
            if self:getResFunBuildingByIndexBigType(ResFunBuildDefine.BUILDE_TYPE_RESOUCE, json.ID) == nil then
                if combuild.level > json.openlv then
                    self:addResFunBuild(ResFunBuildDefine.BUILDE_TYPE_RESOUCE, 0, json.ID, 0, 1)
                else
                    self:addResFunBuild(ResFunBuildDefine.BUILDE_TYPE_RESOUCE, 0, json.ID, 0, 0)
                end
            end
        end
    end
    
end

function ResFunBuildProxy:addResFunBuild(bigType, smallType, index, level, state)
	self:createResFunBuild(bigType, smallType, index, level, state)
end

function ResFunBuildProxy:createResFunBuild(bigType, smallType, index, level, state)
    local rfb = ResFunBuilding.new()
    rfb.bigType = bigType
    rfb.smallType = smallType
    rfb.index = index
    rfb.level = level
    rfb.state = state
    rfb.lastBlanceTime = GameConfig.serverTime
    rfb.nextLevelTime = GameConfig.serverTime

    table.insert(self._rfbs, rfb)
end

function ResFunBuildProxy:getResFunBuildingByBigType(bigType)
    local list = {}
    for _, rfb in pairs(self._rfbs) do
    	if rfb.bigType == bigType then
    		table.insert(list, rfb)
    	end
    end
    return list
end

--通过Index ，子类型 获取rfb
function ResFunBuildProxy:getResFunBuildingByIndexSmallType(smallType, index)
    for _, rfb in pairs(self._rfbs) do
    	if rfb.index == index and rfb.smallType == smallType then
    		return rfb
    	end
    end
    return nil
end

function ResFunBuildProxy:getResFunBuildingByIndexBigType(bigType, index)
	for _, rfb in pairs(self._rfbs) do
    	if rfb.index == index and rfb.bigType == bigType then
    		return rfb
    	end
    end
    return nil
end

--是否可以建造该类型
function ResFunBuildProxy:isCanBuildType(smallType, index)
	if table.indexOf(ResFunBuildDefine.BASEBUILDLIST, smallType) >= 0 then
        local info = ConfigDataManager:getConfigById(ConfigData.BuildOpenConfig, index)
		if info ~= nil and info.type == smallType then
			return true
		end
	else
        local info = ConfigDataManager:getConfigById(ConfigData.BuildBlankConfig, index)
		if info ~= nil then
            local canbuild = StringUtils:jsonDecode(info.canbulid)
			if table.indexOf(canbuild, smallType) >= 0 then
				return true
			end
		end
	end
	return false
end

--获得某个建筑的位置
function ResFunBuildProxy:getResFunBuildingByBigsamll(bigType, samllType)
    for _, rfb in pairs( self._rfbs ) do
    	if rfb.bigType == bigType and rfb.smallType == samllType then
    		return rfb.index
    	end
    end

    return -1
end

--根据建筑类型获取等级
function ResFunBuildProxy:getResFunBuildingLevelBySmallType(smallType, index)
    local building = self:getResFunBuildingByIndexSmallType(smallType, index)
    if building ~= nil then
    	return building.level
    end
    return -1
end

--活动某种建筑的最高等级
function ResFunBuildProxy:getMaxLevelByBuildType(buildType)
	local level = 0
	for _, rfb in pairs( self._rfbs ) do
		if rfb.smallType == buildType then
			if rfb.level > level then
				level = rfb.level
			end
	    end
	end
	return level
end

--获得某种类型建筑数量
function ResFunBuildProxy:getBuildTypeNum(buildType)
    local num = 0
    for _, rfb in pairs( self._rfbs ) do
		if rfb.smallType == buildType and rfb.level > 0 then
			num = num + 1
	    end
	end
	return num
end

--获得某个建筑的类型
function ResFunBuildProxy:getResFunBuildType(bigType, index)
    local building = self:getResFunBuildingByIndexBigType(bigType, index)
    if building ~= nil then
    	return building.smallType
    end
    return -1
end

--改变建筑类型
function ResFunBuildProxy:changeResFunBuildType( buildType, index, changeType )
	-- body
	local building = self:getResFunBuildingByIndexSmallType(buildType, index)
	if building ~= nil then
		building.smallType = changeType
	end
end

--改变建筑等级
function ResFunBuildProxy:changeResFunBuildLevel(buildType, index, level)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    if building ~= nil then
    	building.level = level
    end
end

--建筑升级
function ResFunBuildProxy:addResFunBuildLevel(buildType, index)
	local building = self:getResFunBuildingByIndexSmallType(buildType, index)
	if building == nil then
		building = self:getResFunBuildingByIndexBigType(ResFunBuildDefine.BUILDE_TYPE_RESOUCE, index)
	end

	if building ~= nil then
		local level = building.level
		building.level = level + 1
	end
end

--设置建筑升级完成时间
function ResFunBuildProxy:setFinishLevelTime(buildType, index, time)
	local building = self:getResFunBuildingByIndexSmallType(buildType, index)
	if building ~= nil then
        building.nextLevelTime = time
	end
end

function ResFunBuildProxy:getFinishLevelTime(buildType, index)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    local time = building.nextLevelTime - GameConfig.serverTime
    if time < 0 then
    	time = 0
    end

    return time
end


function ResFunBuildProxy:speedCost(second)
    local num = math.ceil( second / 60 ) --TODO 要确认下 向上取整
    return num
end

--根据建筑类型获得确认建筑属于自愿还是功能
function ResFunBuildProxy:getBuildTypeByType(buildType)
	local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildSheetConfig, 'type', buildType)
	if info == nil then
		return 0
	end
	return info.typesheet
end

--根据建筑类型获得确认建筑属于资源还是功能
function ResFunBuildProxy:getBuildTypeByPower(buildType)
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildSheetConfig, 'type', buildType)
	if info == nil then
		return 0
	end
	local power = StringUtils:jsonDecode(info.power) --TODO power字段需要导表
	if #power > 0 then
		return power[1]
	end

	return 0
end

--根据建筑类型获得建筑生产加速消耗的道具
function ResFunBuildProxy:getSpeedLevelNeedItem(buildType, index)
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildSheetConfig, 'type', buildType)
    local prospeeditem = StringUtils:jsonDecode(info.prospeeditem) 
    return prospeeditem[index]
end

--获取等待队列
function ResFunBuildProxy:getHadWaitQueue()
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
    local hadWaitQueue = vipProxy:getVipNum(ActorDefine.VIP_WAITQUEUE) + ResFunBuildDefine.MIN_WAITQUEUE
    return hadWaitQueue
end

--建筑是否资源类型
function ResFunBuildProxy:isResouceType(buildType)
    if table.indexOf(ResFunBuildDefine.RESOUCETYPELIST, buildType) >= 0 then
        return true
    end 
    return false
end

--获得某个建筑的功能开启状态
function ResFunBuildProxy:getResFunBuildStateByIndex(smallType, index)
    local combuild = self:getResFunBuildingByIndexSmallType(ResFunBuildDefine.BUILDE_TYPE_COMMOND, 1)
    if table.indexOf(ResFunBuildDefine.BASEBUILDLIST, smallType) >= 0 then
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.BuildOpenConfig, index)
        if combuild.level < jsonObject.condition then
            return false
        end
    else
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.BuildBlankConfig, index)
        if combuild.level < jsonObject.openlv then
            return false
        end
    end
    return true
end

-------------------------------------------------------------------
--------------------------------------------------------------------
--获取建筑协议信息  M10.BuildingInfo
function ResFunBuildProxy:getBuildingInfo(buildType, index)
    local timedbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local rfb = self:getResFunBuildingByIndexSmallType(buildType, index)
    if rfb == nil then
    	return nil
    end
    local buildingInfo = {}
    buildingInfo.index = rfb.index
    buildingInfo.level = rfb.level
    buildingInfo.buildingType = rfb.smallType
    local time = rfb.nextLevelTime - GameConfig.serverTime
    if time < 0 then
    	time = 0
    end
    buildingInfo.levelTime = time
    buildingInfo.productionInfos = timedbProxy:getProductionInfo(rfb.index, rfb.smallType)
    buildingInfo.buildingDetailInfos = self:getBuildingDetailInfo(rfb.smallType, rfb.index)

    buildingInfo.speedRate = 0 
    local powertype = self:getBuildTypeByPower(buildType)
    if powertype ~= 0 then
        buildingInfo.speedRate = playerProxy:getPowerValue(powertype)
    end
    buildingInfo.productNum = self:getHadWaitQueue()


    return buildingInfo
end

--获取建筑所有 List<M10.BuildingInfo>
function ResFunBuildProxy:getBuildingInfos()
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local list = {}
    local level = self:getResFunBuildingLevelBySmallType(ResFunBuildDefine.BUILDE_TYPE_COMMOND, 1)
    for _, rfb in pairs(self._rfbs) do
        if rfb.bigType == ResFunBuildDefine.BUILDE_TYPE_FUNTION then
            local buildingInfo = {}
            buildingInfo.index = rfb.index
            buildingInfo.level = rfb.level
            buildingInfo.buildingType = rfb.smallType
            local time = 0
            if rfb.nextLevelTime ~= 0 then
                time = rfb.nextLevelTime - GameConfig.serverTime
            end
            if time < 0 then
                time = 0
            end
            buildingInfo.levelTime = time
            buildingInfo.productionInfos = timerdbProxy:getProductionInfo(rfb.index, rfb.smallType)
            buildingInfo.buildingDetailInfos = self:getBuildingDetailInfo(rfb.smallType, rfb.index)
            buildingInfo.speedRate = 0 
            local powertype = self:getBuildTypeByPower(rfb.smallType)
            if powertype ~= 0 then
                buildingInfo.speedRate = playerProxy:getPowerValue(powertype)
            end
            buildingInfo.productNum = self:getHadWaitQueue()
            table.insert(list, buildingInfo)
        else
            local jsonObject = ConfigDataManager:getConfigById(ConfigData.BuildBlankConfig, rfb.index)
            if level >= jsonObject.openlv then
                local buildingInfo = {}
                buildingInfo.index = rfb.index
                buildingInfo.level = rfb.level
                buildingInfo.buildingType = rfb.smallType
                local time = 0
                if rfb.nextLevelTime ~= 0 then
                    time = rfb.nextLevelTime - GameConfig.serverTime
                end
                if time < 0 then
                    time = 0
                end
                buildingInfo.levelTime = time
                buildingInfo.productionInfos = {}
                buildingInfo.buildingDetailInfos = {}
                buildingInfo.speedRate = 0 
                local powertype = self:getBuildTypeByPower(rfb.smallType)
                if powertype ~= 0 then
                    buildingInfo.speedRate = playerProxy:getPowerValue(powertype)
                end
                buildingInfo.productNum = self:getHadWaitQueue()
                table.insert(list, buildingInfo) 
            end
        end
    end
    return list
end

--获得某个类型建筑信息  List<M10.BuildingInfo>
function ResFunBuildProxy:getBuildingInfoByType(buildType)
    local infos = {}
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    for _, rfb in pairs(self._rfbs) do
        if rfb.smallType == buildType then
            local buildingInfo = {}
            buildingInfo.index = rfb.index
            buildingInfo.level = rfb.level
            buildingInfo.buildingType = rfb.smallType
            local time = rfb.nextLevelTime - GameConfig.serverTime
            if time < 0 then
                time = 0
            end
            buildingInfo.levelTime = time
            buildingInfo.productionInfos = timerdbProxy:getProductionInfo(rfb.index, rfb.smallType)
            buildingInfo.buildingDetailInfos = self:getBuildingDetailInfo(rfb.smallType, rfb.index)
        
            buildingInfo.speedRate = 0 
            local powertype = self:getBuildTypeByPower(buildType)
            if powertype ~= 0 then
                buildingInfo.speedRate = playerProxy:getPowerValue(powertype)
            end
            buildingInfo.productNum = self:getHadWaitQueue()
            table.insert(infos, buildingInfo)
        end
    end
    return infos
end

------------------------------------------------------------
--建筑升级
function ResFunBuildProxy:buildingLevelUp(buildType, index, type, powerlist, justCheck)
	local building = self:getResFunBuildingByIndexSmallType(buildType, index)
	if building == nil then
		building = self:getResFunBuildingByIndexBigType(ResFunBuildDefine.BUILDE_TYPE_RESOUCE, index)
	end

	if building == nil then
		return ErrorCodeDefine.M100001_1
	end

	if building.smallType ~= 0 then
		if building.smallType ~= buildType then
			return  ErrorCodeDefine.M100001_11
		end
	end
	
    --TODO 客户端的服务器时间同步会不精确，导致可能升级请求时，会出现这个错误码
    --客户端逻辑不会在倒计时中，请求
    if TimerDefine.triggerTime < building.nextLevelTime then  
        --logger:error("==========lv Buildings==========dt:%d" , (building.nextLevelTime - TimerDefine.triggerTime))
		return ErrorCodeDefine.M100001_2
	end

    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
	if timerdbProxy:getBuildLevelNum() <= 0 then
        return ErrorCodeDefine.M100001_6
	end
	
	if self:getResFunBuildStateByIndex(buildType,index) == false then
        return ErrorCodeDefine.M100001_9
	end

    if self:isCanBuildType(buildType, index) == false then
    	return ErrorCodeDefine.M100001_10
    end

    local buildConfigName = ConfigData.BuildResourceConfig

    if self:getBuildTypeByType(buildType) == 1 then --资源建筑
    	--资源建筑
    	buildConfigName = ConfigData.BuildResourceConfig
        
    else --TODO 功能建筑
        buildConfigName = ConfigData.BuildFunctionConfig
    end

    local info = ConfigDataManager:getInfoFindByTwoKey(
        buildConfigName, 'type', buildType, 'lv', building.level)
    local upinfo = ConfigDataManager:getInfoFindByTwoKey(
        buildConfigName, 'type', buildType, 'lv', building.level + 1)
    	if upinfo == nil then
    		return ErrorCodeDefine.M100001_3
    	end

    	if self:getResFunBuildingLevelBySmallType(ResFunBuildDefine.BUILDE_TYPE_COMMOND, 1) <
    		info.commandlv then
    		return ErrorCodeDefine.M100001_5
    	end

    	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    	local needAry = StringUtils:jsonDecode(info.need)
    	local coin = info.gold
    	if type == 1 then  --一般建筑升级
    		for _, need in pairs(needAry) do
    			local typeid = need[1]
    			local num = need[2]
    			if playerProxy:getPowerValue(typeid) < num then
    				return ErrorCodeDefine.M100001_4
    			end
    		end
    	else --元宝升级
    		if playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold ) < coin then
    			return ErrorCodeDefine.M100001_8
    		end
    	end
    	
        if justCheck == true then
            return 0
        end
    	
        --扣除费用
        if type == 1 then
            for _, need in pairs(needAry) do
                local typeid = need[1]
                local num = need[2]
                table.insert(powerlist, typeid)
                playerProxy:reducePowerValue(typeid, num)
            end
        else
            playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, coin)
        end
        self:changeResFunBuildType(building.smallType, index, buildType)
        local time = info.time
        local buildspeedrate = playerProxy:getPowerValue(PlayerPowerDefine.NOR_POWER_buildspeedrate)
        time = math.ceil(time / (1 + buildspeedrate / 100.0))
        local needtime = TimerDefine.triggerTime + time
        --设置建筑升级完成时间
        self:setFinishLevelTime(buildType, index, needtime)
        --设置定时器

        local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
        timerdbProxy:addTimer(TimerDefine.BUILDING_LEVEL_UP, 0, time, -1, building.smallType, building.index)
        timerdbProxy:setLastOperationTime(TimerDefine.BUILDING_LEVEL_UP, building.smallType, building.index, needtime)


    return 0
end

--建筑生产
function ResFunBuildProxy:builderProduction(buildType, index, typeId, num, reward)
    --TODO itemProxy rewardProxy vipProxy
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
    local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)

    local hadWaitQueue =  vipProxy:getVipNum(ActorDefine.VIP_WAITQUEUE) + ResFunBuildDefine.MIN_WAITQUEUE

    if buildType == ResFunBuildDefine.BUILDE_TYPE_TANK then --坦克生产
        if num > ResFunBuildDefine.SODIER_CREATE_MAX_NUM then
            return ErrorCodeDefine.M100006_1
        end
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ArmProductConfig, typeId)
        local needList = StringUtils:jsonDecode(jsonObject.need)
        for _, need in pairs(needList) do
            local needid = need[1]
            local neednum = need[2] * num
            if playerProxy:getPowerValue(needid) < neednum then
                return ErrorCodeDefine.M100006_2
            end
        end
    
        --TODO itemneed itemProxy
        local itemJsonArray = StringUtils:jsonDecode(jsonObject.itemneed)
        for _, itemneed in pairs(itemJsonArray) do
            local needid = itemneed[1]
            local neednum = itemneed[2]
            if itemProxy:getItemNum(needid) < neednum then
                return ErrorCodeDefine.M100006_3
            end
        end
    
        if timerdbProxy:getCreatingNum(index) >= hadWaitQueue then
            return ErrorCodeDefine.M100006_4
        end
    
        if playerProxy:getPowerValue(PlayerPowerDefine.POWER_level) < jsonObject.commanderLv then
            return ErrorCodeDefine.M100006_5
        end
    
        local lvneed = StringUtils:jsonDecode(jsonObject.Lvneed)
        if self:getResFunBuildingLevelBySmallType(buildType, index) < lvneed[2] then
            return ErrorCodeDefine.M100006_6
        end
    
        --扣除费用
        for _, need in pairs(needList) do
            local needid = need[1]
            local neednum = need[2] * num
            playerProxy:reducePowerValue(needid, neednum)
        end
    
        --TODO itemProxy
        for _, itemneed in pairs(itemJsonArray) do
            local needid = itemneed[1]
            local neednum = itemneed[2]
            itemProxy:reduceItemNum(needid, neednum)
            --TODO rewardProxy
            rewardProxy:addItemToReward(reward, needid, neednum)
        end
    
        local lessTime = jsonObject.timeneed
        local powertype = self:getBuildTypeByPower(buildType)
        if powertype ~= 0 then
            local power = playerProxy:getPowerValue(powertype)
            lessTime = math.ceil(lessTime / (1 + power / 100.0))
        end
        lessTime = lessTime * num
    
        --添加计数器   smallType=工厂的index  otherType 队列的第几个
        local order = timerdbProxy:getCreateBigNum(index)
        local timeId = timerdbProxy:addTimer(TimerDefine.BUILD_CREATE, num, lessTime,
            -1, index, order + 1)
        timerdbProxy:setAttrValue(timeId, 1, typeId)
        timerdbProxy:setAttrValue(timeId, 2, lessTime)
        local timeadd = lessTime
        local lasttime = timerdbProxy:getLastCreateTime(index, order) + timeadd
        timerdbProxy:setLastOperationTime(TimerDefine.BUILD_CREATE, index, order + 1, lasttime)
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_SCIENCE then  --TODO 科技相关
        --TODO technologyProxy
        local technologyProxy = self:getProxy(ActorDefine.TECHNOLOGY_PROXY_NAME)
        return technologyProxy:technologyLevelUp(buildType, index, typeId, num)
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_CREATEROOM then --TODO 制造车间
        return self:manufacturing(index, typeId, num, buildType, reward)
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_RREFIT then --TODO 校场
        return self:armsTransformation(index, typeId, num, buildType, reward)
    end
    
    return 0

end

--制造车间生产
function ResFunBuildProxy:manufacturing(index, typeId, num, buildType, reward)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
    local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
    local hadWaitQueue = vipProxy:getVipNum(ActorDefine.VIP_WAITQUEUE) + ResFunBuildDefine.MIN_WAITQUEUE
    if num > ResFunBuildDefine.SODIER_CREATE_MAX_NUM then
        return ErrorCodeDefine.M100006_7
    end
    local jsonObject = ConfigDataManager:getConfigById(ConfigData.ItemMadeConfig, typeId)
    if jsonObject == nil then
        return ErrorCodeDefine.M100006_8
    end
    if timerdbProxy:getCreatingNum(index) >= hadWaitQueue then
        return ErrorCodeDefine.M100006_9
    end
    local needAry = StringUtils:jsonDecode(jsonObject.need)
    for _, need in pairs(needAry) do
        local id = need[1]
        local resnum = need[2] * num
        if playerProxy:getPowerValue(id) < resnum then
            return ErrorCodeDefine.M100006_11
        end
    end

    local itemAry = StringUtils:jsonDecode(jsonObject.itemneed)
    for _, item in pairs(itemAry) do
        local itemId = item[1]
        local itemnum = item[2] * num
        if itemProxy:getItemNum(itemId) < itemnum then
            return ErrorCodeDefine.M100006_12
        end
    end

    --扣除费用
    for _, need in pairs(needAry) do
        local id = need[1]
        local resnum = need[2] * num
        playerProxy:reducePowerValue(id, resnum)
    end

    for _, item in pairs(itemAry) do
        local itemId = item[1]
        local itemnum = item[2] * num
        itemProxy:reduceItemNum(itemId, itemnum)
        rewardProxy:addItemToReward(reward, itemId, itemnum)
    end

    --执行创建生产队列
    local lessTime = jsonObject.timeneed
    local powertype = self:getBuildTypeByPower(buildType)
    if powertype ~= 0 then
        local power = playerProxy:getPowerValue(powertype)
        lessTime = math.ceil(lessTime / (1 + power / 100.0))
    end
    lessTime = lessTime * num
    --添加计数器  smallType=工厂的index  otherType 队列的第几个
    local order = timerdbProxy:getCreateBigNum(index)
    local timeId = timerdbProxy:addTimer(TimerDefine.BUILD_CREATE, num, lessTime, -1, index, order + 1, playerProxy)
    timerdbProxy:setAttrValue(timeId, 1, typeId)
    timerdbProxy:setAttrValue(timeId, 2, lessTime)
    local timeadd = lessTime
    local lasttime = timerdbProxy:getLastCreateTime(index, order) + timeadd
    timerdbProxy:setLastOperationTime(TimerDefine.BUILD_CREATE, index, order + 1, lasttime)

    return 0
end

--兵种改造
function ResFunBuildProxy:armsTransformation(index, typeId, num, buildType, reward)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
    local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
    local soldierProxy = self:getProxy(ActorDefine.SOLDIER_PROXY_NAME)
    local hadWaitQueue = vipProxy:getVipNum(ActorDefine.VIP_WAITQUEUE) + ResFunBuildDefine.MIN_WAITQUEUE
    if num > ResFunBuildDefine.SODIER_CREATE_MAX_NUM then
        return ErrorCodeDefine.M100006_13
    end
    local jsonObject = ConfigDataManager:getConfigById(ConfigData.ArmRemouldConfig, typeId)
    if jsonObject == nil then
        return ErrorCodeDefine.M100006_14
    end
    if timerdbProxy:getCreatingNum(index) >= hadWaitQueue then
        return ErrorCodeDefine.M100006_4
    end
    local buildAry = StringUtils:jsonDecode(jsonObject.Lvneed) 
    if self:getMaxLevelByBuildType(buildAry[1]) < buildAry[2] then
        return ErrorCodeDefine.M100006_27
    end
    if playerProxy:getPowerValue(PlayerPowerDefine.POWER_level) < jsonObject.commanderLv then
        return ErrorCodeDefine.M100006_28
    end
    --资源判断
    local soldierAry = StringUtils:jsonDecode(jsonObject.tankneed)
    local soldierId = soldierAry[1][1]
    local soldierNum = soldierAry[1][2]  * num
    if soldierProxy:getSoldierNum(soldierId) < soldierNum then
        return ErrorCodeDefine.M100006_15
    end
    local resAry = StringUtils:jsonDecode(jsonObject.need)
    for _, res in pairs(resAry) do
        local reId = res[1]
        local renum = res[2] * num
        if playerProxy:getPowerValue(reId) < renum then
            return ErrorCodeDefine.M100006_16
        end
    end
    local itemAry = StringUtils:jsonDecode(jsonObject.itemneed)
    for _,item in pairs(itemAry) do
        local itemId = itemAry[1]
        local itemnum = itemAry[2] * num
        if itemProxy:getItemNum(itemId) < itemnum then
            return ErrorCodeDefine.M100006_12
        end
    end

    --扣除费用
    soldierProxy:reduceSoldierNum(soldierId, soldierNum, 0)
    rewardProxy:addSoldierToReward(reward, soldierId, soldierNum)
    for _, need in pairs(resAry) do
        local id = need[1]
        local resnum = need[2] * num
        playerProxy:reducePowerValue(id, resnum)
    end

    for _, item in pairs(itemAry) do
        local itemId = item[1]
        local itemnum = item[2] * num
        itemProxy:reduceItemNum(itemId, itemnum)
        rewardProxy:addItemToReward(reward, itemId, itemnum)
    end

    --执行创建生产队列
    local lessTime = jsonObject.timeneed
    local powertype = self:getBuildTypeByPower(buildType)
    if powertype ~= 0 then
        local power = playerProxy:getPowerValue(powertype)
        lessTime = math.ceil(lessTime / (1 + power / 100.0))
    end
    lessTime = lessTime * num
    --添加计数器  smallType=工厂的index  otherType 队列的第几个
    local order = timerdbProxy:getCreateBigNum(index)
    local timeId = timerdbProxy:addTimer(TimerDefine.BUILD_CREATE, num, lessTime, -1, index, order + 1, playerProxy)
    timerdbProxy:setAttrValue(timeId, 1, typeId)
    timerdbProxy:setAttrValue(timeId, 2, lessTime)
    local timeadd = lessTime
    local lasttime = timerdbProxy:getLastCreateTime(index, order) + timeadd
    timerdbProxy:setLastOperationTime(TimerDefine.BUILD_CREATE, index, order + 1, lasttime)

    return 0
end


--取消升级生产
function ResFunBuildProxy:cancelLevelCreate(buildType, index, order, reward)
    local rs = 0
    if order == -1 then
        self:cancelBuildLevelUp(buildType, index)
    else
        self:cancelCreate(buildType, index, order, reward)
    end

    return rs
end

--取消建筑升级
function ResFunBuildProxy:cancelBuildLevelUp(buildType, index)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    if building == nil then
        return ErrorCodeDefine.M100003_1  --该建筑不存在
    end
    if TimerDefine.triggerTime >= building.nextLevelTime then
        return ErrorCodeDefine.M100003_2  --建筑没有在升级中
    end
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)

    local configName = ConfigData.BuildResource
    if self:isResouceType(building.smallType) then
        configName = ConfigData.BuildResourceConfig
    else
        configName = ConfigData.BuildFunctionConfig
    end

    local jsonObject = ConfigDataManager:getInfoFindByTwoKey(configName,
        "type", building.smallType, "lv", building.level)
    local needAry = StringUtils:jsonDecode(jsonObject.need)
    for _, need in pairs(needAry) do
        local addValue = need[2] * ResFunBuildDefine.CANCEL_LEVEL_RETURN / 100
        playerProxy:addPowerValue(need[1], addValue)
    end
    --删除定时器
    timerdbProxy:delTimer(TimerDefine.BUILDING_LEVEL_UP, buildType, index)
    self:setFinishLevelTime(buildType, index, TimerDefine.triggerTime)
end

--生产取消
function ResFunBuildProxy:cancelCreate(buildType, index, order, reward)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    if building == nil then
        return ErrorCodeDefine.M100003_1  --该建筑不存在
    end
    local time = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_CREATE, index, order)
    local num = timerdbProxy:getTimerNum(TimerDefine.BUILD_CREATE, index, order)
    time = time - TimerDefine.triggerTime
    if time <= 0 then
        return ErrorCodeDefine.M100003_2  --建筑没有在升级中
    end
    local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
    local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
    local soldierProxy = self:getProxy(ActorDefine.SOLDIER_PROXY_NAME)

    --返还资源
    local id = timerdbProxy:getAttr1(TimerDefine.BUILD_CREATE, index, order)
    if buildType == ResFunBuildDefine.BUILDE_TYPE_TANK then
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ArmProductConfig, id)
        local needAry = StringUtils:jsonDecode(jsonObject.need)
        for _, need in pairs(needAry) do
            playerProxy:addPowerValue(need[1], num * need[2] * ResFunBuildDefine.CANCEL_LEVEL_RETURN / 100 )
        end
        local itemAry = StringUtils:jsonDecode(jsonObject.itemneed)
        for _, item in pairs(itemAry) do
            itemProxy:addItem(item[1], num * item[2])
            rewardProxy:addItemToReward(reward, item[1], num * item[2])
        end
    elseif buildType == ResFunBuildDefine.BUILD_TYPE_SCIENCE then --太学院
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ScienceLvConfig, id)
        local needAry = StringUtils:jsonDecode(jsonObject.need)
        for _, need in pairs(needAry) do
            playerProxy:addPowerValue(need[1], num * need[2] * ResFunBuildDefine.CANCEL_LEVEL_RETURN / 100 )
        end
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_RREFIT then --校场
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ScienceLvConfig, id)
        local needAry = StringUtils:jsonDecode(jsonObject.need)
        for _, need in pairs(needAry) do
            playerProxy:addPowerValue(need[1], num * need[2] * ResFunBuildDefine.CANCEL_LEVEL_RETURN / 100 )
        end
        local tankneedAry = StringUtils:jsonDecode(jsonObject.tankneed)
        for _,tankneed in pairs(tankneedAry) do
            --TODO soldierProxy
            soldierProxy:addSoldierNum(tankneed[1], num * tankneed[2])
            rewardProxy:addSoldierToReward(reward, tankneed[1], num * tankneed[2])
        end
    end

    --删除定时器
    timerdbProxy:delTimer(TimerDefine.BUILD_CREATE, index, order)
    timerdbProxy:modifyBuildFinishTime(index, time, order)
end

--建筑加速
function ResFunBuildProxy:buildSpeed(buildType, index, order, contType, reward)
    local rs = 0
    if order == -1 then
        rs = self:speedBuildLevelup(buildType, index, contType, reward)
    else
        rs = self:speedProduct(buildType, index, order, contType, reward)
    end
    return rs
end

--建筑升级加速
function ResFunBuildProxy:speedBuildLevelup(buildType, index, costType, reward)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local systemProxy = self:getProxy(ActorDefine.SYSTEM_PROXY_NAME)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)

    if building == nil then
        return ErrorCodeDefine.M100004_1
    end

    if TimerDefine.triggerTime >= building.nextLevelTime then
        return ErrorCodeDefine.M100004_2
    end

    if costType == 1 then --金币加速
        local time = building.nextLevelTime - TimerDefine.triggerTime
        local cost = self:speedCost(time)
        if playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold) < cost then
            return ErrorCodeDefine.M100004_3
        end
        playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, cost)
        systemProxy:doBuildingLevelUp(buildType, index)
        self:setFinishLevelTime(buildType, index, TimerDefine.triggerTime)
        return 1
    else --道具加速
        local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
        -- 道具加速
        local typeId = ResFunBuildDefine.SPEEDBUILDLEVELUP[costType - 1]
        local hasnum = itemProxy:getItemNum(typeId)
        if hasnum < 1 then --直接购买
            local jsonObject = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", typeId)
            if jsonObject == nil then
                return ErrorCodeDefine.M100004_5
            end
            if playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold) < jsonObject.goldprice then
                return ErrorCodeDefine.M100004_7
            end
            playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, jsonObject.goldprice)
            itemProxy:addItem(typeId, 1)
        end
        local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeId)
        itemProxy:reduceItemNum(typeId, 1)
        rewardProxy:addItemToReward(reward, typeId, 1) --TOOD 应该有问题
        local reduceTime = StringUtils:jsonDecode(jsonObject.effect)[1] * 60
        local needTime = building.nextLevelTime - reduceTime
        self:setFinishLevelTime(buildType, index, needTime)
        timerdbProxy:setLastOperationTime(TimerDefine.BUILDING_LEVEL_UP, building.smallType, building.index, needTime)
        if TimerDefine.triggerTime >= building.nextLevelTime then
            systemProxy:doBuildingLevelUp(buildType, index)
        end
        if needTime <= TimerDefine.triggerTime then
            return 1
        end
    end

    return 0

end

--生产队加速完成
function ResFunBuildProxy:speedProduct(buildType, index, order, costType, reward)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    if building == nil then
        return  ErrorCodeDefine.M100004_1 --该建筑不存在
    end
    local time = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_CREATE, index, order)
    time = time - TimerDefine.triggerTime
    if time <= 0 then
        return  ErrorCodeDefine.M100004_8
    end
    if costType == 1 then --金币加速
        local cost = self:speedCost(time)
        if playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold) < cost then
            return  ErrorCodeDefine.M100004_3
        end
        playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, cost)
        timerdbProxy:modifyBuildFinishTime(index, time, order)
    else
        local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
        -- 道具加速
        local typeId = self:getSpeedLevelNeedItem(buildType, costType - 1)
        local hasnum = itemProxy:getItemNum(typeId)
        if hasnum < 1 then --直接购买
            local jsonObject = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", typeId)
            if jsonObject == nil then
                return ErrorCodeDefine.M100004_5
            end
            if playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold) < jsonObject.goldprice then
                return ErrorCodeDefine.M100004_7
            end
            playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, jsonObject.goldprice)
            itemProxy:addItem(typeId, 1)
        end
        local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeId)
        itemProxy:reduceItemNum(typeId, 1)
        rewardProxy:addItemToReward(reward, typeId, 1) --TOOD 应该有问题
        local reduceTime = StringUtils:jsonDecode(jsonObject.effect)[1] * 60
        if reduceTime > time then
            reduceTime = time
        end
        timerdbProxy:modifyBuildFinishTime(index, reduceTime, order)
    end

    local list = {}
    timerdbProxy:checkBuildCreate(list, reward, playerTasks)

    return 0
end

--拆除野外建筑
function ResFunBuildProxy:dropBuilding(buildType, index)
    local building = self:getResFunBuildingByIndexSmallType(buildType, index)
    if building == nil then
        return ErrorCodeDefine.M100005_1
    end
    if self:isCanRemove(buildType) == false then
        return ErrorCodeDefine.M100005_2
    end
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)

    --删除定时器
    timerdbProxy:delTimer(TimerDefine.BUILDING_LEVEL_UP, building.smallType, index)

    self:changeResFunBuildLevel(buildType, index, 0)
    self:changeResFunBuildType(buildType, index, 0)

    return 0

end

--建筑类型是否可以拆除
function ResFunBuildProxy:isCanRemove(buildType)
    if table.indexOf(ResFunBuildDefine.REMOVEBUILDLIST, buildType) >= 0 then
        return true
    end
    return false
end

--购买自动升级
function ResFunBuildProxy:buyAutoLevel()
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    if playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold) < TimerDefine.BUILDAUTOLEVELPRICE then
        return ErrorCodeDefine.M100011_1
    end
    playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, TimerDefine.BUILDAUTOLEVELPRICE)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local hastime = timerdbProxy:getTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
    local lasttime = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
    local endTime = TimerDefine.triggerTime - lasttime
    if hastime > 0 then
        playerProxy:setAutoBuildState(TimerDefine.BUILDAUTOLEVEL_OPEN)
        timerdbProxy:setTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, 0) --TODO setNum
        timerdbProxy:setLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, TimerDefine.triggerTime + hastime + TimerDefine.BUILDAUTOLEVEL_ADDTIME)
    else
        if endTime < 0 then
            --拥有自动升级
            timerdbProxy:setLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, lasttime + TimerDefine.BUILDAUTOLEVEL_ADDTIME)
        else
            playerProxy:setAutoBuildState(TimerDefine.BUILDAUTOLEVEL_OPEN)
            timerdbProxy:setLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, TimerDefine.triggerTime + TimerDefine.BUILDAUTOLEVEL_ADDTIME)
        end
    end

    return 0
end

--判断某个时间是否有在自动升级
function ResFunBuildProxy:isAutoLeveling(nowTime)
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local lasttime = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
    local endTime = nowTime - lasttime
    if endTime >= 0 then
        local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
        if playerProxy:getAutoBuildState() == TimerDefine.BUILDAUTOLEVEL_OPEN then
            playerProxy:setAutoBuildState(TimerDefine.BUILDAUTOLEVEL_OFF)
        end
        return false
    end
    return true
end

--获得某个建筑的升级所需要的时间还未做处理前
function ResFunBuildProxy:getBuildLevelNeedTime(resFunBuilding)
    if self:getBuildTypeByType(resFunBuilding.smallType) == 1 then
        local jsonUp = ConfigDataManager:getInfoFindByTwoKey(ConfigData.BuildResourceConfig,
            "type", resFunBuilding.smallType, "lv", resFunBuilding.level)
        if jsonUp == nil then
            return -1
        end
        return jsonUp.time
    else
        local jsonUp = ConfigDataManager:getInfoFindByTwoKey(ConfigData.BuildFunctionConfig,
            "type", resFunBuilding.smallType, "lv", resFunBuilding.level)
        if jsonUp == nil then
            return -1
        end
        return jsonUp.time
    end
end

--获取一样等级的建筑
function ResFunBuildProxy:getSameLevelBuild(level)
    local list = {}
    local newlist = {}
    for _,rfb in pairs(self._rfbs) do
        if level == rfb.level then
            table.insert(list, rfb)
        end
    end

--    local newtime = {}
    for i=1, #list do
        local time = 2000000000
        local building = nil
        for j=1, #list do
            local needtime = self:getBuildLevelNeedTime(list[j])
            if needtime > 0 and needtime < time and table.indexOf(newlist, list[j]) < 0 then
                building = list[j]
                time = needtime
            end
        end
        if building ~= nil and table.indexOf(newlist, list[j]) < 0 then
            table.insert(newlist, building)
        end
    end

    return newlist
end

--获取当前能够升级的建筑数据
function ResFunBuildProxy:getCurCanLevelUpBuilding()
end

--建筑自动升级 --TODO 自动升级，为什么要这样子处理！！遍历那么多次
function ResFunBuildProxy:buildAutoLevelUp(m3info, justCheck)
    --    local doLevelMap = {} --and doLevelMap[rbs.level] == nil
    local time = os.clock()
    local comp = function(a, b)
        return a.level < b.level
    end
    local list = {}
    for _, rfb in pairs(self._rfbs) do
        table.insert(list, rfb)
    end
    table.sort(list,comp)
    local map = {}
    for _,rbs in pairs(list) do
        if rbs.smalltype ~= 0 and rbs.level ~= 0 then
--            doLevelMap[rbs.level] = true
            local newlist = self:getSameLevelBuild(rbs.level)
            for _,building in pairs(newlist) do
                local rs = self:buildingLevelUp(building.smallType, building.index, 1, {}, justCheck)
                if rs == 0 then
                    local key = building.smallType .. "," .. building.index
                    if map[key] == nil then
                        local timeInfo = {}
                        timeInfo.remainTime = 0
                        timeInfo.bigtype = TimerDefine.BUILDING_LEVEL_UP
                        timeInfo.smalltype = building.smallType
                        timeInfo.othertype = building.index
                        map[key] = true
                        --                    print("========buildAutoLevelUp=================", building.smallType, building.index)
                        table.insert(m3info, timeInfo)
                    end
                end
            end
        end
    end
    
--    print("======buildAutoLevelUp=xx=======", os.clock() - time)
end

--判断有没有在自动升级
function ResFunBuildProxy:isHasAutoLevel()
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local lasttime = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
    local endTime = GameConfig.serverTime - lasttime
    if endTime < 0 then
        return true
    end
    if timerdbProxy:getTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0) > 0 then
        return true
    end

    return false
end

function ResFunBuildProxy:changeAutoBuildState(type)
    if type == TimerDefine.BUILDAUTOLEVEL_OPEN then
        if self:isHasAutoLevel() == false then
            return ErrorCodeDefine.M100012_1
        end
    end
    local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local hastime = timerdbProxy:getTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0)
    if playerProxy:getAutoBuildState() == TimerDefine.BUILDAUTOLEVEL_OFF then
        if type == TimerDefine.BUILDAUTOLEVEL_OPEN then
            timerdbProxy:setLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, GameConfig.serverTime + hastime)
            timerdbProxy:setTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, 0)
            playerProxy:setAutoBuildState(type)
        end
    end

    if playerProxy:getAutoBuildState() == TimerDefine.BUILDAUTOLEVEL_OPEN then
        if type == TimerDefine.BUILDAUTOLEVEL_OFF then
            local lestime = timerdbProxy:getLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0) - GameConfig.serverTime
            timerdbProxy:setLastOperationTime(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, GameConfig.serverTime)
            timerdbProxy:setTimerNum(TimerDefine.BUILD_AUTO_LEVLE_UP, 0, 0, lestime)
            playerProxy:setAutoBuildState(type)
        end
    end
    
    return 0
end

function ResFunBuildProxy:buyBuildSizePrice()
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local hadBuildSize = playerProxy:getPowerValue(PlayerPowerDefine.POWER_buildsize)
    local needGold = ((hadBuildSize - ResFunBuildDefine.MIN_BUILD_SIZE) + 1) * ResFunBuildDefine.MIN_BUY_BUILD_GOlD

    return needGold
end

--请求购买建筑位
function ResFunBuildProxy:askBuyBuildSize()
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local canBuy = vipProxy:getVipNum(ActorDefine.VIP_BULIDQUEUE) - ResFunBuildDefine.MIN_BUILD_SIZE
    local hadBuildSize = playerProxy:getPowerValue(PlayerPowerDefine.POWER_buildsize)
    local hadGold = playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold)
    local needGold = ((hadBuildSize - ResFunBuildDefine.MIN_BUILD_SIZE) + 1) * ResFunBuildDefine.MIN_BUY_BUILD_GOlD
    local vipInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.VipDataConfig, 
        "level", vipProxy:getMaxVIPLv())
    local vipMaxHadNum = vipInfo[ActorDefine.VIP_BULIDQUEUE]
    local vipHadNum = vipProxy:getVipNum(ActorDefine.VIP_BULIDQUEUE)
    if canBuy <= 0 then
        return 2
    elseif hadBuildSize >= vipMaxHadNum then
        return 1
    elseif hadBuildSize >= vipHadNum and vipHadNum < vipMaxHadNum then
        return 2
    elseif hadGold < needGold then
        return 3
    end
    return needGold
end

--VIP购买建筑位
function ResFunBuildProxy:buyBuildSize()
    local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local canBuy = vipProxy:getVipNum(ActorDefine.VIP_BULIDQUEUE) - ResFunBuildDefine.MIN_BUILD_SIZE
    local hadBuildSize = playerProxy:getPowerValue(PlayerPowerDefine.POWER_buildsize)
    local hadGold = playerProxy:getPowerValue(PlayerPowerDefine.POWER_gold)
    local needGold = ((hadBuildSize - ResFunBuildDefine.MIN_BUILD_SIZE) + 1) * ResFunBuildDefine.MIN_BUY_BUILD_GOlD
    local vipInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.VipDataConfig, 
        "level", vipProxy:getMaxVIPLv())
    local vipMaxHadNum = vipInfo[ActorDefine.VIP_BULIDQUEUE]
    local vipHadNum = vipProxy:getVipNum(ActorDefine.VIP_BULIDQUEUE)
    if canBuy <= 0 then
        return 2
    elseif hadBuildSize >= vipMaxHadNum then
        return 1
    elseif hadBuildSize >= vipHadNum and vipHadNum < vipMaxHadNum then
        return 2
    elseif hadGold < ResFunBuildDefine.BUY_BUILD_SIZE_GOLD then
        return 3
    end
    playerProxy:addPowerValue(PlayerPowerDefine.POWER_buildsize, 1)
    playerProxy:reducePowerValue(PlayerPowerDefine.POWER_gold, needGold)
    return 0
end


-----建筑详细信息 List<M10.BuildingDetailInfo>
function ResFunBuildProxy:getBuildingDetailInfo(buildType, index)
    local list = {}
    if buildType == ResFunBuildDefine.BUILDE_TYPE_TANK then --兵营
    	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    	local jsonArrayList = ConfigDataManager:getConfigData(ConfigData.ArmProductConfig)
    	for _, info in pairs(jsonArrayList) do
    		local lvneed = StringUtils:jsonDecode(info.Lvneed)
    		local commanderLv = info.commanderLv
    		local typeid = info.ID
            if playerProxy:getPowerValue(PlayerPowerDefine.POWER_level) >= commanderLv and 
    			self:getResFunBuildingLevelBySmallType(buildType, index) >= lvneed[2] then
    			local detailInfo = {}
    			detailInfo.num = 0
    			detailInfo.typeid = typeid
    			table.insert(list, detailInfo)
    		end
    	end
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_SCIENCE then  --科技馆
    	--TechnologyProxy
    	local technologyProxy = self:getProxy(ActorDefine.TECHNOLOGY_PROXY_NAME)
    	local jsonAry = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
        for _, jsonObj in pairs(jsonAry) do --TODO 每次都要遍历
            local typeId = jsonObj.scienceType
            local level = technologyProxy:getTechnologyLevelByType(typeId)
            local detailInfo = {}
            detailInfo.typeid = typeId
            detailInfo.num = level
            table.insert(list, detailInfo)
    	end
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_CREATEROOM then --工匠坊
    	local jsonArrayList = ConfigDataManager:getConfigData(ConfigData.ItemMadeConfig)
    	for _, info in pairs(jsonArrayList) do
    		local typeid = info.ID
    		local detailInfo = {}
    		detailInfo.num = 0
    		detailInfo.typeid = typeid
    		table.insert(list, detailInfo)
    	end
    elseif buildType == ResFunBuildDefine.BUILDE_TYPE_RREFIT then --校场
    	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    	local jsonArrayList = ConfigDataManager:getConfigData(ConfigData.ArmRemouldConfig)
    	for _, info in pairs(jsonArrayList) do
    		local lvneed = StringUtils:jsonDecode(info.Lvneed)
    		local commanderLv = info.commanderLv
    		local typeid = info.ID
            if playerProxy:getPowerValue(PlayerPowerDefine.POWER_level) >= commanderLv and 
    			self:getResFunBuildingLevelBySmallType(lvneed[1], index) >= lvneed[2] then
    			local detailInfo = {}
    			detailInfo.num = 0
    			detailInfo.typeid = typeid
    			table.insert(list, detailInfo)
    		end
    	end
    end

    return list
end