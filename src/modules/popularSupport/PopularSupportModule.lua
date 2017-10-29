
PopularSupportModule = class("PopularSupportModule", BasicModule)

function PopularSupportModule:ctor()
    PopularSupportModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    self:initRequire()
end

function PopularSupportModule:initRequire()
    require("modules.popularSupport.event.PopularSupportEvent")
    require("modules.popularSupport.view.PopularSupportView")
end

function PopularSupportModule:finalize()
    PopularSupportModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PopularSupportModule:initModule()
    PopularSupportModule.super.initModule(self)
    self._view = PopularSupportView.new(self.parent)
    self:addEventHandler()
end

function PopularSupportModule:addEventHandler()
    self._view:addEventListener(PopularSupportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PopularSupportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Role,AppEvent.POWER_VALUE_UPDATE, self, self.updateNums)
    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20600, self, self.updateRewards)
    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20601, self, self.getReward)

end

function PopularSupportModule:removeEventHander()
    self._view:removeEventListener(PopularSupportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PopularSupportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Role,AppEvent.POWER_VALUE_UPDATE, self, self.updateNums)
    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20600, self, self.updateRewards)
    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20601, self, self.getReward)

end

function PopularSupportModule:onOpenModule()
    self._view:openView()
end

function PopularSupportModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PopularSupportModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function PopularSupportModule:updateRewards(data)
    if data.rs == 0 then
        local popularSupportProxy = self:getProxy(GameProxys.PopularSupport)
        popularSupportProxy:updateSupportReward(data.supportReward)
        popularSupportProxy:addRefreshTimes()
        self._view:updatePanel(true)
        self._view:refreshAction()
    else
        self:setMask(false)  --民心刷新失败时，遮罩也得去掉
    end    
end

function PopularSupportModule:getReward(data)
    if data.rs == 0 then 
        local popularSupportProxy = self:getProxy(GameProxys.PopularSupport)
        popularSupportProxy:updateSupportGetReward(data.supportReward,data.id)
        self._view:updatePanel(true)
        self._view:getAction()
    end
end

function PopularSupportModule:updateNums()
    self._view:updateNums()
end