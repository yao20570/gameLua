
SeasonsView = class("SeasonsView", BasicView)

function SeasonsView:ctor(parent)
    SeasonsView.super.ctor(self, parent)
end

function SeasonsView:finalize()
    SeasonsView.super.finalize(self)
end

function SeasonsView:registerPanels()
    SeasonsView.super.registerPanels(self)

    require("modules.seasons.panel.SeasonsPanel")
    self:registerPanel(SeasonsPanel.NAME, SeasonsPanel)

    require("modules.seasons.panel.SeasonsFourSeasonPanel")

    self:registerPanel(SeasonsFourSeasonPanel.NAME, SeasonsFourSeasonPanel)

    require("modules.seasons.panel.SeasonsWorldLevel")

    self:registerPanel(SeasonsWorldLevel.NAME, SeasonsWorldLevel)
end

function SeasonsView:initView()
    local panel = self:getPanel(SeasonsPanel.NAME)
    panel:show()
end

function SeasonsView:openView()
    local panel = self:getPanel(SeasonsPanel.NAME)
    panel:show()
end




function SeasonsView:updateSeasonView()
    local panel = self:getPanel(SeasonsFourSeasonPanel.NAME)
    panel:updateView()
end

function SeasonsView:updateWorldLevelView()
    local panel = self:getPanel(SeasonsWorldLevel.NAME)
    panel:updateView()
end
