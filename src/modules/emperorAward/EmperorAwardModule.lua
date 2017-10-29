
EmperorAwardModule = class("EmperorAwardModule", BasicModule)

function EmperorAwardModule:ctor()
    EmperorAwardModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self:initRequire()
end

function EmperorAwardModule:initRequire()
    require("modules.emperorAward.event.EmperorAwardEvent")
    require("modules.emperorAward.view.EmperorAwardView")
end

function EmperorAwardModule:finalize()
    EmperorAwardModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EmperorAwardModule:initModule()
    EmperorAwardModule.super.initModule(self)
    self._view = EmperorAwardView.new(self.parent)

    self:addEventHandler()
end

function EmperorAwardModule:addEventHandler()
    self._view:addEventListener(EmperorAwardEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EmperorAwardEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(EmperorAwardEvent.GET_EVNET, self, self.getEmperorAwards)
    self:addEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230023, self, self.getEmperorAwardsRsp)
    self:addProxyEventListener(GameProxys.EmperorAward, AppEvent.PROXY_UPDATE_EMPERPRAWARD, self, self.updateInfos)
end

function EmperorAwardModule:removeEventHander()
    self._view:removeEventListener(EmperorAwardEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EmperorAwardEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(EmperorAwardEvent.GET_EVNET, self, self.getEmperorAwards)
    self:removeEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230023, self, self.getEmperorAwardsRsp)
    self:removeEventListener(GameProxys.EmperorAward, AppEvent.PROXY_UPDATE_EMPERPRAWARD, self, self.updateInfos)

end

function EmperorAwardModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function EmperorAwardModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function EmperorAwardModule:onOpenModule()
    EmperorAwardModule.super.onOpenModule(self)
    self._view:onOpenView()
end

function EmperorAwardModule:getEmperorAwards(data)
    self:sendServerMessage(AppEvent.NET_M23, AppEvent.NET_M23_C230023, data)
end

function EmperorAwardModule:getEmperorAwardsRsp(data)
    if data.rs == 0 then 
        local proxy = self:getProxy(GameProxys.EmperorAward)
        proxy:setHasgetIds(data.id,data.choiceIds)
        self._view:updatePanel()  
    end
end
function EmperorAwardModule:updateInfos()
    self._view:updateInfos()  
end
