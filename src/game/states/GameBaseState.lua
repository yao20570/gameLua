
GameBaseState = class("GameBaseState", BaseState)

function GameBaseState:ctor()
    self._msgCenter = nil
    self._moduleList = {}
    self._moduleConfigMap = {} --存储模块相关的配置
    self._moduleExtrasConfigMap = {} --存储模块相关的配置
    self._showModuleMap = {} --显示的模块

    self._showFreeModuleMap = {} --free显示模块

    self.name = nil
    self.gameScene = nil
    self._isExit = false
    
    self._startLocalZOrder = 0
    
    self._showModuleList = {}  --显示模块的列表，用来处理显示栈

    self._loadingTime = 0

    self._isEnterScene = false

    self._textureKeyMap = {} --所有纹理的计数器，当count为0时，则会被释放掉

    self._updateCount = 0
end

function GameBaseState:enter(game)
    GameBaseState.super.enter(self)

    self._isExit = false
    self._game = game
    self._msgCenter = game:getMsgCenter()
    self:initialize()
end

function GameBaseState:exit(owner, telegram, callback)
    GameBaseState.super.enter(self)
    self._isExit = true
    self:finalize()
end

--
function GameBaseState:finalize(callback)
    self:removeHandler()

    ccs.ActionManagerEx:getInstance():releaseActions()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
--    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()  --状态切换，纹理保存
--    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    ccs.ArmatureDataManager:destroyInstance()

    AudioManager:finalizeRecorder()

    if self._uiSysMessage ~= nil then
        self._uiSysMessage:finalize()
    end
    self._uiSysMessage = nil
    
    if self._uiLoading ~= nil then
        self._uiLoading:finalize()
    end
    self._uiLoading = nil
    
    if self._uiDownloading ~= nil then
        self._uiDownloading:finalize()
    end
    self._uiDownloading = nil

    SpineModelPool:finalize()
    SpineEffectPool:finalize()

    for key, module in pairs(self._moduleList) do
        if module.isInit == true then
            logger:error("~~~~~~~~~释放模块~~~:%s~~~~~~", module.name)
            module:finalize()
            if self.name == GameStates.Login then
                self:finalizeModuleRes(module)  --写死了，登录状态的模块资源也释放掉
            end
            --  --不释放资源
            --    	    coroutine.yield(1)
        end
        self._showModuleMap[key] = nil
        self._showModuleMap[key] = nil
    end

    ComponentUtils:finalize()
    GuideManager:finalize()
    
    self._moduleList = {}
    self._showModuleMap = {}
    self._showFreeModuleMap = {}
    self._moduleConfigMap = {}
    self._moduleExtrasConfigMap = {}
    self._showModuleList = {}
    self._textureKeyMap = {}

    self._gameLayer:finalize()
    CountDownManager:finalize()
    HttpRequestManager:finalize()
    TimerManager:finalize()
    ModuleJumpManager:finalize()
    GuideManager:finalize()
    EffectQueueManager:finalize()
    AnimationFactory:finalize()
    
    if self.gameServer ~= nil then
        self.gameServer:finalize()
    end
    self.gameServer = nil
end

function GameBaseState:initialize()

    self._game:resetNetChannelMsgBoxFlag()

    SDKManager:setGameState(self)
    TextureManager:setGameState(self)

    SpineEffectPool:init(self)
    SpineModelPool:init(self)

    CountDownManager:init()
    HttpRequestManager:init()
    TimerManager:init()
    ModuleJumpManager:init(self)
    RewardManager:init(self)
    GuideManager:init(self)
    EffectQueueManager:init(self)

    
    self:createScene()
    self:addEventHandler()
    self:registerModules()
    
    self:hookDebug()
end

--
function GameBaseState:getMsgCenter()
    return self._msgCenter
end

function GameBaseState:getProxy(proxyName)
    return self._game:getProxy(proxyName)
end
--

function GameBaseState:registerModules()
end


function GameBaseState:registerModule(name, module)
    self._moduleList[name] = module
    module.name = name
    module:setMsgCenter(self._msgCenter)
    module:setGameState(self)
end

function GameBaseState:addModuleConfig(name, url, isExtras)
    self._moduleConfigMap[name] = url
    self._moduleExtrasConfigMap[name] = isExtras
end

function GameBaseState:getModuleConfig(name)
    return self._moduleConfigMap[name]
end

function GameBaseState:getModuleExtraConfig(name)
    return self._moduleExtrasConfigMap[name]
end

