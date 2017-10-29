--------created by zhangfan in 2016-08-12
--------群雄涿鹿排行榜模块
WarlordsRankModule = class("WarlordsRankModule", BasicModule)

function WarlordsRankModule:ctor()
    WarlordsRankModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function WarlordsRankModule:initRequire()
    require("modules.warlordsRank.event.WarlordsRankEvent")
    require("modules.warlordsRank.view.WarlordsRankView")
end

function WarlordsRankModule:finalize()
    WarlordsRankModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function WarlordsRankModule:initModule()
    WarlordsRankModule.super.initModule(self)
    self._view = WarlordsRankView.new(self.parent)
    self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
    self._actId = self._battleActivityProxy:onGetWorloardsActId()
    self:addEventHandler()
end

function WarlordsRankModule:addEventHandler()
    self._view:addEventListener(WarlordsRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(WarlordsRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WINSRANKMEMBERS, self, self.onGetWinsRankInfos)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WINSRANKLEGIONS, self, self.onGetWinsRankLegionInfos)
end

function WarlordsRankModule:removeEventHander()
    self._view:removeEventListener(WarlordsRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(WarlordsRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WINSRANKMEMBERS, self, self.onGetWinsRankInfos)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WINSRANKLEGIONS, self, self.onGetWinsRankLegionInfos)
end

function WarlordsRankModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function WarlordsRankModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function WarlordsRankModule:onOpenModule(extraMsg)
    WarlordsRankModule.super.onOpenModule(self)
    --self._battleActivityProxy:onTriggerNet330007Req({activityId = self._actId})
    self._view:onOpenModule()
    --TimerManager:addOnce(500,function() self._battleActivityProxy:onTriggerNet330008Req({activityId = self._actId}) end,self)
end

function WarlordsRankModule:onGetWinsRankInfos(data)
    self._view:onGetWinsRankInfos(data)
end

function WarlordsRankModule:onGetWinsRankLegionInfos(data)
    self._view:onGetWinsRankLegionInfos(data)
end