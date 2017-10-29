-- /**
--  * @Author:    luzhuojian
--  * @DateTime:    2017-01-06
--  * @Description: 限时活动 煮酒论英雄
--  */
CookingWineModule = class("CookingWineModule", BasicModule)

function CookingWineModule:ctor()
    CookingWineModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function CookingWineModule:initRequire()
    require("modules.cookingWine.event.CookingWineEvent")
    require("modules.cookingWine.view.CookingWineView")
end

function CookingWineModule:finalize()
    CookingWineModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CookingWineModule:initModule()
    CookingWineModule.super.initModule(self)
    self._view = CookingWineView.new(self.parent)

    self:addEventHandler()
end

function CookingWineModule:addEventHandler()
    self._view:addEventListener(CookingWineEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CookingWineEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --煮酒论英雄信息变更通知
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_COOKINFO, self, self.updateCookInfo)
    --更换英雄成功关闭选择面板
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_CLOSE_COOKSELECTPANEL, self, self.closeCookselectPanel)
    --230034通知特效
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_AFTER_TOAST, self, self.afterToast)


end

function CookingWineModule:removeEventHander()
    self._view:removeEventListener(CookingWineEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CookingWineEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_COOKINFO, self, self.updateCookInfo)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_CLOSE_COOKSELECTPANEL, self, self.closeCookselectPanel)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_AFTER_TOAST, self, self.afterToast)
end

function CookingWineModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function CookingWineModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function CookingWineModule:updateCookInfo()
    self._view:updateCookInfo()
end
function CookingWineModule:closeCookselectPanel()
    self._view:closeCookselectPanel()
end
function CookingWineModule:onOpenModule(extraMsg)
    CookingWineModule.super.onOpenModule(self)
    self:updateRankDataReq()
    TimerManager:add(300000, self.updateRankDataReq, self,-1) 
end

function CookingWineModule:updateRankDataReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    local id = proxy.curActivityData.activityId
    proxy:onTriggerNet230019Req({activityid = id})
end

function CookingWineModule:onHideModule()
    TimerManager:remove(self.updateRankDataReq, self)
end
function CookingWineModule:afterToast(effectData)
    self._view:afterToast(effectData)
end