function GameBaseState:getModule(name)
    return self._moduleList[name]
end

function GameBaseState:getGame()
    return self._game
end

function GameBaseState:getGameServer()
    return self.gameServer 
end

--
function GameBaseState:createScene()
    local scene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

    self.gameScene = scene
    self._gameLayer = GameLayer.new(scene)
    self._gameLayer:setMsgCenter(self:getMsgCenter())

    AnimationFactory:init(self) --只能在这里初始化
    
    --飘字实现
end

--显示飘字
function GameBaseState:showSysMessage(content, color, font)
    --本来是放在poplayer节点下面的，但是因为在进入战斗的时候，poplayer被隐藏了
    --战斗结束后的战利品可以分享，然后分享回来的飘字就没能显示出来。
    --todo暂时先放在toplayer这一层下面
    if self._uiSysMessage == nil then
        local topLayer = self:getLayer(GameLayer.popLayer)
        local isVisible = topLayer:isVisible()
        local isModuleShow = self:isModuleShow(ModuleName.CreateRoleModule)
        if isVisible ~= true or isModuleShow == true then --如果poplayer被隐藏了，或者是在创建角色界面，就用toplayer 
            topLayer = self:getLayer(GameLayer.topLayer)
        end
        self._uiSysMessage = UISysMessage.new(topLayer)
    end
    
    self._uiSysMessage:show(content, color, font)
end

--显示加载画面
function GameBaseState:showLoading(content, type)
    if self._uiLoading == nil then
        local popLayer = self:getLayer(GameLayer.popLayer)
        self._uiLoading = UILoading.new(popLayer)
    end
    self._loadingTime = os.time()
    self._uiLoading:show(content, type)
end

function GameBaseState:hideLoading(callback)  
    if self._uiLoading ~= nil then
        local endTime = os.time()
        local remainTime = os.difftime (endTime, self._loadingTime)
        local function call()
            self._uiLoading:hide()
            logger:error("... 进度条加载时长 time(s) : %2.5f",endTime - self._loadingTime)
            if callback then
                callback()
            end
        end
        if remainTime >= 0.5 then --ps:最少持续2秒
            call()
        else
            remainTime = (0.5 - remainTime ) * 1000
            TimerManager:addOnce(remainTime, call, self)
        end
    end
end

function GameBaseState:getLoadingType()
    if self._uiLoading ~= nil then
        return self._uiLoading:getType()
    end
end

--显示对话框
function GameBaseState:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent)
    local popLayer = parent or self:getLayer(GameLayer.topLayer) -- 层级调整
    --layout是加多一层屏蔽层，因为messagebox打开有30毫秒的延迟，狂点会叠加
    local layout = popLayer:getChildByName("layout")
    if layout ~= nil then
        popLayer:removeChildByName("layout")
    end
    local oldBox = popLayer:getChildByName("messagebox")
    --保持messagebox弹出只有一个  2017年1月4日21:36:14
    if oldBox ~= nil then
        popLayer:removeChildByName("messagebox")
    end
    local box = UIMessageBox.new(popLayer)
    box:show(content, okCallback, canCelcallback, okBtnName,canelBtnName)
    return box
end

function GameBaseState:getLayer(layerName)
    local layer = self._gameLayer:getLayer(layerName)
    return layer
end

--设置蒙版
function GameBaseState:setMask(visible)
    self._gameLayer:setMask(visible)
end

function GameBaseState:isMask()
    return self._gameLayer:isMask()
end

--除了一个层次全部隐藏
function GameBaseState:hideAllLayerExcept(layerName,layerName2)
    self._gameLayer:hideAllLayerExcept(layerName,layerName2)
end

--将所有的视图还原
function GameBaseState:resetLayers()
    self._gameLayer:resetLayers()
end

function GameBaseState:addEventListener(mainevent, subevent, obj, fun)
    self._msgCenter:addEventListener(mainevent, subevent, obj, fun)
end

function GameBaseState:addProxyEventListener(proxyName, subevent, object, fun)
    local proxy = self:getProxy(proxyName)
    proxy:addEventListener(subevent, object, fun)
end

function GameBaseState:removeProxyEventListener(proxyName, subevent, object, fun)
    local proxy = self:getProxy(proxyName)
    proxy:removeEventListener(subevent, object, fun)
end

function GameBaseState:removeEventListener(mainevent, subevent, obj, fun)
    self._msgCenter:removeEventListener(mainevent, subevent, obj, fun)
end

