------------------------军械神将模块-----------------------
PartsGodModule = class("PartsGodModule", BasicModule)

function PartsGodModule:ctor()
    PartsGodModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function PartsGodModule:initRequire()
    require("modules.partsGod.event.PartsGodEvent")
    require("modules.partsGod.view.PartsGodView")
end

function PartsGodModule:finalize()
    PartsGodModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PartsGodModule:initModule()
    PartsGodModule.super.initModule(self)
    self._view = PartsGodView.new(self.parent)

    self:addEventHandler()
end

function PartsGodModule:addEventHandler()
    self._view:addEventListener(PartsGodEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PartsGodEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:addEventListener(PartsGodEvent.PERSON_INFO_REQ, self, self.onGetPersonInfoReq)
    self._view:addEventListener(PartsGodEvent.PARTS_CREATE_REQ, self, self.onPartsCreateReq)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_GETREWARD, self, self.onGetRewardResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_SETFREE, self, self.onSetPartsGodFree)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_UPDATERANKDATA, self, self.onUpdateRankData)
end

function PartsGodModule:removeEventHander()
    self._view:removeEventListener(PartsGodEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PartsGodEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:removeEventListener(PartsGodEvent.PERSON_INFO_REQ, self, self.onGetPersonInfoReq)
    self._view:removeEventListener(PartsGodEvent.PARTS_CREATE_REQ, self, self.onPartsCreateReq)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_GETREWARD, self, self.onGetRewardResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_SETFREE, self, self.onSetPartsGodFree)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_PARTSGOD_UPDATERANKDATA, self, self.onUpdateRankData)
end

function PartsGodModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PartsGodModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function PartsGodModule:onOpenModule(extraMsg)
    PartsGodModule.super.onOpenModule(self)
    local activityId
    
    if type(extraMsg) == type({}) and extraMsg.activityId ~= nil then
        activityId = extraMsg.activityId
    else
        local proxy = self:getProxy(GameProxys.Activity)
        local info = proxy:getCurActivityData()
        activityId = info.activityId
    end
    
    self._view:setActivityId(activityId)
    self._activityId = activityId
    self:onUpdateRankDataReq()
    TimerManager:add(300000, self.onUpdateRankDataReq, self, -1)  --5分钟刷新一下数据
end

function PartsGodModule:onUpdateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    proxy:onTriggerNet230019Req({activityid = self._activityId})
end

function PartsGodModule:onHideModule()
    TimerManager:remove(self.onUpdateRankDataReq, self)
end

function PartsGodModule:onGetRewardResp(data)
    self._view:onGetRewardResp(data)
end

function PartsGodModule:onGetPersonInfoReq(data)
    local proxy = self:getProxy(GameProxys.Activity)
    proxy:onTriggerNet140001Req(data)
end

function PartsGodModule:onChatPersonInfoResp(data)
    if data.rs == 0 then
        self._view:onChatPersonInfoResp(data)
    end
end

function PartsGodModule:onPartsCreateReq(data)
    local proxy = self:getProxy(GameProxys.Activity)
    proxy:onTriggerNet230017Req(data)
end

function PartsGodModule:onSetPartsGodFree()
    self._view:onSetPartsGodFree()
end

function PartsGodModule:onUpdateRankData()
    self._view:onUpdateRankData()
end