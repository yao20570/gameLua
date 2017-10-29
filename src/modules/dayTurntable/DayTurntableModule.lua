
DayTurntableModule = class("DayTurntableModule", BasicModule)

function DayTurntableModule:ctor()
    DayTurntableModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function DayTurntableModule:initRequire()
    require("modules.dayTurntable.event.DayTurntableEvent")
    require("modules.dayTurntable.view.DayTurntableView")
end

function DayTurntableModule:finalize()
    DayTurntableModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function DayTurntableModule:initModule()
    DayTurntableModule.super.initModule(self)
    self._view = DayTurntableView.new(self.parent)

    self:addEventHandler()
end

function DayTurntableModule:addEventHandler()
    self._view:addEventListener(DayTurntableEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(DayTurntableEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ZPVIEW, self, self.updateView)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_RESET_TTDATA, self, self.resetView)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_UPDATERANKDATA, self, self.updateRankData)
end

function DayTurntableModule:removeEventHander()
    self._view:removeEventListener(DayTurntableEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(DayTurntableEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ZPVIEW, self, self.updateView)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_RESET_TTDATA, self, self.resetView)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_UPDATERANKDATA, self, self.updateRankData)
end

function DayTurntableModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function DayTurntableModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function DayTurntableModule:updateRankData()
    self._view:updateRankData()
end

function DayTurntableModule:updateView(data)
    self._view:updateView(data)
end

function DayTurntableModule:resetView()
    self._view:resetView()
end

function DayTurntableModule:onOpenModule(extraMsg)
    DayTurntableModule.super.onOpenModule(self)
    self:updateRankDataReq()
    TimerManager:add(300000, self.updateRankDataReq, self, -1) 
end

function DayTurntableModule:updateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityData.activityId
    proxy:onTriggerNet230019Req({activityid = id})
end

function DayTurntableModule:onHideModule()
    TimerManager:remove(self.updateRankDataReq, self)
end