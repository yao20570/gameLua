NetChannel = class("NetChannel")

function NetChannel:ctor()
    require "framework.proto.protobuf"

    self._transceiver = SocketTransceiver.new()
    self._transceiver:setChannel(self)  --直接设置

    self._msgCenter = nil
    self._protoData = {}
    self:initProtobuf()
    
    self._lastSendProtoMap = {} --协议最后发送的时间
    self._minSendInval = 0.3 --s  最小发送间隔
    self._serverList = {}
    
    self._transceiverQueue = Queue.new() --协议传输队列
    self._recvQueue =  Queue.new() --接受到的数据队列
    
    self._curSendNetCount = 0 --当前发送的协议数
    self._curRecvNetCount = 0 --当前接受的协议数
    self._curLogNetCount = 0 --
    
    self._maxSendFrame = 3 --一帧只能多少个协议传输
    self._curSendCount = 0
    self._isCanSend = true --接受到协议数据才能进行下一次发送
    
    self._netReqTimeMap = {} --发送协议的时间MAP
    
    local function onProtoSchedule()
        self:onProtoSchedule()
    end
    self.protoSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onProtoSchedule,0,false)
--    for i=1, 0 do
--        table.insert(self._serverList, SocketTransceiver.new()) --test
--    end
end

function NetChannel:finalize()

    if self.protoSchedule ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.protoSchedule)
    end

    self._msgCenter:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_SEND_DATA, self, self.onSend)
    self._msgCenter:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_HAND_CLOSE_CONNECT, self, self.onHandCloseNet)
    self._msgCenter:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, self, self.onAutoCloseNet)
    self._transceiver:finalize()
    
    self._transceiver = nil
    self:clearQueue()
end

function NetChannel:clearQueue()
    self._isCanSend = true
    self._transceiverQueue:clear()
    self._netReqTimeMap = {}
end

function NetChannel:onProtoSchedule()

    --------------重新请求---那些服务器还没有返回的协议请求-------------
    for _, data in pairs(self._netReqTimeMap) do
        local dtTime = os.time() - data.sendTime
        if dtTime > 3 then  --超过3秒，服务端还没有对这条协议做处理，重新请求一下
            if data.tryReqCount >= 3 then  --尝试了5次请求了，还没有反应，直接断网处理
                self:onAutoCloseNet()  --上面有做处理了，同条协议，请求3次就会断网
                break
            else
            logger:error("=====no==error=try====c--->s(%d %d)==reqTime:%d==", data.mId, data.cmdId, data.reqTime)
                if self._isCanSend == false then --当前网络不流畅，不直接发送，先push到队列
                    self._transceiverQueue:push({mId = data.mId, cmdId = data.cmdId, buffer = data.buffer})
                else
                    self:onSendOneNet(data.mId, data.cmdId, data.buffer, data.reqTime)
                end
                data.tryReqCount = data.tryReqCount + 1
                data.sendTime = os.time()
            end
        end
    end
    
    if self._curLogNetCount > 800 then
        -- logger:error("====当前发送的协议数:%d==当前接受的协议数:%d=======", self._curSendNetCount, self._curRecvNetCount )
        self._curLogNetCount = 0
    end
    self._curLogNetCount = self._curLogNetCount + 1
    if self._isCanSend == false then
        local size = self._transceiverQueue:size()
        if size >= 10 then --有10个协议还未操作，弹框提示
