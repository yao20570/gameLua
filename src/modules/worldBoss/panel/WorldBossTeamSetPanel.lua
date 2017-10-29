-----------------------------------------------------------------------------------------
WorldBossTeamSetPanel = class("WorldBossTeamSetPanel", BasicPanel)
WorldBossTeamSetPanel.NAME = "WorldBossTeamSetPanel"
function WorldBossTeamSetPanel:ctor(view, panelName)
    WorldBossTeamSetPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function WorldBossTeamSetPanel:finalize()
    if self.teamPanel then
        self.teamPanel:finalize()
    end
    WorldBossTeamSetPanel.super.finalize(self)
end

function WorldBossTeamSetPanel:initPanel()
    WorldBossTeamSetPanel.super.initPanel(self)
    self:setTitle(true, "setTeam", true)
    self:setBgType(ModulePanelBgType.TEAM)
    self.proxy = self:getProxy(GameProxys.BattleActivity)
end

function WorldBossTeamSetPanel:onShowHandler(sendData)
    if self.teamPanel == nil then
        -- self.teamPanel = UITeamMiPanel.new(self, sendData, 4, nil, self:topAdaptivePanel())
        local tabsPanel = self:topAdaptivePanel2()
        self.teamPanel = UITeamMiPanel.new(self, sendData, 4, nil, tabsPanel)
    else
        self.teamPanel:onUpdateData(sendData, 4)
    end
end

function WorldBossTeamSetPanel:onClosePanelHandler()
    self:hide()
end

--通用部队面板的保存阵型回调
function WorldBossTeamSetPanel:onTouchProtectBtnHandle(data)
    local sendInfo = {}
    for k,v in pairs(data.info.members) do
        if v.num ~= 0 and v.num ~= nil then
            sendInfo[k] = v
        end
    end
    self.proxy:onTriggerNet320003Req({members = sendInfo})
end