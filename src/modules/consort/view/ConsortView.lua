
ConsortView = class("ConsortView", BasicView)

function ConsortView:ctor(parent)
    ConsortView.super.ctor(self, parent)
end

function ConsortView:finalize()
    ConsortView.super.finalize(self)
end

function ConsortView:registerPanels()
    ConsortView.super.registerPanels(self)

    require("modules.consort.panel.ConsortPanel")
    self:registerPanel(ConsortPanel.NAME, ConsortPanel)

    require("modules.consort.panel.ConsortInfoPanel")
    self:registerPanel(ConsortInfoPanel.NAME, ConsortInfoPanel)

    require("modules.consort.panel.ConsortRankPanel")
    self:registerPanel(ConsortRankPanel.NAME, ConsortRankPanel)

    require("modules.consort.panel.ConsortRewardPanel")
    self:registerPanel(ConsortRewardPanel.NAME, ConsortRewardPanel)
end

function ConsortView:initView()
    local panel = self:getPanel(ConsortPanel.NAME)
    panel:show()
end

function ConsortView:updateConsortInfo(data)
    local panel = self:getPanel(ConsortInfoPanel.NAME)
    panel:updateUI()
end

function ConsortView:updateConsortRank(data)
    local panel = self:getPanel(ConsortRankPanel.NAME)
    panel:updateUI()
end 

function ConsortView:playConsortAnima(data)
    local panel = self:getPanel(ConsortInfoPanel.NAME)
    panel:playerAnima(data)
end