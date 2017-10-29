
VipBoxModule = class("VipBoxModule", BasicModule)

function VipBoxModule:ctor()
    VipBoxModule.super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.RIGHT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function VipBoxModule:initRequire()
    require("modules.vipBox.event.VipBoxEvent")
    require("modules.vipBox.view.VipBoxView")
end

function VipBoxModule:finalize()
    VipBoxModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function VipBoxModule:initModule()
    VipBoxModule.super.initModule(self)
    self._view = VipBoxView.new(self.parent)

    self.showActionType = ModuleShowType.LEFT
    self:addEventHandler()
end

function VipBoxModule:onOpenModule()
    VipBoxModule.super.onOpenModule(self)
    --self._view:openPanel()
end
function VipBoxModule:addEventHandler()
    self._view:addEventListener(VipBoxEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    -- self._view:addEventListener(TigerMachineEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self._view:addEventListener(TigerMachineEvent.SHOW_ALL_PANEL_EVENT_REQ, self, self.updatePanelReq)
    self:addProxyEventListener(GameProxys.VIPBox, AppEvent.PROXY_UPDATE_VIPBOXVIEW, self, self.updatePanelResp)
end

function VipBoxModule:removeEventHander()
    self._view:removeEventListener(VipBoxEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    -- self._view:removeEventListener(TigerMachineEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self._view:removeEventListener(TigerMachineEvent.SHOW_ALL_PANEL_EVENT_REQ, self, self.updatePanelReq)
    self:removeProxyEventListener(GameProxys.VIPBox, AppEvent.PROXY_UPDATE_VIPBOXVIEW, self, self.updatePanelResp)
end

function VipBoxModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function VipBoxModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function VipBoxModule:updatePanelResp() --收到
    self._view:updatePanelResp()
end