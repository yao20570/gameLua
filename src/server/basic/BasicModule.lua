module("server", package.seeall)

BasicModule = class("BasicModule")

function BasicModule:ctor(gameProxy, gameServer)
	self._gameProxy = gameProxy
	self._gameServer = gameServer
end

function BasicModule:onTriggerNetEvent(cmd, data)
    local func = self["OnTriggerNet" .. cmd .. "Event"]
    if func ~= nil then
        local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
        local map = playerProxy:getAllPowerValue()
        TimerDefine.triggerTime = os.time()
    	func(self, data)
        self:checkPlayerPowerValues(map)
    	return true
    else
    	return false
    end
end

--接受到其他消息
function BasicModule:onReceiveOtherMsg(msg)

end

function BasicModule:getProxy(name)
	return self._gameProxy:getProxy(name)
end

--检测power值是否改变了
function BasicModule:checkPlayerPowerValues(map)
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    local newMap = playerProxy:getAllPowerValue()

    local diffs = {}
    for key, value in pairs(newMap) do
        local oldValue = map[key]
        if oldValue ~= value then
            local diff = {}
            diff.typeid = key
            diff.value = value
            diff.showValue = 0
            --TODO power exp
            table.insert(diffs, diff)

            --TODO TASK
        end
    end

    if #diffs > 0 then
        local builder = {}
        builder.diffs = diffs 
        self:sendNetMsg(ActorDefine.ROLE_MODULE_ID, ProtocolModuleDefine.NET_M2_C20002, builder)
    end

    
end

--M2.M20002.S2C.Builder
function BasicModule:sendDifferent(powerList)
    local builder = {}
    builder.diffs = {}
    local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
    for _, power in pairs(powerList) do
        local value = playerProxy:getPowerValue(power)
        local diff = {}
        --TODO exp
        --TODO level
        diff.typeid = power
        diff.value = value
        diff.showValue = 0
        table.insert(builder.diffs, diff)
    end

    return builder
end

--发送处理好的协议到客户端
function BasicModule:sendNetMsg(moduleId, cmd, data)
    local recv = {}
    recv.mId = moduleId
    recv.cmdId = cmd
    recv.data = data
    self._gameServer:onRespNetMsg(recv, true)
end

--module -> module 发送消息
function BasicModule:sendModuleMsg(moduleId, msg)
    local module = self._gameServer:getModule(moduleId)
    if module ~= nil then
        module:onReceiveOtherMsg(msg)
    end
end


