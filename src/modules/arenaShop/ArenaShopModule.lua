
ArenaShopModule = class("ArenaShopModule", BasicModule)

function ArenaShopModule:ctor()
    ArenaShopModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = true
    
    self:initRequire()
end

function ArenaShopModule:initRequire()
    require("modules.arenaShop.event.ArenaShopEvent")
    require("modules.arenaShop.view.ArenaShopView")
end

function ArenaShopModule:finalize()
    ArenaShopModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ArenaShopModule:initModule()
    ArenaShopModule.super.initModule(self)
    self._view = ArenaShopView.new(self.parent)

    self:addEventHandler()
end

function ArenaShopModule:addEventHandler()
    self._view:addEventListener(ArenaShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ArenaShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self._view:addEventListener(ArenaShopEvent.CALL_BUY_REQ, self, self.onCallBuyReqHandler)
end

function ArenaShopModule:removeEventHander()
    self._view:removeEventListener(ArenaShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ArenaShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self._view:removeEventListener(ArenaShopEvent.CALL_BUY_REQ, self, self.onCallBuyReqHandler)
end

function ArenaShopModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ArenaShopModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ArenaShopModule:onOpenModule()
    ArenaShopModule.super.onOpenModule(self)
    self._view:setOpenModule()
    self:onGetRoleInfo()
end

function ArenaShopModule:onGetRoleInfo()
    self._view:onGetRoleInfo()
end

function ArenaShopModule:onCallBuyReqHandler(data)
    self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200004, data)
end