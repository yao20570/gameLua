
LegionAdviceModule = class("LegionAdviceModule", BasicModule)

function LegionAdviceModule:ctor()
    LegionAdviceModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionAdviceModule:initRequire()
    require("modules.legionAdvice.event.LegionAdviceEvent")
    require("modules.legionAdvice.view.LegionAdviceView")
end

function LegionAdviceModule:finalize()
    LegionAdviceModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionAdviceModule:initModule()
    LegionAdviceModule.super.initModule(self)
    self._view = LegionAdviceView.new(self.parent)

    self:addEventHandler()
end

function LegionAdviceModule:onOpenModule(extraMsg)
    self.super.onOpenModule(self)
    self:sendServerMessage(AppEvent.NET_M22,AppEvent.NET_M22_C220300, {})
end

function LegionAdviceModule:addEventHandler()
    self._view:addEventListener(LegionAdviceEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionAdviceEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_ADVICE_INFO_UPDATE, self, self.updateAdvice)
    
end

function LegionAdviceModule:removeEventHander()
    self._view:removeEventListener(LegionAdviceEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionAdviceEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_ADVICE_INFO_UPDATE, self, self.updateAdvice)
  
end

function LegionAdviceModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionAdviceModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionAdviceModule:updateAdvice(data)
    self._view:updateAdvice()
end