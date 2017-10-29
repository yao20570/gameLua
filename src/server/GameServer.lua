-----------------
---
---游戏服务器入口
--------
module("server", package.seeall)

GameServer = class("GameServer")

function GameServer:ctor()
    self._moduleMap = {}
    self._transceiver = nil
    
    self._sendNetMap = {}
    self._clientNetRsMap = {} --记录客户端的逻辑rs,判断是不是跟服务器一直
    
    self._sendProtoMap = {} --发送的协议数据，用来处理丢包的情况，如果发送不出去，则过一段时间再发送，多次发送失败，直接断网 先处理建筑模块
    
--    self:init(m20000)
end

function GameServer:finalize()
    self._moduleMap = {}
    self._sendNetMap = {}
    self._clientNetRsMap = {}
    self._sendProtoMap = {}
end


function GameServer:launch(m20000, m30000)
    self:init(m20000, m30000)
end

function GameServer:init(m20000, m30000)

    --print("=======!!========GameServer:init===========!!!======")

    self._moduleMap = {}
    self._sendNetMap = {}
    self._clientNetRsMap = {}
    self._sendProtoMap = {}
    
    self:launchAllLogicModules(m20000, m30000)  --
end

function GameServer:setTransceiver(transceiver)
    self._transceiver = transceiver
end

function GameServer:setNetChannel(netChannel)
    self._netChannel = netChannel
end

--协议中转站 c => s
function GameServer:onSendNetMsg(proto)
--    local module = netMsg.module
--    local cmd = netMsg.cmd
    
    local moduleId = proto.mId
    local cmd = proto.cmdId
    
--    logger:info("======onSendNetMsg===%d=====%d======", moduleId, cmd)
--    
--    --TODO 流转到各个协议模块中
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local isAutoLeveling  = false
    if resFunBuildProxy ~= nil then
        isAutoLeveling = resFunBuildProxy:isAutoLeveling(os.time())
    end
   local module = self:getModule(moduleId)
    if module ~= nil and isAutoLeveling ~= true then
       local time = os.clock()
       local result = module:onTriggerNetEvent(cmd, proto.obj)
       
        print("============onSendNetMsg=================", os.clock() - time, cmd)
       if result == true then
--            self._sendNetMap[cmd] = true
       end
   end

    self._transceiver:send(proto.data)
    
    if moduleId == ActorDefine.BUILD_MODULE_ID and isAutoLeveling ~= true then
        local function callback(obj, data)
            if self._sendProtoMap[cmd] ~= nil and self._sendProtoMap[cmd] > 0 then --15秒钟还没有返回，再发一次
                --logger:error("---send------cmd:%d------count:%d----------", cmd, self._sendProtoMap[cmd])
                self._transceiver:send(data)
            end
        end
        if self._sendProtoMap[cmd] == nil then
            self._sendProtoMap[cmd] = 0
        end
        self._sendProtoMap[cmd] = self._sendProtoMap[cmd] + 1
        TimerManager:addOnce(15000, callback, self, proto.data)
    end
    
    --网络等待 直接Loading，不处理丢包了，长时间，则直接断网
    if NetWaitingMap[cmd] ~= nil then
        if self._sendProtoMap[cmd] == nil then
            self._sendProtoMap[cmd] = 0
        end
        self._sendProtoMap[cmd] = self._sendProtoMap[cmd] + 1
        
        local function callback()
            if self._sendProtoMap[cmd] ~= nil and self._sendProtoMap[cmd] > 0 then  --显示Loading
                if GameConfig.isConnected == true then
                    self._netChannel:showLoading()
                else --已经断开链接了，把loading去掉
                    self._netChannel:hideLoading()
                end
            end
        end
        TimerManager:addOnce(NetWaitingMap[cmd].waitTime * 1000, callback, self)
    end
end

--收到真正从服务器传过来的数据
--这里做一层校验，如果跟客户端计算的一致，则不再进行派发
--有些会保存一些初始化的协议数据
--需要做处理，如果协议收到不到
function GameServer:onRespNetMsg(recv, clientProxy)
    local mId = recv.mId
    local cmdId = recv.cmdId
--    if cmdId ~= 8888 then
        logger:info("=====no==error==s--->c(%d %d)==clientProxy:%s==", mId, cmdId, tostring(clientProxy))
