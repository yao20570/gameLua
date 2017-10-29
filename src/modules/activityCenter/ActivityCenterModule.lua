
ActivityCenterModule = class("ActivityCenterModule", BasicModule)

function ActivityCenterModule:ctor()
    ActivityCenterModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    -- self.showActionType = ModuleShowType.LEFT
    self.isFullScreen = false
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function ActivityCenterModule:initRequire()
    require("modules.activityCenter.event.ActivityCenterEvent")
    require("modules.activityCenter.view.ActivityCenterView")
end

function ActivityCenterModule:finalize()
    ActivityCenterModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ActivityCenterModule:initModule()
    ActivityCenterModule.super.initModule(self)
    self._view = ActivityCenterView.new(self.parent)

    self:addEventHandler()
end

function ActivityCenterModule:setVisible(visible)
    if visible == true and self:isVisible() == false then
        self._view:updateBlurSprite()
    end
    ActivityCenterModule.super.setVisible(self, visible)
end


function ActivityCenterModule:addEventHandler()
    self._view:addEventListener(ActivityCenterEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ActivityCenterEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_REMOVE_ACT, self, self.removeActivity)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_NEW_ACT, self, self.newActivity)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW, self, self.newBattleActivity)

    self:addProxyEventListener(GameProxys.RedPoint, AppEvent.PROXY_REDPOINT_UPDATE, self, self.updateRedPoint)
   
    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_OPENWARLORDS, self, self.onOpenwarlords)

end

function ActivityCenterModule:removeEventHander()
    self._view:removeEventListener(ActivityCenterEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ActivityCenterEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_REMOVE_ACT, self, self.removeActivity)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_NEW_ACT, self, self.newActivity)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW, self, self.newBattleActivity)

    self:removeProxyEventListener(GameProxys.RedPoint, AppEvent.PROXY_REDPOINT_UPDATE, self, self.updateRedPoint)
    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_OPENWARLORDS, self, self.onOpenwarlords)
end

function ActivityCenterModule:onHideSelfHandler()
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})

    local function hideCallback()
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
        return ""
    end
    self:getPanel(ActivityCenterPanel.NAME):hide(hideCallback, self)
end

function ActivityCenterModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function ActivityCenterModule:removeActivity(data)
    logger:info("活动结束飘字")
    self._view:updateActCount(true)
    local proxy = self:getProxy(GameProxys.Activity)
    for k,v in pairs(data) do
        local name = proxy:getModuleData(v)
        -- print()
        if name then
            self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = name})
            proxy.moduleName[v] = nil
        end
    end
end

function ActivityCenterModule:newActivity()
    self._view:updateActCount()
end

function ActivityCenterModule:newBattleActivity()
    self._view:newBattleActivity()
end

function ActivityCenterModule:updateRedPoint()
    self._view:updateRedPoint()
end

function ActivityCenterModule:onOpenwarlords()
    self._view:onOpenwarlords()
end