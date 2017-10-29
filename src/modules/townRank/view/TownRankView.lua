
TownRankView = class("TownRankView", BasicView)

function TownRankView:ctor(parent)
    TownRankView.super.ctor(self, parent)
end

function TownRankView:finalize()
    TownRankView.super.finalize(self)
end

function TownRankView:registerPanels()
    TownRankView.super.registerPanels(self)

    require("modules.townRank.panel.TownRankPanel")
    self:registerPanel(TownRankPanel.NAME, TownRankPanel)
end

function TownRankView:initView()
--    local panel = self:getPanel(TownRankPanel.NAME)
--    panel:show()
end


function TownRankView:onShowView(extraMsg, isInit)
    TownRankView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(TownRankPanel.NAME)
    panel:show()
end