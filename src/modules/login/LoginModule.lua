LoginModule = class("LoginModule", BasicModule)

function LoginModule:ctor()
    print("LoginModule:ctor")
    LoginModule.super.ctor(self)
    
    self:initRequire()
    
end


function LoginModule:initRequire()
    print("LoginModule:initRequire")
    require("modules.login.event.LoginEvent")
    require("modules.login.view.LoginView")
    
end

function LoginModule:finalize()
    LoginModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
    
    _G["sdkLoginSuccess"] = nil
    _G["loginApplicationDidEnterBackground"] = nil
    _G["onGameLogoutHandler"] = nil
end

function LoginModule:initModule()
    print("LoginModule:initModule")
    LoginModule.super.initModule(self)
    
    self._view = LoginView.new(self.parent)
    self:addEventHandler()
    
    self._view:showLoginPanel() -- 模块总管理，显示loginPanel
    -- 获取服务器列表数据
    self:getServerListInfo()

    FunctionWebManager:init()

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then  --PC直接发送获取实名验证，其他平台登录后才发送
        -- self:getRealNameVerify()
    end
    

    self._isActivation = GameConfig.isActivation
    
    self:initSDKLoginModule()

end

-- function LoginModule:checkPlatform()
--     local isShowUI = false  --默认不显示登录UI
--     local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--     if cc.PLATFORM_OS_WINDOWS == targetPlatform then  --PC 直接显示登录UI,并且不走SDK
--         isShowUI = true
--     end
--     return isShowUI
-- end

function LoginModule:initSDKLoginModule()
    -- local isShowUI = self:checkPlatform()
    -- if isShowUI == true then
    --     self._view:isShowLoginUI(true)
    --     return
    -- end

    require("json")
    local function sdkLoginSuccess(result)
        if VersionManager:isShowFloatIcon() == true then   --是否显示3k悬浮标志
            SDKManager:canShowFloatIcon(true)
        else
            SDKManager:canShowFloatIcon(false)
        end

        local loginData = json.decode(result)
        local userId = loginData["userId"]
        local platformChanleId = loginData["platformChanleId"]

        GameConfig.registerOverTime = os.time()

        if userId == "" then --空用户
            SDKManager:showReLogionView() --再次登录
            return
        end

        GameConfig.userId = userId
        GameConfig.accountName = userId .. "_" .. platformChanleId
        GameConfig.isRelogin = false
        --print("======sdk将数据回调回来了啊===== ",userId,platformChanleId)
        logger:error("==not=error====sdkLoginSuccess==:%s=========", GameConfig.accountName)

        KKKLog:accountLoginLog() --SDK登录成功

        self:getActivateInfo() --SDK登录成功后，获取激活信息

        -- self:getRealNameVerify()  --SDK登录成功后，获取实名认证开启状态

        self:autoLogin()  --SDK登录后，执行自动登录

    end

    _G["sdkLoginSuccess"] = sdkLoginSuccess

    if GameConfig.autoLoginDebug == true then --自动登录调试 不弹出SKD登录
        -- self._view:isShowLoginUI(true)
        return
    end

    -- local isRelogin = self:getLocalData("gameLogoutHandler", true) == "1"
    -- if isRelogin then
    --     self:setLocalData("gameLogoutHandler", "0", true) 
    --     GameConfig.isRelogin = true
    -- end
    --去掉重登，某些渠道不支持，有问题。

    local isShowLoginView = false
    local function showLoginView()
        if GameConfig.sceneAccountName == "" then
            if GameConfig.accountName == "" and GameConfig.isRelogin == false then
                SDKManager:showLoginView()
                isShowLoginView = true
            else
                logger:error("==not=error====showReLogionView======")
                SDKManager:showReLogionView()
            end
        else
            GameConfig.accountName = GameConfig.sceneAccountName
            GameConfig.sceneAccountName = ""
            -- self._view:isShowLoginUI(true)
        end
    end

    local function checkInitOnFinish()
        local isInitSDKFinish = SDKManager:isInitSDKFinish()
        logger:error("~~~~~~SDK初始化未完毕，正在初始化中~~获取~isInitSDKFinish~~~~~~~~~~~" .. tostring(isInitSDKFinish))
        GameConfig.isInitSDKFinish = isInitSDKFinish
        if isInitSDKFinish == true then
            showLoginView()
        else
            TimerManager:addOnce(500, checkInitOnFinish, self)
        end
    end
    
    checkInitOnFinish()

    local function delayReLogin()
        if GameConfig.accountName == ""  then
            self:delayReLogin()
        end
    end

    -- 在登录界面回来了，重新检测
    _G["loginApplicationDidEnterBackground"] = function()
        if GameConfig.accountName == "" then  --只有在没有登录账号的时候，处理登录
            local isInitSDKFinish = SDKManager:isInitSDKFinish()
            if isInitSDKFinish == true then
                logger:error("~~~~~~~loginApplicationDidEnterBackground~~~showReLogionView~~~~~~~~~~~")
                 --重home回来后，且已经打开登录View了，重新登录
                TimerManager:addOnce(50 * 30, delayReLogin,self)
            end
        end
    end

    _G["onGameLogoutHandler"] = function( ... )
        GameConfig.accountName = ""  --切换账号，清空账号记录
        SDKManager:showReLogionView()  --打开重登界面
    end
    
