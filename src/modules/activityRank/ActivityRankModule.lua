
ActivityRankModule = class("ActivityRankModule", BasicModule)

function ActivityRankModule:ctor()
    ActivityRankModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.Animation
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function ActivityRankModule:initRequire()
    require("modules.activityRank.event.ActivityRankEvent")
    require("modules.activityRank.view.ActivityRankView")
end

function ActivityRankModule:finalize()
    ActivityRankModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ActivityRankModule:initModule()
    ActivityRankModule.super.initModule(self)
    self._view = ActivityRankView.new(self.parent)

    self:addEventHandler()
end

function ActivityRankModule:addEventHandler()
    self._view:addEventListener(ActivityRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ActivityRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTIVITY_RANK, self, self.updateView)
end

function ActivityRankModule:removeEventHander()
    self._view:removeEventListener(ActivityRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ActivityRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTIVITY_RANK, self, self.updateView)

end

function ActivityRankModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ActivityRankModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ActivityRankModule:updateView(data)
    self._view:updateView(data)
end

function ActivityRankModule:onOpenModule(extraMsg)
    ActivityRankModule.super.onOpenModule(self)
    TimerManager:add(300000, self.updateRankDataReq, self, -1) 
end

function ActivityRankModule:updateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityId
    proxy:onTriggerNet230019Req({activityid = id})
end

function ActivityRankModule:onHideModule()
    TimerManager:remove(self.updateRankDataReq, self)
end