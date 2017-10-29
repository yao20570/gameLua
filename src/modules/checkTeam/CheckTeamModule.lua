
CheckTeamModule = class("CheckTeamModule", BasicModule)

function CheckTeamModule:ctor()
    CheckTeamModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    self:initRequire()
end

function CheckTeamModule:initRequire()
    require("modules.checkTeam.event.CheckTeamEvent")
    require("modules.checkTeam.view.CheckTeamView")
end

function CheckTeamModule:finalize()
    CheckTeamModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CheckTeamModule:initModule()
    CheckTeamModule.super.initModule(self)
    self._view = CheckTeamView.new(self.parent)

    self:addEventHandler()
end

function CheckTeamModule:addEventHandler()
    self._view:addEventListener(CheckTeamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CheckTeamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function CheckTeamModule:removeEventHander()
    self._view:removeEventListener(CheckTeamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CheckTeamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function CheckTeamModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function CheckTeamModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end