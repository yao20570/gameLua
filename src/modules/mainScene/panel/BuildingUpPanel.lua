BuildingUpPanel = class("BuildingUpPanel", BasicPanel)
BuildingUpPanel.NAME = "BuildingUpPanel"

function BuildingUpPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    BuildingUpPanel.super.ctor(self, view, panelName, true, layer)
    
    self:setUseNewPanelBg(true)
end

function BuildingUpPanel:finalize()
    if self._uiBuilding ~= nil then
        self._uiBuilding:finalize()
    end
    BuildingUpPanel.super.finalize(self)
end

function BuildingUpPanel:initPanel()
    BuildingUpPanel.super.initPanel(self)
    self:addBuilding()
    
    self:setBgType(ModulePanelBgType.NONE)
    --self:setBgType(ModulePanelBgType.BLACKFULL)
    -- self:setBgImg3Full()
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_9)
end

function BuildingUpPanel:onUpdateBuildingInfo()
    self:onShowHandler()
end

function BuildingUpPanel:addBuilding()
    local mainPanel = self:getChildByName("mainPanel")
    -- local uiBuilding = UIBuilding.new(mainPanel, self)
    mainPanel:setVisible(false)
    mainPanel:setTouchEnabled(false)
    local tabsPanel = self:topAdaptivePanel()
    tabsPanel = GlobalConfig.topHeight
    local uiBuilding = UIBuilding.new(self, self, tabsPanel)


    self._uiBuilding = uiBuilding
    
    self["upBtn"] = uiBuilding._upBtn
    self["quickBtn"] = uiBuilding._quickBtn
end

function BuildingUpPanel:onHideHandler()
--    self:setParentZOrder(ModuleLayer.UI_Z_ORDER_1)
    
    --移除事件
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:clearEvent()
    
    self.view:hideFullScreenPanel()
    
end

function BuildingUpPanel:onShowHandler(closeCallback)

    self.view:showFullScreenPanel()
--    self:setParentZOrder(ModuleLayer.UI_Z_ORDER_2)
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()

    local info = buildingProxy:getCurBuildingConfigInfo()
    
    self._uiBuilding:updateInfo(info, buildingInfo)
    
    buildingProxy:registerCurBuilingInfoChangeEvent(self, self.onUpdateBuildingInfo)
    
    local titleStr = self:getTextWord(tonumber(string.format("1810%d", info.type)))
    local title = string.format("(Lv.%d)", info.lv)
    self:setTitle(true, titleStr, true, title)
    
    if closeCallback ~= nil then
        self._closeCallback = closeCallback
    end
end

--选择好加速类型了
function BuildingUpPanel:onQuickReq(quickType, cost, info, num)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local data = {}
    -- data.order = -1
    data.buildingType = buildingInfo.buildingType
    data.index = buildingInfo.index
    data.useType = quickType
    data.useNum = num
    buildingProxy:onTriggerNet280004Req(data)
    -- buildingProxy:buildingQuickReq(data)

end

function BuildingUpPanel:onDemolitHandler()
    self:hide()
end

function BuildingUpPanel:update()
    self._uiBuilding:update()
end

function BuildingUpPanel:onClosePanelHandler()
    BuildingUpPanel.super.onClosePanelHandler(self)
    self:hide()
    
    if self._closeCallback ~= nil then
        self._closeCallback()
        self._closeCallback = nil
    end
end

function BuildingUpPanel:onItemReq(data)
    local sendData = {}
    local proxy = self:getProxy(GameProxys.Item)
    if data.type == 0 then --使用
        sendData.typeId = data.itemID
        sendData.num = data.num
        proxy:onTriggerNet90001Req(sendData)
    elseif data.type == 1 then --购买使用
        sendData.id = data.id
        proxy:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100007, sendData)
    end
end
