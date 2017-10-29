SystemProxy = class("SystemProxy", BasicProxy)

function SystemProxy:ctor()
    SystemProxy.super.ctor(self)
    self.proxyName = GameProxys.System
    
    self._timeInfoMap = {}
    self._cacheInfoMap = {}
    
    self._lastUpdateTime = os.time()
    
    self._lastHeartbeatTime = os.time()
    self._lastHeartbeatReq = 0 --用来计算出网络延迟

    self._oneQueueTime = 5

    self._isShowCollectSysMsg = true
end


function SystemProxy:resetAttr()
    self._timeInfoMap = {}
    self._cacheInfoMap = {}
    self._isSend = false
    self._isInitServer = nil
end

function SystemProxy:initSyncData(data)
    SystemProxy.super.initSyncData(self, data)
    self:onClientCacheResp(data)
end

------------网络协议返回--------------
--网关登录返回
function SystemProxy:onTriggerNet9999Resp(data)

    logger:info("!!!!!!!!!!网关登录返回!!!!!!!!!!!!!!rs:%d!!", data.rs)

    self._curQueueTime = nil
    if self._queueBox ~= nil then
        self._queueBox:finalize()
        self._queueBox = nil
    end

    if data.rs == ErrorCodeDefine.M9999_1 then
        GameConfig.isServerFull = true
    end

    if data.rs == ErrorCodeDefine.M9999_2 or 
        data.rs == ErrorCodeDefine.M9999_3 then

        self._lastGateResp = os.time() --最后一次收到网关信息，证明还有个服务端通讯
        GameConfig.isInGateQueue = true
        ------进入排队界面
        local queueNum = data.queueNum
        self:updateGateQueueNum(queueNum)
        local str = self:getQueueContent(self._curQueueTime)

        local function okCallback()
            self._queueBox = nil

            if not self:isLoginState() then
                SDKManager:gameLogout()
            else
                self:onTriggerNet9988Req()
            end
        end
        local function canCelcallback()
            self._queueBox = nil

            if not self:isLoginState() then
                SDKManager:gameLogout()
            else
                self:onTriggerNet9988Req()
            end
        end

        local popLayer = self:getCurGameLayer(GameLayer.popLayer)
        self._queueBox = self:showMessageBox(str, nil, canCelcallback , TextWords:getTextWord(17), nil, popLayer)
        self._queueBox:setTitleName("登录排队")
        self._queueBox:setLocalZOrder(9999)

        
    else
        GameConfig.isInGateQueue = false
        self:sendNotification(AppEvent.PROXY_SYSTEM_LOGINGATE,data)
    end
    
end

--更新排队人数数量
function SystemProxy:updateGateQueueNum(queueNum)
    local time = queueNum * self._oneQueueTime
    self._curQueueTime = time

    TimerManager:addOnce(time * 1000, self.timeToReqLoginGate, self)
end


function SystemProxy:getQueueContent(time)
    local queueNum = math.ceil(time / 5)
    local timeStr = TimeUtils:getStandardFormatTimeString7(time)
    local str = string.format(TextWords:getTextWord(16), queueNum, timeStr)
    return str
end

function SystemProxy:update()
    SystemProxy.super.update(self)

    if self._curQueueTime ~= nil and self._queueBox ~= nil then
        self._curQueueTime = self._curQueueTime - 1
        if self._curQueueTime < 0 then
            self._curQueueTime = 0
        end

        if GameConfig.isConnected == false then  --网络断开了
            self._queueBox:finalize()
            self._queueBox = nil
            self:showSysMessage(TextWords:getTextWord(18))
            return
        end

        local content = self:getQueueContent(self._curQueueTime)
        self._queueBox:updateContent(content)

        --TODO 定时发送心跳
        if os.time() - self._lastGateResp > 15 then  --发一下心跳包，证明客户端还活着 心跳要加快 
            self:onTriggerNet8888Req({})
            self._lastGateResp = os.time()
        end
    end
end

-----定时去请求网关了
function SystemProxy:timeToReqLoginGate()
    self:onTriggerNet9999Req({account = GameConfig.accountName, type = 1, areId = GameConfig.serverId})
end


--服务端主动断开连接 返回
function SystemProxy:onTriggerNet9998Resp(data)
    self:sendNotification(AppEvent.PROXY_SYSTEM_OTHERLOGIN,data)
end

--服务端主动断开连接 返回
function SystemProxy:onTriggerNet9998Resp(data)
    self:sendNotification(AppEvent.PROXY_SYSTEM_OTHERLOGIN,data)
end