--
function GameBaseState:addEventHandler()
    self:addEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, self, self.showModuleCheck)
    self:addEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_LOADING_OPEN_EVENT, self, self.showModuleByLoading)
    self:addEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, self, self.closeModule)
    self:addEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_FINALIZE_EVENT, self, self.finalizeModule)
    self:addEventListener(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, self, self.changeState)
end

function GameBaseState:removeHandler()
    self:removeEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, self, self.showModuleCheck)
    self:removeEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_LOADING_OPEN_EVENT, self, self.showModuleByLoading)
    self:removeEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, self, self.closeModule)
    self:removeEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_FINALIZE_EVENT, self, self.finalizeModule)
    self:removeEventListener(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, self, self.changeState)
end

function GameBaseState:sendNotification(mainevent, subevent, data)
    self._msgCenter:sendNotification(mainevent, subevent, data)
end

function GameBaseState:sendServerMessage(moduleId, cmdId, obj)
    local data = {}
    data["moduleId"] = moduleId
    data["cmdId"] = cmdId
    data["obj"] = obj
    self:sendNotification("net_event", "net_send_data", data)
end

function GameBaseState:changeState(data)
    local stateName = data["stateName"]
    self.stateName = stateName

    local state = self._game:getState(self.stateName)
    self._game:changeState(state)
end

--直接打开module的某个Panel
function GameBaseState:openModulePanel(moduleName, panelName)
    if self._showModuleMap[moduleName] == nil then
        return
    end
    
    local module = self._showModuleMap[moduleName]
    local panel = module:getPanel(panelName)
    panel:show()
end

function GameBaseState:showModuleByLoading(data)

    local moduleName = data["moduleName"]
    local module = self:getModule(moduleName)
    if module == nil then
--        component.Loading:show()
        TimerManager:addOnce(60, self.showModuleCheck, self, data)
    else
        self:showModule(data)
    end
    
end

function GameBaseState:getUIDownloading()
    if self._uiDownloading == nil then
        self._uiDownloading = UIDownloading.new()
        self._uiDownloading:setGame(self)
    end
    return self._uiDownloading
end

--打开模块检测
function GameBaseState:showModuleCheck(data)
    local moduleName = data["moduleName"]
    local isExtra = self:getModuleExtraConfig(moduleName)
    if GameConfig.isFullPackage then --整包的，不走分包流程
        isExtra = nil  --屏蔽分包下载
    end
    
    local function checkModuleCallback(result)
        if result == true then
            self:preLoadModule(data)
        else --TODO 提示
            --if GameConfig.targetPlatform ~= cc.PLATFORM_OS_WINDOWS then 
                logger:error("=============模块：%s  分包出现错误==========",moduleName)
            --else
                --self:showModule(data)
            --end
        end
    end

    if GameConfig.targetPlatform == cc.PLATFORM_OS_WINDOWS then
        self:preLoadModule(data)
        return
    end
    
    if isExtra ~= nil then --需要检测资源的现在情况
        local uiDownloading = self:getUIDownloading()
        uiDownloading:checkModule(moduleName, checkModuleCallback,isExtra)
    else
        self:preLoadModule(data)
    end
end

--单独打开某个panel时候下载分包
function GameBaseState:onSubcontractPanel(moduleName,callback,isExtra)
    if GameConfig.targetPlatform == cc.PLATFORM_OS_WINDOWS then
        return
    end
    
    local function checkModuleCallback(result)
        if result == true then
            callback()
        else
            logger:error("=============模块：%s  分包出现错误==========",moduleName)
        end
    end
    local uiDownloading = self:getUIDownloading()
    uiDownloading:checkModule(moduleName, checkModuleCallback,isExtra)
end

--预加载资源
function GameBaseState:preLoadModule(data)
    local function completeCallback()
        self:showModule(data)

        TimerManager:addOnce(300, self.hideLoading, self)
    end

    local moduleName = data["moduleName"]
    local loadInfo = ModuleLoadMap[moduleName]
    local module = self:getModule(moduleName)
    if loadInfo ~= nil and module == nil then
        self:showLoading()
        local textures = loadInfo.textures or {}
        local plists = loadInfo.plists or {}
        TextureManager:preLoadImage(textures, plists, completeCallback)
    else
        completeCallback()
    end
end

