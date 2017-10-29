
WorldBossView = class("WorldBossView", BasicView)

function WorldBossView:ctor(parent)
    WorldBossView.super.ctor(self, parent)
end

function WorldBossView:finalize()
    WorldBossView.super.finalize(self)
end

function WorldBossView:registerPanels()
    WorldBossView.super.registerPanels(self)

    require("modules.worldBoss.panel.WorldBossPanel")
    self:registerPanel(WorldBossPanel.NAME, WorldBossPanel)

    require("modules.worldBoss.panel.InspirePanel")
    self:registerPanel(InspirePanel.NAME, InspirePanel)
    
    require("modules.worldBoss.panel.WorldBossTeamSetPanel")
    self:registerPanel(WorldBossTeamSetPanel.NAME, WorldBossTeamSetPanel)
end

function WorldBossView:initView()
    -- local panel = self:getPanel(WorldBossPanel.NAME)
    -- panel:show()
end

function WorldBossView:saveCurActivityData(data)
	self.curData = data
end

function WorldBossView:getCurActivityData()
	return self.curData
end

function WorldBossView:onShowView(extraMsg,isInit)
	WorldBossView.super.onShowView(self,extraMsg, false)
	local panel = self:getPanel(WorldBossPanel.NAME)
    panel:show()
end

function WorldBossView:updateAutoBattleState(data)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:updateAutoBattleState(data)
end

function WorldBossView:updateInspireView()
    local panel = self:getPanel(InspirePanel.NAME)
    panel:updateView()
end

function WorldBossView:updateBossInfo(data)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:updateView(data)
end

function WorldBossView:showView(isNotOpen)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:showView(isNotOpen)
end

function WorldBossView:updateRankView(data)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:updateRankView(data)
end

function WorldBossView:showMyAttack(data)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:showMyAttack(data)
end

function WorldBossView:setTeamIcon(data)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:setTeamIcon(data)
end

function WorldBossView:bossDied(data)
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:bossDied(data)
end

function WorldBossView:cancelColdDown()
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:cancelColdDown()
end

function WorldBossView:activityEnd()
    local panel = self:getPanel(WorldBossPanel.NAME)
    panel:activityEnd()
end