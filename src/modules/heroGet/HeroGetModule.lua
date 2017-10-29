
HeroGetModule = class("HeroGetModule", BasicModule)

function HeroGetModule:ctor()
    HeroGetModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroGetModule:initRequire()
    require("modules.heroGet.event.HeroGetEvent")
    require("modules.heroGet.view.HeroGetView")
end

function HeroGetModule:finalize()
    HeroGetModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroGetModule:initModule()
    HeroGetModule.super.initModule(self)
    self._view = HeroGetView.new(self.parent)

    self:addEventHandler()

    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_SEC_TOP + 1)
end

function HeroGetModule:addEventHandler()
    self._view:addEventListener(HeroGetEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroGetEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_SHOW_RESOLVE, self, self.showResolveView)
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_POS_RESOLVE, self, self.hideResolveView)
end

function HeroGetModule:removeEventHander()
    self._view:removeEventListener(HeroGetEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroGetEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_SHOW_RESOLVE, self, self.showResolveView)
    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_POS_RESOLVE, self, self.hideResolveView)
end

function HeroGetModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroGetModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function HeroGetModule:showResolveView(data)
    self._view:showResolveView(data)
end

function HeroGetModule:hideResolveView()
    self._view:hideResolveView()
end