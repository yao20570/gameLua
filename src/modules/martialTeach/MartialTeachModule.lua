-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-23
--  * @Description: 武学讲堂
--  */
MartialTeachModule = class("MartialTeachModule", BasicModule)

function MartialTeachModule:ctor()
    MartialTeachModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function MartialTeachModule:initRequire()
    require("modules.martialTeach.event.MartialTeachEvent")
    require("modules.martialTeach.view.MartialTeachView")
end

function MartialTeachModule:finalize()
    MartialTeachModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function MartialTeachModule:initModule()
    MartialTeachModule.super.initModule(self)
    self._view = MartialTeachView.new(self.parent)

    self:addEventHandler()
end

function MartialTeachModule:addEventHandler()
    self._view:addEventListener(MartialTeachEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(MartialTeachEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --武学讲堂信息变更通知
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_MARTIALINFO, self, self.updateMartialinfo)
    --230019排行榜数据
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTIVITY_RANK, self, self.updateRankData)
    --230032学习成果通知特效与刷新页面
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_AFTER_MARTIALLEARN, self, self.afterMartiallearn)


end

function MartialTeachModule:removeEventHander()
    self._view:removeEventListener(MartialTeachEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(MartialTeachEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_MARTIALINFO, self, self.updateMartialinfo)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTIVITY_RANK, self, self.updateRankData)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_AFTER_MARTIALLEARN, self, self.afterMartiallearn)
end

function MartialTeachModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function MartialTeachModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function MartialTeachModule:onOpenModule(extraMsg)
    MartialTeachModule.super.onOpenModule(self)
    self:updateRankDataReq()
    TimerManager:add(300000, self.updateRankDataReq, self,-1) 
end

function MartialTeachModule:updateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityData.activityId
    proxy:onTriggerNet230019Req({activityid = id})
end

function MartialTeachModule:onHideModule()
    TimerManager:remove(self.updateRankDataReq, self)
end

function MartialTeachModule:updateMartialinfo()
    self._view:updateMartialinfo()
end
function MartialTeachModule:updateRankData()
    self._view:updateRankData()
end
function MartialTeachModule:afterMartiallearn(rewardList)
    self._view:afterMartiallearn(rewardList)
end


