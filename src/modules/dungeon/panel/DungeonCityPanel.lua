-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
DungeonCityPanel = class("DungeonCityPanel", BasicPanel)
DungeonCityPanel.NAME = "DungeonCityPanel"

function DungeonCityPanel:ctor(view, panelName)
    DungeonCityPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function DungeonCityPanel:finalize()
    if self.UITeamDetailPanel then
        self.UITeamDetailPanel:finalize()
    end
    DungeonCityPanel.super.finalize(self)
end

function DungeonCityPanel:initPanel()
    DungeonCityPanel.super.initPanel(self)
    self:setTitle(true,"budui",true)
    self:setBgType(ModulePanelBgType.TEAM)
end

function DungeonCityPanel:registerEvents()
    DungeonCityPanel.super.registerEvents(self)
end

function DungeonCityPanel:onClosePanelHandler()
    local dungeonMapPanel = self:getPanel(DungeonMapPanel.NAME)
    dungeonMapPanel:setVisible(true)
    dungeonMapPanel:onDungeonInfoFlush()
    dungeonMapPanel:updateEnergyData()
    self:hide()

end

function DungeonCityPanel:onHideHandler()
     local dungeonMapPanel = self:getPanel(DungeonMapPanel.NAME)
     dungeonMapPanel:setVisible(true)
     dungeonMapPanel:updateEnergyData()
end

function DungeonCityPanel:onShowHandler(data)
    self._sendData = data
    
    local proxy = self:getProxy(GameProxys.Dungeon)
    self._uiType = proxy:getCurrType()
    local subtype = proxy:getSubBattleType()
    if subtype then
        self._sendData.extra = {}
        self._sendData.extra.subtype = subtype
    end

    if self.UITeamDetailPanel then
        self.UITeamDetailPanel:onUpdateData(self._sendData,self._uiType)
    else
        self.UITeamDetailPanel = UITeamDetailPanel.new(self,self._sendData,self._uiType)
        self["fightBtn"] = self.UITeamDetailPanel:getFightBtn()
    end


    if not self:isRunShowPanelAction() then
        self:showPanelAction()
    end
end

function DungeonCityPanel:panelActionCallback()
    local dungeonMapPanel = self:getPanel(DungeonMapPanel.NAME)
    dungeonMapPanel:setVisible(false)
end

function DungeonCityPanel:onFightCallback(callback)

    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:setVisible(true)
    panel:updateEnergyData()

    --TODO  执行DungeonMap的战斗特效逻辑
    local dungeonMapPanel = self:getPanel(DungeonMapPanel.NAME)
    dungeonMapPanel:playFightAnimation(callback)
end

function DungeonCityPanel:setMaxFightTeam()
    self.UITeamDetailPanel:onTouchFigAndWeiBtnHandle()
end

-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
