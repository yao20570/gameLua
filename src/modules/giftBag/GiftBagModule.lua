-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-03-17
--  * @Description: 热卖礼包
--  */
GiftBagModule = class("GiftBagModule", BasicModule)

function GiftBagModule:ctor()
    GiftBagModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    
    self:initRequire()
end

function GiftBagModule:initRequire()
    require("modules.giftBag.event.GiftBagEvent")
    require("modules.giftBag.view.GiftBagView")
end

function GiftBagModule:finalize()
    GiftBagModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function GiftBagModule:initModule()
    GiftBagModule.super.initModule(self)
    self._view = GiftBagView.new(self.parent)

    self:addEventHandler()
end

function GiftBagModule:addEventHandler()
    self._view:addEventListener(GiftBagEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(GiftBagEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.GiftBag, AppEvent.PROXY_GIFTBAGINFOS_UPDATE, self, self.updateInfos)
    self:addProxyEventListener(GameProxys.GiftBag, AppEvent.PROXY_GIFTBAG_CAN_BUY, self, self.doBuyAction)
end

function GiftBagModule:removeEventHander()
    self._view:removeEventListener(GiftBagEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(GiftBagEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(GameProxys.GiftBag, AppEvent.PROXY_GIFTBAGINFOS_UPDATE, self, self.updateInfos)
    self:removeEventListener(GameProxys.GiftBag, AppEvent.PROXY_GIFTBAG_CAN_BUY, self, self.doBuyAction)
end

function GiftBagModule:onHideSelfHandler()
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    local function hideCallback()
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
        return ""
    end
    self:getPanel(GiftBagPanel.NAME):hide(hideCallback, self)
end

function GiftBagModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function GiftBagModule:updateInfos()
    self._view:updateInfos()
end
--询问服务器礼包是否可以购买返回
function GiftBagModule:doBuyAction(data)
    self._view:doBuyAction(data)
end