--            component.Loading:show("数据正在处理中", 1)
        end
        if size >= 3 then --直接断网重连
            local curState = self._game:getCurState()
            if curState.name == GameStates.Scene then
                local sceneModule = curState:getModule(ModuleName.MainSceneModule)
                if sceneModule ~= nil and sceneModule:isEnterScene() then --在场景里面，有3个操作没有返回了
                    local list = self._transceiverQueue:getList()
                    local maxSame = 0
                    local tmpMap = {}
                    for _, proto in pairs(list) do
                        local cmd = proto.cmdId
                        if tmpMap[cmd] == nil then
                            tmpMap[cmd] = 0
                        end
                        tmpMap[cmd] = tmpMap[cmd] + 1
                        if maxSame < tmpMap[cmd] then
                            maxSame = tmpMap[cmd]
                        end
                    end
                    if maxSame >= 3 then  --还未发送的协议里面，如果有3条一样的，则直接断开连接
                        logger:error("~~~~~~~~~~还未发送的协议里面，如果有3条一样的，则直接断开连接~~~~~~~")
                        self:onAutoCloseNet()
                        return
                    end
                end
            end
        end
        if size >= 15 then
            local curState = self._game:getCurState()
            local sceneModule = curState:getModule(ModuleName.MainSceneModule)
            if sceneModule ~= nil and sceneModule:isEnterScene() then --在场景里面，有15个操作没有返回了
                logger:error("~~~~~~~~~在场景里面，有15个操作没有返回了~~~~~~~")
                self:onAutoCloseNet()
            end
        end
        return
    end

    local sendList = {}
    local len = 0
    for i=1,10 do
        local proto = self._transceiverQueue:pop()
        if proto ~= nil then
            table.insert(sendList, proto)
            len = len + string.len(proto.buffer)
        end
    end

    if #sendList > 0 then
        -- print("=========sendList========", #sendList)
        local sendCount = #sendList
        local byteArray = ByteArray.new()
        byteArray:writeInt(4 + 1 + (1 + 4 + 4) * sendCount + len)
        local curTime = math.abs(math.ceil(os.clock() * 100)) 
        byteArray:writeInt(curTime)
        byteArray:writeByte(sendCount)
        for _, proto in pairs(sendList) do
            self._curSendNetCount = self._curSendNetCount + 1
            byteArray:writeInt(string.len(proto.buffer))
            byteArray:writeByte(proto.mId)
            byteArray:writeInt(proto.cmdId)
            byteArray:writeBytes(proto.buffer)
        end

        self._transceiver:send(byteArray:toString())

        self._curSendCount = self._curSendCount + 1
        if self._curSendCount >= self._maxSendFrame then
            self._isCanSend = false --达到最大发送条数了
            self._curSendCount = 0
        end
    end

--     local proto = self._transceiverQueue:pop()  --TODO 把多条协议打包一起发送
--     if proto ~= nil then
-- --        local loadingType = component.Loading:getType()
-- --        if loadingType ~= nil then
-- --            component.Loading:hide()
-- --        end
--         self._curSendNetCount = self._curSendNetCount + 1
--         self:sendNet(proto)
-- --        self._transceiver:send(proto.data)
-- --        if proto.cmdId ~= 8888 then
--             logger:info("=====no==error==send==c--->s(%d %d)======", proto.mId, proto.cmdId)
-- --        end
--         self._curSendCount = self._curSendCount + 1
--         if self._curSendCount >= self._maxSendFrame then
--             self._isCanSend = false --达到最大发送条数了
--             self._curSendCount = 0
--         end
--     end
    
    --一次处理10条协议
    for index=1, 5 do 
        local recv = self._recvQueue:pop()
        if recv ~= nil then
            self:recvNet(recv)
            self._curRecvNetCount = self._curRecvNetCount + 1
            --        local mId = recv.mId
            --        local cmdId = recv.cmdId
            --        if cmdId ~= 8888 then
            --            logger:info("=====no==error==s--->c(%d %d)====", mId, cmdId)
            --        end
            --        local data = recv.data
            --        self:errorCodeHandler(cmdId, data)
            --        self._msgCenter:sendNotification( mId, cmdId, data)
        end
    end
    
end

------
-- M20000数据初始化消息号，moduleIdList包含import的模块id
-- 新import但没加入会导致错误
function NetChannel:initProtobuf()
    local data = cc.FileUtils:getInstance():getFileData("proto/Common.pb")
    protobuf.register(data)
    
    local moduleIdList = {1,10,28,3,4,5,6,7,47,16,8,26,12,41,57,58,60,61,23,9,20,54,14,21,17,31,32,33,27,22,36,38,30,35,37,34,39,20,43,46,13,48,49,51,53,44,59}
    for _, moduleId in pairs(moduleIdList) do
        self:registerProto(moduleId)
    end
end

function NetChannel:setMsgCenter(msgCenter, game)
    self._msgCenter = msgCenter
    self._game = game
    
    self:registerEvent()
end

--接受到网络消息，中间增加GameServer Proxy层
function NetChannel:recvNet(recv)
    local curState = self._game:getCurState()
    local gameServer = curState:getGameServer()
    if gameServer == nil then
        local mId = recv.mId
        local cmdId = recv.cmdId
--        if cmdId ~= 8888 then
          if GameConfig.packageInfo ~= 2 then
            logger:error("=====no==error==s--->c(%d %d)====", mId, cmdId)
          end
--        end
        local data = recv.data
        self:errorCodeHandler(cmdId, data)
        self._msgCenter:sendNotification( mId, cmdId, data)
        
        if self._netReqTimeMap[cmdId] ~= nil then
            local checkFunction = self._netReqTimeMap[cmdId].checkFunction
            if checkFunction ~= nil then
                TimerManager:remove(checkFunction, self)
            end
        end

        self._netReqTimeMap[cmdId] = nil
        
        --没有等待队列，才隐藏掉
        if self._isShowDelayLoading == true and table.size(self._netReqTimeMap) == 0 then
            self._isShowDelayLoading = false
            self:hideLoading()  --只有延迟加载，才会隐藏
        end
        
        self._game:recvNet(cmdId, data)
    else
        gameServer:setNetChannel(self)
        gameServer:onRespNetMsg(recv)
    end
end

--发送网络消息，中间增加GameServer Proxy层
function NetChannel:sendNet(proto)
    local curState = self._game:getCurState()
    local gameServer = curState:getGameServer()
    if gameServer == nil then
        self._transceiver:send(proto.data)
    else
        gameServer:setTransceiver(self._transceiver) --TODO 可优化，不用每次都赋值
        gameServer:onSendNetMsg(proto)
    end
end

function NetChannel:showSysMessage(content, color, font)
    local curState = self._game:getCurState()
    curState:showSysMessage(content, color, font)
end

function NetChannel:showLoading(content)
    local curState = self._game:getCurState()
    curState:showLoading(content)
end

function NetChannel:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
    local curState = self._game:getCurState()
    return curState:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
end

function NetChannel:hideLoading()
    local curState = self._game:getCurState()
    curState:hideLoading()
end

-- function NetChannel:getProxy(name)
--     return self._game:getProxy(name)
-- end

function NetChannel:registerEvent()
    self._msgCenter:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_SEND_DATA, self, self.onSend)
    self._msgCenter:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_HAND_CLOSE_CONNECT, self, self.onHandCloseNet)
    self._msgCenter:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, self, self.onAutoCloseNet)