end


function LoginModule:addEventHandler()
    self._view:addEventListener(LoginEvent.LOGIN_REQ, self, self.onLoginVersionCheck)
    self._view:addEventListener(LoginEvent.ACTIVATE_REQ, self, self.onActivateReq)
    self._view:addEventListener(LoginEvent.GET_SERVER_LIST, self, self.getServerListInfo)

    self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGINGATE, self, self.onLoginGateResp)
    -- self:addProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGIN, self, self.onLoginResp)
    self:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_SUCCESS_CONNECT, self, self.onNetSucConnectHandler)
    self:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_FAIL_CONNECT, self, self.onNetFailConnectHandler)
end

function LoginModule:removeEventHander()
    self._view:removeEventListener(LoginEvent.LOGIN_REQ, self, self.onLoginVersionCheck)
    self._view:removeEventListener(LoginEvent.ACTIVATE_REQ, self, self.onActivateReq)
    self._view:removeEventListener(LoginEvent.GET_SERVER_LIST, self, self.getServerListInfo)
    
    self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGINGATE, self, self.onLoginGateResp)
    -- self:removeProxyEventListener(GameProxys.System, AppEvent.PROXY_SYSTEM_LOGIN, self, self.onLoginResp)
    self:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_SUCCESS_CONNECT, self, self.onNetSucConnectHandler)
    self:removeEventListener(AppEvent.NET_EVENT, AppEvent.NET_FAIL_CONNECT, self, self.onNetFailConnectHandler)
end

------------------------------------
--网络连接成功，请求登录网关协议
function LoginModule:onNetSucConnectHandler(data)

    --一连上网络，则直接改变状态
    local areId = GameConfig.serverId
    local data = {account = GameConfig.accountName, type = 1, areId = areId}
    local systemProxy = self:getProxy(GameProxys.System)
    systemProxy:onTriggerNet9999Req(data)

    
end

function LoginModule:toSceneState()
    self:changeState() 
    self:setPushTags()
end

--登录成功后，直接设置推送tags
function LoginModule:setPushTags()
    local serverId = "S" .. GameConfig.serverId
    local platId = "P" .. GameConfig.platformChanleId 
    local version = "V" .. GameConfig.version
    local tags = {serverId, platId, version}
    SDKManager:setPushTags(tags)
end

--网络断开
function LoginModule:onNetFailConnectHandler(data)
    GameConfig.isLoginSucess = false
    self._loginData = nil
    -- self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_HAND_CLOSE_CONNECT, {}) --//断开连接

    self._isStartLoginReq = false
--    component.Loading:hide()
end

function LoginModule:onLoginGateResp(data)
    if data.rs == 0 then --网关登录成功 请求登录到服务器
        --local systemProxy = self:getProxy(GameProxys.System)
        --systemProxy:onTriggerNet10000Req(self._loginData)
        --local serverId = GameConfig.serverId
        --self:setLocalData("lastLoginServer", serverId, true)
        --self:setLocalData("lastLoginAccount", GameConfig.accountName, true)
        self:toSceneState()
    end

    --TODO 通过不同的网关登录错误码，当在线人数上线或者负载更高时，使用排队ui机制
