
GeneralAndSoldierModule = class("GeneralAndSoldierModule", BasicModule)

function GeneralAndSoldierModule:ctor()
    GeneralAndSoldierModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self:initRequire()
end

function GeneralAndSoldierModule:initRequire()
    require("modules.generalAndSoldier.event.GeneralAndSoldierEvent")
    require("modules.generalAndSoldier.view.GeneralAndSoldierView")
end

function GeneralAndSoldierModule:finalize()
    GeneralAndSoldierModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function GeneralAndSoldierModule:initModule()
    GeneralAndSoldierModule.super.initModule(self)
    self._view = GeneralAndSoldierView.new(self.parent)

    self:addEventHandler()
end

function GeneralAndSoldierModule:addEventHandler()
    self._view:addEventListener(GeneralAndSoldierEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(GeneralAndSoldierEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230024, self, self.getRecruitRsp)
    self:addEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230025, self, self.getTrainRsp)
end

function GeneralAndSoldierModule:removeEventHander()
    self._view:removeEventListener(GeneralAndSoldierEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(GeneralAndSoldierEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230024, self, self.getRecruitRsp)
    self:removeEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230025, self, self.getTrainRsp)
end

function GeneralAndSoldierModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function GeneralAndSoldierModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function GeneralAndSoldierModule:getRecruitRsp(data)
    self._view:getRecruitRsp(data)
end

function GeneralAndSoldierModule:getTrainRsp(data)
    self._view:getTrainRsp(data)
end