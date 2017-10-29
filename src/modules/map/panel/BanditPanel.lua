
BanditPanel = class("BanditPanel", BasicPanel)
BanditPanel.NAME = "BanditPanel"

function BanditPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    BanditPanel.super.ctor(self, view, panelName, true, layer)
    
    self:setUseNewPanelBg(true)
end

function BanditPanel:finalize()
    if self.uiTeamDetailPanel then
        self.uiTeamDetailPanel:finalize()
    end
    BanditPanel.super.finalize(self)
end

function BanditPanel:initPanel()
    BanditPanel.super.initPanel(self)
    self:setTitle(true, "budui", true)
    self:setBgType(ModulePanelBgType.TEAM)
end

function BanditPanel:registerEvents()
    BanditPanel.super.registerEvents(self)
end

function BanditPanel:closeOtherPanel()
    local panel = self:getPanel(MapPanel.NAME)
    panel:hide()
    panel = self:getPanel(MapInfoPanel.NAME)
    panel:hide()

    self:setModuleVisible(ModuleName.ToolbarModule, false)
end

function BanditPanel:showOtherPanel()

    self:setModuleVisible(ModuleName.ToolbarModule, true)

    local panel = self:getPanel(MapPanel.NAME)
    panel:show()
    panel = self:getPanel(MapInfoPanel.NAME)
    panel:show()
end

function BanditPanel:onHideHandler()
    self:showOtherPanel()
end

function BanditPanel:onShowHandler(banditDungeon)

    -- self:closeOtherPanel()

    local eventId = banditDungeon.eventId
    local panditMonster = ConfigDataManager:getConfigById(ConfigData.PanditMonsterConfig, eventId)
    panditMonster.chapter = 1

    local sendData = { }
    sendData._info = panditMonster

    local targetName = string.format(self:getTextWord(318), panditMonster.lv, panditMonster.name)

    sendData.star = 1
    sendData.extra = {
        isShowStar = false,
        isShowLost = true,
        isShowSleep = false,
        targetName = targetName
    }

    self._banditDungeon = banditDungeon
    local uiType = GameConfig.battleType.kill
    if self.uiTeamDetailPanel then
        self.uiTeamDetailPanel:onUpdateData(sendData, uiType)
    else
        self.uiTeamDetailPanel = UITeamDetailPanel.new(self, sendData, uiType, self.onCallback)

        self["maxFightBtn"] = self.uiTeamDetailPanel:getMaxFightBtn()
        self["fightBtn"] = self.uiTeamDetailPanel:getFightBtn()
    end

    if not self:isRunShowPanelAction() then
        self:showPanelAction()
    end
end

function BanditPanel:panelActionCallback()
    self:closeOtherPanel()
end

-- ³öÕ½µÄ»Øµ÷
function BanditPanel:onCallback()
    local infos = self.uiTeamDetailPanel:getFightElementInfos()
    local state = self.uiTeamDetailPanel:getSaveTrafficState()

    local sendBattleData = { }
    sendBattleData.id = self._banditDungeon.id
    sendBattleData.infos = infos
    sendBattleData.saveTraffic = state

    local banditDungeonProxy = self:getProxy(GameProxys.BanditDungeon)
    banditDungeonProxy:onTriggerNet340001Req(sendBattleData)

end

function BanditPanel:onClosePanelHandler()
    -- body
    self:hide()
end