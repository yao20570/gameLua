
DayTurntableView = class("DayTurntableView", BasicView)

function DayTurntableView:ctor(parent)
    DayTurntableView.super.ctor(self, parent)
end

function DayTurntableView:finalize()
    DayTurntableView.super.finalize(self)
end

function DayTurntableView:registerPanels()
    DayTurntableView.super.registerPanels(self)

    require("modules.dayTurntable.panel.DayTurntablePanel")
    self:registerPanel(DayTurntablePanel.NAME, DayTurntablePanel)
    
    require("modules.dayTurntable.panel.DayTurntableMainPanel")
    self:registerPanel(DayTurntableMainPanel.NAME, DayTurntableMainPanel)
    
    require("modules.dayTurntable.panel.DayTurntableRankPanel")
    self:registerPanel(DayTurntableRankPanel.NAME, DayTurntableRankPanel)

    -- require("modules.dayTurntable.panel.DayTurnRankPanel")
    -- self:registerPanel(DayTurnRankPanel.NAME, DayTurnRankPanel)

    -- require("modules.dayTurntable.panel.RankRewardPanel")
    -- self:registerPanel(RankRewardPanel.NAME, RankRewardPanel)
end

function DayTurntableView:onShowView(extraMsg, isInit, isAutoUpdate)
    DayTurntableView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(DayTurntablePanel.NAME)
    panel:show()
end

function DayTurntableView:initView()
    -- local panel = self:getPanel(DayTurntablePanel.NAME)
    -- panel:show()
end

function DayTurntableView:updateView(data)
	local panel = self:getPanel(DayTurntablePanel.NAME)
	panel:updateView(data)
end

function DayTurntableView:resetView()
    local panel = self:getPanel(DayTurntablePanel.NAME)
    panel:resetView()
end

function DayTurntableView:updateRankData()
    local panel = self:getPanel(DayTurntablePanel.NAME)
    panel:updateRankView()
end