--    end
    local data = recv.data
    
    if clientProxy == true then --先行的客户端服务器逻辑协议
        local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
        local isAutoLeveling = resFunBuildProxy:isAutoLeveling(os.time())
        if isAutoLeveling ~= true then
            self._sendNetMap[cmdId] = true
            self._clientNetRsMap[cmdId] = data.rs
            data.fromClient = true
            self._netChannel:errorCodeHandler(cmdId, data)
            self._netChannel:sendNotification( mId, cmdId, data)
        else
            self._sendNetMap[cmdId] = nil
        end
    else
        if mId == ActorDefine.BUILD_MODULE_ID then
            if self._sendProtoMap[cmdId] ~= nil then
                self._sendProtoMap[cmdId] = self._sendProtoMap[cmdId] - 1
                --logger:error("---rec------cmd:%d------count:%d----------", cmdId, self._sendProtoMap[cmdId])
            end
        end
        if NetWaitingMap[cmdId] ~= nil then
            self._sendProtoMap[cmdId] = self._sendProtoMap[cmdId] - 1
            if self._sendProtoMap[cmdId] <= 0 then
                self._netChannel:hideLoading()
            end
        end
        if self._sendNetMap[cmdId] == true then
            local rs = rawget(data,"rs")
            if self._clientNetRsMap[cmdId] ~= nil and 
                self._clientNetRsMap[cmdId] ~= rs  then -- or true
                logger:error("=======客户端的操作逻辑rs与服务器不一致！cmd:%d====:%d===:%d===", cmdId, rs, self._clientNetRsMap[cmdId])
                if mId == ActorDefine.BUILD_MODULE_ID and cmdId ~= ProtocolModuleDefine.NET_M10_C100000  then --建筑模块不一致 直接再同步一遍数据
                    local data = {} --TODO
                    data.moduleId = mId
                    data.cmdId = ProtocolModuleDefine.NET_M10_C100000
                    data.obj = {}
                    self._netChannel:onSend(data)
                end
            end
            local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
            local isAutoLeveling = resFunBuildProxy:isAutoLeveling(os.time())
            if rs ~= nil and rs ~= 0 and isAutoLeveling ~= true then  --不再错误码提示了
            else
                logger:info("===server=net=not=send===%d==========", cmdId)
                --先不发，测试
                if isAutoLeveling == true then --自动建筑时，确保走的是之前的服务器逻辑，只同步数据
                    self._netChannel:errorCodeHandler(cmdId, data)
                    self._netChannel:sendNotification( mId, cmdId, data)
                end
--                 --TODO，这里先再刷一般，可优化，对比数据处理
                if cmdId  == ProtocolModuleDefine.NET_M3_C30000 then --30000同步一下
                    local newData = {}
                    newData.fromSysServer = true
                    newData.isAutoLeveling = isAutoLeveling
                    newData.type = data.type
                    newData.timeInfos = {}
                    local timeInfos = data.timeInfos
                    for _, timeInfo in pairs(timeInfos) do
                    	if timeInfo.bigtype ~= TimerDefine.BUILD_CREATE 
                            and timeInfo.bigtype ~= TimerDefine.BUILDING_LEVEL_UP 
                            then
                            table.insert(newData.timeInfos, timeInfo)
                    	end
                    end
                    self._netChannel:sendNotification( mId, cmdId, newData)
                end
                if cmdId == ProtocolModuleDefine.NET_M10_C100000 then
                    if data.rs == 1 then  --建筑数据同步
                        resFunBuildProxy:updateAllBuilding(data.buildingInfos)
                        self._netChannel:errorCodeHandler(cmdId, data)
                        self._netChannel:sendNotification( mId, cmdId, data)
                    end
                end
                
                if cmdId == ProtocolModuleDefine.NET_M2_C20007 or --佣兵数据、角色属性，还是要更新一下 以服务端为主，客户端再做校验
                    cmdId == ProtocolModuleDefine.NET_M2_C20002  then
                    self._netChannel:sendNotification( mId, cmdId, data)
                end
            end
            self._sendNetMap[cmdId] = nil
        else
            if cmdId  == ProtocolModuleDefine.NET_M3_C30000 then
                data.fromAllServer = true
            end
            
            --登录的时候，服务端不自己升级检测. 让服务端登录时升级
            local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
            if resFunBuildProxy ~= nil and cmdId == ProtocolModuleDefine.NET_M10_C100000 then
                if data.rs == 2 then --进场景后续的一些升级的同步
