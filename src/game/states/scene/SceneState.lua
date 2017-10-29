SceneState = class("SceneState",GameBaseState)

function SceneState:ctor()
    SceneState.super.ctor(self)
    
    self.name = GameStates.Scene
end
function SceneState:initialize()
    SceneState.super.initialize(self)
    
    logger:error("====no--error-我被改变了!--当前版本:%s---",  GameConfig.version)
    logger:error("====no--error---账号%s进入场景---",  GameConfig.accountName)
    self._reLogin = false --在场景重新登录
    GameConfig.isOtherLogin = false
    self._lastHeartbeatTime = os.time()
    GameConfig.lastHeartbeatTime = os.time()
    self._heartbeat_sec = 100 --心跳秒数
    self._cur_heartbeat = 1
    self:openLoaderModule()
    
    --查看是否已经有角色信息，如果有直接处理
    local roleProxy = self:getProxy(GameProxys.Role)
    local isInitInfo = roleProxy:isInitInfo()
    if isInitInfo == true then
        self:onGetRoleInfo()
    end
   -- self:roleInfoReq()

    AudioManager:playSceneMusic()
    
    self:setLoadProgress(30, nil, 1)

    self:onLoginGateResp({rs = 0})  --状态切换，直接网关请求 登录网关成功了
    --self:onGatewayReq() --状态切换，直接网关请求

    self:startSceneLoading()

    GlobalConfig:preLoadImage() --再Load一次
end


function SceneState:finalize()
    SceneState.super.finalize(self)
    _G["onGameLogoutHandler"] = nil
    _G["sdkLoginSuccess"] = nil
    self._preLoadComplete = false
end

--
function SceneState:addEventHandler()
    SceneState.super.addEventHandler(self)
    
    self:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_FAILURE_RECONNECT, self, self.onFailureReconnectHandler)
    self:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_SUCCESS_RECONNECT, self, self.onSuccessReconnectHandler)
    self:addEventListener(AppEvent.GAME_EVENT, AppEvent.GAME_LOGOUT_EVENT, self, self.onGameLogoutHandler)

    self:addProxyEventListener(GameProxys.Role,   AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGINGATE, self, self.onLoginGateResp)
    self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_OTHERLOGIN, self, self.onOtherLoginResp)
    self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_HEARTBEAT, self, self.onHeartbeatResp)
    self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGIN, self, self.onLoginResp)
    self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_CHARGESUCESS, self, self.onChargeSucessResp)
    
    local function onGameLogoutHandler()
        LocalDBManager:setValueForKey("gameLogoutHandler", "1", true) --在游戏里面切换账号，登出了
        self:onGameLogoutHandler()
    end
    _G["onGameLogoutHandler"] = onGameLogoutHandler
    
    local function sdkLoginSuccess(result)  --在游戏里面接受到了账号登录回调，直接退出游戏操作
        local loginData = json.decode(result)
        local userId = loginData["userId"]
        local platformChanleId = loginData["platformChanleId"]
        
        GameConfig.userId = userId
        GameConfig.sceneAccountName = userId .. "_" .. platformChanleId
        
        self:onGameLogoutHandler(false) 
        --SDK是否要登出
        --TODO 这里还需要对登录的账号进行处理，避免退出游戏后，又重新弹出登录框
    end
    _G["sdkLoginSuccess"] = sdkLoginSuccess
end
--

function SceneState:removeHandler()
    SceneState.super.removeHandler(self)
    
    self:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_FAILURE_RECONNECT, self, self.onFailureReconnectHandler)
    self:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_SUCCESS_RECONNECT, self, self.onSuccessReconnectHandler)
    self:removeEventListener(AppEvent.GAME_EVENT, AppEvent.GAME_LOGOUT_EVENT, self, self.onGameLogoutHandler)
    
    self:removeProxyEventListener(GameProxys.Role,   AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGINGATE, self, self.onLoginGateResp)
    self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_OTHERLOGIN, self, self.onOtherLoginResp)
    self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_HEARTBEAT, self, self.onHeartbeatResp)
    self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGIN, self, self.onLoginResp)
    self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_CHARGESUCESS, self, self.onChargeSucessResp)
end

function SceneState:onSystemInfoResp(data)
    if data.rs == -1 then
--        component.MessageBox:show("系统消息","战斗验证失败：结束时间提前")
    end
end

