-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownTradeModule = class("TownTradeModule", BasicModule)

function TownTradeModule:ctor()
    TownTradeModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function TownTradeModule:initRequire()
    require("modules.townTrade.event.TownTradeEvent")
    require("modules.townTrade.view.TownTradeView")
end

function TownTradeModule:finalize()
    TownTradeModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function TownTradeModule:initModule()
    TownTradeModule.super.initModule(self)
    self._view = TownTradeView.new(self.parent)

    self:addEventHandler()
end

function TownTradeModule:addEventHandler()
    self._view:addEventListener(TownTradeEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TownTradeEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_TRADE_END, self, self.onUpdateTradeEnd) 
    
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onUpdateTradeEnd)
end

function TownTradeModule:removeEventHander()
    self._view:removeEventListener(TownTradeEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TownTradeEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_TRADE_END, self, self.onUpdateTradeEnd) 

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onUpdateTradeEnd)
end

function TownTradeModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function TownTradeModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function TownTradeModule:onOpenModule()
    TownTradeModule.super.onOpenModule(self)

end

function TownTradeModule:onUpdateTradeEnd()
    self:getPanel(TownTradeResPanel.NAME):onUpdateTradeEnd()
end