end

function NetChannel:lanuch()
    self._transceiver:connect()
    
    for _, s in pairs(self._serverList) do
        s:setChannel(self)
        s:connect()
    end
end

function NetChannel:onHandCloseNet()
    self:clearQueue()
    self._transceiver:close()
end

function NetChannel:onAutoCloseNet()
    self._isCanSend = true
    self:clearQueue()
    self._transceiver:autoClose()
end

--直接重连
function NetChannel:reconnect()
    self._transceiver:reconnect()
end

--网络链接已经打开
function NetChannel:onOpen()
    self._msgCenter:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_SUCCESS_CONNECT, nil)
end

function NetChannel:onClose()
    self._msgCenter:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_FAIL_CONNECT, nil)
end

--重连成功
function NetChannel:onReconnect()
    self:clearQueue()
    self:sendReconnectLogin()
    self._msgCenter:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_SUCCESS_RECONNECT, nil)

    --
    self._game:onReconnect()
end

--重连失败
function NetChannel:onReconnectFailure()
    self._msgCenter:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_FAILURE_RECONNECT, nil)
end

function NetChannel:sendNotification(mainevent, subevent, data)
    self._msgCenter:sendNotification(mainevent, subevent, data)
end

function NetChannel:sendReconnectLogin()
    local areId = GameConfig.serverId
    local sign = SDKManager:getAccountSign(GameConfig.accountName, areId)
    local data = {}
    data["moduleId"] = AppEvent.NET_M1
    data["cmdId"] = AppEvent.NET_M1_C9999
    data["obj"] = {account = GameConfig.accountName, type = 2, areId = areId, sign = sign}
    
    self:onSend(data)
end

--接受到数据
function NetChannel:onRecv(byteArray)   
    
    local startTime = os.clock()
    
    
    
--    if moduleId == 1 and cmdId == 8888 then
--    else
        self._isCanSend = true
    self._curSendCount = self._curSendCount - 1
    if self._curSendCount < 0 then
        self._curSendCount = 0
    end
        
--    end
    
--    logger:error("=====no==error===接受到协议数据===:%d", os.time())

    local responseSize = byteArray:readByte()
    local iscompress = byteArray:readByte()
    if iscompress == 1 then
        local cbytes = byteArray:readBytes()
        local len = string.len(cbytes)
        local newByes = uncompress(cbytes)
        
        byteArray = ByteArray.new()
        byteArray:writeBytes(newByes)
        
