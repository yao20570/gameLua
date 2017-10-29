-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TellTheWorldModule = class("TellTheWorldModule", BasicModule)

function TellTheWorldModule:ctor()
    TellTheWorldModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function TellTheWorldModule:initRequire()
    require("modules.tellTheWorld.event.TellTheWorldEvent")
    require("modules.tellTheWorld.view.TellTheWorldView")
end

function TellTheWorldModule:finalize()
    TellTheWorldModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function TellTheWorldModule:initModule()
    TellTheWorldModule.super.initModule(self)
    self._view = TellTheWorldView.new(self.parent)

    self:addEventHandler()

    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_TOP)
end

function TellTheWorldModule:addEventHandler()
    self._view:addEventListener(TellTheWorldEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TellTheWorldEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function TellTheWorldModule:removeEventHander()
    self._view:removeEventListener(TellTheWorldEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TellTheWorldEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function TellTheWorldModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function TellTheWorldModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end