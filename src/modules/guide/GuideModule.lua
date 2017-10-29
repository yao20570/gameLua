
GuideModule = class("GuideModule", BasicModule)

function GuideModule:ctor()
    GuideModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self.isFullScreen = false
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function GuideModule:initRequire()
    require("modules.guide.event.GuideEvent")
    require("modules.guide.view.GuideView")
end

function GuideModule:finalize()
    GuideModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function GuideModule:initModule()
    GuideModule.super.initModule(self)
    self._view = GuideView.new(self.parent)

    self:addEventHandler()
    
    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_SEC_TOP)
end

function GuideModule:addEventHandler()
    self._view:addEventListener(GuideEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(GuideEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)
end

function GuideModule:removeEventHander()
    self._view:removeEventListener(GuideEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(GuideEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)
end

function GuideModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function GuideModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function GuideModule:onEnterScene()
    self._view:onEnterScene()
end