--心跳包 返回
--可以用来校验服务器时间
function SystemProxy:onTriggerNet8888Resp(data)
    self._lastHeartbeatTime = os.time()
    -- local serverTime = data.serverTime

    local queueNum = data.serverTime
    local nowTime = queueNum * self._oneQueueTime
    if nowTime < self._curQueueTime then
        ------ 现在算出来的时间，小于现在倒时的，直接更新
        self:updateGateQueueNum(queueNum)
    end
    
    
    GameConfig.lastHeartbeatTime = self._lastHeartbeatTime
    
    local delay = os.clock() - self._lastHeartbeatReq
    logger:error("=======网络延迟：%f ms===============", (delay * 1000))
    
    self:sendNotification(AppEvent.PROXY_SYSTEM_HEARTBEAT,data)
end

--登录游戏返回
function SystemProxy:onTriggerNet10000Resp(data)
    self:sendNotification(AppEvent.PROXY_SYSTEM_LOGIN,data)
end

--充值成功 用来处理充值成功后的弹窗提示 返回
function SystemProxy:onTriggerNet30102Resp(data)
    self:sendNotification(AppEvent.PROXY_SYSTEM_CHARGESUCESS,data)
end

function SystemProxy:onTriggerNet30200Resp(data)
    self:showMessageBox(data.versionName)
end

----------------网络协议请求--------------------
--请求心跳包
function SystemProxy:onTriggerNet8888Req(data)
    self:syncNetReq(AppEvent.NET_M1, AppEvent.NET_M1_C8888, data)
    self._lastHeartbeatReq = os.clock()
end

--请求退出排队系统
function SystemProxy:onTriggerNet9988Req()
    self:syncNetReq(AppEvent.NET_M1, AppEvent.NET_M1_C9988, {})
end

---请求网关
--需要计算出校验码
function SystemProxy:onTriggerNet9999Req(data)

    data.sign = SDKManager:getAccountSign(data.account, data.areId)
    
    self:syncNetReq(AppEvent.NET_M1, AppEvent.NET_M1_C9999, data)
end

---请求登录
function SystemProxy:onTriggerNet10000Req(data)
    self:syncNetReq(AppEvent.NET_M1, AppEvent.NET_M1_C10000, data)
end

function SystemProxy:onTriggerNet30200Req(data)
    self:syncNetReq(AppEvent.NET_M3, AppEvent.NET_M3_C30200, data)
end

------------------------------------------

---TODO ##################下面的定时器逻辑将要删除########################

--场景重新连接，重新同步GameServer，重新启动
function SystemProxy:reLinkScene()
    self._isInitServer = nil
end

function SystemProxy:addTimer(gameServer)
--    TimerManager:add(1000, self.onUpdate, self, -1) --会一直定时
    self._lastUpdateTime = os.time()
    CountDownManager:add(2000000000, self.onUpdate, self) --给一个大大的倒计时器。。
    self.gameServer = gameServer
end

function SystemProxy:reEnterScene()
    self._timeInfoMap = {}
    self._isInitServer = nil
end

--系统倒计时 帮服务器倒计时 已无用
function SystemProxy:onSysTimeResp(data)
    self._isSend = false
    local timeInfos = data.timeInfos
    
    if rawget(data, "fromClient") ~= true then --客户端的不重置，只更新部分
--        self._timeInfoMap = {}
    end
    self._timeInfos = timeInfos
    self._isBuildTimeAutoUp = false
    local updateKeyMap = {}
    for _, timeInfo in pairs(timeInfos) do
        if timeInfo.isReset ~= 1 then
            local key = self:getKey(timeInfo.bigtype, timeInfo.smalltype, timeInfo.othertype)
--            local oldTimeInfo = self._timeInfoMap[key]
--            if oldTimeInfo ~= nil then
--                if math.abs(oldTimeInfo.remainTime - timeInfo.remainTime) >= 5 then
--                    self._timeInfoMap[key] = timeInfo
--                end
--            else
                self._timeInfoMap[key] = timeInfo
