
BasicModule = class("BasicModule")

function BasicModule:ctor()
    self._msgCenter = nil
    self._gameState = nil --所属状态
    self._modelList = {}
    self._isShowLoading = false
    self._hideUseAction = false
    
    self.isInit = false
    self.name = nil
    self.parent = nil
    self.isOpen = false --是否打开中
    self.lastCloseTime = 0 --最后关闭的时间
    self.isHideModule = false --模块是否隐藏掉了
    self.isTimeFinalize = false --是否关闭时间到了就释放掉模块 通过资源的配置来处理

    self.logicVisible = false --逻辑视图 由show hide控制

    self.isFirstDelayAction = false --初始化模块是否延迟动画，对于一些模块在初始化的时候需要延迟渲染，则设置为true

    self.isLayoutNode = true  --默认模块是带触摸事件的Widget，false则为node
    
    
    self.isFullScreen = true --是否全屏
    
    self.moduleLevel = ModuleLevel.NORMAL_LEVEL
    
    self.groupModuleName = {}
    self.mutexModuleName = {}
    
    self.uiLayerName = "uiLayer"
    self.uiZOrder = ModuleLevel.UI_Z_ORDER_0
    
    self.isFirstShowLoader = false
    self.isShowAction = false
    
    self.showActionType = ModuleShowType.NONE --模块显示动画
    
    self.isOpenShowLoader = false --打开的时候是否展示加载，外部模块需要在某个点隐藏掉加载框
    
    self.hideRemoveEvent = true --只在战斗用到，用来处理引导的实现，其他地方不能用！

    self._textureKeyMap = {}  --用到的纹理Key列表，需要配置，以便模块释放(key是相对于res的目录)
    
    self._moduleEventList = {}
    self._proxyEventList = {}

    --打开之前，所有的纹理Key
    -- self._beforeOpenAllTextureKey = cc.Director:getInstance():getTextureCache():getAllTextureKey()
end

function BasicModule:finalize()
end

function BasicModule:setMsgCenter(msgCenter)
    self._msgCenter = msgCenter
end

function BasicModule:setGameState(state)
    self._gameState = state
end

function BasicModule:getGameState()
    return self._gameState
end

function BasicModule:getProxy(proxyName)
    return self._gameState:getProxy(proxyName)
end

function BasicModule:addTextureKey(key)
    
    if self._textureKeyMap[key] == nil then  --这个模块，第一次，才会添加进去，不然计数有问题
        logger:error("~~~~~添加纹理资源到模块~~key:%s~~~module:%s~~", key, self.name)
        self._gameState:addTextureKey(key)
    end

    self._textureKeyMap[key] = true
end

function BasicModule:getTextureKeyMap()
    return self._textureKeyMap
end

--获取模块自身对应的UI纹理key，通过名字，便可获得
--这个是单独使用的，不需要计数
function BasicModule:getModuleUITextureKey()
    local str = StringUtils:toLowerCaseFirstOne(self.name)
    local key = string.format("ui/%s_ui_resouce_big_0%s", str, TextureManager.file_type) 
    return string.gsub(key, "Module", "")
end

--隐藏模块的时候，将事件移除掉
function BasicModule:hideModuleRemoveEvent()
    for _, event in pairs(self._moduleEventList) do
        self:removeEventListener(event.mainevent,event.subevent,event.object,event.fun)
    end
    for _, event in pairs(self._proxyEventList) do
        self:removeProxyEventListener(event.proxyName,event.subevent,event.object,event.fun)
    end
end

function BasicModule:showModuleResetEvent()
    for _, event in pairs(self._moduleEventList) do
        self:addEventListener(event.mainevent,event.subevent,event.object,event.fun, false)
    end
    for _, event in pairs(self._proxyEventList) do
        self:addProxyEventListener(event.proxyName,event.subevent,event.object,event.fun, false)
    end
end

--事件监听入口统一， 在模块关闭后，可能会把相关事件移除掉
function BasicModule:addEventListener(mainevent, subevent, object, fun, isInit)
    self._msgCenter:addEventListener(mainevent, subevent, object, fun)
    
    if isInit ~= false then
        table.insert(self._moduleEventList, 
            {mainevent = mainevent, subevent = subevent, object = object, fun = fun})
    end
    
end

function BasicModule:removeEventListener(mainevent, subevent, object, fun)
    self._msgCenter:removeEventListener(mainevent, subevent, object, fun)
end

