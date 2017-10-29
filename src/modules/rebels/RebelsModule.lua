-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-11-29 16:06:00
--  * @Description: 消灭叛军
--  */
RebelsModule = class("RebelsModule", BasicModule)

function RebelsModule:ctor()
    RebelsModule.super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil

    self:initRequire()
end

function RebelsModule:initRequire()

    require("modules.rebels.event.RebelsEvent")
    require("modules.rebels.view.RebelsView")
end

function RebelsModule:finalize()
    RebelsModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RebelsModule:initModule()
    RebelsModule.super.initModule(self)
    self._view = RebelsView.new(self.parent)

    self:addEventHandler()
end

function RebelsModule:addEventHandler()
    self._view:addEventListener(RebelsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RebelsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_ACTIVITY_INFO, self, self.onActivityInfo)    
    self:addProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_RANK_UPDATE, self, self.onRebelsRankUpdate)
    self:addProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REDPOINT_UPDATE, self, self.onRebelsRewardUpdate)
    self:addProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_OPEN_MAP_AND_JUMP_TO_TILE, self, self.onGoToMap) 
end

function RebelsModule:removeEventHander()
    self._view:removeEventListener(RebelsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RebelsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_ACTIVITY_INFO, self, self.onActivityInfo)
    self:removeProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_RANK_UPDATE, self, self.onRebelsRankUpdate)
    self:removeProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REDPOINT_UPDATE, self, self.onRebelsRewardUpdate)
    self:removeProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_OPEN_MAP_AND_JUMP_TO_TILE, self, self.onGoToMap) 
end

-- 每次open都走这条
function RebelsModule:onOpenModule()
    RebelsModule.super.onOpenModule(self)
        
    self._view:updateRedPointCount()
end


function RebelsModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = self.name })
end

function RebelsModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, { moduleName = moduleName })
end

function RebelsModule:isCanShow(data)
    local rebelsProxy = self:getProxy(GameProxys.Rebels)
    local isShow = rebelsProxy:checkCanJoinRebelsActivity()
    return isShow
end

function RebelsModule:onGoToMap(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = self.name })
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ActivityCenterModule })
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ChatModule })
    self:onHideSelfHandler()
end

function RebelsModule:onActivityInfo(data)
    self._view:onActivityInfo(data)
end

function RebelsModule:onRebelsRankUpdate(data)
    self._view:onRebelsRankUpdate(data)
end 

function RebelsModule:onRebelsRewardUpdate(data)
    self._view:onRebelsRewardUpdate(data)

    self._view:updateRedPointCount()
end 
