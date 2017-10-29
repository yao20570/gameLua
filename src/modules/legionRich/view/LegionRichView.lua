
LegionRichView = class("LegionRichView", BasicView)

function LegionRichView:ctor(parent)
    LegionRichView.super.ctor(self, parent)
end

function LegionRichView:finalize()
    LegionRichView.super.finalize(self)
end

function LegionRichView:registerPanels()
    LegionRichView.super.registerPanels(self)

    require("modules.legionRich.panel.LegionRichPanel")
    self:registerPanel(LegionRichPanel.NAME, LegionRichPanel)
	require("modules.legionRich.panel.LegionRichGatherPanel")
    self:registerPanel(LegionRichGatherPanel.NAME, LegionRichGatherPanel)
	require("modules.legionRich.panel.LegionRichDetailPanel")
    self:registerPanel(LegionRichDetailPanel.NAME, LegionRichDetailPanel)
	require("modules.legionRich.panel.LegionRichRankPanel")
    self:registerPanel(LegionRichRankPanel.NAME, LegionRichRankPanel)
	require("modules.legionRich.panel.LegionRichRewardPanel")
    self:registerPanel(LegionRichRewardPanel.NAME, LegionRichRewardPanel)
end

function LegionRichView:initView()
    local panel = self:getPanel(LegionRichPanel.NAME)
    panel:show()
end
function LegionRichView:updateView(data)
    local panel = self:getPanel(LegionRichGatherPanel.NAME)
    panel:updateLegionRichGatherView(data)
    local panel = self:getPanel(LegionRichPanel.NAME)
    panel:updateTips(data)
end
function LegionRichView:updateMemberView(data)
    local panel = self:getPanel(LegionRichDetailPanel.NAME)
    panel:updateLegionRichDetailView(data)
end
