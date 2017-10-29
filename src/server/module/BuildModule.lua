
module("server", package.seeall)

BuildModule = class("BuildModule", BasicModule)

function BuildModule:onReceiveOtherMsg(object)
    if instanceof(object, BuildInfo) then
        local infoList = object.infos
        local builder = {}
        builder.buildingInfos = {}
        local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
        local getlist = {}
        for _, list in pairs(infoList) do
            local buildType = list[1]
            local index = list[2]
            if buildType == ResFunBuildDefine.BUILDE_TYPE_COMMOND then
                resFunBuildProxy:initResFunBuild(getlist)
            end
            local buildingInfo = resFunBuildProxy:getBuildingInfo(buildType, index)
            table.insert(builder.buildingInfos, buildingInfo)
            if buildType == ResFunBuildDefine.BUILDE_TYPE_TANK then
                local buildingInfos = resFunBuildProxy:getBuildingInfoByType(ResFunBuildDefine.BUILDE_TYPE_RREFIT)
                for _,buildingInfo in pairs(buildingInfos) do
                    table.insert(builder.buildingInfos, buildingInfo)
                end
            end
        end
        for _,list in pairs(getlist) do
            local buildType = list[1]
            local index = list[2]
            if resFunBuildProxy:getBuildingInfo(buildType, index) ~= nil then
                local buildingInfo = resFunBuildProxy:getBuildingInfo(buildType, index)
                table.insert(builder.buildingInfos, buildingInfo)
            end
        end
        if #builder.buildingInfos > 0 then
            builder.rs = 0
            self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100000, builder)
        end
    end
end

--建筑升级
function BuildModule:OnTriggerNet100001Event(request)
    local index = request.index
    local type = request.type
    local buildType = request.buildingType
    local isAutoLv = request.isAutoLv

    local builder = {}

    local powerlist = {}

    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local rs = resFunBuildProxy:buildingLevelUp(buildType, index, type, powerlist)
    if rs == ErrorCodeDefine.M100001_6 and isAutoLv ~= 1 then
        local needGold = resFunBuildProxy:askBuyBuildSize()
        if needGold > 0 then
            local builder = {}
            builder.rs = needGold
            builder.gold = needGold
            self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100009, builder)
        else
            builder.rs = rs
            builder.buildingInfo = resFunBuildProxy:getBuildingInfo(buildType, index)
            if rs == 0 then
                self:sendTimer(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100001, builder, powerlist)
            else
                self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100001, builder)
            end
        end
    else
    	builder.rs = rs
        local buildingInfo = resFunBuildProxy:getBuildingInfo(buildType, index)
        builder.buildingInfo = buildingInfo
        if rs == 0 or isAutoLv == 1 then
            --TODO sendTimer 先发定时器，可能逻辑操作都超过定时了，建筑信息直接有问题。 定时器直接关闭掉
            self:sendTimer(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100001, builder, powerlist)
    	else
            self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100001, builder)
        end
    end
end

--取消升级 生产
function BuildModule:OnTriggerNet100003Event(request)
    local buildingType = request.buildingType
    local index = request.index
    local order = request.order --TODO order的同步

    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {} --M100003
    local reward = PlayerReward.new() 
    local rs = resFunBuildProxy:cancelLevelCreate(buildingType, index, order, reward)
    builder.rs = rs
    local buildingInfo = resFunBuildProxy:getBuildingInfo(buildingType, index)
    builder.buildingInfo = buildingInfo
    if rs == 0 then
        --reward
        local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
        local message = rewardProxy:getRewardClientInfo(reward)
        self:sendNetMsg(ActorDefine.ROLE_MODULE_ID, ProtocolModuleDefine.NET_M2_C20007, message)
    end

    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100003, builder)

    if rs == 0 then
        self:sendSystemTimer()
    end

end

--建筑加速
function BuildModule:OnTriggerNet100004Event(request)
    local buildingType = request.buildingType
    local index = request.index
    local order = request.order
    local useType = request.useType

    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {}
    local reward = PlayerReward.new()
    local rs = resFunBuildProxy:buildSpeed(buildingType, index, order, useType, reward)
    if rs >= 0 then
        builder.rs = 0
    else
        builder.rs = rs
    end

    if rs >= 0 then
        local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
        local message = rewardProxy:getRewardClientInfo(reward)
        self:sendNetMsg(ActorDefine.ROLE_MODULE_ID, ProtocolModuleDefine.NET_M2_C20007, message)
        local systemProxy = self:getProxy(ActorDefine.SYSTEM_PROXY_NAME)
        local m3info = {}
        local tb = {}
        tb.othertype = index
        tb.bigtype = TimerDefine.BUILD_CREATE
        tb.remainTime = 0
        tb.smalltype = buildingType
        table.insert(m3info, tb)

        --TODO TASK

        local message = SystemTimer.new(systemProxy:getTimerNotify(m3info, reward, {}), m3info)
        self:sendModuleMsg(ActorDefine.SYSTEM_MODULE_ID, message)

        --TODO task
    end

    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100004, builder)