--事件监听入口统一， 在模块关闭后，可能会把相关事件移除掉
function BasicModule:addProxyEventListener(proxyName, subevent, object, fun, isInit)
    local proxy = self:getProxy(proxyName)
    proxy:addEventListener(subevent, object, fun)
    
    if isInit ~= false then
        table.insert(self._proxyEventList, 
            {proxyName = proxyName, subevent = subevent, object = object, fun = fun})
    end
end

function BasicModule:removeProxyEventListener(proxyName, subevent, object, fun)
    local proxy = self:getProxy(proxyName)
    proxy:removeEventListener(subevent, object, fun)
end

function BasicModule:sendNotification(mainevent, subevent, data)
    self._msgCenter:sendNotification(mainevent, subevent, data)
end

function BasicModule:sendServerMessage(moduleId, cmdId, obj, index)
    local data = {}
    data["moduleId"] = moduleId
    data["cmdId"] = cmdId
    data["obj"] = obj
    self:sendNotification("net_event", "net_send_data", data)
    
end

function BasicModule:delaySendServerMessage(data, index)
--    local delay = index or 1
--    coroutine.yield(delay)
    self:sendNotification("net_event", "net_send_data", data)
end

--打开模块，如果是动画过度的，则先播放动画，再显示
--isPerLoad 是否预加载，预加载不做动画相关的
function BasicModule:showModule(extraMsg, callback, isPerLoad)
    self.isHideModule = false --不关闭了
    self.logicVisible = true
    local isInit = self.isInit
    if self.isInit ~= true and  
        self._gameState.name == GameStates.Scene and 
       self.isFirstShowLoader == true then
--        component.Loading:show()  
        self._isShowLoading = true
    end
    if self.parent == nil then
        -- print("~~~~~~~self.isLayoutNode~~~~~~~~~", self.isLayoutNode)
        if self.isLayoutNode == true then
            self.parent = ccui.Layout:create() -- 
            self.parent:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            -- self.parent:setBackGroundColorOpacity(155)
            self.parent:setTouchEnabled(true)
            self.parent:setContentSize(2000, 960) 
        else
            self.parent = cc.Node:create()  
        end
        

        self.parent:retain()
        self.parent.module = self

        --
    else
        self.parent:setVisible(false)
    end
    
    local function delayShowModule()
        self.parent:setVisible(true)
        self:delayShowModule(extraMsg, isPerLoad)

        if callback ~= nil then
            callback()
        end
    end

    --播放动画的时候，延迟
    if self:isShowModuleAnimation() and isPerLoad ~= true then --云动画
        self:showModuleAnimation(delayShowModule) -- dalayShowModule
        return
    end

    delayShowModule()
    
end

function BasicModule:delayShowModule(extraMsg, isPerLoad)
    
    if self.parent:getParent() == nil then
        self.isTimeFinalize = ModulePersistMap[self.name] == nil --不持久配置，标记为可释放
        self:addToLayer()

        self.parent:release()
        
        self:initModule() --初始化
        self._isInitModule = true
    else 
        if self.hideRemoveEvent == true then
            self:showModuleResetEvent()
        end
    end
    
    if self.moduleLevel == ModuleLevel.LOW_LEVEL then
        self.parent:setLocalZOrder(100)
    elseif self.moduleLevel == ModuleLevel.SUPER_LEVEL then
        self.parent:setLocalZOrder(400)
    end
    
    self:onOpenModule(extraMsg, isPerLoad) -- 开启模块

    if self._view ~= nil then  --在上面有可能模块就被释放掉了，比如加载，比较特殊
        self._view:onShowView(extraMsg, isInit)
    end
    
    if self._isShowLoading == true then
        self._isShowLoading = false
        TimerManager:addOnce(300, self.delayHideLoading, self)
    end

    self._isInitModule = false
end

function BasicModule:delayHideLoading()
--    coroutine.yield(10)
    if self._gameState.name == GameStates.Scene then
--        component.Loading:hide()  
    end
end

function BasicModule:hideModule()
    self.logicVisible = false
    if self.parent ~= nil then
        self.lastCloseTime = os.time()
        self.isHideModule = true
        if self._hideUseAction == true then
            NodeActionVisible:setActionVisible(self.parent,false) --component.
        else
            self:setVisible(false) -- 将self.parent 隐藏
        end
        if self._view ~= nil then
            self._view:onCloseView() -- stopTimer
        end
        if self.hideRemoveEvent == true then
            self:hideModuleRemoveEvent()
        end

        if self._view ~= nil then
            self:onOpenCloseContentHeight() -- 关闭ContentHeight > 0 的界面
        end
        self:onHideModule()
    end
end

function BasicModule:resetInitState()
    self._gameState:resetInitState()
end

function BasicModule:setVisible(visible)
    self.parent:setVisible(visible)