function GameBaseState:showModuleAnimation( callback )
    -- body 这里需要加入蒙版，屏蔽各种触摸事件
    local topLayer = self:getLayer(GameLayer.topLayer)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local uiAnimation = UICCBLayer.new(GlobalConfig.moduleJumpAnimationName, topLayer, nil, nil, true)        
    uiAnimation:setPosition(visibleSize.width/2,visibleSize.height/2)
    uiAnimation:setLocalZOrder(10000)

    self:setMask(true)

    local function complete()
        self:setMask(false)

        if type(callback) == "function" then
            callback()
        end
    end

    TimerManager:addOnce(GlobalConfig.moduleJumpAnimationDelay,complete,self) --410毫秒特效达到全屏，执行回调

end

function GameBaseState:showModule(data)

     self:showModuleReal(data)

--    local function callback()
--        self:showModuleReal(data)
--    end


--    local moduleName = data["moduleName"]
--    local module = self:getModule(moduleName)
--    if module then
--        -- 当module的self.showActionType == ModuleShowType.Animation 播放过场动画
--        if module:isShowModuleAnimation() == true then
--            self:showModuleAnimation(callback)
--            return
--        end
--    -- end

--    -- 第一次加载的module，不是新手引导，并且不是预加载进来的，播放过场动画
--    elseif data["isPerLoad"] ~= true then
--        self:showModuleAnimation(callback)
--        return
--    end

--    -- 其他情况都不播放过场动画
--    callback()

end

--动态改变层级，越慢打开，层级越高
-- function GameBaseState:showModule(data)
function GameBaseState:showModuleReal(data)

    local moduleName = data["moduleName"]
    local isPerLoad = data["isPerLoad"]
    local extraMsg = data["extraMsg"]  --额外信息，用来实现模块间的通讯
    local srcModule = data["srcModule"] --从哪个模块打开的，有传的时候，需要将那个模块关闭，然后在这个模块关闭时，再将其打开
    local srcExtraMsg = data["srcExtraMsg"]

    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- if ConfigDataManager:isFuncOpen(roleProxy,moduleName) == false and isPerLoad ~= true then
    --     return
    -- end
    
    local module = self:getModule(moduleName)
    
    logger:error("--打开模块:%s---", moduleName)

    if module == nil then
        local moduleConfig = self:getModuleConfig(moduleName)
        if moduleConfig == nil then
            logger:error("%s--模块不存在---", moduleName)
            return
        else
--            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--            if targetPlatform == cc.PLATFORM_OS_ANDROID and GameConfig.debug == false then
--            else
--                
--            end
            
            require(moduleConfig)
            local configs = StringUtils:splitString(moduleConfig,".")

--            local moduels = _G[configs[1]]
--            local space = moduels[configs[2]]
--            local mClass = space[configs[3]]
            local mClass = _G[configs[3]]
            
            module = mClass.new(self.name)
            self:registerModule(moduleName,module)
        end
    end
    
    local isAutoZOrder = false
    module.srcModule = srcModule
    module.srcExtraMsg = srcExtraMsg
    if module.isInit == true then
        self:autoSetZOrder(module)
        isAutoZOrder = true
    end
    
    if self._showModuleMap[moduleName] ~= nil then
        logger:info("--模块已打开:%s---", moduleName)
        return
    end
    
    if module:isCanShow(extraMsg) == false then
        return
    end

--    local groupModuleName = module.groupModuleName
--    for _, moduleName in pairs(groupModuleName) do
--        local module = self:getModule(moduleName)
--        if module ~= nil then
--            self._showModuleMap[moduleName] = module
--            module:showModule()
--        end
--    end
--
--    local mutexModuleName = module.mutexModuleName
--    for _, moduleName in pairs(mutexModuleName) do
--        local module = self:getModule(moduleName)
--        if module ~= nil then
--            self._showModuleMap[moduleName] = nil
--            module:hideModule()
--        end
--    end

    module.isHideModule = false  --模块不隐藏了
    self:showModuleHandler(module)
    self._showModuleMap[moduleName] = module
    table.insert(self._showModuleList, moduleName)
    
--    local function resetModuleView()
--        self:resetModuleView(true)
--    end
    module:showModule(extraMsg, nil, isPerLoad)

    if module.showActionType == ModuleShowType.NONE then
        self:resetModuleView(true)
    else --有模块过度动画，延后执行重置视图
        TimerManager:addOnce(400, self.resetModuleView, self, true) --1秒之后再隐藏下面的
    end
    
