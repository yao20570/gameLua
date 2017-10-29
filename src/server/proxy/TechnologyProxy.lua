-------------
----科技相关处理代理
-------------
module("server", package.seeall)

TechnologyProxy = class("TechnologyProxy", BasicProxy)

function TechnologyProxy:ctor()
    self._technologies = {}
    self._expandPowerMap = {}
end

function TechnologyProxy:initTechnology(buildingInfos)
    for _, buildingInfo in pairs(buildingInfos) do
        if buildingInfo.buildingType == ResFunBuildDefine.BUILDE_TYPE_SCIENCE then
            local buildingDetailInfos = buildingInfo.buildingDetailInfos
            for _, buildingDetailInfo in pairs(buildingDetailInfos) do
                local info = ConfigDataManager:getConfigById(ConfigData.MuseumConfig, buildingDetailInfo.typeid)
                if buildingInfo.level >= info.reqSCenterLv then
                    self:addTechnology(buildingDetailInfo.typeid, buildingDetailInfo.num, 1)
                else
                    self:addTechnology(buildingDetailInfo.typeid, buildingDetailInfo.num, 0)
                end
            end
        end
    end
--	local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
--	local museumLevel = resFunBuildProxy:getResFunBuildingLevelBySmallType(ResFunBuildDefine.BUILDE_TYPE_FUNTION, ResFunBuildDefine.BUILDE_TYPE_SCIENCE)
--	--TODO 初始化太学院数据
--	local museum = resFunBuildProxy:getBuildingInfo(ResFunBuildDefine.BUILDE_TYPE_SCIENCE, 12 )
--    local techlist = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
--	for _,json in pairs(techlist) do
--		if self:getTechnologyByType(json.scienceType) == nil then
--			if museumLevel >= json.reqSCenterLv then
--				self:addTechnology(json.scienceType, 0, 1)
--			else
--				self:addTechnology(json.scienceType, 0, 0)
--			end
--		end
--	end
end

--科技升级
function TechnologyProxy:technologyLevelUp(buildType, index, typeId, num)
	local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
	local vipProxy = self:getProxy(ActorDefine.VIP_PROXY_NAME)
	local hadWaitQueue = vipProxy:getVipNum(ActorDefine.VIP_WAITQUEUE) + ResFunBuildDefine.MIN_WAITQUEUE
	local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
	local museumLevel = resFunBuildProxy:getResFunBuildingLevelBySmallType(buildType, index)
	local prestigeLv = playerProxy:getPowerValue(PlayerPowerDefine.POWER_prestigeLevel)
    local technologyLv = self:getTechnologyLevelByType(typeId)
    local jsonObject = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ScienceLvConfig,
    	"level", technologyLv, "scienceType", typeId)
    if jsonObject == nil then
    	return ErrorCodeDefine.M100006_8
    end
    local reqSCenterLv = jsonObject.reqSCenterLv
    local reqPrestigeLv = jsonObject.reqPrestigeLv
    local needAry = StringUtils:jsonDecode(jsonObject.need)

    if museumLevel < reqSCenterLv then
    	return ErrorCodeDefine.M100006_18  --;//科技馆等级不够
    end
    if prestigeLv < reqPrestigeLv then
    	return ErrorCodeDefine.M100006_19  --;//声望等级不够
    end
    if prestigeLv == 0 and museumLevel == 0 then --TODO 这个判断可能有问题
    	return ErrorCodeDefine.M100006_20  --;//已是最高级
    end
    if timerdbProxy:getCreatingNum(index) >= hadWaitQueue then
    	 return ErrorCodeDefine.M100006_9  --;//队列已满
    end

    if timerdbProxy:scienceIsCanLevel(index, typeId) == false then
    	 return ErrorCodeDefine.M100006_26
    end
    for _,need in pairs(needAry) do
    	local power = need[1]
    	local count = need[2]
    	if playerProxy:getPowerValue(power) < count then
    		return ErrorCodeDefine.M100006_11
    	end
    end
    --扣掉升级所需资源
    for _,need in pairs(needAry) do
    	local power = need[1]
    	local count = need[2]
    	playerProxy:reducePowerValue(power, count)
    end
    local lessTime = jsonObject.time
    local powertype = resFunBuildProxy:getBuildTypeByPower(buildType)
    if powertype ~= 0 then
    	local power = playerProxy:getPowerValue(powertype)
    	lessTime = math.ceil(lessTime / (1 + power / 100.0))
    end

    local order = timerdbProxy:getCreateBigNum(index)
    local timeId = timerdbProxy:addTimer(TimerDefine.BUILD_CREATE, num, lessTime, TimerDefine.TIMER_REFRESH_NONE, index, order + 1, playerProxy)
    timerdbProxy:setAttrValue(timeId, 1, typeId)
    timerdbProxy:setAttrValue(timeId, 2, lessTime)
    local timeadd = lessTime
    local lasttime = timerdbProxy:getLastCreateTime(index, order) + timeadd
    timerdbProxy:setLastOperationTime(TimerDefine.BUILD_CREATE, index, order + 1, lasttime)

    return 0
end

function TechnologyProxy:addTechnology(typeId, level, state)
    self:createTechnology(typeId, level, state)
end

function TechnologyProxy:createTechnology(typeId, level, state)
	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
	local tech = Technology.new()
	tech.type = typeId
	tech.level = level
	tech.lastBlanceTime = GameConfig.serverTime
	tech.nextLevelTime = GameConfig.serverTime
	tech.state = state

	self._technologies[typeId] = tech

	return typeId
end

function TechnologyProxy:addTechnologyLevel(typeId)
	local tech = self:getTechnologyByType(typeId)
	if tech ~= nil then
		tech.level = tech.level + 1
	end
end

--获得某个科技的等级
function TechnologyProxy:getTechnologyLevelByType(typeId)
    local tech = self:getTechnologyByType(typeId)
    if tech ~= nil then
    	return tech.level
    end
    return -1
end

function TechnologyProxy:getTechnologyByType(typeId)
    return self._technologies[typeId]
end

--TODO
function TechnologyProxy:expandPowerTechnology()
	self._expandPowerMap = {}
	for _, tech in pairs(self._technologies) do
		-- local jsonObject = ConfigDataManager:getConfigById(ConfigData.MuseumConfig, tech.type)
		-- if jsonObject ~= nil then
		-- 	local lv = tech.level
		-- 	local jsonAry = StringUtils:jsonDecode(jsonObject.property)
		-- 	for k,v in pairs(jsonAry) do
		-- 		print(k,v)
		-- 	end
		-- end
	end
end