--            end
            
            updateKeyMap[key] = true

            -- 特殊处理：自动升级建筑倒计时通知
            if timeInfo.bigtype == SystemTimerConfig.BUILDING_AUTO_UPGRATE and timeInfo.smalltype == 0 and timeInfo.othertype == 0 then
                self:sendNotification(AppEvent.TIME_AUTO_UPGRATE, {})
                self._isBuildTimeAutoUp = true
            end
        end
    end
    
    --print_r(timeInfos)
    
    --需要把现在有的定时器，而更新里面没有的定时器给删除掉
    local removeKeyList = {}
    if rawget(data, "fromClient") == true then --客户端自己的数据 服务器数据会把建筑相关的定时器屏蔽掉
        for key, timeInfo in pairs(self._timeInfoMap) do
            if updateKeyMap[key] == nil then --把m相关的定时器 删除掉
                if timeInfo.bigtype == server.TimerDefine.BUILD_CREATE 
                    or timeInfo.bigtype == server.TimerDefine.BUILDING_LEVEL_UP then
                table.insert(removeKeyList, key)
            end
            end 
        end
    end
    
    if rawget(data, "fromSysServer") == true then
        for key, timeInfo in pairs(self._timeInfoMap) do
            if updateKeyMap[key] == nil then --把m相关的定时器 删除掉
                if timeInfo.bigtype ~= server.TimerDefine.BUILD_CREATE 
                    and timeInfo.bigtype ~= server.TimerDefine.BUILDING_LEVEL_UP
                    or data.isAutoLeveling == true then
                    table.insert(removeKeyList, key)
                end
            end 
        end
    end
    
    if rawget(data, "fromAllServer") == true then
        local newMap = {}
        local removeMap = {}
        for _, timeInfo in pairs(timeInfos) do
            local key = self:getKey(timeInfo.bigtype, timeInfo.smalltype, timeInfo.othertype)
            newMap[key] = timeInfo
        end
        
        for key, timeInfo in pairs(self._timeInfoMap) do
        	if newMap[key] == nil then
                removeMap[key] = timeInfo
        	end
        end
        
        local send = false
        for _, timeInfo in pairs(removeMap) do
        	if timeInfo.bigtype == server.TimerDefine.BUILD_CREATE or
        	    timeInfo.bigtype == server.TimerDefine.BUILDING_LEVEL_UP then
        	    send = true
        	end
        end
        
        if send == true then
            if self.gameServer ~= nil then
                self.gameServer:onTrigger30000()
            end
        end
        
        self._timeInfoMap = newMap
    end
--    else  --服务器传来的定时器，删掉非建筑相关的定时器
--        for key, timeInfo in pairs(self._timeInfoMap) do
--            if updateKeyMap[key] == nil then --把m相关的定时器 删除掉
--                if timeInfo.bigtype ~= server.TimerDefine.BUILD_CREATE 
--                    and timeInfo.bigtype ~= server.TimerDefine.BUILDING_LEVEL_UP
--                    or self._isBuildTimeAutoUp == true then
--                    table.insert(removeKeyList, key)
--                end
--            end 
--        end
--    end
    
    for _, key in pairs(removeKeyList) do
        self._timeInfoMap[key] = nil
    end
    
    --print("========############===============")
    --print_r(data)
    --print_r(self._timeInfoMap)
    --print("========############===============")
    
    if self.gameServer ~= nil then
        if self._isInitServer ~= true and rawget(data, "fromAllServer") == true then
            local roleProxy = self:getProxy(GameProxys.Role)
            local m20000 = roleProxy:getM20000()
            self.gameServer:launch(m20000, data)
            self._isInitServer = true
            
            local buildingProxy = self:getProxy(GameProxys.Building)
            buildingProxy:buildingAutoUpReq()
        end
    end
end

function SystemProxy:isBuildTimeAutoUp()
    return self._isBuildTimeAutoUp
end

function SystemProxy:getGameServer()
    return self.gameServer
end

function SystemProxy:onUpdate()
    if self._timeInfos == nil or self._isSend == true then
        return
    end
    
    local dt = os.time() - self._lastUpdateTime
    --remainTime 是定时器到点的时间戳
    local isSend = false
    for _, timeInfo in pairs(self._timeInfoMap) do
        timeInfo.remainTime = timeInfo.remainTime - dt
--        local remainTime = timeInfo.remainTime - GameConfig.serverTime
--        if timeInfo.remainTime <= 0 then
        if timeInfo.remainTime <= 0 then
            local key = self:getKey(timeInfo.bigtype, timeInfo.smalltype, timeInfo.othertype)
            self._timeInfoMap[key] = nil
            isSend = true
--            break
        end
    end
    
    self._lastUpdateTime = os.time()
    
    if isSend == true then
        self._isSend = isSend
        
        if self.gameServer ~= nil then
            self.gameServer:onTrigger30000()
        end
--        self:sendServerMessage(AppEvent.NET_M3, AppEvent.NET_M3_C30000, {})
    end
end