--    resetModuleView()
    
    if isAutoZOrder == false then
        self:autoSetZOrder(module)
        isAutoZOrder = true
    end
    
    
    if srcModule ~= nil then
        local module = self:getModule(srcModule)
        if module ~= nil then
            self._showModuleMap[srcModule] = nil

            local function delayHide()
                module:hideModule()
            end
            
            TimerManager:addOnce(400, delayHide, self)
        end
    end

    --
    local moduleLevel = module.moduleLevel
    if moduleLevel == ModuleLevel.FREE_LEVEL then
        self._showFreeModuleMap[moduleName] = 1
    end

    if data.beforeCall ~= nil then
        data.beforeCall()
    end

    self:onHideMainSceneModule(moduleName)
end

function GameBaseState:resetModuleView(isShow)

     
    if self.name ~= GameStates.Scene then
        return
    end
    local fullScreenIndex = -1
    for index=#self._showModuleList, 1, -1 do
        local name = self._showModuleList[index]
        local module = self:getModule(name)
        if module.isFullScreen == true  then --且模块是打开的
            fullScreenIndex = index
            if not isShow then  --打开模块的重置View，由具体的模块处理显示
                --print("!!!!!!!!!resetModuleView!!!isFullScreen1!!!true!!!!!!!!!", name)
                module:setVisible(true)
                module:onResetModuleCallback()
            end
            break
        end
    end
    for index=fullScreenIndex-1, 1, -1 do
        local name = self._showModuleList[index]
        local module = self:getModule(name)
        if module ~= nil and module.uiLayerName ~= ModuleLayer.UI_TOP_LAYER 
            and module.uiLayerName ~= ModuleLayer.UI_POP_LAYER  then
            
            --print("!!!!!!!!!resetModuleView!!!isFullScreen2!!!false!!!!!!!!!", name)
            if name == ModuleName.MainSceneModule then
                if GuideManager:isStartGuide() ~= true then  --引导过程中，场景不隐藏
                    module:setVisible(false)
                end
            else
                module:setVisible(false)
            end
        end
    end
    --没有全屏盖住的了 还原
    if fullScreenIndex == -1 then
        for _, name in pairs(self._showModuleList) do
            local module = self:getModule(name)
            if module ~= nil and module.uiLayerName ~= ModuleLayer.UI_TOP_LAYER
                and module.uiLayerName ~= ModuleLayer.UI_POP_LAYER then
                module:setVisible(true)
                module:onResetModuleCallback()
                --print("!!!!!!!!!resetModuleView!!!isFullScreen!3!!true!!!!!!!!!", name)
            end
        end
    end

    self:isModuleShow(ModuleName.MainSceneModule)
    local sceneModule = self:getModule(ModuleName.MainSceneModule)
     if sceneModule ~= nil and sceneModule:isVisible() then
         self:setAnimationInterval(50) --主城50帧
     else
         self:setAnimationInterval(40) --其他40帧
     end
end

function GameBaseState:setAnimationInterval(interval)
    if self._interval == interval then
        return
    end
    self._interval = interval
    SDKManager:setAnimationInterval(interval)
end

function GameBaseState:autoSetZOrder(module)
    local curZOrder = self._startLocalZOrder + 1
    if module.uiLayerName == ModuleLayer.UI_3_LAYER then
        module:setLocalZOrder(curZOrder)
        self._startLocalZOrder = curZOrder
    end
end

function GameBaseState:closeModule(data)
    local moduleName = data["moduleName"]
    local unlink = data["unlink"]
    local module = self:getModule(moduleName)
    
    logger:error("--关闭模块:%s---", moduleName)

    if module == nil then
        logger:error("%s--模块不存在---", moduleName)
    else

--        local groupModuleName = module.groupModuleName
--        for _, moduleName in pairs(groupModuleName) do
--            local module = self:getModule(moduleName)
--            if module ~= nil then
--                self._showModuleMap[moduleName] = nil
--                module:hideModule()
--            end
--        end
--
--        local mutexModuleName = module.mutexModuleName
--        for _, moduleName in pairs(mutexModuleName) do
--            local module = self:getModule(moduleName)
--            if module ~= nil then
--                self._showModuleMap[moduleName] = module
--                module:showModule()
--            end
--        end

        if unlink == true then  --解锁
            module.srcModule = nil
        end

        self._showModuleMap[moduleName] = nil
        table.removeValue(self._showModuleList,moduleName)
        

        local actionReset = false
        local srcModule = module.srcModule
        local srcExtraMsg = module.srcExtraMsg
        if srcModule ~= nil then
            local module = self:getModule(srcModule)
            if module ~= nil then
                module.isHideModule = false  --模块不隐藏了
                self._showModuleMap[srcModule] = module
                if srcExtraMsg ~= nil then
                    module:showModule(srcExtraMsg)
                else
                    module:showModule()
                end
                if module.showActionType ~= ModuleShowType.NONE then
                    actionReset = true
                end
            end
        else
