ScienceBuildPanel = class("ScienceBuildPanel", BasicPanel)
ScienceBuildPanel.NAME = "ScienceBuildPanel"

function ScienceBuildPanel:ctor(view, panelName)
    ScienceBuildPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function ScienceBuildPanel:finalize()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:finalize()
    end
    if self._uiBuilding ~= nil then
        self._uiBuilding:finalize()
    end
    ScienceBuildPanel.super.finalize(self)
end

function ScienceBuildPanel:initPanel()
    ScienceBuildPanel.super.initPanel(self)

    self:addBuilding()
end


function ScienceBuildPanel:addBuilding()
    local mainPanel = self:getChildByName("mainPanel")
    mainPanel:setVisible(false)
    mainPanel:setTouchEnabled(false)

    -- local uiBuilding = UIBuilding.new(mainPanel, self)
    local tabsPanel = self:getTabsPanel()
    local uiBuilding = UIBuilding.new(self, self, tabsPanel)
    self["upBtn"] = uiBuilding._upBtn
    self["quickBtn"] = uiBuilding._quickBtn

    self._uiBuilding = uiBuilding
end

function ScienceBuildPanel:onUpdateBuildingInfo()
    self:onShowHandler()

    if self._uiAcceleration ~= nil then
        self._uiAcceleration:update()
    end
end

function ScienceBuildPanel:onShowHandler()
    local panel = self:getPanel(ScienceMuseumPanel.NAME)
    -- panel:setBgType(ModulePanelBgType.BLACKFULL)

    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()

    local info = buildingProxy:getCurBuildingConfigInfo()
    --self._uiBuilding:adjustView(self:getTabsPanel())
    self._uiBuilding:updateInfo(info, buildingInfo)
end

--选择好加速类型了
function ScienceBuildPanel:onQuickReq(quickType, cost, info, num)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local data = {}
    data.order = nil -- -1
    data.buildingType = buildingInfo.buildingType
    data.index = buildingInfo.index
    data.useType = quickType
    data.useNum = num
    buildingProxy:onTriggerNet280004Req(data)

end

function ScienceBuildPanel:update()
    self._uiBuilding:update()
end

function ScienceBuildPanel:onItemReq(data)
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