--充值成功推送
function SceneState:onChargeSucessResp(data)
    local name = ConfigDataManager:getChargeProductName(data.amount, 0)
    
    local content = string.format( TextWords[120], name)
    self:showMessageBox(content)
end

--消费点记录
function SceneState:onPurchaseResp(data)
    local value = data.value
    local optType = data.optType
    
    local moneyType = data.moneyType --1:钻石，0是金钱
    
    
    local roleProxy = self:getProxy(GameProxys.Role)
    local actorInfo = roleProxy:getActorInfo()
    
    if moneyType == 0 then
        game.log.KKKLog:logUserCoinLog(data.getOrLose,data.optType,data.value,data.resValue,actorInfo)
    elseif moneyType == 1 then
        game.log.KKKLog:logUserGoldLog(data.getOrLose,data.optType,data.value,data.resValue,actorInfo)
    end
    
end

--该账号在别的地方登陆，不进行重连
--被踢下线
function SceneState:onOtherLoginResp(data)
    local function callback()
        self:onGameLogoutHandler()
    end
    local reason = data.reason
    if reason == "" then
        reason = TextWords:getTextWord(10 + data.rs)
    end
    GameConfig.isOtherLogin = true --该标志表示客户端不进行重连了
    self:showMessageBox(reason, callback, callback)
end

function SceneState:onCloseServerResp(data)
    local function callback()
        self:onGameLogoutHandler()
    end
    
    GameConfig.isConnected = false --表示关服，没有链接了
    GameConfig.isOtherLogin = true --该标志表示客户端不进行重连了
    
    self:showMessageBox("系统提示", "系统已在维护中，请稍后重登！", callback, callback)
end

function SceneState:onGatewayReq()
    local areId = GameConfig.serverId
    local data = {account = GameConfig.accountName, type = 1, areId = areId}
    local systemProxy = self:getProxy(GameProxys.System)
    systemProxy:onTriggerNet9999Req(data)
end

--重连失败，服务器已经判断下线，重新登录
function SceneState:onLoginGateResp(data)

    ------------
    ------
    local serverTime = GameConfig.serverTime
    local now = os.time()
    if now - serverTime >= 30 * 60 then
        self:onGameLogoutHandler()  --重连成功后，如果大于半小时的时间，则直接重登游戏
        return
    end


    self._lastHeartbeatTime = os.time()
    GameConfig.lastHeartbeatTime = os.time()
    
    self:showLoading("网络重连中")
    if data.rs == 2 then  --获取服务器版本，判断版本号
        --服务端已经没有这个账号了
        --TODO 需要判断一下当前客户端版本，如果版本不匹配则登出游戏 不然在场景里面登录
--        self:sendNotification(AppEvent.GAME_EVENT, AppEvent.GAME_LOGOUT_EVENT, {})
        self:sceneReLogin()
    else
        --场景直接登录
        self:sceneReLogin()
        --TODO 强制回到场景中-
    end
end

--场景中重新登录
function SceneState:sceneReLogin()
    self._lastHeartbeatTime = os.time()
    GameConfig.lastHeartbeatTime = os.time()
    GameConfig.isInitRoleInfo = false

    local roleProxy = self:getProxy(GameProxys.Role)
    local isInitInfo = roleProxy:isInitInfo()
    if isInitInfo == true then  --数据初始化完毕，才证明是重登的
        self._reLogin = true
    end

    local areId = GameConfig.serverId
    local loginData = PhoneInfo:getLoginData(GameConfig.accountName, areId)
    self:sendServerMessage(AppEvent.NET_M1, AppEvent.NET_M1_C10000, loginData) --请求登录
    
    AppUtils:loadGameComplete()
    
--    component.Loading:show()
end

function SceneState:onLoginResp(data)
    local rs = data.rs

    if rs == 0 or rs == 5 then  --5:表示没有领取新手礼包
        if rs == 5 then
            GameConfig.isNewPlayer = true
        end
        GameConfig.isLoginSucess = true
    elseif rs == -1 then --没有角色
        GameConfig.isLoginSucess = true
    end

    if rs == 0 or rs == 5 then --登录成功
        GameConfig.isLoginSucess = true
