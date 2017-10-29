
ShopView = class("ShopView", BasicView)

function ShopView:ctor(parent)
    ShopView.super.ctor(self, parent)
end

function ShopView:finalize()
    ShopView.super.finalize(self)
end

function ShopView:registerPanels()
    ShopView.super.registerPanels(self)

    require("modules.shop.panel.ShopPanel")
    self:registerPanel(ShopPanel.NAME, ShopPanel)
    
    require("modules.shop.panel.ShopResourcePanel")
    self:registerPanel(ShopResourcePanel.NAME, ShopResourcePanel)
    
    require("modules.shop.panel.ShopGainPanel")
    self:registerPanel(ShopGainPanel.NAME, ShopGainPanel)
    
    require("modules.shop.panel.ShopGrowUpPanel")
    self:registerPanel(ShopGrowUpPanel.NAME, ShopGrowUpPanel)
    
    require("modules.shop.panel.ShopSpecialPanel")
    self:registerPanel(ShopSpecialPanel.NAME, ShopSpecialPanel)
    
    require("modules.shop.panel.ShopBuyPanel")
    self:registerPanel(ShopBuyPanel.NAME, ShopBuyPanel)
end

function ShopView:initView()
    local panel = self:getPanel(ShopPanel.NAME)
    panel:show()
end


--关闭系统
function ShopView:onCloseView()
    ShopView.super.onCloseView(self)
end

--------------------------------------------------------------------
function ShopView:onShowView(extraMsg, isInit)
    ShopView.super.onShowView(self,extraMsg, isInit)
    -- local panel = self:getPanel(ShopPanel.NAME)
    -- panel:show()
end

function ShopView:setFirstPanelShow(extraMsg)
    local panel = self:getPanel(ShopPanel.NAME)
    panel:setFirstPanelShow(extraMsg)
end

function ShopView:onOpenView()
    local panel = self:getPanel(ShopResourcePanel.NAME)
    panel:show()
end