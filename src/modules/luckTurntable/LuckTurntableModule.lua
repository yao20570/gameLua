-- /**
--  * @Author:    
--  * @DateTime:    2017-07-10 00:00:00
--  * @Description: прткбжел
--  */
LuckTurntableModule = class("LuckTurntableModule", BasicModule)

function LuckTurntableModule:ctor()
    LuckTurntableModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LuckTurntableModule:initRequire()
    require("modules.luckTurntable.event.LuckTurntableEvent")
    require("modules.luckTurntable.view.LuckTurntableView")
end

function LuckTurntableModule:finalize()
    LuckTurntableModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LuckTurntableModule:initModule()
    LuckTurntableModule.super.initModule(self)
    self._view = LuckTurntableView.new(self.parent)

    self:addEventHandler()
end

function LuckTurntableModule:addEventHandler()
    self._view:addEventListener(LuckTurntableEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LuckTurntableEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.LuckTurntable, AppEvent.PROXY_UPDATE_LUCK_TURNTABLE_INFO, self, self.updateLuckTurntableInfo)
end

function LuckTurntableModule:removeEventHander()
    self._view:removeEventListener(LuckTurntableEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LuckTurntableEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.LuckTurntable, AppEvent.PROXY_UPDATE_LUCK_TURNTABLE_INFO, self, self.updateLuckTurntableInfo)
end

function LuckTurntableModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LuckTurntableModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LuckTurntableModule:updateLuckTurntableInfo(data)
    self._view:updateLuckTurntableInfo(data)
end