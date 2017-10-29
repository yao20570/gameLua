
TownTradeView = class("TownTradeView", BasicView)

function TownTradeView:ctor(parent)
    TownTradeView.super.ctor(self, parent)
end

function TownTradeView:finalize()
    TownTradeView.super.finalize(self)
end

function TownTradeView:registerPanels()
    TownTradeView.super.registerPanels(self)

    require("modules.townTrade.panel.TownTradePanel")
    self:registerPanel(TownTradePanel.NAME, TownTradePanel)

    require("modules.townTrade.panel.TownTradeResPanel")
    self:registerPanel(TownTradeResPanel.NAME, TownTradeResPanel)
end

function TownTradeView:initView()
--    local panel = self:getPanel(TownTradePanel.NAME)
--    panel:show()
end


function TownTradeView:onShowView(extraMsg, isInit, isAutoUpdate)
    TownTradeView.super.onShowView(self, extraMsg, isInit, false)
    local panel = self:getPanel(TownTradePanel.NAME)
    panel:show(extraMsg)
end