end

function LoginModule:onLoginResp(data)
    logger:info("-------接受登录反馈--------")
    self._isStartLoginReq = false
    local rs = data.rs
    if rs == 0 or rs == 5 then  --5:表示没有领取新手礼包
        if rs == 5 then
            GameConfig.isNewPlayer = true
        end
        GameConfig.isLoginSucess = true
        self:changeState()
    elseif rs == -1 then --没有角色
        GameConfig.isLoginSucess = true
        self:changeState()
    end
    
end

function LoginModule:changeState()
    local data = {}
    data["stateName"] = GameStates.Scene
    self:sendNotification(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, data)
end

----------------------------

function LoginModule:getServerListInfo()
    local params = {}
    params["game_id"] = GameConfig.gameId
    params["os"] = GameConfig.osName
    params["plat_id"] = GameConfig.platformChanleId
    params["channel_id"] = GameConfig.channelId
    params["client_version"] = GameConfig.mainVersion .. "." .. GameConfig.localVersion --这个版本号，是用来审核的，用包的版本号为依据
    params["client_version_real"] = GameConfig.clientVersion
    params["service"] = "Server.GetServerList"
    params["test"] = GameConfig.isTest
    params["mac"] = PhoneInfo:getInfoByKey("mac") or ""  --修改成mac

    --print("GameConfig.server_list_url:  ",GameConfig.server_list_url)
    -- 发送Http协议，设置相关的回调函数
    HttpRequestManager:send(GameConfig.server_list_url,params, self, self.onGetServerListSuccess, self.onGetServerListFail)
end

function LoginModule:onGetServerListSuccess(info)
    --print("===onGetServerListSuccess====",info)
    if VersionManager:isShowFloatIcon() == true then   --是否显示3k悬浮标志
        SDKManager:canShowFloatIcon(true)
        --print("========SDKManager:canShowFloatIcon(true)=======")
    else
        SDKManager:canShowFloatIcon(false)
        --print("========SDKManager:canShowFloatIcon(false)=======")
    end
    logger:info("------onGetServerListSuccess:%s-------------", info)
    self._view:updateServerList(info)
end

function LoginModule:onGetServerListFail()
    --print("=======onGetServerListFail======")
    logger:info("-------onGetServerListFail----------")
    self:getServerListInfo()
end

--获取激活信息--
--
function LoginModule:getActivateInfo()

    if self._isActivation == true then --已经激活了
        return
    end

    self._getActivating = true  --获取激活信息

    local params = {}
    params["game_id"] = GameConfig.gameId
    params["plat_id"] = GameConfig.platformChanleId
    params["account_name"] = GameConfig.accountName  --needCode
    params["service"] = "ActivationCode.needCode"

    HttpRequestManager:send(GameConfig.client_activate_url,params, self, self.onGetActivateInfoSuccess, self.onGetActivateInfoFail)

end

--获取数据成功，查看返回数据，看是否需要弹出激活框
function LoginModule:onGetActivateInfoSuccess(info)

    logger:info("~~~~~~onGetActivateInfoSuccess:%s~~~~~~~~~~",info)

    self._getActivating = false
    local result = StringUtils:jsonDecode(info)
    local res = result["res"]
    if res == true or res == "true" then  --需要激活校验
        self._isActivation = false
        self:showActivationPanel()  --直接弹出激活面板
    else
        self._isActivation = true  --是否激活了
    end
end

function LoginModule:onGetActivateInfoFail()
    logger:info("-------onGetActivateInfoFail----------")
    self:getActivateInfo()
end

---------------------------------------------
--激活请求
function LoginModule:onActivateReq(data)

    self._isActivating = true --激活中

    local params = {}
    params["game_id"] = GameConfig.gameId
    params["plat_id"] = GameConfig.platformChanleId
    params["account_name"] = GameConfig.accountName  --activation
    params["activation_code"] = data.code
    params["service"] = "ActivationCode.activation"

    HttpRequestManager:send(GameConfig.client_activate_url,params, self, self.activateReqSuccess, self.activateReqFail)
end