--                    print("=======resFunBuildProxy===2=========")
                    resFunBuildProxy:updateBuildings(data.buildingInfos)
                    self._netChannel:sendNotification( mId, cmdId, data) --还是得通知客户端更新一下
                end
            end
            
            if cmdId  == ProtocolModuleDefine.NET_M3_C30000
            and resFunBuildProxy ~= nil and 
                resFunBuildProxy:isAutoLeveling(os.time()) == false then --没有在自动升级 30000同步一下
                local newData = {}
                newData.fromSysServer = true
                newData.isAutoLeveling = resFunBuildProxy:isAutoLeveling(os.time())
                newData.type = data.type
                newData.timeInfos = {}
                local timeInfos = data.timeInfos
                for _, timeInfo in pairs(timeInfos) do
                    if timeInfo.bigtype ~= TimerDefine.BUILD_CREATE 
                        and timeInfo.bigtype ~= TimerDefine.BUILDING_LEVEL_UP 
                    then
                        table.insert(newData.timeInfos, timeInfo)
                    end
                end
                self._netChannel:sendNotification( mId, cmdId, newData)
            else
                if cmdId == ProtocolModuleDefine.NET_M10_C100000 and
                 resFunBuildProxy ~= nil and --直接屏蔽掉服务器自动发送过来的建筑更新数据
                   resFunBuildProxy:isAutoLeveling(os.time()) == false
                   and data.rs == 0 then
                   logger:error("===服务器发送的普通建筑信息，不更新===============")
                else
                    self._netChannel:errorCodeHandler(cmdId, data)
                    self._netChannel:sendNotification( mId, cmdId, data)
                end
            end
        end
        
        if self._gameProxy == nil then
            return
        end
        
        local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
        local isAutoLeveling = resFunBuildProxy:isAutoLeveling(os.time())
        
        if mId == ActorDefine.BUILD_MODULE_ID then
            if data.rs >= 0 then
                local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
                if cmdId == ProtocolModuleDefine.NET_M10_C100000 then
                    if data.rs == 1 then --请求全部建筑信息同步的
                        resFunBuildProxy:updateAllBuilding(data.buildingInfos)
                    else
                        if isAutoLeveling == true then
                            resFunBuildProxy:updateBuildings(data.buildingInfos)
                        end
                    end
                end
                
                if isAutoLeveling == true then
                    if cmdId == ProtocolModuleDefine.NET_M10_C100001
                        or cmdId == ProtocolModuleDefine.NET_M10_C100003
                        or cmdId == ProtocolModuleDefine.NET_M10_C100005
                        or cmdId == ProtocolModuleDefine.NET_M10_C100006 then
                        resFunBuildProxy:updateBuildings({data.buildingInfo})
                    end
                end
                
            end
        end
        
        if cmdId  == ProtocolModuleDefine.NET_M3_C30000 then
            local notUpList = {}
            if isAutoLeveling == true then
                local timerdbProxy = self:getProxy(ActorDefine.TIMERDB_PROXY_NAME)
                notUpList = timerdbProxy:updateTimer(data.timeInfos)
            end
        end
        
        local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
        if cmdId == ProtocolModuleDefine.NET_M2_C20002 then --同步一下数据
            for _, diff in pairs(data.diffs) do
                playerProxy:setPowerValue(diff.typeid, diff.value)
            end
        end
        
        if cmdId == ProtocolModuleDefine.NET_M2_C20007 then --同步一下道具、佣兵数据
            if #data.itemList > 0 then
                local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
                itemProxy:updateItems(data.itemList)
            end
            if #data.soldierList > 0 then
                local soldierProxy = self:getProxy(ActorDefine.SOLDIER_PROXY_NAME)
                soldierProxy:updateSoldiers(data.soldierList)
            end
        end
    end
end

--function Game


function GameServer:launchAllLogicModules(m20000, m30000)
    --TODO 重连时，需要把相关的proxy、module释放掉

    local gameProxy = GameProxy.new(m20000, m30000)
    self._gameProxy = gameProxy
    self._moduleMap[ActorDefine.ROLE_MODULE_ID] = RoleModule.new(gameProxy, self)
    self._moduleMap[ActorDefine.BUILD_MODULE_ID] = BuildModule.new(gameProxy, self)
    self._moduleMap[ActorDefine.SYSTEM_MODULE_ID] = SystemModule.new(gameProxy, self)
end

function GameServer:getCanAutoLevelBuild()
    local m3info = {}
    if self._gameProxy == nil then
        return m3info
    end
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    resFunBuildProxy:buildAutoLevelUp(m3info, true)
    return m3info
end

function GameServer:onTrigger30000()
    local resFunBuildProxy = self:getProxy(ActorDefine.RESFUNBUILD_PROXY_NAME)
    local isAutoLeveling  = false
    if resFunBuildProxy ~= nil then
        isAutoLeveling = resFunBuildProxy:isAutoLeveling(os.time())
    end

    local sysModule = self:getModule(ActorDefine.SYSTEM_MODULE_ID)
    if sysModule ~= nil and isAutoLeveling ~= true then
        sysModule:OnTriggerNet30000Event()
    end
end

function GameServer:getModule(moduleId)
    if self._moduleMap == nil then
        return
    end
    return self._moduleMap[moduleId]
end

function GameServer:getProxy(name)
    if self._gameProxy == nil then
        return nil
    end
    return self._gameProxy:getProxy(name)
end





