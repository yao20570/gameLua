
RechargeModule = class("RechargeModule", BasicModule)

function RechargeModule:ctor()
    RechargeModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_TOP_LAYER
    -- self.uiLayerName =ModuleLayer.UI_TOP_LAYER
    self.showActionType = ModuleShowType.LEFT
        
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function RechargeModule:initRequire()
    require("modules.recharge.event.RechargeEvent")
    require("modules.recharge.view.RechargeView")
end

function RechargeModule:finalize()
    RechargeModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RechargeModule:initModule()
    RechargeModule.super.initModule(self)
    self._view = RechargeView.new(self.parent)

    self:addEventHandler()

    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_12)
end

function RechargeModule:addEventHandler()
    self._view:addEventListener(RechargeEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RechargeEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_RECHARGE_INFO, self, self.updateRechargeInfo)
end

function RechargeModule:removeEventHander()
    self._view:removeEventListener(RechargeEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RechargeEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_RECHARGE_INFO, self, self.updateRechargeInfo)
end

function RechargeModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RechargeModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function RechargeModule:updateRechargeInfo()
    self._view:updateRechargeInfo()
end