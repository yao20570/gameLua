
OpenServerGiftModule = class("OpenServerGiftModule", BasicModule)

function OpenServerGiftModule:ctor()
    OpenServerGiftModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.left

    self.isFirstDelayAction = true

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function OpenServerGiftModule:initRequire()
    require("modules.openServerGift.event.OpenServerGiftEvent")
    require("modules.openServerGift.view.OpenServerGiftView")
end

function OpenServerGiftModule:finalize()
    OpenServerGiftModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function OpenServerGiftModule:initModule()
    OpenServerGiftModule.super.initModule(self)
    self._view = OpenServerGiftView.new(self.parent)

    self:addEventHandler()
end

function OpenServerGiftModule:addEventHandler()
    self._view:addEventListener(OpenServerGiftEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(OpenServerGiftEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(OpenServerGiftEvent.SHOW_ALLVIEW_EVENT_REQ, self, self.updaOpenServerGiftViewReq)
    self:addProxyEventListener(GameProxys.Role,AppEvent.PROXY_OPENSERVERGIFT_INFO_UPDATE, self, self.updaOpenServerGiftViewResp)
end

function OpenServerGiftModule:removeEventHander()
    self._view:removeEventListener(OpenServerGiftEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(OpenServerGiftEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(OpenServerGiftEvent.SHOW_ALLVIEW_EVENT_REQ, self, self.updaOpenServerGiftViewReq)
    self:removeProxyEventListener(GameProxys.Role,AppEvent.PROXY_OPENSERVERGIFT_INFO_UPDATE, self, self.updaOpenServerGiftViewResp)
end

function OpenServerGiftModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function OpenServerGiftModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function OpenServerGiftModule:updaOpenServerGiftViewReq(data) --请求协议
    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:onTriggerNet20015Req(data)
end

function OpenServerGiftModule:updaOpenServerGiftViewResp(data)   --显示的所有信息
    self._view:updaOpenServerGiftView(data)
end
