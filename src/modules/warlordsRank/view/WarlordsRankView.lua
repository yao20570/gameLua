
WarlordsRankView = class("WarlordsRankView", BasicView)

function WarlordsRankView:ctor(parent)
    WarlordsRankView.super.ctor(self, parent)
end

function WarlordsRankView:finalize()
    WarlordsRankView.super.finalize(self)
end

function WarlordsRankView:registerPanels()
    WarlordsRankView.super.registerPanels(self)

    require("modules.warlordsRank.panel.WarlordsRankPanel")
    self:registerPanel(WarlordsRankPanel.NAME, WarlordsRankPanel)

    require("modules.warlordsRank.panel.WarlordsRankLegionPanel")
    self:registerPanel(WarlordsRankLegionPanel.NAME, WarlordsRankLegionPanel)

    require("modules.warlordsRank.panel.WarlordsRankPerPanel")
    self:registerPanel(WarlordsRankPerPanel.NAME, WarlordsRankPerPanel)

    require("modules.warlordsRank.panel.WarlordsRankRewardPanel")
    self:registerPanel(WarlordsRankRewardPanel.NAME, WarlordsRankRewardPanel)
end

function WarlordsRankView:initView()
    local panel = self:getPanel(WarlordsRankPanel.NAME)
    panel:show()
end

function WarlordsRankView:onOpenModule()
    -- local panel = self:getPanel(WarlordsRankPanel.NAME)
    -- panel:onOpenModule()
end

function WarlordsRankView:onGetWinsRankInfos(data)
    local panel = self:getPanel(WarlordsRankPerPanel.NAME)
    panel:onGetWinsRankInfos(data)
end

function WarlordsRankView:onGetWinsRankLegionInfos(data)
    local panel = self:getPanel(WarlordsRankLegionPanel.NAME)
    panel:onGetWinsRankLegionInfos(data)
end