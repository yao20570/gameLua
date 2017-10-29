-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-20
--  * @Description: 雄狮轮盘
--  */
LionTurntableModule = class("LionTurntableModule", BasicModule)

function LionTurntableModule:ctor()
    LionTurntableModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LionTurntableModule:initRequire()
    require("modules.lionTurntable.event.LionTurntableEvent")
    require("modules.lionTurntable.view.LionTurntableView")
end

function LionTurntableModule:finalize()
    LionTurntableModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LionTurntableModule:initModule()
    LionTurntableModule.super.initModule(self)
    self._view = LionTurntableView.new(self.parent)

    self:addEventHandler()
end

function LionTurntableModule:addEventHandler()
    self._view:addEventListener(LionTurntableEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LionTurntableEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LIONTURN_CONSCRIPT, self, self.afterConscript)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_LIONTURNINFO, self, self.updateLionTurnView)
end

function LionTurntableModule:removeEventHander()
    self._view:removeEventListener(LionTurntableEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LionTurntableEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LIONTURN_CONSCRIPT, self, self.afterConscript)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_LIONTURNINFO, self, self.updateLionTurnView)
end

function LionTurntableModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LionTurntableModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LionTurntableModule:afterConscript(data)
    self._view:afterConscript(data)
end
function LionTurntableModule:updateLionTurnView()
    self._view:updateLionTurnView()
end
