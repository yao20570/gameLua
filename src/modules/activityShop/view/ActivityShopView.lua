
ActivityShopView = class("ActivityShopView", BasicView)

function ActivityShopView:ctor(parent)
    ActivityShopView.super.ctor(self, parent)
end

function ActivityShopView:finalize()
    ActivityShopView.super.finalize(self)
end

function ActivityShopView:registerPanels()
    ActivityShopView.super.registerPanels(self)

    require("modules.activityShop.panel.ActivityShopPanel")
    self:registerPanel(ActivityShopPanel.NAME, ActivityShopPanel)

    require("modules.activityShop.panel.ActivityShopBuyPanel")
    self:registerPanel(ActivityShopBuyPanel.NAME, ActivityShopBuyPanel)

    require("modules.activityShop.panel.ActivityShopHotPanel")
    self:registerPanel(ActivityShopHotPanel.NAME, ActivityShopHotPanel)

    require("modules.activityShop.panel.ActivityShopSpecialPanel")
    self:registerPanel(ActivityShopSpecialPanel.NAME, ActivityShopSpecialPanel)
end

function ActivityShopView:initView()
    local panel = self:getPanel(ActivityShopPanel.NAME)
    panel:show()
end

-- 更新打折面板
function ActivityShopView:onUpdateUIPanelDiscount(data)
    local panel = self:getPanel(ActivityShopHotPanel.NAME)
    panel:updateUIPanelDiscount()
end 

-- 更新黑市面板
function ActivityShopView:onUpdateUIPanelBlackMarket(data)
    local panel = self:getPanel(ActivityShopHotPanel.NAME)
    panel:updateUIPanelBlackMarket()
end 

-- 更新特卖面板
function ActivityShopView:onUpdateUIPanelSpecial(data)    
    local panel = self:getPanel(ActivityShopSpecialPanel.NAME)
    panel:updateUI()
end 

function ActivityShopView:onReqSellerInfo(data)
    local panel = self:getPanel(ActivityShopHotPanel.NAME)
    panel:updateUI()

    local panel = self:getPanel(ActivityShopSpecialPanel.NAME)
    panel:updateUI()

    
end 

function ActivityShopView:onUpdateCouponNumUI(data)
    local panel = self:getPanel(ActivityShopHotPanel.NAME)
    panel:updateCouponNumUI(data)
end

function ActivityShopView:onCloseBuyPanel(data)
    local panel = self:getPanel(ActivityShopBuyPanel.NAME)
    if data.isClose == true then        
        panel:hide()
    else
        panel:updatePanel(0)
    end
end