end

--建筑拆除
function BuildModule:OnTriggerNet100005Event(request)
    local buildingType = request.buildingType
    local index = request.index
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {}
    local rs = resFunBuildProxy:dropBuilding(buildingType, index)
    builder.rs = rs
    if rs == 0 then
        builder.buildingInfo = resFunBuildProxy:getBuildingInfo(0, index)
    end
    builder.index = index
    builder.buildingType = buildingType
    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100005, builder)
end

--建筑生产
function BuildModule:OnTriggerNet100006Event(request)
    local buildingType = request.buildingType
    local index = request.index
    local typeid = request.typeid
    local num = request.num

    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {} --M100006
    local reward = PlayerReward.new()

    local builder = {}
    local rs = resFunBuildProxy:builderProduction(buildingType, index, typeid, num, reward)
    builder.rs = rs
    if rs == 0 then
        local buildingInfo = resFunBuildProxy:getBuildingInfo(buildingType, index)
        builder.buildingInfo = buildingInfo
        self:sendTimer(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100006, builder, {})
    else
        self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100006, builder)
    end

    if rs == 0 then  --TODO 奖励Proxy
        local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
        local msg = rewardProxy:getRewardClientInfo(reward)
        self:sendNetMsg(ActorDefine.ROLE_MODULE_ID, ProtocolModuleDefine.NET_M2_C20007, msg)
    end
end

--请求购买建筑位
function BuildModule:OnTriggerNet100009Event(request)
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {}
    local rs = resFunBuildProxy:askBuyBuildSize()
    builder.rs = rs
    builder.gold = resFunBuildProxy:buyBuildSizePrice()
    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100009, builder)
end

--VIP购买建筑位
function BuildModule:OnTriggerNet100010Event(request)
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {}
    local rs = resFunBuildProxy:buyBuildSize()
    builder.rs = rs
    if rs == 0 then
        builder.buildingInfos = {} --resFunBuildProxy:getBuildingInfos()
        resFunBuildProxy:changeAutoBuildState(TimerDefine.BUILDAUTOLEVEL_OPEN)
    end
    if resFunBuildProxy:isAutoLeveling(GameConfig.serverTime) then
        builder.type = 1
    else
        builder.type = 2
    end
    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100010, builder)
    if rs == 0 then
        resFunBuildProxy:changeAutoBuildState(1)
        local msg = SendTimer.new()
        self:sendModuleMsg(ActorDefine.SYSTEM_MODULE_ID, msg)
    end
end

--请求购买建筑位
function BuildModule:OnTriggerNet100011Event(request)
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local builder = {}
    local rs = resFunBuildProxy:buyAutoLevel()
    builder.rs = rs
    if resFunBuildProxy:isAutoLeveling(GameConfig.serverTime) then
        builder.type = 1
    else
        builder.type = 2
    end
    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100011, builder)

    if rs == 0 then
        --发送定时器
        local msg = SendTimer.new()
        self:sendModuleMsg(ActorDefine.SYSTEM_MODULE_ID, msg)
    end
end

--设置自动建筑定时器状态
function BuildModule:OnTriggerNet100012Event(request)
    local state = request.type
    local builder  = {}
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local rs = resFunBuildProxy:changeAutoBuildState(state)
    builder.rs = rs
    builder.type = state
    self:sendNetMsg(ProtocolModuleDefine.NET_M10, ProtocolModuleDefine.NET_M10_C100012, builder)
    if rs == 0 then
        --发送定时器
        local msg = SendTimer.new()
        self:sendModuleMsg(ActorDefine.SYSTEM_MODULE_ID, msg)
    end
end



function BuildModule:sendTimer(cn, cmd, obj, powerlist)
    local systemProxy = self:getProxy(ActorDefine.SYSTEM_PROXY_NAME)
    local m3info = {}
    local reward = PlayerReward.new()
    local m30000 = systemProxy:getTimerNotify(m3info, reward, {})
    local message = BuildTimer.new(m30000, cn, cmd, obj, powerlist)
    self:sendModuleMsg(ActorDefine.SYSTEM_MODULE_ID, message)
end

function BuildModule:sendSystemTimer()
    local systemProxy = self:getProxy(ActorDefine.SYSTEM_PROXY_NAME)
    local m3info = {}
    local reward = PlayerReward.new()
    local message = SystemTimer.new(systemProxy:getTimerNotify(m3info, reward, {}), m3info)
    self:sendModuleMsg(ActorDefine.SYSTEM_MODULE_ID, message)
end