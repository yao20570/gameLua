
RebelsView = class("RebelsView", BasicView)

function RebelsView:ctor(parent)
    RebelsView.super.ctor(self, parent)
end

function RebelsView:finalize()
    RebelsView.super.finalize(self)
end

function RebelsView:registerPanels()
    RebelsView.super.registerPanels(self)

    require("modules.rebels.panel.RebelsPanel")
    self:registerPanel(RebelsPanel.NAME, RebelsPanel)

    require("modules.rebels.panel.RebelsInfoPanel")
    self:registerPanel(RebelsInfoPanel.NAME, RebelsInfoPanel)

    require("modules.rebels.panel.RebelsRankPanel")
    self:registerPanel(RebelsRankPanel.NAME, RebelsRankPanel)

    require("modules.rebels.panel.RebelsRewardPanel")
    self:registerPanel(RebelsRewardPanel.NAME, RebelsRewardPanel)
end

function RebelsView:initView()
    local panel = self:getPanel(RebelsPanel.NAME)
    panel:show()
end


function RebelsView:onActivityInfo(data)
    local panel = self:getPanel(RebelsInfoPanel.NAME)
    panel:updateUI()
end

function RebelsView:onRebelsRankUpdate(data)
    local panel = self:getPanel(RebelsRankPanel.NAME)
    panel:updateUI()
end 

function RebelsView:onRebelsRewardUpdate(data)
    local panel = self:getPanel(RebelsRewardPanel.NAME)
    panel:updateUI()
end 

function RebelsView:updateRedPointCount()
    local panel = self:getPanel(RebelsPanel.NAME)
    panel:updateRewardRedCount()
end 