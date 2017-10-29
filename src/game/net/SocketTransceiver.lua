SocketTransceiver = class("SocketTransceiver")

function SocketTransceiver:ctor()
    self.socket = nil
    self.connected  = false
    self._channel = nil
    
    self._maxReconnect = 20 --最大重连次数
    self._curReconnect = 0
    self._isReconnect = false
    self._isAutoClose = true --是否自动关闭
    
    self._buffList = {} --断开连接后，尚未发出去的协议数据
end

function SocketTransceiver:finalize()
    self:close()
end

function SocketTransceiver:setChannel(channel)
    self._channel = channel
end

function SocketTransceiver:showSysMessage(content, color, font)
    self._channel:showSysMessage(content, color, font)
end

-- function SocketTransceiver:getProxy(name)
--     return self._channel:getProxy(name)
-- end

function SocketTransceiver:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
    return self._channel:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
end

function SocketTransceiver:showLoading(content)
    self._channel:showLoading(content)
end

function SocketTransceiver:hideLoading()
    self._channel:hideLoading()
end

--客户端强制断开连接
function SocketTransceiver:close()
    if self.socket ~= nil then
        self._isAutoClose = false
        self.socket:close()
    end
    self:openNetCloseBox()
    logger:error(debug.traceback())
end

function SocketTransceiver:autoClose()
    logger:error("~~~~~~客户端~~~自动断开链接~~:%s~", debug.traceback())
    if self.socket ~= nil then
        self.socket:close()
    end
    self:openNetCloseBox()
end


--发送
function SocketTransceiver:send(buffer)
    if self.socket == nil then
        logger:error("========已与服务器断开连接================")
        return
    end
    self.socket:sendString(buffer)
end

--打开网络关闭提示框，用来重连等
function SocketTransceiver:openNetCloseBox()
    self:unregisterSocket()

    if GameConfig.isLoginSucess == true and self._isAutoClose == true and GameConfig.isOtherLogin == false then
    else
        return  --其他情况，不打开
    end

    if self._isShowNetClostBox == true then
        return
    end

    self._isShowNetClostBox = true
    local function callback()
        self._isShowNetClostBox = false
        self:reconnect() --在登录成功后，才重连
    end
    local function exitApp()
        self._isShowNetClostBox = false
        SDKManager:exitApp()
    end
    local messageBox = self:showMessageBox(TextWords:getTextWord(13), callback, exitApp)
    messageBox:setLocalZOrder(3000)
end

--注销掉监听
function SocketTransceiver:unregisterSocket()

    self.socket = nil
    self.connected = false
    GameConfig.isConnected = false
    self._channel:onClose()
    self:hideLoading()

    if self.socket ~= nil then
        self.socket:unregisterScriptHandler(cc.WEBSOCKET_OPEN)
        self.socket:unregisterScriptHandler(cc.WEBSOCKET_MESSAGE)
        self.socket:unregisterScriptHandler(cc.WEBSOCKET_CLOSE)
        self.socket:unregisterScriptHandler(cc.WEBSOCKET_ERROR)
        self.socket = nil
    end
end

function SocketTransceiver:connect()

    local link      = "ws://" .. GameConfig.server .. ":" .. GameConfig.port
    self.socket     = cc.WebSocket:create(link)
    
    local function wsSendBinaryOpen(strData)
--        logger:error("NO ERROE ! Send Binary WS was opened.")
        self._channel:onOpen()
        self.connected = true
        GameConfig.isConnected = true
        self._isAutoClose = true
        
        if self._isReconnect == true then
            logger:error("==NO ERROE !======重连成功=================")
--            self:showSysMessage("网络重连成功")
--            self:hideLoading()  --load要等到获取
            self._isReconnect = false
            self._curReconnect = 0
            self._channel:onReconnect() --重连成功
        end
    end

    --接受到数据，进行解析
    local function wsSendBinaryMessage(buffer)
--        logger:error("NO ERROE ! --wsSendBinaryMessage--")
        local byteArray = ByteArray.new()
        byteArray:writeBytes(buffer)
        self._channel:onRecv(byteArray)
        logger:info("============协议包大小===============", byteArray:getLength())
    end

    local function wsSendBinaryClose(strData)
        logger:error("NO ERROE ! _wsiSendBinary websocket instance closed.")
        self.socket:close()
        self.socket = nil
        self.connected = false
        GameConfig.isConnected = false
        self._channel:onClose()
        self:hideLoading()
        
        -- self:showSysMessage("网络连接关闭")
        --9999返回-1的时候  会把GameConfig.isServerFull设置为true  
        --这里特殊处理在返回-1，服务端主动断开网络的时候不弹提示
        if not GameConfig.isServerFull then
            self:onCloseSysMessage("网络连接关闭")
        end
        GameConfig.isServerFull = false
        
        
        self:openNetCloseBox()
        
    end

    local function wsSendBinaryError(strData)
        logger:error("sendBinary Error was fired")
        self:hideLoading()
        self.socket:close()
        self.socket = nil
        self.connected = false
        GameConfig.isConnected = false
        self._channel:onClose()
        
        self:onCloseSysMessage("网络数据异常" .. strData)
        -- self:showSysMessage("网络数据异常" .. strData)

        self:openNetCloseBox()
    end

    if nil ~= self.socket then
        self.socket:registerScriptHandler(wsSendBinaryOpen,cc.WEBSOCKET_OPEN)
        self.socket:registerScriptHandler(wsSendBinaryMessage,cc.WEBSOCKET_MESSAGE)
        self.socket:registerScriptHandler(wsSendBinaryClose,cc.WEBSOCKET_CLOSE)
        self.socket:registerScriptHandler(wsSendBinaryError,cc.WEBSOCKET_ERROR)
    end
    
end

function SocketTransceiver:onCloseSysMessage(msg)

    if GameConfig.isInGateQueue then
        self:showSysMessage("退出排队")
    else
        self:showSysMessage(msg)
    end

    GameConfig.isInGateQueue = false
end

--重连
function SocketTransceiver:reconnect()
    logger:error("==NO ERROE !======开始重连=================")
    -- self:showSysMessage("网络开始重连")
    self:onCloseSysMessage("网络开始重连")
    self:showLoading("网络重连中")
    -- local chatProxy = self:getProxy(GameProxys.Chat)
    -- chatProxy:setReset(true, "isClearWorldChatView")
    -- chatProxy:setReset(true, "isClearLegionChatView")
    -- chatProxy:setReset(true, "isClearPrivateChatView")
    -- _G["isClearWorldChatView"] = true
    -- _G["isClearLegionChatView"] = true
    -- _G["isClearPrivateChatView"] = true
--    if self._curReconnect > self._maxReconnect then
--        --重连次数大于最大重连数，直接踢回登录界面
--        self._isReconnect = false
--        self._curReconnect = 0
--        self._channel:onReconnectFailure()
--        return
--    else 
--        self._curReconnect = self._curReconnect + 1
--    end
    
    self._isReconnect = true
--    framework.coro.CoroutineManager:startCoroutine(self.delayReconnect, self)
    TimerManager:addOnce(30, self.delayReconnect, self)
end

function SocketTransceiver:delayReconnect()
--    coroutine.yield(150)
    if GameConfig.isOtherLogin == true then
        self._isReconnect = false
        return
    end
    self:connect()
end

function SocketTransceiver:resetNetChannelMsgBoxFlag()
    self._isShowNetClostBox = false
end