--            self:onShowMainSceneModule(moduleName)
        end

        local function delayHide()
            module:hideModule()

            self:resetModuleView()


            if module.isFullScreen then  --只有全屏的模块，才会触发
                self:checkFinalizeModule()  --关闭模块时，顺便检查一下内存释放
            end
        end

        module.lastCloseTime = os.time()

        if actionReset then
            TimerManager:addOnce(400, delayHide, self)
        else
            delayHide()
        end

        local moduleLevel = module.moduleLevel
        if moduleLevel == ModuleLevel.FREE_LEVEL then
            self._showFreeModuleMap[moduleName] = nil
        end
    end
end

function GameBaseState:finalizeModule(data)
    local moduleName = data["moduleName"]
    local module = self:getModule(moduleName)

    logger:info("--~~~~关闭释放模块:%s-~~~~~~~--", moduleName)

    if module == nil then
        logger:error("%s--模块不存在---", moduleName)
    else
        self._showModuleMap[moduleName] = nil
        table.removeValue(self._showModuleList,moduleName)

        self._moduleList[moduleName] = nil
        module:finalize()
        self:finalizeModuleRes(module)
        

        self:resetModuleView()

        local srcModule = module.srcModule
        if srcModule ~= nil then
            local module = self:getModule(srcModule)
            if module ~= nil then
                local srcExtraMsg = module.srcExtraMsg
                self._showModuleMap[srcModule] = module
                if srcExtraMsg ~= nil then
                    module:showModule(srcExtraMsg)
                else
                    module:showModule()
                end
            end
        end

        local moduleLevel = module.moduleLevel
        if moduleLevel == ModuleLevel.FREE_LEVEL then
            self._showFreeModuleMap[moduleName] = nil
        end
    end
end

function GameBaseState:timeFinalizeModule(data)
    local moduleName = data["moduleName"]
    local module = self:getModule(moduleName)

    logger:error("--~timeFinalizeModule~~~关闭释放模块:%s-~~~~~~~--", moduleName)

    if module == nil then
        logger:error("%s--模块不存在---", moduleName)
    else
        self._showModuleMap[moduleName] = nil
        table.removeValue(self._showModuleList,moduleName)

        self._moduleList[moduleName] = nil

        module:finalize()
        self:finalizeModuleRes(module)
        
    end
end


--释放掉模块的资源
function GameBaseState:finalizeModuleRes(module)

    local key = module:getModuleUITextureKey()
    
    -- 
    local removeTextureList = {}
    table.insert(removeTextureList, key)

    local list = module:getTextureKeyMap() or {}
    for key, _ in pairs(list) do
        local count = self._textureKeyMap[key] - 1
        self._textureKeyMap[key] = count
        if count <= 0 then
            table.insert(removeTextureList, key)
            self._textureKeyMap[key] = nil
        end
    end

    for _, key in pairs(removeTextureList) do 
        TextureManager:removeTextureForKey(key)
    end


    -- local loadInfo = ModuleLoadMap[moduleName]
    -- if loadInfo ~= nil then
    --     local textures = loadInfo.textures or {}
    --     local plists = loadInfo.plists or {}
    --     -- local sharedTextureCache = cc.Director:getInstance():getTextureCache()
    --     -- sharedTextureCache:dumpCachedTextureInfo()
      
    --     for _, plist in pairs(plists) do
    --         cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plist)
    --     end
    --     for _, texture in pairs(textures) do
    --         cc.Director:getInstance():getTextureCache():removeTextureForKey(texture)
    --     end
        
    --     -- sharedTextureCache:dumpCachedTextureInfo()

    -- end
end

function GameBaseState:dumpModuleTextureInfo()
    for key, count in pairs(self._textureKeyMap) do
        logger:error("!!!!!!!!!!!!_textureKeyMap!!!:%s----->%d!!!!!", key, count)
    end
end

function GameBaseState:retainTexture()

end

--添加纹理key，通过计数器，增加一层是否要释放掉
--处理共用资源
function GameBaseState:addTextureKey(key)
    if self._textureKeyMap[key] == nil then
        self._textureKeyMap[key] = 0
    end
    self._textureKeyMap[key] = self._textureKeyMap[key] + 1
end

