
BasicView = class("BasicView", EventDispatcher)

------------------------Panel name需要与 所对应的UI名字一致
function BasicView:ctor(parent)
    BasicView.super.ctor(self)
    self._parent = parent
    
    self._panelMap = {}
    self._panelClassMap = {}
    self:registerPanels()
    
    self._showPanelMap = {}

    self._updateDt = 1000 --毫秒
    self._curCountTime = 0
    
    self:initView()
end

function BasicView:finalize()
    self:stopTimer()
    BasicView.super.finalize(self)
    for _, panel in pairs(self._panelMap) do
    	panel:finalize()
    end

    self._parent:removeFromParent()
end

function BasicView:initView()
end

function BasicView:onCloseView()
    self:stopTimer()

    for _, panel in pairs(self._panelMap) do
    	panel:pauseCCB()
    end
end

--不是初始化才会去渲染onShowHandler
--初始化时，各自Panel会去自己Show出来
--不自动更新了
function BasicView:onShowView(extraMsg, isInit, isAutoUpdate)
    self:startTimer()
    
    for _, panel in pairs(self._panelMap) do
        panel:resumeCCB()
    end

    --模块跳转统一处理方法
    if type(extraMsg) == type({}) and rawget(extraMsg, "panelName") ~= nil then
        local panel = self:getPanel(extraMsg.panelName)
        if panel ~= nil and panel:isVisible() then
            panel:show()
        else
            local mainPanelName = self:getMainPanelName()
            local mainPanel = self:getPanel(mainPanelName)
            local flag = mainPanel:changeTabSelectByName(extraMsg.panelName)
            if flag == false then  --这个Panel不是通过Main标签切换的，直接show
                local panel = self:getPanel(extraMsg.panelName)
                if panel ~= nil then
                    panel:show()
                end
            end
        end
    else
        local mainPanelName = self:getMainPanelName()
        local mainPanel = self:getPanel(mainPanelName)
        if mainPanel ~= nil then
            mainPanel:changeDefaultTabPanel()  --默认，没有参数的，切换到默认标签中去，如果没有标签的面板，则不会受到影响
        end
    end
    
    --不是初始化才会去渲染onShowHandler
    --初始化时，各自Panel会去自己Show出来
    --不自动更新了
    if isInit ~= false and isAutoUpdate == true then
        for panelName, _ in pairs(self._showPanelMap) do
            local panel = self:getPanel(panelName)
            panel:onShowHandler()
        end
    end

    return flag
end

--模块动画结束后，回调
function BasicView:onAfterActionView()
    for panelName, _ in pairs(self._showPanelMap) do
        local panel = self:getPanel(panelName)
        if panel:isVisible() then
            panel:onAfterActionHandler()
        end
    end
end

function BasicView:showPanel(panelName)
    self._showPanelMap[panelName] = true
end

function BasicView:hidePanel(panelName)
    self._showPanelMap[panelName] = nil
end

function BasicView:getHidePanelState(panelName)
    return self._showPanelMap[panelName] == true -- 没有经过hide的才返回true，否则返回nil
end

function BasicView:getPanelMap()
    return self._panelMap
end

function BasicView:clearShowPanel()
    self._showPanelMap = {}
end

function BasicView:startTimer()
    TimerManager:add(self._updateDt, self.update, self, -1)
end

function BasicView:stopTimer()
    TimerManager:remove(self.update, self)
end

--function BasicView:setParent(parent)
--    self._parent = parent
--end

function BasicView:addChild(child)
    self._parent:addChild(child)
end

function BasicView:getParent()
    return self._parent
end

function BasicView:setVisible(visible)
    self._parent:setVisible(visible)
end

function BasicView:isVisible()
    return self._parent:isVisible()
end

function BasicView:isModuleVisible()
    local module = self._parent.module
    return module:isModuleVisible()
end

--模块是否在动画中
function BasicView:isModuleRunAction()
    local module = self._parent.module
    return module:isModuleRunAction()
end

function BasicView:registerPanels()

end

function BasicView:registerPanel(name, panelClass)
    self._panelClassMap[name] = panelClass
end

--Panel是否注册过
function BasicView:isPanelRegister(name)
    return self._panelClassMap[name] ~= nil
end

function BasicView:getPanel(name)
    if self._panelMap[name] == nil and self:isPanelRegister(name) == true then
        self._panelMap[name] = self._panelClassMap[name].new(self, name)
--        self._panelMap[name]:startInitPanel()
    end
    
    return self._panelMap[name]
end

function BasicView:setLocalData(key, value, isGloble)
    LocalDBManager:setValueForKey(key, value, isGloble)
end

function BasicView:getLocalData(key, isGloble)
    local ret = LocalDBManager:getValueForKey(key, isGloble)
    return ret
end

function BasicView:getProxy(name)
    local module = self._parent.module
    return module:getProxy(name)
end

function BasicView:getShowModuleMap()
    local module = self._parent.module
    return module:getShowModuleMap()
end

function BasicView:getModulePanel(moduleName, panelName)
    local module = self._parent.module
    return module:getModulePanel(moduleName, panelName)
end

--设置模块的显示，用来优化GC的
function BasicView:setModuleVisible(moduleName, visible)
    local module = self._parent.module
    local m = module:getModule(moduleName)
    if m then
        m:setVisible(visible)
    end
end

function BasicView:writeLog(mainEvent, labelEvent, infos)
--    framework.platform.AppUtils:onEventTCAgent(mainEvent, labelEvent, infos)
end

function BasicView:makeGuideParame(name, touchCallback)

    local node = {}
    node.getWorldPosition = function() return cc.p(0, 0) end
    node.getContentSize = function() return cc.p(0, 0) end
    node.getAnchorPoint = function() return cc.p(0, 0) end
    node.touchCallback = touchCallback
    
    self[name] = node
end

function BasicView:clearGuideParame(name)
    self[name] = nil
end

function BasicView:update(dt)
    dt = self._updateDt / 1000 / cc.Director:getInstance():getScheduler():getTimeScale() 
    if self._curCountTime + dt < self._updateDt / 1000 then
        self._curCountTime = self._curCountTime + dt
        return
    end
    self._curCountTime = 0
    for _, panel in pairs(self._panelMap) do
        if panel:isVisible() then
            panel:update(self._updateDt)
        end
    end
end

function BasicView:getTextWord(id)
    return TextWords:getTextWord(id)
end

-------------------开后门方法----------------------
function BasicView:showSysMessage(content, color, font)
    local module = self._parent.module
    module:showSysMessage(content, color, font)
end

function BasicView:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent, isRemove)
    return self._parent.module:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent, isRemove)
end

function BasicView:getLayer(uiLayerName)
    return self._parent.module:getLayer(uiLayerName)
end

function BasicView:getMainPanelName()
    return self._parent.module:getMainPanelName()
end

function BasicView:getState()
    local module = self._parent.module
    return module:getGameState()
end

function BasicView:getModuleName()
    local module = self._parent.module
    return module.name
end

function BasicView:setMask(visible)
    self._parent.module:setMask(visible)
end

function BasicView:isMask()
    return self._parent.module:isMask()
end

function BasicView:resetInitState()
    self._parent.module:resetInitState()
end

