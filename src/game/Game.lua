Game = class("Game")

local DEBUG_MEM = true

function Game:ctor()
    self._stateMachine = nil
    self._msgCenter = nil
    self._stateMap = {}
    self._proxyMap = nil
    self._curState = nil
    
    -- self:initGameServer()
    self:initKKKLog()
    
    self:initPhoneInfo()
    self:initSDKInfo()
    
    self:initConfig()
    self:initDriver()
    
    self:initMsgCenter()
    self:initNetChannel()
    
    self:addStateMachine()
    self:registerProxys()
    self:loadAllModule() --加载所有的模块

    AudioManager:init(self)
    CustomHeadManager:init(self)
    
--    self:createFont()
    
    KKKLog:logActiveLog()

end

function Game:finalize()
    
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.gameSecondSchedule)
    self._netChannel:finalize()
    self._stateMachine:finalize()
    self:finalizeProxy()
    self._msgCenter:finalize()
    
    self._stateMachine = nil
    self._stateMap = nil
    self._msgCenter = nil
    self._proxyMap = nil
    self._curState = nil
end

function Game:gameLogout()
    self:resetProxy()
end

function Game:initGameServer()
    require("server.__init")
end

function Game:initKKKLog()
    GameConfig.startGameTime = os.time()
end

--初始化崩溃检测系统
function Game:initTestinCrash()
    if _G["initTestinAgent"] ~= nil then
--        setUserInfo("no login user")
        initTestinAgent("eb175812d2e86a667dde6e74516942ba",  "3kwan")
        
--        logger:error("on error!!!  TestinCrash 检测系统启动")
    end
end

function Game:initTalkingDataGA()
    if _G["TalkingDataGA"] ~= nil then
--        TalkingDataGA:setVerboseLogDisabled()
        TalkingDataGA:onStart("E09FC6DE4D91DC38FE91488D5E6D6C3E", "3kwan")
        
        local eviceId= TalkingDataGA:getDeviceId()
        logger:error("no error!!! 设备ID为：" .. eviceId)
        
    end
end

--初始化手机信息
function Game:initPhoneInfo()
    local phoneInfo = AppUtils:getPhoneInfo()
    -- logger:error("==not==error==initPhoneInfo=========:%s====", phoneInfo)
    require("json")
    local function decode()
        local result = json.decode(phoneInfo)
        return result
    end
    local status, phoneInfoData = pcall(decode)
    if status ~= true then
        logger:error("~~~~~~~initPhoneInfo解析失败~~~~~~~~~~~~~~~")
        phoneInfoData = {}
    end
    
--    phoneInfoData["plat_id"] = 33
    PhoneInfo:init(phoneInfoData)
    GameConfig:setPackageInfo(phoneInfoData.packageInfo or -1)
--    GameConfig:setPackageInfo(1) -- A
    GameConfig.localVersion = phoneInfoData.localVersion or 0
    
    
end

--just ios
function Game:initSDKInfo()
    local info = {}
    info["appid"] = "375"--"302"
    info["appKey"] = "naET3BJseBxzyyxS0gQHffLFT2h07F8S" --"4872a0d20c60f0906ac4aef9131a4da3"
    info["merchantId"] = "1"
    info["md5Key"] = "4872a0d20c60f0906ac4aef9131a4da3"  --"3005f706aea1e290324848e43d917cb8"
    info["gameIdFor3k"] = "128"
    info["gameNameFor3k"] = "攻城online IOS正版"
    SDKManager:initSDKInfo(info)
end

function Game:initFramework()
    require("framework.__init")

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
        logger:setLevel("WARN")
    end

--    logger:setLevel("WARN")
end

--function Game:initComponent()
--    require("component.__init")
--end

function Game:initConfig()

    cc.Texture2D:PVRImagesHavePremultipliedAlpha(true)

    local director = cc.Director:getInstance()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
--        game.const.GameConfig.frameRate = 60
--        director:setAnimationInterval(1.0 / 60)
        GameConfig.debug = true
    elseif cc.PLATFORM_OS_IPHONE == targetPlatform or
        targetPlatform == cc.PLATFORM_OS_IPAD then
        GameConfig.debug = false
        --GameConfig.autoLoginDebug = true --TODO测试