--激活数据返回，判断结果码
function LoginModule:activateReqSuccess(info)
    self._isActivating = false
    logger:info("~~~~~~LoginModule:activateReqSuccess:%s~~~~~~~~", info)
    local result = StringUtils:jsonDecode(info)
    local res = result["res"]

    if res == true or res == "true" then --激活成功
        self._isActivation = true
        self:hideActivationPanel()
        self:showSysMessage(self:getTextWord(206))
    else --激活失败，提示
        local msg = tonumber(result["msg"])
        self:showSysMessage(self:getTextWord(210 + msg))
    end
end 

function LoginModule:activateReqFail()
    logger:info("-------activateReqFail----------")
    self:activateReq()
end

--------------------------------------
--打开激活面板
function LoginModule:showActivationPanel()
    local panel = self._view:getPanel(ActivationPanel.NAME)
    panel:show()
end

--关闭激活面板
function LoginModule:hideActivationPanel()
    local panel = self._view:getPanel(ActivationPanel.NAME)
    panel:hide()
end

--改变版本，需要重启游戏
function LoginModule:changeVersion()

    self:setIsAutoLoginGame(1)
    SDKManager:gameLogout()
    
    ------需要记录这种状态，下次进入登录界面，直接进入游戏

end

--设置自动登录游戏
function LoginModule:setIsAutoLoginGame(value)
    self:setLocalData("isAutoLogin", value, true)
end

--
function LoginModule:isAutoLoginGame()
    return self:getLocalData("isAutoLogin", true) == 1
end

function LoginModule:autoLogin()
    local isAutoLoginGame = self:isAutoLoginGame()
    if isAutoLoginGame then
        GameConfig.serverId = tonumber(self:getLocalData("lastLoginServer", true))
        local lastLoginAccount = self:getLocalData("lastLoginAccount", true)
        if lastLoginAccount == GameConfig.accountName then --登录名跟最后登录的一样，自动登录
            self:onLoginReq(data)
        end
    end
end

----登录时，版本校验检测
function LoginModule:onLoginVersionCheck(data)

    
    --先缓存请求的服务器id
    if self:getLocalData("lastLoginServer", true) ~= tostring(GameConfig.serverId) then
        self:setLocalData("lastLoginServer", GameConfig.serverId, true)
    end

    if self:getLocalData("lastLoginAccount", true) ~= GameConfig.accountName then
        self:setLocalData("lastLoginAccount", GameConfig.accountName, true)
    end

    if GameConfig.targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
        self:onSplitPackageHandler() --只有在非WIN平台才删除目录
    end
    --

    local state = self:getGameState()
    local uiPreDownloading = state:getUIPreDownloading()
    if GameConfig.isPre then  --进入的这个服务器是预览版的

        self:setLocalData("isLoginPre", 1, true)  --登录到预览版版本
        local function checkCallback( isUpdate )
            if isUpdate then
                --通过更新的，直接重新启动游戏，并记录自动进入游戏
                self:changeVersion()
            else
                self:onLoginReq(data)
            end
        end

        uiPreDownloading:checkPreServerVersion(checkCallback)
    else
        self:setLocalData("isLoginPre", 0, true) --登录到正式版版本
        ------需要检测之前是否进入了预览版--如果是预览版，则需要
        -------删除掉预览版目录
        local preLocalVersion = uiPreDownloading:getPreLocalVersion()
        if preLocalVersion > 0 then
            uiPreDownloading:deletPreFloder()  --进入正式版的，将
            self:changeVersion()  --重启游戏
            return
        end
        self:onLoginReq(data)
    end
end

-----------
--处理分包路径 预览版的，将正式版的路径删除掉
--正式版的，将预览版的路径删除掉
function LoginModule:onSplitPackageHandler()
    local mainVersion = require("version")
    --将正式版的资源目录删除掉
    if GameConfig.isPre then  --预览版的，直接将正式版目录删除掉
        local tmprespath = createDownloadDir("tmpres" .. mainVersion)
        deleteDownloadDir(tmprespath)
        --清除掉对应的模块version
        GlobalConfig:removeAllSubcontract("")  --这里是要删除正式版的
    else --正式版的，直接将预览版目录资源
        local tmprespath = createDownloadDir("tmppreres" .. mainVersion)
        deleteDownloadDir(tmprespath) 
        GlobalConfig:removeAllSubcontract("pre")  --这里是要删除预览版的
    end
    
end

