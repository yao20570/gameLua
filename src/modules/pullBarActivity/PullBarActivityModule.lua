
PullBarActivityModule = class("PullBarActivityModule", BasicModule)

function PullBarActivityModule:ctor()
    PullBarActivityModule .super.ctor(self)
    

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function PullBarActivityModule:initRequire()
    require("modules.pullBarActivity.event.PullBarActivityEvent")
    require("modules.pullBarActivity.view.PullBarActivityView")
end

function PullBarActivityModule:finalize()
    PullBarActivityModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PullBarActivityModule:initModule()
    PullBarActivityModule.super.initModule(self)
    self._view = PullBarActivityView.new(self.parent)

    self:addEventHandler()
end

function PullBarActivityModule:addEventHandler()
    self._view:addEventListener(PullBarActivityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PullBarActivityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(PullBarActivityEvent.DRAW_EVENT_REQ, self, self.drawReq)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LABA_INFO, self, self.updateLabaInfo)
end

function PullBarActivityModule:removeEventHander()
    self._view:removeEventListener(PullBarActivityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PullBarActivityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(PullBarActivityEvent.DRAW_EVENT_REQ, self, self.drawReq)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LABA_INFO, self, self.updateLabaInfo)
end

function PullBarActivityModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PullBarActivityModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function PullBarActivityModule:updateLabaInfo(data)
    self._view:updateLabaInfo(data)
end

function PullBarActivityModule:drawReq(data)
    local activityProxy = self:getProxy(GameProxys.Activity)
    activityProxy:onTriggerNet230003Req(data)
end