--        game.const.GameConfig.debug = true
--        game.const.GameConfig.autoLoginDebug = true
    else
--        game.const.GameConfig.frameRate = 30
--        director:setAnimationInterval(1.0 / 30)
        GameConfig.debug = false --false
    end
    
    director:setAnimationInterval(1.0 / GameConfig.frameRate)
    
    if  GameConfig.packageInfo == 2  --android正式包
        or GameConfig.packageInfo == 4 --版署包
        or GameConfig.packageInfo == 5 then --ios包
        director:setDisplayStats(false)
    else
        director:setDisplayStats(true)
    end
    
    local rate = NodeUtils:getFrameViewRate()
    --小于3:2采用
    if rate < 1.5 then
        director:getOpenGLView():setDesignResolutionSize(640, 960, cc.ResolutionPolicy.SHOW_ALL)
    else
        director:getOpenGLView():setDesignResolutionSize(640, 960, cc.ResolutionPolicy.NO_BORDER)
    end
    
    -- director:setProjection(0)  --2d渲染
    math.randomseed(os.time())

    SDKManager:setMaxRecorderTime(GameConfig.maxRecorderTime)
    
end


function Game:initMsgCenter()
    self._msgCenter = MsgCenter.new()
end

function Game:getMsgCenter()
    return self._msgCenter
end

----游戏驱动-------
function Game:initDriver()
--    local Framework = framework.Framework 
    
--    local function update(dt)
--        Framework:update(dt)
--    end
--    self.gameSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update,0,false)
    
    
    local function gameUpdate(dt)
        self:update()
    end
    self.gameSecondSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(gameUpdate,1.0,false)
end

function Game:initNetChannel()
    local netChannel = NetChannel.new()
    netChannel:setMsgCenter(self._msgCenter, self)
    
    self._netChannel = netChannel
    self._msgCenter:addEventListener(AppEvent.NET_EVENT, AppEvent.NET_START_CONNECT, self, self.onConnectNetHandler)
end


function Game:resetNetChannelMsgBoxFlag()
    self._netChannel:resetNetChannelMsgBoxFlag()
end

--开始连接网络
function Game:onConnectNetHandler(data)
    self._netChannel:lanuch()
end

function Game:getNetChannel()
    return self._netChannel
end

function Game:onReconnect() --重连
    for _, proxy in pairs(self._proxyMap) do
        proxy:onReconnect()
    end
end

function Game:addStateMachine()
    self:initState()
    
    self._stateMachine = StateMachine.new(self)
    local state = nil
    if GlobalConfig.isOpenTestState then
        state = self:getState(GameStates.Test)
    else
        state = self:getState(GameStates.UpdateState)
    end
    self._stateMachine:setCurState(state)
    self._curState = state
end

function Game:initState()
    self._stateMap[GameStates.Login] = LoginState.new()
    
    self._stateMap[GameStates.Scene] = SceneState.new()
    
    self._stateMap[GameStates.UpdateState] = UpdateState.new()
    
    self._stateMap[GameStates.Test] = TestState.new()
end

function Game:getState(name)
    local state = self._stateMap[name]
    state.name = name
    return state
end

function Game:changeState(state)
    self._curState = state
    self._stateMachine:changeState(state)
end

--注册数据代理
function Game:registerProxys()
    self._proxyMap = {}

    for name, url in pairs(GameProxyMap) do
        require(url)
        self:registerProxy(_G[name .. "Proxy"])
    end
    
    
    -- require("game.proxy.DungeonXProxy")
    -- self:registerProxy(DungeonXProxy)
end

function Game:registerProxy(proxyClass)
    local proxy = proxyClass.new()
    proxy:setMsgCenter(self._msgCenter)
    proxy:setGame(self)
    proxy:registerNetEvents()
    local proxyName = proxy:getProxyName()
    self._proxyMap[proxyName] = proxy
end

function Game:getProxy(proxyName)
    return self._proxyMap[proxyName]
end

function Game:finalizeProxy()
    for _, proxy in pairs(self._proxyMap) do
    	proxy:finalize()
    end
