-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionTaskModule = class("LegionTaskModule", BasicModule)

function LegionTaskModule:ctor()
    LegionTaskModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.isFullScreen = true
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionTaskModule:initRequire()
    require("modules.legionTask.event.LegionTaskEvent")
    require("modules.legionTask.view.LegionTaskView")
end

function LegionTaskModule:finalize()
    LegionTaskModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionTaskModule:initModule()
    LegionTaskModule.super.initModule(self)
    self._view = LegionTaskView.new(self.parent)

    self:addEventHandler()
end

function LegionTaskModule:addEventHandler()
    self._view:addEventListener(LegionTaskEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionTaskEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_TASKINFO_UPDATE, self, self.updateLegionTaskInfo) 
end

function LegionTaskModule:removeEventHander()
    self._view:removeEventListener(LegionTaskEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionTaskEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_TASKINFO_UPDATE, self, self.updateLegionTaskInfo)
end

function LegionTaskModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionTaskModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionTaskModule:updateLegionTaskInfo()
    self._view:updateLegionTaskInfo()
end 