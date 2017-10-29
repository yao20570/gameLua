-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-22
--  * @Description: 限时活动_精绝古城
--  */
JingJueCityModule = class("JingJueCityModule", BasicModule)

function JingJueCityModule:ctor()
    JingJueCityModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function JingJueCityModule:initRequire()
    require("modules.jingJueCity.event.JingJueCityEvent")
    require("modules.jingJueCity.view.JingJueCityView")
end

function JingJueCityModule:finalize()
    JingJueCityModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function JingJueCityModule:initModule()
    JingJueCityModule.super.initModule(self)
    self._view = JingJueCityView.new(self.parent)

    self:addEventHandler()
end

function JingJueCityModule:addEventHandler()
    self._view:addEventListener(JingJueCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(JingJueCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_OPEN, self, self.afterOpen)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_OPEN_ONEPOS, self, self.afterOpenOnePos)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_UPDATE, self, self.updateJingJueView)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_OPEN_ALL, self, self.openSeverback)
end

function JingJueCityModule:removeEventHander()
    self._view:removeEventListener(JingJueCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(JingJueCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_OPEN, self, self.afterOpen)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_UPDATE, self, self.updateJingJueView)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_JINGJUECITY_OPEN_ALL, self, self.openSeverback)

end

function JingJueCityModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function JingJueCityModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function JingJueCityModule:afterOpen(data)
    self._view:afterOpen(data)
end
function JingJueCityModule:afterOpenOnePos(data)
    self._view:afterOpenOnePos(data)
end
function JingJueCityModule:updateJingJueView()
    self._view:updateJingJueView()
end
function JingJueCityModule:onOpenModule(extraMsg)
    JingJueCityModule.super.onOpenModule(self)
    self:updateRankDataReq()
    TimerManager:add(300000, self.updateRankDataReq, self,-1) 
end
function JingJueCityModule:updateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityData.activityId
    proxy:onTriggerNet230019Req({activityid = id})
end
function JingJueCityModule:onHideModule()
    TimerManager:remove(self.updateRankDataReq, self)
end
function JingJueCityModule:openSeverback()
    self._view:openSeverback()
end