--        print("=======iscompress====len==========", byteArray:getLength())
    end
    
    for i=1, responseSize do
    
        local protoSize = byteArray:readInt()
        
        local moduleId = byteArray:readInt()
        local cmdId = byteArray:readInt()
        
        local buffer = byteArray:readBytes(protoSize)
        local mId = moduleId
        local cmdId = cmdId
        self:registerProto(mId)

        local data = protobuf.decode("M" .. mId .. ".M" .. cmdId .. ".S2C", buffer, protoSize)
        self._recvQueue:push({mId = mId, cmdId = cmdId, data = data})
        
    end
    
    if responseSize == 0 then --只有一个数据包
        local moduleId = byteArray:readInt()
        local cmdId = byteArray:readInt()

        local buffer = byteArray:readBytes()
        local mId = moduleId
        local cmdId = cmdId
        self:registerProto(mId)

        local data = protobuf.decode("M" .. mId .. ".M" .. cmdId .. ".S2C", buffer)
        self._recvQueue:push({mId = mId, cmdId = cmdId, data = data})
    end
    
    
--    local moduleId = byteArray:readInt()
--    local cmdId = byteArray:readInt()
--    
--    local buffer = byteArray:readBytes()
--    
--    
--    local mId = moduleId
--    local cmdId = cmdId
--    self:registerProto(mId)
--    
--    local data = protobuf.decode("M" .. mId .. ".M" .. cmdId .. ".S2C", buffer)
--    self._recvQueue:push({mId = mId, cmdId = cmdId, data = data})
--    
--    if cmdId ~= 8888 then
--        logger:info("=====no==error==s--->c(%d %d)===耗时:%f===", moduleId, cmdId, (os.clock() - startTime))
--    end
    
--    self:errorCodeHandler(cmdId, data)
    
end

function NetChannel:errorCodeHandler(cmdId, data)

    if type(data) ~= type({}) then
        return
    end

    local rc = rawget(data,"rc")
    local rs = rawget(data,"rs")
    if rc == nil and rs == nil then
        return
    end
    local code = nil
    if rc ~= nil then
        if rc < 0 then
            code = cmdId .. "-" .. math.abs(rc)
        else
            code = cmdId .. "+" .. math.abs(rc)
        end

    elseif rs ~= nil then
        if rs < 0 then
            code = cmdId .. "-" .. math.abs(rs)
        else
            code = cmdId .. "+" .. math.abs(rs)
        end
    end

    if cmdId == 9999 and (code == "9999-2" or code == "9999-3") then
        return ------排队，不提示，TODO 后面有做一个优化，配置表，是否需要显示
    elseif cmdId == 540001 and (code == "540001-5") then 
        return --不显示错误码
    end

    if code ~= nil then
        local info = ConfigDataManager:getInfoFindByOneKey(
            ConfigData.ErrorCodeConfig, "code", code)
        if info ~= nil then
            self:showSysMessage(info.info)
            --print(info.info)
        else
            --cmdId ~= 10000 and 
            if (rs ~= nil and rs < 0 and rs ~= -10) or (rc ~= nil and rc < 0 and rc ~= -10) then
                self:showSysMessage(TextWords:getTextWord(102) .. tostring(code))
            end
        end
    end
end

--发送数据
function NetChannel:onSend(data)

    GameConfig.curSendNetNum = GameConfig.curSendNetNum + 1

    local mId = data.moduleId
    local cmdId = data.cmdId
    
    --TODO 有问题
--    local canSend = self:checkSend(mId,cmdId)  
--    if canSend == false then
--        return
--    end
    
    local obj = data.obj
    if cmdId ~= 8888 then
--        logger:info("=====no==error==push==c--->s(%d %d)======", mId, cmdId)
    end
    self:registerProto(mId)
    local buffer = protobuf.encode("M" .. mId .. ".M" .. cmdId .. ".C2S", obj)
    