--
function GameBaseState:showModuleHandler(module)
    local moduleName = module.name
    local moduleLevel = module.moduleLevel
    local showModuleNameList = self:getShowModuleNameList()
    for _, name in pairs(showModuleNameList) do
        local m = self._showModuleMap[name]
        if name ~= moduleName then
            local level = m.moduleLevel
            if level >= moduleLevel and level ~= ModuleLevel.FREE_LEVEL
                and level ~=  ModuleLevel.SUPER_LEVEL then
                local data = {}
                data["moduleName"] = m.name
                self:closeModule(data)
            end
        end
    end
end

function GameBaseState:getShowModuleNameList()
    local list = {}
    for name, m in pairs(self._showModuleMap) do
        table.insert(list, name)
    end
    return list
end

--还原到原始状态
--关闭所有的free模块 打开dungeon模块
function GameBaseState:resetInitState()
    for moduleName, _ in pairs(self._showFreeModuleMap) do
        if moduleName ~= ModuleName.RoleInfoModule
            and moduleName ~= ModuleName.ToolbarModule
            and moduleName ~= ModuleName.MainSceneModule 
            and moduleName ~= ModuleName.DramaModule then
            self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = moduleName})
        end
    end
    
    local mainSceneModule = self:getModule(ModuleName.MainSceneModule)
    if mainSceneModule ~= nil then
        local buildingUpPanel = mainSceneModule:getPanel(BuildingUpPanel.NAME)
        buildingUpPanel:hide()
        local buildingCreatePanel = mainSceneModule:getPanel(BuildingCreatePanel.NAME)
        buildingCreatePanel:hide()
    end
end

function GameBaseState:isModuleShow(moduleName)
    return self._showModuleMap[moduleName] ~= nil
end

function GameBaseState:getCurShowModuleName()
    return self._showModuleList[#self._showModuleList]
end
-- self._showModuleList值存储了名字
function GameBaseState:getShowModuleMap()
    return self._showModuleMap
end

--获取最上层的模块,即最后一次打开的模块
function GameBaseState:getTopShowModule()
    local name = self:getCurShowModuleName()
    return self:getModule(name)
end

--游戏登出
function GameBaseState:gameLogout()
    GameConfig.accountName = "" --清空登录名
    GameConfig.isRelogin = true
    self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_HAND_CLOSE_CONNECT, {})
    self._game:gameLogout()
end

function GameBaseState:writeLog(mainEvent, labelEvent, infos)
--    framework.platform.AppUtils:onEventTCAgent(mainEvent, labelEvent, infos)
end

---注意，改接口，只能登陆游戏成功后，才能调用
function GameBaseState:gameEventLog(eventId)
    local data = {}
    data.eventId = eventId
    self:sendServerMessage(AppEvent.NET_M1, AppEvent.NET_M1_C10002, data)
end

--是否不释放资源
--noFinalizeInMap 在世界地图是否不释放，模型释放 在世界是可以直接战斗的
function GameBaseState:isNotFinalizeRes(noFinalizeInMap)

    local isNotFinalize = false
    if GuideManager:isStartGuide() == true then  --引导过程中，不进行内存释放检测
        isNotFinalize = true
        return isNotFinalize --直接返回，不释放 
    end

    local sceneModule = self:getModule(ModuleName.MainSceneModule)
    local mapModule = self:getModule(ModuleName.MapModule)
    local isNotFinalize = false --是否不释放资源，只有在世界、主城，才会执行释放机制
    if sceneModule == nil then
        isNotFinalize = true
    end

    if sceneModule ~= nil and sceneModule:isVisible() == false then
        isNotFinalize = true
    end

    if sceneModule ~= nil and sceneModule:getPanel("BuildingUpPanel"):isVisible() then
        isNotFinalize = true
    end

    if sceneModule ~= nil and sceneModule:getPanel("BuildingCreatePanel"):isVisible() then
        isNotFinalize = true
    end

    if noFinalizeInMap ~= true and mapModule ~= nil and mapModule:isVisible() then --世界模块打开，执行释放
        isNotFinalize = false
    end


    return isNotFinalize
end

function GameBaseState:update()
    if self._isExit == true then
        return
    end

    --5秒检测一次
    --是否在主城
    -- local isNotFinalize = self:isNotFinalizeRes()--是否不释放资源，只有在世界、主城，才会执行释放机制

    -- if isNotFinalize then
    --     self._updateCount = 0
    --     return
    -- end

    -- self._updateCount = self._updateCount + 1
    -- if self._updateCount % 5 ~= 0 then
    --     return
    -- end
    -- self._updateCount = 0

    -- local now = os.time()
    -- if now - GameConfig.lastTouchTime < 5 then --5秒有触摸，不释放
    --     return
    -- end

    -- self:checkFinalizeModule()
    --先不做定时的释放--
