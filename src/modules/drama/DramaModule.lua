
DramaModule = class("DramaModule", BasicModule)

function DramaModule:ctor()
    DramaModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_POP_LAYER
    self.isFullScreen = false
    
    self:initRequire()
end

function DramaModule:initRequire()
    require("modules.drama.event.DramaEvent")
    require("modules.drama.view.DramaView")
end

function DramaModule:finalize()
    DramaModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function DramaModule:initModule()
    DramaModule.super.initModule(self)
    self._view = DramaView.new(self.parent)

    self:addEventHandler()

    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_SEC_TOP + 10000)

    AudioManager:playWorldMusic()
end

function DramaModule:addEventHandler()
    self._view:addEventListener(DramaEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(DramaEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(DramaEvent.FINALIZE_SELF_EVENT, self, self.onFinalizeHandler)
end

function DramaModule:removeEventHander()
    self._view:removeEventListener(DramaEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(DramaEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function DramaModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function DramaModule:onFinalizeHandler()

--    local data = {} --剧情结束了， 弹出创建角色模块
--    data["moduleName"] = ModuleName.CreateRoleModule
--    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_FINALIZE_EVENT, {moduleName = self.name})

    
end

function DramaModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end