--        local actorInfo = data.actorInfo
--        local roleProxy = self:getProxy(GameProxys.Role)
--        roleProxy:setActorInfo(actorInfo)

       GameConfig.serverTime = data.serverTime
        
       self:roleInfoReq() --角色信息请求

       local isfirstLogin = LocalDBManager:getValueForKey("firstLogin", nil, "")
       if isfirstLogin == nil then
          self:gameEventLog(EventConfig.ReqRoleInfo)
       end
        
        KKKLog:accountLoginLog()
    elseif rs == -2 then --被封号了！
        local parent = self:getLayer(GameLayer.popLayer)
        local reason = rawget(data, "reason")
        if reason == nil or reason == "" then
            reason = TextWords:getTextWord(14)
        end
        local box = self:showMessageBox(reason, nil, nil,nil,nil, parent)
        box:setLocalZOrder(12345)
        self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, {})  --断开连接
    elseif rs == -3 then --IP被封了
        local parent = self:getLayer(GameLayer.popLayer)
        local box = self:showMessageBox(TextWords:getTextWord(19), nil, nil,nil,nil, parent)
        box:setLocalZOrder(12345)
        self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, {})  --断开连接
    else --登录失败
        logger:error("===重登登录失败！！！=====")
        local parent = self:getLayer(GameLayer.popLayer)
        local box = self:showMessageBox(TextWords:getTextWord(15), nil, nil,nil,nil, parent)
        box:setLocalZOrder(12345)
        self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, {})  --断开连接
    end
end

--直接自动登录
function SceneState:delayChangeLoginState()
    coroutine.yield(30)

    --跳到更新界面，查看这时候没有没更新
    GameConfig.isAutoLogin = true
    local data = {}
    data["stateName"] = GameStates.UpdateState
    self:changeState(data)
end

function SceneState:onFailureReconnectHandler(data)
    local data = {}
    data["stateName"] = GameStates.Login
    self:changeState(data)
end

function SceneState:onSuccessReconnectHandler()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setToolbarRedPonintInfo()
    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:setReConnectState(true)
end

function SceneState:onHeartbeatResp(data)
    self._lastHeartbeatTime = os.time() --最后一次心跳时间 心跳时间 还是用本地时间检测
    GameConfig.lastHeartbeatTime = os.time()
    GameConfig.serverTime = data.serverTime
    
    logger:info("======接受心跳==========:%d==服务器时间：%d==", self._lastHeartbeatTime, data.serverTime)
    if self._isShowLoading == true then
        local loadingType = self:getLoadingType()
        if loadingType ~= nil then
--            component.Loading:hide()
            self:hideLoading()
        end
--        component.Component:setLocalZOrder(ModuleLayer.UI_Z_ORDER_7)
    end
    
    TimerManager:addOnce(self._heartbeat_sec * 1000, self.startHeartbeat, self)
end

--开始心跳
function SceneState:startHeartbeat()
    self._lastHeartbeatTime = os.time()
    GameConfig.lastHeartbeatTime = os.time()
--    framework.coro.CoroutineManager:startCoroutine(self.delayStartHeartbeat, self)
    self:delayStartHeartbeat()
end

function SceneState:delayStartHeartbeat()
--    while true do
--        GameConfig.count = GameConfig.count + 1
    local systemProxy = self:getProxy(GameProxys.System)
--    systemProxy:onTriggerNet8888Req({})
        self:checkHeartbeat()
--        coroutine.yield(GameConfig.frameRate * HEARTBEAT_SEC)  --10秒做一次心跳
--    end 
end

--客户端再做一次心跳检测
function SceneState:checkHeartbeat()
    if GameConfig.isConnected == false then
        return
    end
    local curTime = os.time()
    local detalTime = curTime - GameConfig.lastHeartbeatTime --self._lastHeartbeatTime
    if detalTime >= self._heartbeat_sec + 5 then --超过5秒则弹出loading条
        if true then -- or true  GameConfig.debug == false
            --self:showLoading(TextWords:getTextWord(115), 1)
            self._isShowLoading = true
--            local systemProxy = self:getProxy(GameProxys.System)
--            systemProxy:onTriggerNet8888Req({})
        end
    end
    
    if detalTime > 120 * 1 then  --2分钟直接踢下线
        if GameConfig.isConnected == true 
            and  GameConfig.isInitRoleInfo == true
            and GameConfig.isInGateQueue == false then --GameConfig.debug == false  and  or true 客户端网络状态还是连接的，但是已经没有心跳了
