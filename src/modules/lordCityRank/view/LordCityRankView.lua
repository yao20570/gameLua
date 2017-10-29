
LordCityRankView = class("LordCityRankView", BasicView)

function LordCityRankView:ctor(parent)
    LordCityRankView.super.ctor(self, parent)
end

function LordCityRankView:finalize()
    LordCityRankView.super.finalize(self)
end

function LordCityRankView:registerPanels()
    LordCityRankView.super.registerPanels(self)

    require("modules.lordCityRank.panel.LordCityRankPanel")
    self:registerPanel(LordCityRankPanel.NAME, LordCityRankPanel)

    require("modules.lordCityRank.panel.LordCityRankLegionPanel")
    self:registerPanel(LordCityRankLegionPanel.NAME, LordCityRankLegionPanel)

    require("modules.lordCityRank.panel.LordCityRankSinglePanel")
    self:registerPanel(LordCityRankSinglePanel.NAME, LordCityRankSinglePanel)

    require("modules.lordCityRank.panel.LordCityRankRewardPrePanel")
    self:registerPanel(LordCityRankRewardPrePanel.NAME, LordCityRankRewardPrePanel)
end

function LordCityRankView:initView()
    local panel = self:getPanel(LordCityRankPanel.NAME)
    panel:show()
end

function LordCityRankView:onSingleRankMapUpdate()
    local panel = self:getPanel(LordCityRankSinglePanel.NAME)
    if panel:isVisible() then
        panel:onSingleRankMapUpdate()
    end
end

function LordCityRankView:onLegionRankMapUpdate()
    local panel = self:getPanel(LordCityRankLegionPanel.NAME)
    if panel:isVisible() then
        panel:onLegionRankMapUpdate()
    end
end

