
RedPacketModule = class("RedPacketModule", BasicModule)

function RedPacketModule:ctor()
    RedPacketModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self.showActionType = ModuleShowType.LEFT

    self:initRequire()
end

function RedPacketModule:initRequire()
    require("modules.redPacket.event.RedPacketEvent")
    require("modules.redPacket.view.RedPacketView")
end

function RedPacketModule:finalize()
    RedPacketModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RedPacketModule:initModule()
    RedPacketModule.super.initModule(self)
    self._view = RedPacketView.new(self.parent)

    self:addEventHandler()
end

function RedPacketModule:addEventHandler()
    self._view:addEventListener(RedPacketEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RedPacketEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW, self, self.updateView)
    
end

function RedPacketModule:removeEventHander()
    self._view:removeEventListener(RedPacketEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RedPacketEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW, self, self.updateView)
    
end

function RedPacketModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RedPacketModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function RedPacketModule:updateView(data)
    self._view:updateView(data)
end