--            self:onLoginGateResp({rs = 2}) --重连失败
--            self:onGameLogoutHandler({})  --直接退出游戏
--            component.Loading:hide()
            self:hideLoading()
            logger:error("~~~~~~~~~~没有心跳，断开链接~~~~~~~")
            self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, {})  --断开连接，会启动自动重连
            self._lastHeartbeatTime = os.time()
            GameConfig.lastHeartbeatTime = os.time()
        end
    end
end

function SceneState:onGameLogoutHandler(data)
--    framework.coro.CoroutineManager:startCoroutine(self.delayGameLogout,self)
    TimerManager:addOnce(30, self.delayGameLogout, self,data)
end

function SceneState:delayGameLogout(isSDKLogout)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
       GameConfig.accountName = ""
       SDKManager:gameLogout()
    elseif cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
        self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, {})
        self:gameLogout()
        local data = {}
        data["stateName"] = GameStates.Login --TODO 先到登录界面  UpdateState
        self:sendNotification(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, data)
    end




--    coroutine.yield(1)
    --GameConfig.accountName = ""
    --SDKManager:gameLogout()
    
    -- if isSDKLogout ~= false then
    --     self:gameLogout()
    -- end
    

    -- local data = {}
    -- data["stateName"] = GameStates.Login --TODO 先到登录界面  UpdateState
    -- self:sendNotification(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, data)
end
--

--不请求详细信息了，直接由服务器推送
function SceneState:roleInfoReq()
    -- self:setLoadState("请求角色信息")

   local sendData = self:packageSendData(roleProxy)
   self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20000, sendData)
end

function SceneState:packageSendData(roleProxy)

    local data = {}

--    data.utma = PhoneInfo:getInfoByKey("utma") or ""
--    data.imei = PhoneInfo:getInfoByKey("imei") or ""
--    data.screen = PhoneInfo:getInfoByKey("screen") or ""
--    data.os = PhoneInfo:getInfoByKey("os") or 3
--    data.model = PhoneInfo:getInfoByKey("model") or ""
--    data.net = PhoneInfo:getInfoByKey("net") or ""
--    data.operators = PhoneInfo:getInfoByKey("operators") or ""
--    data.location = PhoneInfo:getInfoByKey("location") or ""
--    data.package_name = PhoneInfo:getInfoByKey("package_name") or ""
--    data.package_size = PhoneInfo:getInfoByKey("package_size") or ""
--    data.plat_id = GameConfig.platformChanleId
    
--    logger:error("-no-error----utma:%s--imei:%s--screen:%s--os:%d--model:%s--net:%s---operators:%s--location:%s--package_name:%s--package_size:%s",
--        data.utma, data.imei, data.screen, data.os, data.model, data.net, data.operators, data.location,data.package_name,data.package_size )
    return data
end

function SceneState:onGetRoleInfo(data)
    --一些协议只能在获取角色信息后 才能请求
    
--    game.log.KKKLog:roleLoginLog(data.actorInfo)
    GameConfig.isInitRoleInfo = true

    self:startNetInitReq()  --角色信息获取后，统一请求其余网络数据

    if self._reLogin == true then  --场景里面登录
    
        self:hideLoading()
        
        if GuideManager:isStartGuide() then  --还在引导中，不处理
        else
            self:resetInitState()
            local data = {}
            data["moduleName"] = ModuleName.MainSceneModule
            self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
        end
    
        self:sendNotification(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, {})
        self._reLogin = false
        
        -- self.gameServer:finalize()
        -- local gameServer = server.GameServer.new(data) --重新启动一个
        -- self.gameServer = gameServer
        
        
        
--        component.Loading:hide()
    else
        --TODO---在这里启动GameServer
        -- local gameServer = server.GameServer.new(data)
        -- self.gameServer = gameServer

--        
        self:tryEnterScene()

         --
        
        -- self:startSceneLoading()
        self:writeAccountLog()
    end
end

--获取到角色奖励后的预加载
function SceneState:preLoadModuleAfterRoleInfo()
    local  loadAry = {}
    table.insert(loadAry, {info = "加载资源2", module = ModuleName.GameActivityModule} )


    -- local isFileExist = cc.FileUtils:getInstance():isFileExist("res/bg/activity/1.webp")
    -- if isFileExist then
        local data = {}
        data["moduleName"] = ModuleName.GameActivityModule
        data["isPerLoad"] = true
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
    -- end

    local function delayHide()
        local data = {}
        data["moduleName"] = ModuleName.GameActivityModule
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
    end

    TimerManager:addOnce(10, delayHide, self)
