-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-09
--  * @Description: 限时活动_同盟致富
--  */
LegionRichModule = class("LegionRichModule", BasicModule)

function LegionRichModule:ctor()
    LegionRichModule .super.ctor(self)
        self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionRichModule:initRequire()
    require("modules.legionRich.event.LegionRichEvent")
    require("modules.legionRich.view.LegionRichView")
end

function LegionRichModule:finalize()
    LegionRichModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionRichModule:initModule()
    LegionRichModule.super.initModule(self)
    self._view = LegionRichView.new(self.parent)

    self:addEventHandler()
end

function LegionRichModule:addEventHandler()
    self._view:addEventListener(LegionRichEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionRichEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --230056
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_UPDATE_VIEW, self, self.updateView)
    --前往世界
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_GOTOWORLD, self, self.gotoWorld)
    --230054
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_UPDATE_MEMBERVIEW, self, self.updateMemberView) 
    --不符合活动条件关闭模块
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_CLOSE_MODULE, self, self.closeLegionRichModule) 
    
end

function LegionRichModule:removeEventHander()
    self._view:removeEventListener(LegionRichEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionRichEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_UPDATE_VIEW, self, self.updateView)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_GOTOWORLD, self, self.gotoWorld)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_UPDATE_MEMBERVIEW, self, self.updateMemberView) 
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_LEGIONRICH_CLOSE_MODULE, self, self.closeLegionRichModule) 
end

function LegionRichModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionRichModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionRichModule:updateView(data)
    self._view:updateView(data)
end
function LegionRichModule:updateMemberView(data)
    self._view:updateMemberView(data)
end

function LegionRichModule:gotoWorld(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.LegionRichModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ActivityCenterModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MapModule})

end
function LegionRichModule:onHideModule()
    TimerManager:remove(self.updateRankDataReq, self)
end
function LegionRichModule:onOpenModule(extraMsg)
    LegionRichModule.super.onOpenModule(self)
    self:updateRankDataReq()
    TimerManager:add(300000, self.updateRankDataReq, self,-1) 
end
function LegionRichModule:updateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityData.activityId
    proxy:onTriggerNet230019Req({activityid = id})
end

function LegionRichModule:closeLegionRichModule(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.LegionRichModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ActivityCenterModule})
end
