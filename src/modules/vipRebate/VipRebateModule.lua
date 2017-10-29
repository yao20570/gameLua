
VipRebateModule = class("VipRebateModule", BasicModule)

function VipRebateModule:ctor()
    VipRebateModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.RIGHT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function VipRebateModule:initRequire()
    require("modules.vipRebate.event.VipRebateEvent")
    require("modules.vipRebate.view.VipRebateView")
end

function VipRebateModule:finalize()
    VipRebateModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function VipRebateModule:initModule()
    VipRebateModule.super.initModule(self)
    self._view = VipRebateView.new(self.parent)

    self:addEventHandler()
end

function VipRebateModule:addEventHandler()
    self._view:addEventListener(VipRebateEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(VipRebateEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.VipRebate,AppEvent.PROXY_UPDATE_VIPREBATEVIEW, self, self.updatePanelResp)
end

function VipRebateModule:removeEventHander()
    self._view:removeEventListener(VipRebateEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(VipRebateEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.VipRebate,AppEvent.PROXY_UPDATE_VIPREBATEVIEW, self, self.updatePanelResp)
end

function VipRebateModule:updatePanelResp()
    self._view:updatePanelResp()
end

function VipRebateModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function VipRebateModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end