end

function SceneState:writeAccountLog()
    local roleProxy = self:getProxy(GameProxys.Role)
    local areaId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_areaId)
    logger:info("=======areaId:%d===============", areaId)
    
    local actorInfo = roleProxy:getActorInfo()
    GameConfig.actorid = actorInfo.playerId
    GameConfig.actorName = actorInfo.name
    GameConfig.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local userMoney = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    
    SDKManager:initSDKExtendData(userMoney)
end

function SceneState:registerModules()  
    for name, config in pairs(SceneModuleMap) do
        self:addModuleConfig(name, config.url, config.isExtras)
    end
end

function SceneState:openLoaderModule()
    local data = {}
    data["moduleName"] = ModuleName.LoaderModule
    data["isPerLoad"] = true
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

--场景加载
function SceneState:startSceneLoading()
    KKKLog:intoGameLoading()
    
    TimerManager:addOnce(40, self.sceneModuleLoading, self)
--    self:sceneModuleLoading()
end

--一些初始化的数据请求
function SceneState:startNetInitReq()
--    self:sendServerMessage(AppEvent.NET_M3, AppEvent.NET_M3_C30000, {isInit = 1})
--    local proxy = self:getProxy(GameProxys.System)
--    proxy:reEnterScene()
--    proxy:addTimer(self.gameServer)
    
    local netReqList = {}
    --table.insert(netReqList, {AppEvent.NET_M6, AppEvent.NET_M6_C60000, {}}) -- 获取副本列表协议
    --table.insert(netReqList, {AppEvent.NET_M13, AppEvent.NET_M13_C130000, {}}) -- 获取武将信息
    --table.insert(netReqList, {AppEvent.NET_M3, AppEvent.NET_M3_C30100, {}}) -- 
    --table.insert(netReqList, {AppEvent.NET_M7, AppEvent.NET_M7_C70000, {}}) -- 
    --table.insert(netReqList, {AppEvent.NET_M17, AppEvent.NET_M17_C170000, {}}) -- 好友信息
    --table.insert(netReqList, {AppEvent.NET_M19, AppEvent.NET_M19_C190000, {}}) --任务信息
    -- table.insert(netReqList, {AppEvent.NET_M12, AppEvent.NET_M12_C120000, {}}) --技能信息
    --table.insert(netReqList, {AppEvent.NET_M2, AppEvent.NET_M2_C20010, {state=0}}) --声望领取状态
    local roleProxy = self:getProxy(GameProxys.Role)
    if roleProxy:hasLegion() then
        --军团信息
        table.insert(netReqList, {AppEvent.NET_M22, AppEvent.NET_M22_C220200, {}})
        --军团待审批数量
        table.insert(netReqList, {AppEvent.NET_M22, AppEvent.NET_M22_C220205, {}})
        --军团福利院 
        table.insert(netReqList, {AppEvent.NET_M22, AppEvent.NET_M22_C220012, {}}) 
        -- -- 军团副本信息
        table.insert(netReqList, {AppEvent.NET_M27,AppEvent.NET_M27_C270000, {}})
    end


    local state = 0
    if GameConfig.isOpenRealNameVerify then
        state = 1
    end    
    table.insert(netReqList, {AppEvent.NET_M46,AppEvent.NET_M46_C460001, {switchState = state}})

    --初始化 增益数据
--    table.insert(netReqList, {AppEvent.NET_M9,AppEvent.NET_M9_C90003, {}})
    --执行任务部队数据初始化
    --table.insert(netReqList, {AppEvent.NET_M8,AppEvent.NET_M8_C80003, {}})
    --邮件
    --table.insert(netReqList, {AppEvent.NET_M16, AppEvent.NET_M16_C160000, {}})
    --总活动信息
    --table.insert(netReqList, {AppEvent.NET_M23, AppEvent.NET_M23_C230000, {}})
    --军师府信息
    --table.insert(netReqList, {AppEvent.NET_M26, AppEvent.NET_M26_C260000, {}})
    --军师招募信息
    --table.insert(netReqList, {AppEvent.NET_M26, AppEvent.NET_M26_C260004, {}})
    --限时活动
    --table.insert(netReqList, {AppEvent.NET_M23, AppEvent.NET_M23_C230002, {}})
    --开福利包
    --table.insert(netReqList, {AppEvent.NET_M2,AppEvent.NET_M2_C20015, {dayNum=0}})
    --获取体力购买协议
    --table.insert(netReqList, {AppEvent.NET_M2, AppEvent.NET_M2_C20013, {}})
    --战力排行榜数据初始化
