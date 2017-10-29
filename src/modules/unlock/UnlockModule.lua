
UnlockModule = class("UnlockModule", BasicModule)

function UnlockModule:ctor()
    UnlockModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    
    self.isFullScreen = false

    self:initRequire()
end

function UnlockModule:initRequire()
    require("modules.unlock.event.UnlockEvent")
    require("modules.unlock.view.UnlockView")
end

function UnlockModule:finalize()
    UnlockModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function UnlockModule:initModule()
    UnlockModule.super.initModule(self)
    self._view = UnlockView.new(self.parent)

    self:addEventHandler()

    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_SEC_TOP + 1)
end

function UnlockModule:addEventHandler()
    self._view:addEventListener(UnlockEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(UnlockEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function UnlockModule:removeEventHander()
    self._view:removeEventListener(UnlockEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(UnlockEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function UnlockModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function UnlockModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end