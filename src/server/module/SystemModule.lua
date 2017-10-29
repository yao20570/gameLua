module("server", package.seeall)

SystemModule = class("SystemModule", BasicModule)

--接受到别的模块发送来的消息
function SystemModule:onReceiveOtherMsg(object)
    if instanceof(object, BuildTimer) then
    	local cn = object.cn
    	local cmd = object.cmd
    	local obj = object.obj
    	local powerlist = object.powerlist
    	self:sendBuildTimer(cn, cmd, obj, powerlist)
    elseif instanceof(object, SystemTimer) then
    	local builder = object.m30000
    	local infoList = object.infoList
    	self:send30000(builder, infoList)
    elseif instanceof(object, SendTimer) then
        self:OnTriggerNet30000Event()
    end
end


function SystemModule:sendBuildTimer(cn, cm, object, powerlist)
    local different = self:sendDifferent(powerlist)
    self:sendNetMsg(ActorDefine.ROLE_MODULE_ID, ProtocolModuleDefine.NET_M2_C20002, different)

    self:OnTriggerNet30000Event(nil)
    --再去拿一次数据
    local buildType = object.buildingInfo.buildingType
    local index = object.buildingInfo.index
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local buildingInfo = resFunBuildProxy:getBuildingInfo(buildType, index)
    object.buildingInfo = buildingInfo
    self:sendNetMsg(cn, cm, object)
end


function SystemModule:OnTriggerNet30000Event(request)
    --print("==========SystemModule:OnTriggerNet30000Event======================")
    TimerDefine.triggerTime = os.time() --现在客户端直接调用了
    local systemProxy = self:getProxy(ActorDefine.SYSTEM_PROXY_NAME)
    local infoList = {} --M3.TimeInfo
    local reward = PlayerReward.new()
    local playerTasks = {}

    --TODO self:checkMop()
    local builder = systemProxy:getTimerNotify(infoList, reward, playerTasks)
    builder.type = 0
    self:sendNetMsg(ProtocolModuleDefine.NET_M3, ProtocolModuleDefine.NET_M3_C30000, builder)

    --TODO ---rewardProxy
    local rewardProxy = self:getProxy(ActorDefine.REWARD_PROXY_NAME)
    local message = rewardProxy:getRewardClientInfo(reward)
    self:sendNetMsg(ActorDefine.ROLE_MODULE_ID, ProtocolModuleDefine.NET_M2_C20007, message)
    self:dueInfo(infoList, {})

    --TODO buffProxy 推送刷新buff

end


function SystemModule:send30000(builder, infoList)
    builder.type = 0
    self:sendNetMsg(ProtocolModuleDefine.NET_M3, ProtocolModuleDefine.NET_M3_C30000, builder)
    
    --TODO 
    --dueInfo 任务相关的
    self:dueInfo(infoList, {})
end

function SystemModule:dueInfo(infoList, playerTasks)
	local buildlist = {}
	for _, ti in pairs(infoList) do
		if ti.bigtype == TimerDefine.BUILD_CREATE or ti.bigtype == TimerDefine.BUILDING_LEVEL_UP then
			local list = {}
			table.insert(list, ti.smalltype)
			table.insert(list, ti.othertype)
			table.insert(buildlist, list)
		end
	end
	if #infoList > 0 then
		local message = BuildInfo.new(buildlist)
        self:sendModuleMsg(ActorDefine.BUILD_MODULE_ID, message)

		--TODO task
	end
end