--    table.insert(netReqList, {AppEvent.NET_M21,AppEvent.NET_M21_C210000, {}})
    --伤兵数据初始化
    --table.insert(netReqList, {AppEvent.NET_M4,AppEvent.NET_M4_C40001, {}})

    local function sendServerMessage(req)
        self:sendServerMessage(req[1], req[2], req[3])
    end
    -- 批量发送消息
    local index = 1
    local delay = 300
    for _, req in pairs(netReqList) do
        -- TimerManager:addOnce(delay * index, sendServerMessage, req, req)
        sendServerMessage(req)
        index = index + 1
    end
end



--TODO 中文需要文本定义
function SceneState:sceneModuleLoading()
--    self:endSceneLoading()
--    self:startNetInitReq()
--    self:preLoadAnimation()
    
    local function preLoadImageEnd()
        local yieldTime = 4

        local loadAry = {}
        -- table.insert(loadAry, {info = "加载资源2", module = ModuleName.OpenServerGiftModule} )
        table.insert(loadAry, {info = "加载资源3", module = ModuleName.RoleInfoModule} )
        table.insert(loadAry, {info = "加载资源2", module = ModuleName.ToolbarModule} )
        table.insert(loadAry, {info = "加载资源5", module = ModuleName.MainSceneModule} )
        table.insert(loadAry, {info = "加载资源5", module = ModuleName.ChatModule} )
--        table.insert(loadAry, {info = "加载资源2", module = ModuleName.GameActivityModule} )
        --table.insert(loadAry, {info = "加载资源6", module = ModuleName.MailModule} )

--        local localVerion = cc.UserDefault:getInstance():getIntegerForKey(moduleName,-1000)
--        if localVerion ~= -1000 then
--            table.insert(loadAry, {info = "加载资源6", module = ModuleName.MailModule})
--        end

        if LocalDBManager:getValueForKey("firstLogin") == nil then --ps:新手期间  预打开这些模块
            --table.insert(loadAry, {info = "加载资源7", module = ModuleName.BarrackModule} )
           -- table.insert(loadAry, {info = "加载资源8", module = ModuleName.EquipModule} )
            -- table.insert(loadAry, {info = "加载资源9", module = ModuleName.TaskModule} )
        end

        local loadNum = #loadAry

        local function completeLoad()
            self:closeLoadModule()
            TimerManager:addOnce(50, self.endSceneLoading, self)
            self:setLoadProgress(80, true)
        end

        local index = 1
        local function updateLoad()
            local loader = loadAry[index]
            if loader == nil then
                TimerManager:remove(updateLoad, self)
                completeLoad()
                return
            end
            local curTime =  os.clock()
            logger:error("====开始加载====:%s %f", loader.module, curTime)
            self:loadModule(loader.info, loader.module)

            if loader.isHide == true then
                self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = loader.module})
            end

            local progress = 30 + 50 / loadNum * index
            local delay = 100
            if index == 1 then
                delay = 500
            end
            TimerManager:addOnce(delay, self.setLoadProgress, self, progress)
            -- self:setLoadProgress(progress)

            index = index + 1

            TimerManager:addOnce(100 * yieldTime, updateLoad, self)

            logger:error("====结束加载====:%s %f\n", loader.module, os.clock() - curTime)
        end

        TimerManager:addOnce(30 * yieldTime, updateLoad, self)
    end
    
    preLoadImageEnd()
    -- self:preLoadImage(preLoadImageEnd)
    -- self:preLoadSpriteCache()
    
end

-- 预加载特效资源
function SceneState:preLoadSpriteCache()
    -- body
    -- 预加载特效资源 请前往GlobalConfig.lua配置
    -- local effectTab = {"rpg-levelup","rpg-time", "rpg-Criticalpoint", "rpg-sidelight", "rpg-Positivelight"}

    local url = nil
    for k,v in pairs(GlobalConfig.ScenePreEffects) do
        url = "effect/frame/" .. v .. ".plist"
        cc.SpriteFrameCache:getInstance():addSpriteFrames(url)
    end
end

