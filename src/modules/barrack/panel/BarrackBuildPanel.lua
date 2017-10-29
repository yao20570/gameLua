--兵营建造
BarrackBuildPanel = class("BarrackBuildPanel", BasicPanel)
BarrackBuildPanel.NAME = "BarrackBuildPanel"

function BarrackBuildPanel:ctor(view, panelName)
    BarrackBuildPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function BarrackBuildPanel:finalize()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:finalize()
    end
    if self._uiBuilding ~= nil then
        self._uiBuilding:finalize()
    end
    BarrackBuildPanel.super.finalize(self)
end

function BarrackBuildPanel:initPanel()
    BarrackBuildPanel.super.initPanel(self)
    self:addBuilding()
end

function BarrackBuildPanel:addBuilding()
    local mainPanel = self:getChildByName("mainPanel")
    mainPanel:setVisible(false)
    mainPanel:setTouchEnabled(false)
    -- local uiBuilding = UIBuilding.new(mainPanel, self)
    local tabsPanel = self:getTabsPanel()
    local uiBuilding = UIBuilding.new(self, self, tabsPanel)

    --uiBuilding:setIconScale(0.8, 0.8)

    self._uiBuilding = uiBuilding
    self["upBtn"] = uiBuilding._upBtn
    self["quickBtn"] = uiBuilding._quickBtn
end

function BarrackBuildPanel:onUpdateBuildingInfo()
    self:onShowHandler()
    
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:update()
    end
end

function BarrackBuildPanel:onShowHandler()
    local panel = self:getPanel(BarrackPanel.NAME)
    panel:setBgType(ModulePanelBgType.NONE)

    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    
    local info = buildingProxy:getCurBuildingConfigInfo()
    local tabsPanel = self:getTabsPanel()
    --self._uiBuilding:adjustView(tabsPanel)
    self._uiBuilding:updateInfo(info, buildingInfo)
end

--选择好加速类型了
function BarrackBuildPanel:onQuickReq(quickType, cost, info, num)
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

function BarrackBuildPanel:update()
    self._uiBuilding:update()
end

function BarrackBuildPanel:onItemReq(data)
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