--整个系统的倒计时 都在这里拿
function SystemProxy:getRemainTime(bigtype, smalltype, othertype )
    local remainTime = 0
    local key = self:getKey(bigtype, smalltype, othertype)
    local timeInfo = self._timeInfoMap[key]
    if timeInfo ~= nil then
        remainTime = timeInfo.remainTime
--        remainTime = timeInfo.remainTime - GameConfig.serverTime
--        if remainTime < 0 then
--            remainTime = 0
--        end
--        remainTime = math.ceil(remainTime)
    end
    return remainTime
end

--设置倒计时时间
function SystemProxy:setRemainTime(bigtype, smalltype, othertype, remainTime)
    local key = self:getKey(bigtype, smalltype, othertype)
    local timeInfo = {}
    timeInfo.bigtype = bigtype
    timeInfo.smalltype = smalltype
    timeInfo.othertype = othertype
    timeInfo.remainTime = remainTime
    
    if self._timeInfoMap[key] == nil and self._timeInfos ~= nil then
        table.insert(self._timeInfos, timeInfo)
    end
    self._timeInfoMap[key] = timeInfo
end

function SystemProxy:getKey(bigtype, smalltype, othertype)
    return bigtype .. "_" .. smalltype .. "_" .. othertype
end

----建筑生产--bigtype:BUILDING_CREATE----smalltype:index------othertype:typeid----------
--建筑升级---bigtype:BUILDING_LEVEL_UP  --smalltype:buildingType----othertype:index

-- 恢复体力 
-- bigtype = DEFAULT_ENERGY_RECOVER
-- smalltype = 0
-- othertype = 0

------------------------------------------------------------------------------------
function SystemProxy:onClientCacheResp(data)
    local cacheInfos = data.cacheInfos
    
    self._cacheInfoMap = {}
    for _, cacheInfo in pairs(cacheInfos) do
        self._cacheInfoMap[cacheInfo.msgType] = cacheInfo
    end
    
    local worldCollectionInfos = self:getCacheProtoMsgByType(ClientCacheType.WORLD_COLLECTION)

    if worldCollectionInfos == false then --解析失败
        logger:error("==========世界收藏数据解析失败！！===========")
        return
    end
    local friendProxy = self:getProxy(GameProxys.Friend)
--    friendProxy:synWorldCollectionInfo()
    friendProxy:initWorldCollectionInfos(worldCollectionInfos)
end

function SystemProxy:getCacheProtoMsgByType(type)
    local info = self._cacheInfoMap[type] or {}
    local name = self:getMessageProtoName(type)
    local msg = info.msg or ""
--    print(string.len(msg), msg)
--    for index=1, string.len(msg) do
--        print(string.byte(msg,index))
--    end
    local data = protobuf.decode("M3." .. name , msg)
    return data
end

function SystemProxy:getCacheInfoByType(type)
    return  self._cacheInfoMap[type]
end

function SystemProxy:updateProtoGeneratedMessage(type, data)
    local name = self:getMessageProtoName(type)
    local msg = protobuf.encode("M3." .. name , data)

    self:updateCacheMsg(type, msg)
end

--更新缓存数据，没有的话，则插入
function SystemProxy:updateCacheMsg(type, msg)
    local info = self:getCacheInfoByType(type)
    if info == nil then
        info = {}
    end
    
    self._type = type
    info.msgType = type
    info.msg = msg
    
    self._cacheInfoMap[type] = info
    
    --通知服务器
    self:sendServerMessage(AppEvent.NET_M3, AppEvent.NET_M3_C30101,{cacheInfo = info})
end

function SystemProxy:onTriggerNet30101Resp(data)
    if data.msgType == ClientCacheType.WORLD_COLLECTION then
        if self._isShowCollectSysMsg then
            self:showSysMessage("收藏成功")
        else
            self._isShowCollectSysMsg = true
        end
    end
end

function SystemProxy:getMessageProtoName(type)
    if self._protoNameMap == nil then
        self._protoNameMap = {}
        self._protoNameMap[ClientCacheType.WORLD_COLLECTION] = "WorldCollectionInfos"
        self._protoNameMap[ClientCacheType.WORLD_ENTER] = "EnterWorld"
    end
    
    return self._protoNameMap[type]
end


---//场景切换协议
function SystemProxy:onTriggerNet30105Req(data)
    self:syncNetReq(AppEvent.NET_M3, AppEvent.NET_M3_C30105, data)
end

function SystemProxy:onTriggerNet30105Resp(data)
    if data.rs == 0 then
    end
end

-- 设置是否显示“收藏成功”
function SystemProxy:setIsShowCollectSysMsg(isShow)
    self._isShowCollectSysMsg = isShow
end