--
function SceneState:preLoadSpineModel(infos, isStartGuide)

    local effectList = {}
    if isStartGuide == true then
        effectList = {"bu01_hit", "gong01_atk", 
            "gong01_hit", "qi01_atk", "qiang01_atk",
            "qiang01_hit", "xuli_blue"}
    end
        
    for _, effect in pairs(effectList) do
    	local info = {}
    	info.type = "effect"
    	info.modelID = effect
    	info.num = 1
        table.insert(infos, info)
    end

    local function nextLoad()
        self:setLoadProgress(90)
        if GameConfig.targetPlatform == cc.PLATFORM_OS_WINDOWS then  --tudo:windows上预加载无法播放
            TimerManager:addOnce(300, self.delayHideLoader, self)
        else
            self:preLoadSound() --开始预加载音效
        end
    end

    if #infos == 0 then
        nextLoad()
        return
    end

    local startProgree = 80
    local loadNum = 0
    local maxNum = 0
    local function loadSpineModel(obj, modelID)
        local layer = self:getLayer(ModuleLayer.UI_1_LAYER)
        local spine = nil
        if obj.info.type == "effect" then
--            spine = SpineEffect.new(modelID, layer, false, true)
--            spine:finalize()
            SpineEffectPool:preLoad(modelID)
        else
--            spine = SpineModel.new(modelID, layer, true, true)
            SpineModelPool:preLoad(modelID)
        end
--        print("========loadSpineModel===========", modelID)
        loadNum = loadNum + 1
        
        local progree = startProgree + (loadNum / maxNum) * 10
        self:setLoadProgress(progree)
        
--        print("===============loadSpineModel=================",loadNum, maxNum, progree, os.clock())
        if loadNum >= maxNum then
            nextLoad()
        end
    end
    
    local index = 1
    for _, info in pairs(infos) do
        for num=1, 1 do --info.num
            local temp = {}
            temp.info = info
            TimerManager:addOnce(30 * index, loadSpineModel, temp, info.modelID)
            index = index + 1
            maxNum = maxNum + 1
        end
    end
    
end

--预加载音效
function SceneState:preLoadSound()

    local startProgree = 90
    local loadNum = 0
    local maxNum = 0
    
    local function loadSound(obj, name)
        cc.SimpleAudioEngine:getInstance():preloadEffect("sounds/" .. name .. "." .. AudioManager.defaultSoundType)
        
        local progree = startProgree + (loadNum / maxNum) * 10
        self:setLoadProgress(progree)
        
        loadNum = loadNum + 1
        if loadNum >= maxNum then
            self:setLoadProgress(100)
            TimerManager:addOnce(300, self.delayHideLoader, self)
        end
    end
    
    local soundList = {
        "battlle_daoatk","battlle_daohit","battlle_gongatk",
        "battlle_gonghit","battlle_qiangatk","battlle_qianghit",
        "battlle_qiatk", "battlle_qihit"
    }
    
    local index = 1
    for _, sound in pairs(soundList) do
        local temp = {}
        TimerManager:addOnce(30 * index, loadSound, temp, sound)
        index = index + 1
        maxNum = maxNum + 1
    end
    
end

--预加载动画
function SceneState:preLoadAnimation()

    local function dataLoaded()
    end
    local urlList = {
        "effect/001.ExportJson"
    }
    
    for _, url in pairs(urlList) do
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(
            url, dataLoaded)
    end

    
end


function SceneState:loadModule(stateLabel, moduleName)

    self:setLoadState("努力加载中，加载过程中不消耗流量")
    local data = {}
    data["moduleName"] = moduleName
    data["isPerLoad"] = true
    -- data["extraMsg"] = {isPerLoad = true}
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
    
    local isfirstLogin = LocalDBManager:getValueForKey("firstLogin")
    local eventId = EventConfig:getPreLoadModuleId(moduleName)
    if eventId ~= nil and isfirstLogin == nil then  --这里还得判断是否为新号
        self:gameEventLog(eventId)
    end
end

function SceneState:closeLoadModule()
    
end

function SceneState:endSceneLoading()

--    self:initShowSceneModule() --没用的
    
--    local roleProxy = self:getProxy(GameProxys.Role) --TODO
--    local actorInfo = roleProxy:getActorInfo()
--    game.log.KKKLog:roleLoginLog(actorInfo)  --进入场景之后，才算角色登录

    KKKLog:intoGame()
    
    local isfirstLogin = LocalDBManager:getValueForKey("firstLogin")
    if isfirstLogin == nil then
        self:gameEventLog(EventConfig.EnterScene)
    end
    
    LocalDBManager:setValueForKey("firstLogin", true) 
    
    local data = {}
    data["moduleName"] = ModuleName.ChatModule
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
    
   --  data["moduleName"] = ModuleName.OpenServerGiftModule
   --  self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

   --  data["moduleName"] = ModuleName.MailModule
   --  self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

   -- data["moduleName"] = ModuleName.LotteryEquipModule
   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

