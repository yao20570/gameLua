
TigerMachineModule = class("TigerMachineModule", BasicModule)

function TigerMachineModule:ctor()
    TigerMachineModule .super.ctor(self)
    
    self.isFullScreen = false
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER

    self.showActionType = ModuleShowType.RIGHT
    self.isFullScreen = false
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function TigerMachineModule:initRequire()
    require("modules.tigerMachine.event.TigerMachineEvent")
    require("modules.tigerMachine.view.TigerMachineView")
end

function TigerMachineModule:finalize()
    TigerMachineModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function TigerMachineModule:initModule()
    TigerMachineModule.super.initModule(self)
    self._view = TigerMachineView.new(self.parent)

    self:addEventHandler()
end

function TigerMachineModule:addEventHandler()
    self._view:addEventListener(TigerMachineEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TigerMachineEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(TigerMachineEvent.SHOW_ALL_PANEL_EVENT_REQ, self, self.updatePanelReq)
    self:addProxyEventListener(GameProxys.Role,AppEvent.PROXY_EVERYDAYLOGGIFT_INFO_UPDATE, self, self.updatePanelResp)
end

function TigerMachineModule:removeEventHander()
    self._view:removeEventListener(TigerMachineEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TigerMachineEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(TigerMachineEvent.SHOW_ALL_PANEL_EVENT_REQ, self, self.updatePanelReq)
    self:removeProxyEventListener(GameProxys.Role,AppEvent.PROXY_EVERYDAYLOGGIFT_INFO_UPDATE, self, self.updatePanelResp)
end

function TigerMachineModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function TigerMachineModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function TigerMachineModule:updatePanelReq(data)  --请求面板信息 抽奖
    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:onTriggerNet20016Req(data)
end
function TigerMachineModule:updatePanelResp(data) --收到
    self._view:updatePanelResp(data)
end