-----------------------------------------------------------
function LoginModule:onLoginReq(data)
    logger:info("--请求登录-----")
    if self._loginData ~= nil then
        logger:error("--no-erro----已经在请求登录了-----")
        return
    end

    if self._getActivating == true then --获取激活信息中，提示
        self:showSysMessage(self:getTextWord(220))
        return
    end

    if self._isActivating == true then --激活中，提示
        self:showSysMessage(self:getTextWord(221))
        return
    end

    if self._isActivation ~= true then
        logger:info("--~需要激活，弹出激活窗~-----")
        self:showActivationPanel()
        return
    end
    
    local name = self._view:getUserName()
    
    local targetPlatform = GameConfig.targetPlatform
    if  (targetPlatform  == cc.PLATFORM_OS_ANDROID or
        cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform) and
        GameConfig.autoLoginDebug ~= true then
        name = GameConfig.accountName
        --print("========我在ios系统，用户名=====",name)
    else
        GameConfig.accountName = name
    end

    KKKLog:selectServerLog()
    --print("=========callbackname=====",name)

    if GameConfig.targetPlatform  == cc.PLATFORM_OS_ANDROID then
        local isReLoginView = SDKManager:isReLoginView()
        if isReLoginView == true then
            logger:error("== 切换账号OR重登 重新弹窗SDK登录框 ==")
            self:reLogin(false)
            return
        end
    end

    if name == "" then
        logger:error("---not-error----请输入名称-----")
        self:reLogin(true)
        return
    end

    self:setIsAutoLoginGame(0)
    
    local serverId = tonumber(GameConfig.serverId) 
    self._loginData = self:getLoginData(name, serverId)

    local function endSharkCall()
        --print("======我正式向服务器发送登录的请求了啊========")
        self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_START_CONNECT, nil)
    end
    NodeUtils:shark(self:getCurLayer(), nil, endSharkCall)
    -- 帐号服务器数据存储
    if self:getLocalData("lastLoginServer", true) ~= tostring(GameConfig.serverId) then
        self:setLocalData("lastLoginServer", GameConfig.serverId, true)
    end
    if self:getLocalData("lastLoginAccount", true) ~= GameConfig.accountName then
        self:setLocalData("lastLoginAccount", GameConfig.accountName, true)
    end
end

function LoginModule:reLogin(isShowMsg)
    self._isStartLoginReq = false
    if GameConfig.targetPlatform  == cc.PLATFORM_OS_ANDROID then
        if self._isReLogin ~= true then
            self._isReLogin = true
            if isShowMsg == true then
                self:showSysMessage(self:getTextWord(201))
            end
            TimerManager:addOnce(50 * 30, self.delayReLogin,self)
        end
    end
end

--这里名字是空的，还是调用直接登录
function LoginModule:delayReLogin()
    self._isReLogin = false
    SDKManager:showReLogionView()
end

function LoginModule:getLoginData(account, areId)
    local data = PhoneInfo:getPackPhoneInfo()
    data["account"] = account
    data["areId"] = areId
    return data
end

function LoginModule:getRealNameVerify()
    local params = {}
    params["os"] = GameConfig.osName
    params["channel_id"] = tonumber(GameConfig.channelId)
    params["game_id"] = GameConfig.gameId
    params["client_version"] = GameConfig.clientVersion
    params["test"] = tonumber(GameConfig.isTest)
    params["service"] = "RealNameVerify.GetRealNameVerify"
    params["server_id"] = GameConfig.serverId
    params["plat_id"] = tonumber(GameConfig.platformChanleId)

    HttpRequestManager:send(GameConfig.real_name_url, params, self, self.onGetRealNameVerifySuccess, self.onGetRealNameVerifyFail)

end

function LoginModule:onGetRealNameVerifySuccess(info)
    local result = StringUtils:jsonDecode(info)
    local ret = result["ret"]
    if ret == 1 then
        logger:error("== 实名验证已开启 : %d ==", ret)
        GameConfig.isOpenRealNameVerify = true
    else
        logger:error("== 实名验证已关闭 : %d ==", ret)
        GameConfig.isOpenRealNameVerify = false
    end

end

function LoginModule:onGetRealNameVerifyFail()
    logger:error("=========实名验证信息获取失败==============")
end