end

function BasicModule:setLocalZOrder(zOrder)
    self.parent:setLocalZOrder(zOrder)
end

function BasicModule:onOpenModule(extraMsg, isPerLoad)
    
    if self.isOpenShowLoader == true then
        self.parent:setVisible(false)
--        component.Loading:show()
    end 


    if self.showActionType == ModuleShowType.NONE then
        return
    end
    
    -- if self.showActionType == ModuleShowType.Animation then
    --     local uiAnimation = UIAnimation.new(self.parent, "001", false)
    --     uiAnimation:play(nil, false)
    --     uiAnimation:pause()
    --     TimerManager:addOnce(30, self.delayResumeAnimation, self, uiAnimation)
    --     return
    -- end

    -- 过场动画已经移到GameBaseState:showModule(data)处理
    if self.showActionType == ModuleShowType.Animation then
        -- local winSize = cc.Director:getInstance():getWinSize()
        -- local visibleSize = cc.Director:getInstance():getVisibleSize()
        -- local uiAnimation = UICCBLayer.new("rgb-guochangyun", self.parent, nil, nil, true)        
        -- uiAnimation:setPosition(visibleSize.width/2,visibleSize.height/2)
        -- uiAnimation:setLocalZOrder(9000)
        return
    end

    if isPerLoad == true then
        return
    end

    self:showAction()

end

function BasicModule:onModuleLoadComplete()
    self.parent:setVisible(true)
--    component.Loading:hide()
end

function BasicModule:onHideModule()
end

function BasicModule:onResetModuleCallback()
end

function BasicModule:isVisible()
    return  self.parent:isVisible()
end

function BasicModule:isModuleVisible()
    return self.logicVisible
end

function BasicModule:initModule()
    self.isInit = true
    
end

function BasicModule:addToLayer()
    --TODO test
    local layer = nil
    --将toolbar放到最上一层，以防其他操作拦住toolbar
--    layer = game.GameLayer:getLayer(self.uiLayerName)
    layer = self._gameState:getLayer(self.uiLayerName)
    layer:addChild(self.parent)
end

function BasicModule:getLayer(uiLayerName)
    local layer = self._gameState:getLayer(uiLayerName)
    return layer
end

function BasicModule:getShowModuleMap()
    return self._gameState:getShowModuleMap()
end

--除了一个层次全部隐藏
function BasicModule:hideAllLayerExcept(layerName,layerName2)
    self._gameState:hideAllLayerExcept(layerName,layerName2)
end

--将所有的视图还原
function BasicModule:resetLayers()
    self._gameState:resetLayers()
end

function BasicModule:addGroupModuleName(moduleName)
    table.insert(self.groupModuleName, moduleName)
end

function BasicModule:addMutexModuleName(moduleName)
    table.insert(self.mutexModuleName, moduleName)
end

function BasicModule:gameLogout()
    self._gameState:gameLogout()
end

--注册数据模型
function BasicModule:registerModel(model)
--    model:setMsgCenter(self._msgCenter)
    table.insert(self._modelList,model)
end

function BasicModule:writeLog(mainEvent, labelEvent, infos)
end

-- 模块检测是否能打开
function BasicModule:isCanShow(data)
    return true;
end

function BasicModule:isModuleShow(moduleName)
    return self._gameState:isModuleShow(moduleName)
end

function BasicModule:getPanel(panelName)
    return self._view:getPanel(panelName)
end

function BasicModule:getView()
    return self._view
end

--这个方法只有引导才会用到！
function BasicModule:getWidget(panelName, name, backdoor)
    if self._view == nil then
        return nil
    end

    if self._runShowModuleAction == true then  --还在做模块动画，返回nil
        return nil
    end
    
    local panel = self._view:getPanel(panelName)
    if panel == nil or (panel:isVisible() ~= true and backdoor ~= true) then
        return nil
    end
    local widget = panel[name]
    
    return widget
end

--置空
function BasicModule:resetWidget(panelName, name, backdoor)
    if self._view == nil then
        return nil
    end

    local panel = self._view:getPanel(panelName)
    if panel == nil then
        return nil
    end
    panel[name] = nil
end

--开挂
function BasicModule:getModule(name)
    return self._gameState:getModule(name)
end

--暂时开挂
function BasicModule:getModulePanel(moduleName, panelName)
    local module =  self._gameState:getModule(moduleName)
    local panel = module:getPanel(panelName)
    return panel
end

function BasicModule:setLocalData(key, value, isGloble)
    LocalDBManager:setValueForKey(key, value, isGloble)
end

