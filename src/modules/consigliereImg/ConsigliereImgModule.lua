
ConsigliereImgModule = class("ConsigliereImgModule", BasicModule)

function ConsigliereImgModule:ctor()
    ConsigliereImgModule.super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self:initRequire()
end

function ConsigliereImgModule:initRequire()
    require("modules.consigliereImg.event.ConsigliereImgEvent")
    require("modules.consigliereImg.view.ConsigliereImgView")
end

function ConsigliereImgModule:finalize()
    ConsigliereImgModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ConsigliereImgModule:initModule()
    ConsigliereImgModule.super.initModule(self)
    self._view = ConsigliereImgView.new(self.parent)

    self:addEventHandler()
end

function ConsigliereImgModule:addEventHandler()
    self._view:addEventListener(ConsigliereImgEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ConsigliereImgEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function ConsigliereImgModule:removeEventHander()
    self._view:removeEventListener(ConsigliereImgEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ConsigliereImgEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function ConsigliereImgModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ConsigliereImgModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end