
EquipSoulModule = class("EquipSoulModule", BasicModule)

function EquipSoulModule:ctor()
    EquipSoulModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function EquipSoulModule:initRequire()
    require("modules.equipSoul.event.EquipSoulEvent")
    require("modules.equipSoul.view.EquipSoulView")
end

function EquipSoulModule:finalize()
    EquipSoulModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EquipSoulModule:initModule()
    EquipSoulModule.super.initModule(self)
    self._view = EquipSoulView.new(self.parent)

    self:addEventHandler()
end

function EquipSoulModule:addEventHandler()
    self._view:addEventListener(EquipSoulEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EquipSoulEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_IMG_VIEW, self, self.updateView)
    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_EQUIP_VIEW, self, self.resetView)
end

function EquipSoulModule:removeEventHander()
    self._view:removeEventListener(EquipSoulEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EquipSoulEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_IMG_VIEW, self, self.updateView)
    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_EQUIP_VIEW, self, self.resetView)
end

function EquipSoulModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function EquipSoulModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function EquipSoulModule:updateView(data)
    self._view:updateView(data)
end

function EquipSoulModule:resetView()
    self._view:resetView()
end