function BasicModule:getLocalData(key, isGloble)
    local ret = LocalDBManager:getValueForKey(key, isGloble)
    return ret
end

function BasicModule:delayCallback(second, callback)
    
    local action = cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc(callback))
    self.parent:runAction(action)
    
end

--模块是否在动画中
function BasicModule:isModuleRunAction()
    return self._runShowModuleAction
end

function BasicModule:showAction()  
    -- NodeUtils:addSwallow() 
    self:setMask(true)
    self._runShowModuleAction = true --正在动画中
    local dir = -1
    if self.showActionType == ModuleShowType.RIGHT then
        dir = 1
    end

    if  self.parent.srcX == nil then
        local srcX , srcY = self.parent:getPosition()
        self.parent.srcX = srcX
        self.parent.srcY = srcY
    end

    local x, y = self.parent.srcX, self.parent.srcY
    local scale = NodeUtils:getAdaptiveScale()
    self.parent:setPosition(x + 640 * dir, y)

    local function callback()
        self.parent:stopAllActions()
        -- logger:error("==动画完毕回调再设一次坐标==",x,y) 
        self.parent:setPosition(x, y)  --防止快速点击打开时，坐标问题
        -- print("~~~~~~~~~~移动完毕~~~~~~~~~~~")
        self._runShowModuleAction = false

        if self._view ~= nil then  --在上面有可能模块就被释放掉了，比如加载，比较特殊
            -- print("~~~~~~onAfterActionView~~~~~~")
            self._view:onAfterActionView()
        end
        self:setMask(false)
        -- TimerManager:addOnce(30, onAfterActionView, self)
    end

--, cc.DelayTime:create(0.05)
    local function delayRunAction()
        local delayTime = 0.4
        if self._isInitModule then --初始模块的话
            delayTime = 0.5  --延迟0.5
        end
        local move = cc.MoveTo:create(0.2, cc.p(x,y))
        local afterAction = cc.Sequence:create(cc.DelayTime:create(delayTime),  cc.CallFunc:create(callback))
        local spawn = cc.Spawn:create(move, afterAction)
        -- local action = cc.Sequence:create(move, cc.CallFunc:create(callback), 
        --     cc.CallFunc:create(onAfterActionView))
        self.parent:runAction(spawn)
    end
    
    -- if self._isInitModule == true and self.isFirstDelayAction == true then
    --     TimerManager:addOnce(100, delayRunAction, self)
    -- else
        delayRunAction()
    -- end
    -- 
    
end

function BasicModule:showModuleAnimation( callback )
    -- body 这里需要加入蒙版，屏蔽各种触摸事件
    local topLayer = self:getLayer(GameLayer.topLayer)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local uiAnimation = UICCBLayer.new(GlobalConfig.moduleJumpAnimationName, topLayer, nil, nil, true)        
    uiAnimation:setPosition(visibleSize.width/2,visibleSize.height/2)
    uiAnimation:setLocalZOrder(10000)

    self._gameState:setMask(true)

    local function complete()
       
        if type(callback) == "function" then
            callback()
        end

        self._gameState:setMask(false)
    end

    TimerManager:addOnce(GlobalConfig.moduleJumpAnimationDelay,complete,self) --410毫秒特效达到全屏，执行回调
    
end

function BasicModule:delayResumeAnimation(animation)
    animation:resume()
end

function BasicModule:update()
--    logger:info("=======BasicModule========update========")
    if self._view ~= nil then
        self._view:update()
    end
end

function BasicModule:getTextWord(id)
    return TextWords:getTextWord(id)
end

function BasicModule:showSysMessage(content, color, font)
    self._gameState:showSysMessage(content, color, font)
end

function BasicModule:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent, isRemove)
    return self._gameState:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent, isRemove)
end

function BasicModule:getCurLayer()
    return self:getLayer(self.uiLayerName)
end

--获取模块的主界面名称
function BasicModule:getMainPanelName()
    local panelName = string.gsub(self.name, "Module", "Panel")
    return panelName
end

function BasicModule:isShowModuleAnimation()
    local isTrue
    if self.showActionType == ModuleShowType.Animation then
        isTrue = true
    else
        isTrue = false
    end
    return isTrue
end

function BasicModule:setMask(visible)
    self._gameState:setMask(visible)
end

function BasicModule:isMask()
    return self._gameState:isMask()
end

function BasicModule:onOpenCloseContentHeight()
    for _, panel in pairs(self._view:getPanelMap()) do
        local state01 = panel:getBgContentHeight() > 0
        if state01 then
            local state02 = self._view:getHidePanelState(panel:getSelfName())
            if state02 then
                panel:hide()
            end
        end
    end
end