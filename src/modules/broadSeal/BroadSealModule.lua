-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-06
--  * @Description: 限时活动-国之重器
--  */
BroadSealModule = class("BroadSealModule", BasicModule)

function BroadSealModule:ctor()
    BroadSealModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function BroadSealModule:initRequire()
    require("modules.broadSeal.event.BroadSealEvent")
    require("modules.broadSeal.view.BroadSealView")
end

function BroadSealModule:finalize()
    BroadSealModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function BroadSealModule:initModule()
    BroadSealModule.super.initModule(self)
    self._view = BroadSealView.new(self.parent)

    self:addEventHandler()
end

function BroadSealModule:addEventHandler()
    self._view:addEventListener(BroadSealEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(BroadSealEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --国之重器信息变更通知
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_BROADSEALINFO, self, self.updateBroadSealInfo)
    --230042国之重器收集后通知特效
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_BROADSEAL_COLLECT, self, self.afterCollect)
    --230044国之重器组装后通知特效
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_BROADSEAL_COMPOSE, self, self.afterCompose)



end

function BroadSealModule:removeEventHander()
    self._view:removeEventListener(BroadSealEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(BroadSealEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_BROADSEALINFO, self, self.updateBroadSealInfo)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_BROADSEAL_COLLECT, self, self.afterCollect)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_BROADSEAL_COMPOSE, self, self.afterCompose)
end

function BroadSealModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function BroadSealModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function BroadSealModule:updateBroadSealInfo()
    self._view:updateBroadSealInfo()
end
function BroadSealModule:afterCollect(infoTable)
    self._view:afterCollect(infoTable)
end
function BroadSealModule:afterCompose(rewardList)
    self._view:afterCompose(rewardList)
end



