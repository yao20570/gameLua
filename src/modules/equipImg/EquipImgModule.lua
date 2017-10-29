
EquipImgModule = class("EquipImgModule", BasicModule)

function EquipImgModule:ctor()
    EquipImgModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function EquipImgModule:initRequire()
    require("modules.equipImg.event.EquipImgEvent")
    require("modules.equipImg.view.EquipImgView")
end

function EquipImgModule:finalize()
    EquipImgModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EquipImgModule:initModule()
    EquipImgModule.super.initModule(self)
    self._view = EquipImgView.new(self.parent)

    self:addEventHandler()
end

function EquipImgModule:addEventHandler()
    self._view:addEventListener(EquipImgEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EquipImgEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_IMG_VIEW, self, self.updateView)
end

function EquipImgModule:removeEventHander()
    self._view:removeEventListener(EquipImgEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EquipImgEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_IMG_VIEW, self, self.updateView)
end

function EquipImgModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function EquipImgModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function EquipImgModule:updateView()
    self._view:updateView(true)
end