--   data["moduleName"] = ModuleName.MainSceneModule
--   self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

   -- data["moduleName"] = ModuleName.BarrackModule
   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

   -- data["moduleName"] = ModuleName.EquipModule
   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

   -- data["moduleName"] = ModuleName.TaskModule
   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
    
    local delay = 100
    local isStartGuide = GuideManager:isStartGuide()
    if isStartGuide == true then
        local infos = ConfigDataManager:getConfigData(ConfigData.PreLoadConfig)
        self:preLoadSpineModel(infos, isStartGuide) --TODO 进度条读条优化
        delay = 500
    else
        local roleProxy = self:getProxy(GameProxys.Role)
        local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        local infos = {}
        local config = ConfigDataManager:getConfigData(ConfigData.LevelLoadConfig)
        for _, info in pairs(config) do
        	if info.levelmin <= level and level <= info.levelmax then
                table.insert(infos, info)
                break
        	end
        end
        
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        local list = soldierProxy:getRealSoldierList() 
        for _, soldier in pairs(list) do
        	local loaderInfo = {}
        	loaderInfo.modelID = soldier.typeid
            local num = soldier.num
            if num > 6 * 7 then
                num = 6 * 7  --最多每种类型只会加42个
            end
            if num < 7 then
                num = 7
            end
            loaderInfo.num = num
            table.insert(infos, loaderInfo)
        end
        
        self:preLoadSpineModel(infos) 
--        self:setLoadProgress(100)
--        TimerManager:addOnce(delay, self.delayHideLoader, self)
    end
    
    self:enterSceneNetReq()
    
     --TODO
end

function SceneState:delayHideLoader()

    self._preLoadComplete = true --预加载完毕
    local roleProxy = self:getProxy(GameProxys.Role)
    local isInitInfo = roleProxy:isInitInfo()
    if isInitInfo ~= true then  --数据还未初始化完毕
        return
    end

    TimerManager:addOnce(30, self.enterScene, self)
end

function SceneState:tryEnterScene()
    local roleProxy = self:getProxy(GameProxys.Role)
    local isInitInfo = roleProxy:isInitInfo()
    if isInitInfo == true and self._preLoadComplete == true then
        if GlobalConfig.preLoadComplete == true then --判断全局的预加载纹理是否完成
            TimerManager:addOnce(30, self.enterScene, self)
        else
            --还没有预加载完毕，等待检测  --TODO 这里有出现加载没完成问题
            TimerManager:addOnce(300, self.tryEnterScene, self) --300毫秒检测一次
        end
    end
end

function SceneState:enterScene()

   self:preLoadModuleAfterRoleInfo()

    self._isEnterScene = true

    TimerManager:addOnce(30, self.delayHideLoaderModule, self)

    local data = {}
    data["moduleName"] = ModuleName.MainSceneModule
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)

    self:sendNotification(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, {}) --进入场景事件

    
    --进场景，才开始检测心跳
    self:startHeartbeat()
    CountDownManager:add(2000000000, self.checkHeartbeat, self)
end

function SceneState:delayHideLoaderModule()
    local data = {}
    data["moduleName"] = ModuleName.LoaderModule
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
end

function SceneState:enterSceneNetReq()
    
end

function SceneState:initShowSceneModule()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.ToolbarModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.RoleInfoModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MainSceneModule})
    
--    self:sendServerMessage(AppEvent.NET_M3, AppEvent.NET_M3_C30000, {})
--    local proxy = self:getProxy(GameProxys.System)
--    proxy:addTimer()
end

function SceneState:setLoadState(label)
    self:sendNotification(AppEvent.LOADER_MAIN_EVENT, AppEvent.LOADER_UPDATE_STATE, label)
end

function SceneState:setLoadProgress(percent, noAction, delay)
    self:sendNotification(AppEvent.LOADER_MAIN_EVENT, AppEvent.LOADER_UPDATE_PROGRESS, {percent = percent, noAction = noAction, delay = delay})
end








