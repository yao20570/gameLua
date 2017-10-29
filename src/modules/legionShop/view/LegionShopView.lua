
LegionShopView = class("LegionShopView", BasicView)

function LegionShopView:ctor(parent)
    LegionShopView.super.ctor(self, parent)
end

function LegionShopView:finalize()
    LegionShopView.super.finalize(self)
end

function LegionShopView:registerPanels()
    LegionShopView.super.registerPanels(self)

    require("modules.legionShop.panel.LegionShopPanel")
    self:registerPanel(LegionShopPanel.NAME, LegionShopPanel)

    require("modules.legionShop.panel.LegionGoodsPanel")
    self:registerPanel(LegionGoodsPanel.NAME, LegionGoodsPanel)

    -- require("modules.legionShop.panel.LegionTreasurePanel")
    -- self:registerPanel(LegionTreasurePanel.NAME, LegionTreasurePanel)

    require("modules.legionShop.panel.LegionTreasureNewPanel")
    self:registerPanel(LegionTreasureNewPanel.NAME, LegionTreasureNewPanel)
end

function LegionShopView:initView()
    local panel = self:getPanel(LegionShopPanel.NAME)
    panel:show()
end

function LegionShopView:setFirstPanelShow()
    -- local panel = self:getPanel(LegionShopPanel.NAME)
    -- panel:setFirstPanelShow()
end

function LegionShopView:onUpdateShopInfoResp()
    local panel = self:getPanel(LegionShopPanel.NAME)
    panel:onUpdateShopInfo()
end

