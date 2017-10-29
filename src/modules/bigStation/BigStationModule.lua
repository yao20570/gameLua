-- /**
--  * @Author:    fzw
--  * @DateTime:    2017-01-05 14:02:00
--  * @Description: 大军基地
--  */
BigStationModule = class("BigStationModule", BasicModule)

function BigStationModule:ctor()
    BigStationModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function BigStationModule:initRequire()
    require("modules.bigStation.event.BigStationEvent")
    require("modules.bigStation.view.BigStationView")
end

function BigStationModule:finalize()
    BigStationModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function BigStationModule:initModule()
    BigStationModule.super.initModule(self)
    self._view = BigStationView.new(self.parent)

    self:addEventHandler()
end

function BigStationModule:addEventHandler()
    self._view:addEventListener(BigStationEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(BigStationEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function BigStationModule:removeEventHander()
    self._view:removeEventListener(BigStationEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(BigStationEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function BigStationModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function BigStationModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end