--    local testData = {}
--    for var=1, 3000 do
--        table.insert(testData,"1")
--    end
--    buffer = table.concat(testData,"")
    
    -- local len = string.len(buffer)
    
    -- local byteArray = ByteArray.new()
    -- byteArray:writeInt(1 + 4 + len)  --数据包的长度
    -- byteArray:writeByte(mId)
    -- byteArray:writeInt(cmdId)
    -- byteArray:writeBytes(buffer)

    local reqTime = math.abs(math.ceil(os.clock() * 100))
    
    if GameConfig.packageInfo ~= 2 then
        logger:error("=====no==error==c--->s(%d %d)==:%d==", mId, cmdId, reqTime)
    end
    
    -- local sendData = byteArray:toString()
    
    if self._isCanSend == false then --当前网络不流畅，不直接发送，先push到队列
        self._transceiverQueue:push({mId = mId, cmdId = cmdId, buffer = buffer})
    else --直接发送，加快传输
        
        self:onSendOneNet(mId, cmdId, buffer, reqTime)
        
        --需要加等待loading
        if NetWaitingMap[cmdId] ~= nil then  
            self._netReqTimeMap[cmdId] = {mId = mId, cmdId = cmdId, buffer = buffer,
                reqTime = reqTime, sendTime = os.time(), tryReqCount = 0} --有配置，才做loading处理
                
            local function checkCmdState()
                if self._netReqTimeMap[cmdId] ~= nil then --协议还没有返回，
                    self._netReqTimeMap[cmdId].checkFunction = nil --清掉检测方法
                    if GameConfig.isConnected == true then
                        
                        -- if GameConfig.packageInfo == 1 then
                            local time = os.clock()
                            --TODO这里再判断一下时间是否会超时，再loading
                            local dt = time - self._netReqTimeMap[cmdId].reqTime / 100 + 0.1 --多加1毫秒的误差
                            if dt > NetWaitingMap[cmdId].waitTime then
                                self._isShowDelayLoading = true
                                self:showLoading()  --大于配置的时间
                                logger:error("==返回协议超过400毫秒=loading==cmd:%d===dt:%f===", cmdId, dt)
                            end
                        -- end
                    end
                end
            end

            self._netReqTimeMap[cmdId].checkFunction = checkCmdState --
            TimerManager:addOnce( NetWaitingMap[cmdId].waitTime * 1000, checkCmdState, self)
        end
        
    end
    
    
--    if mId == 1 and cmdId == 8888 then --心跳包直接发送
--        self._transceiver:send(sendData)
--    else
        
--    end
    
    
--    
end

--只发送一条网络协议
function NetChannel:onSendOneNet(mId, cmdId, buffer, reqTime)
    local len = string.len(buffer)
    local sendCount = 1
    local byteArray = ByteArray.new()
    byteArray:writeInt(4 + 1 + (1 + 4 + 4) * sendCount + len)
    local curTime = math.abs(reqTime) 
    byteArray:writeInt(curTime)
    byteArray:writeByte(sendCount)

    byteArray:writeInt(string.len(buffer))
    byteArray:writeByte(mId)
    byteArray:writeInt(cmdId)
    byteArray:writeBytes(buffer)

    self._transceiver:send(byteArray:toString())

    self._curSendNetCount = self._curSendNetCount + 1

    self:addOneSendNet(cmdId)
    if self._curSendCount >= self._maxSendFrame then
        self._isCanSend = false --达到最大发送条数了
        self._curSendCount = 0
    end
end

function NetChannel:addOneSendNet(cmdId)
    if cmdId == 9999 then  --网关不进入统计
        return
    end
    self._curSendCount = self._curSendCount + 1
end

function NetChannel:checkSend(mId, cmdId)
    local canSend = false
    if self._lastSendProtoMap[mId] == nil then
        self._lastSendProtoMap[mId] = {}
    end
    
    local curTime = os.clock()
    if self._lastSendProtoMap[mId][cmdId] == nil then
        canSend = true
        self._lastSendProtoMap[mId][cmdId] = curTime
    else
        if curTime - self._lastSendProtoMap[mId][cmdId] < self._minSendInval then
            canSend = false
            logger:warn("------发送的协议太快！！------")
        else
            canSend = true
            self._lastSendProtoMap[mId][cmdId] = curTime
        end
    end
    return canSend
end

function NetChannel:registerProto(moduleId)
    if self._protoData[moduleId] ~= nil then
        return
    end

    
    --logger:info("========>protobuf.register moduleId: %s", moduleId)
    local data = cc.FileUtils:getInstance():getFileData("proto/M" .. moduleId ..".pb")
    protobuf.register(data)
    
    self._protoData[moduleId] = data
end

function NetChannel:resetNetChannelMsgBoxFlag()
    self._transceiver:resetNetChannelMsgBoxFlag()
end