end

function Game:resetProxy()
    for _, proxy in pairs(self._proxyMap) do
        proxy:resetAttr()
    end
end

function Game:getAllProxy()
    return self._proxyMap
end

function Game:recvNet(cmd, data)
    for _, proxy in pairs(self._proxyMap) do   
        proxy:syncNetRecv(cmd, data)
    end
    
    if cmd == AppEvent.NET_M2_C20000 then
        for _, proxy in pairs(self._proxyMap) do
            proxy:afterInitSyncData()
        end
    end
    
    -- 每日重置协议
    if cmd == AppEvent.NET_M3_C30103 then
        for _, proxy in pairs(self._proxyMap) do
            proxy:resetCountSyncData()
        end
    end
end

--加载所有的模块，只有在发布环境下才处理
function Game:loadAllModule()
--    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--    if targetPlatform == cc.PLATFORM_OS_ANDROID and GameConfig.debug == false then
--        require("modules.modules")
--    end
end

function Game:createFont()
    local fontName = "simhei"  
    local targetPlatform = GameConfig.targetPlatform
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        fontName = "DroidSansFallback.ttf"
    elseif targetPlatform == cc.PLATFORM_OS_ANDROID then
        cc.FileUtils:getInstance():addSearchPath("/system/fonts", true)
        if(cc.FileUtils:getInstance():isFileExist("DroidSansFallback.ttf")) then
            fontName = "DroidSansFallback.ttf"
        elseif(cc.FileUtils:getInstance():isFileExist("NotoSansHans-Regular.otf")) then
            logger:error("==========!!=找不到DroidSansFallback系统文字库!!============")
            fontName = "NotoSansHans-Regular.otf"
        else
            logger:error("==========!!=找不到默認的系统文字库!!============")
        end
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE then
        fontName = "DroidSansFallback.ttf"
    end
    
    --[[ 以下是不带描边|阴影的普通字体 ]]
    FontUtils:createFont("fn12", fontName, 0xffffffff, 12, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn14", fontName, 0xffffffff, 14, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn16", fontName, 0xffffffff, 16, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn18", fontName, 0xffffffff, 18, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn20", fontName, 0xffffffff, 20, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn22", fontName, 0xffffffff, 22, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn24", fontName, 0xffffffff, 24, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn26", fontName, 0xffffffff, 26, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn28", fontName, 0xffffffff, 28, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn30", fontName, 0xffffffff, 30, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn32", fontName, 0xffffffff, 32, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn34", fontName, 0xffffffff, 34, 0, 0, 0xff000000, 0)
    FontUtils:createFont("fn36", fontName, 0xffffffff, 36, 0, 0, 0xff000000, 0)
   
end

--外部调用
function Game:startGame()
    local curState = self._stateMachine:getCurState()
    curState:enter(self)
    
end

function Game:getCurState()
    local curState = self._stateMachine:getCurState()
    return curState
end

function Game:showMemoryUsage()
    
   local sharedTextureCache = cc.Director:getInstance():getTextureCache()
    logger:info(string.format("---not-error--LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
    if sharedTextureCache.dumpCachedTextureInfo ~= nil then
        -- sharedTextureCache:dumpCachedTextureInfo()
    end  
    -- local info = sharedTextureCache:getCachedTextureInfo()
    -- print("~~~~~~~~~~~~~", info)
    -- logger:info("--------------------:%s-------------------------------", info)
end

function Game:update()
    for _, proxy in pairs(self._proxyMap) do
    	proxy:update()
    end
--    
   self._curState:update()
    
    if DEBUG_MEM == true then
        if self.debugInval == nil then
            self.debugInval = 0
        end
--        
        if self.debugInval > 20 then
            self:showMemoryUsage()
            self.debugInval = 0
        end
--        
        self.debugInval = self.debugInval + 1
    end
--    
--    if self.removeUnusedInval == nil then
--        self.removeUnusedInval = 0
--    end
--    if self.removeUnusedInval > 300 then
--        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
--        self.removeUnusedInval = 0
--    end
--    
--    self.removeUnusedInval = self.removeUnusedInval + 1
    
end


