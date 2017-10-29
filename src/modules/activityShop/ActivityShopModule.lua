-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-12-13 16:06:00
--  * @Description: 洛阳闹市
--  */
ActivityShopModule = class("ActivityShopModule", BasicModule)

function ActivityShopModule:ctor()
    ActivityShopModule.super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil

    self:initRequire()
end

function ActivityShopModule:initRequire()
    require("modules.activityShop.event.ActivityShopEvent")
    require("modules.activityShop.view.ActivityShopView")
end

function ActivityShopModule:finalize()
    ActivityShopModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ActivityShopModule:initModule()
    ActivityShopModule.super.initModule(self)
    self._view = ActivityShopView.new(self.parent)

    self:addEventHandler()
end

function ActivityShopModule:addEventHandler()
    self._view:addEventListener(ActivityShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ActivityShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_DISCOUNT, self, self.onUpdateUIPanelDiscount)
    self:addProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_BLACK_MARKET, self, self.onUpdateUIPanelBlackMarket)
    self:addProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_SPECIAL, self, self.onUpdateUIPanelSpecial)
    self:addProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_SELLER_INFO_REQ, self, self.onReqSellerInfo)
    self:addProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_COUPONS_UPDATE, self, self.onUpdateCouponNumUI)

    self:addProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_BUY_RESULT, self, self.onCloseBuyPanel)
end

function ActivityShopModule:removeEventHander()
    self._view:removeEventListener(ActivityShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ActivityShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)


    self:removeProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_DISCOUNT, self, self.onUpdateUIPanelDiscount)
    self:removeProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_BLACK_MARKET, self, self.onUpdateUIPanelBlackMarket)
    self:removeProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_SPECIAL, self, self.onUpdateUIPanelSpecial)
    self:removeProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_SELLER_INFO_REQ, self, self.onReqSellerInfo)
    self:removeProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_COUPONS_UPDATE, self, self.onUpdateCouponNumUI)

    self:removeProxyEventListener(GameProxys.ActivityShop, AppEvent.PROXY_ACTIVITY_SHOP_BUY_RESULT, self, self.onCloseBuyPanel)
end

function ActivityShopModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = self.name })
end

function ActivityShopModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, { moduleName = moduleName })
end

-- 更新打折面板
function ActivityShopModule:onUpdateUIPanelDiscount(data)
    self._view:onUpdateUIPanelDiscount(data)
end 

-- 更新黑市面板
function ActivityShopModule:onUpdateUIPanelBlackMarket(data)
    self._view:onUpdateUIPanelBlackMarket(data)
end 

-- 更新特卖面板
function ActivityShopModule:onUpdateUIPanelSpecial(data)
    self._view:onUpdateUIPanelSpecial(data)
end

function ActivityShopModule:onReqSellerInfo(data)
    self._view:onReqSellerInfo(data)
end

function ActivityShopModule:onUpdateCouponNumUI(data)
    self._view:onUpdateCouponNumUI(data)
end

function ActivityShopModule:onCloseBuyPanel(data)
    self._view:onCloseBuyPanel(data)
end