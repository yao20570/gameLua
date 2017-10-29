
RankModule = class("RankModule", BasicModule)

function RankModule:ctor()
    RankModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER    
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil

    self.isFirstDelayAction = true
    
    self:initRequire()
end

function RankModule:initRequire()
    require("modules.rank.event.RankEvent")
    require("modules.rank.view.RankView")
end

function RankModule:finalize()
    RankModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RankModule:initModule()
    RankModule.super.initModule(self)
    self._view = RankView.new(self.parent)

    self:addEventHandler()
end

function RankModule:addEventHandler()
    self._view:addEventListener(RankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onPlayerInfoResp)
    self:addProxyEventListener(GameProxys.Rank, AppEvent.PROXY_RANK_INFO_UPDATE, self, self.updateRankHandler)
    self:addProxyEventListener(GameProxys.Rank, AppEvent.PROXY_RESRANK_INFO_UPDATE, self, self.updateRankHandler)

end

function RankModule:removeEventHander()
    self._view:removeEventListener(RankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onPlayerInfoResp)
    self:removeProxyEventListener(GameProxys.Rank, AppEvent.PROXY_RANK_INFO_UPDATE, self, self.updateRankHandler)
    self:removeProxyEventListener(GameProxys.Rank, AppEvent.PROXY_RESRANK_INFO_UPDATE, self, self.updateRankHandler)
end

function RankModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RankModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function RankModule:onPlayerInfoResp(data)
    -- body
    if data.rs == 0 then
        self._view:onPlayerInfoResp(data)
    end
end

function RankModule:updateRankHandler(data)
    -- body
    self._view:updateRankHandler()
end

function RankModule:updateResRankView(data)
    -- body
    self._view:updateResRankView()
end

function RankModule:onOpenModule(extraMsg)
    RankModule.super.onOpenModule(self, extraMsg)
    self._proxy = self:getProxy(GameProxys.Rank)
    self._proxy:onTriggerNet210001Req({})
    TimerManager:add(300 * 1000, self.getRankData, self)
end

function RankModule:onHideModule()
    TimerManager:remove(self.getRankData, self)
end

function RankModule:getRankData()
    self._proxy:onTriggerNet210001Req({})
end