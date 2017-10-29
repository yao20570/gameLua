-- /**
--  * @Author:      wzy
--  * @DateTime:    2017-02-05 00:00:00
--  * @Description: 礼贤下士活动
--  */
ConsortModule = class("ConsortModule", BasicModule)

function ConsortModule:ctor()
    ConsortModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function ConsortModule:initRequire()
    require("modules.consort.event.ConsortEvent")
    require("modules.consort.view.ConsortView")
end

function ConsortModule:finalize()
    ConsortModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ConsortModule:initModule()
    ConsortModule.super.initModule(self)
    self._view = ConsortView.new(self.parent)

    self:addEventHandler()
end

function ConsortModule:addEventHandler()
    self._view:addEventListener(ConsortEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ConsortEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Consort, AppEvent.PROXY_UPDATE_ACTIVITY_RANK, self, self.updateConsortRank)
    self:addProxyEventListener(GameProxys.Consort, AppEvent.PROXY_UPDATE_CONSORT_INFO, self, self.updateConsortInfo)  
    self:addProxyEventListener(GameProxys.Consort, AppEvent.PROXY_PLAY_CONSORT_ANIMA, self, self.playConsortAnima)  
      

end

function ConsortModule:removeEventHander()
    self._view:removeEventListener(ConsortEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ConsortEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
  
    self:removeProxyEventListener(GameProxys.Consort, AppEvent.PROXY_UPDATE_ACTIVITY_RANK, self, self.updateConsortRank)
    self:removeProxyEventListener(GameProxys.Consort, AppEvent.PROXY_UPDATE_CONSORT_INFO, self, self.updateConsortInfo) 
    self:removeProxyEventListener(GameProxys.Consort, AppEvent.PROXY_PLAY_CONSORT_ANIMA, self, self.playConsortAnima)   
end

function ConsortModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ConsortModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ConsortModule:onOpenModule(extraMsg)
    ConsortModule.super.onOpenModule(self)

    self:reqRankData()
    TimerManager:add(300000, self.reqRankData, self, -1) 
end

function ConsortModule:reqRankData()     
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityData.activityId
    proxy:onTriggerNet230019Req({activityid = id})
end
function ConsortModule:onHideModule()
    TimerManager:remove(self.reqRankData, self)
end

function ConsortModule:updateConsortInfo(data)
    self._view:updateConsortInfo(data)
end

function ConsortModule:updateConsortRank(data)
    self._view:updateConsortRank(data)
end 

function ConsortModule:playConsortAnima(data)
    self._view:playConsortAnima(data)
end