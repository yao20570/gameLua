-- /**
--  * @Author:    wzy
--  * @DateTime:    2016-12-03 15:03:00
--  * @Description:
--  */
MapRebelsFightPanel = class("MapRebelsFightPanel", BasicPanel)
MapRebelsFightPanel.NAME = "MapRebelsFightPanel"

function MapRebelsFightPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    MapRebelsFightPanel.super.ctor(self, view, panelName, true, layer)
    
    self:setUseNewPanelBg(true)
end

function MapRebelsFightPanel:finalize()
    if self.uiTeamDetailPanel then
        self.uiTeamDetailPanel:finalize()
    end
    MapRebelsFightPanel.super.finalize(self)

end

function MapRebelsFightPanel:initPanel()
    MapRebelsFightPanel.super.initPanel(self)
    self:setTitle(true, "budui", true)
    self:setBgType(ModulePanelBgType.TEAM)
end

function MapRebelsFightPanel:registerEvents()
    MapRebelsFightPanel.super.registerEvents(self)
end


function MapRebelsFightPanel:closeOtherPanel()
    -- local panel = self:getPanel(MapPanel.NAME)
    -- panel:hide()
    local panel = self:getPanel(MapInfoPanel.NAME)
    panel:hide()

    self:setModuleVisible(ModuleName.ToolbarModule, false)
end

function MapRebelsFightPanel:showOtherPanel()

    self:setModuleVisible(ModuleName.ToolbarModule, true)

    local panel = self:getPanel(MapPanel.NAME)
    panel:show()
    panel = self:getPanel(MapInfoPanel.NAME)
    panel:show()
end

function MapRebelsFightPanel:onHideHandler()
    self:showOtherPanel()
end

function MapRebelsFightPanel:onShowHandler(tileRebelsData)

    self._tileRebelsData = tileRebelsData

    -- 叛军类型
    local rebelsType = tileRebelsData.rebelInfo.rebelArmyType

    local rebelsCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.ArmyGoDesignConfig, "monsterType", rebelsType)

    local sendData = { }

    sendData._info = { }
    sendData._info.targetName = ""
    sendData._info.monsterGroupId = tileRebelsData.monsterGroupId
    sendData._info.fight = tileRebelsData.rebelInfo.masterCapacity    --战力
    sendData._info.posInfos = { }
    local posInfos = tileRebelsData.rebelInfo.monsterInfo.info
    for k, v in pairs(posInfos) do
        sendData._info.posInfos[v.post] = v
    end

    sendData.star = 1
    sendData.extra = {
        isShowStar = false,
        isShowLost = true,
        isShowSleep = false,
        isConfigData = false,
        targetName = string.format(self:getTextWord(318), tileRebelsData.rebelInfo.level, rebelsCfg.monsterName)
    }

    local teamDetail = self:getProxy(GameProxys.TeamDetail)
    teamDetail:setEnterTeamDetailType(1)

    --14 就是 FightControlConfig.lua里的叛军配置
    local uiType = 14 
    if self.uiTeamDetailPanel ~= nil then
        self.uiTeamDetailPanel:onUpdateData(sendData, uiType)
    else
        self.uiTeamDetailPanel = UITeamDetailPanel.new(self, sendData, uiType, self.onCallback)
    end

    if not self:isRunShowPanelAction() then
        self:showPanelAction()
    end
end

function MapRebelsFightPanel:panelActionCallback()
    self:closeOtherPanel()
end

function MapRebelsFightPanel:onCallback(type)

    local data = { }
    data.team = self.uiTeamDetailPanel:getFightElementInfos()
    data.x = self._tileRebelsData.x
    data.y = self._tileRebelsData.y
    -- self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80001, sendData)
    self:dispatchEvent(MapEvent.ATTCK_REBELS_REQ, data)


    self:hide()
end

function MapRebelsFightPanel:onClosePanelHandler()
    -- body
    self:hide()
end

function MapRebelsFightPanel:setMarchTime(data)
    self.uiTeamDetailPanel:setMarchTime(data)
end