end

--检测模块释放
function GameBaseState:checkFinalizeModule()

    if GuideManager:isStartGuide() == true then  --引导过程中，不进行内存释放检测
        return
    end


    --算出最先关闭的模块，然后进行释放
    --检测隐藏模块的状态，如果隐藏超过了10秒，则直接释放掉
    local now = os.time()
    --if self._lastCheckFinalizeModule ~= nil and now - self._lastCheckFinalizeModule < 5 then
    --    return  --每5秒才检测一遍
    --end

    --self._lastCheckFinalizeModule = now


    local finalizeModuleList = {}

    local finalizeModuleName = nil
    local minCloseTime = 2000000000

    for _, module in pairs(self._moduleList) do
        --logger:info("finalizeModule check => %s", module.name)
        if module.isHideModule and module.isTimeFinalize then
            local lastCloseTime = module.lastCloseTime
            if minCloseTime > lastCloseTime then
                minCloseTime = lastCloseTime
                finalizeModuleName = module.name
            end
        end
    end

    if finalizeModuleName ~= nil and now - minCloseTime > GlobalConfig.FinalizeCD then  --且大于30秒 秒可能会比较短
        self:timeFinalizeModule({moduleName = finalizeModuleName})
        logger:error("~~~~~~~模块释放完毕~~%s~~~~~~~", finalizeModuleName)
    end
end

function GameBaseState:getLocalData(key, isGloble)
    local ret = LocalDBManager:getValueForKey(key, isGloble)
    return ret
end

--直接挂载debug
function GameBaseState:hookDebug()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_WINDOWS then
        local function onKeyReleased(keyCode, event)
            if keyCode == cc.KeyCode.KEY_D  --"d"
            or keyCode == cc.KeyCode.KEY_F1   --gm命令面板
            or keyCode == cc.KeyCode.KEY_F2   --gm命令面板
            or keyCode == cc.KeyCode.KEY_U    --ui调试
            or keyCode>=cc.KeyCode.KEY_0 and keyCode<=cc.KeyCode.KEY_9 then
                local str = cc.FileUtils:getInstance():getStringFromFile("debug.lua")
                local debugF = loadstring(str)
                local debug = debugF()
                
                local function init()
                    debug:init(self, keyCode)
                end

                local status, msg = xpcall(init, __G__TRACKBACK__)
                -- 
            end
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

        local layer = self:getLayer(GameLayer.popLayer)
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    end
end

--基类不应该有这些逻辑的
function GameBaseState:onHideMainSceneModule(moduleName)  --关闭MainScene模块
--    if self._showModuleMap[ModuleName.MainSceneModule] == nil or self._isEnterScene == false or GameConfig.isNewPlayer == true then
--        return
--    end

--    -- if moduleName == ModuleName.LittleHelperModule then
--    --     return
--    -- end

--    local module = self:getModule(moduleName)
--    local uiLayerName = module.uiLayerName
--    if uiLayerName == ModuleLayer.UI_3_LAYER then
--        self:closeModule({moduleName = ModuleName.MainSceneModule})
--        if moduleName ~= ModuleName.LegionSceneModule then
--            self:closeModule({moduleName = ModuleName.RoleInfoModule})
--        end
--    end
end

--基类不应该有这些逻辑的
function GameBaseState:onShowMainSceneModule(moduleName)  --打开MainScene模块
--    if self._isEnterScene == false or self._showModuleMap[ModuleName.MainSceneModule] ~= nil or GameConfig.isNewPlayer == true then
--        return
--    end

--    for name,module in pairs(self._showModuleMap) do
--        local uiLayerName = module.uiLayerName
--        if uiLayerName == ModuleLayer.UI_TOP_LAYER or uiLayerName == ModuleLayer.UI_3_LAYER then
--            return
--        end 
--    end

--    if self._showModuleMap[ModuleName.MapModule] == nil and self._showModuleMap[ModuleName.LegionSceneModule] == nil then
--        self:showModule({moduleName = ModuleName.MainSceneModule})
--        self:showModule({moduleName = ModuleName.RoleInfoModule})
--    end

--    if self._showModuleMap[ModuleName.LegionSceneModule] ~= nil then
--        self:showModule({moduleName = ModuleName.RoleInfoModule})
--    end
end

