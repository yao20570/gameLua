-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
DayRechargeModule = class("DayRechargeModule", BasicModule)

function DayRechargeModule:ctor()
    DayRechargeModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function DayRechargeModule:initRequire()
    require("modules.dayRecharge.event.DayRechargeEvent")
    require("modules.dayRecharge.view.DayRechargeView")
end

function DayRechargeModule:finalize()
    DayRechargeModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function DayRechargeModule:initModule()
    DayRechargeModule.super.initModule(self)
    self._view = DayRechargeView.new(self.parent)

    self:addEventHandler()
end

function DayRechargeModule:addEventHandler()
    self._view:addEventListener(DayRechargeEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(DayRechargeEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW_DAYRECHARGE, self, self.renderPanel)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.renderPanel)  --充值变化 
end

function DayRechargeModule:removeEventHander()
    self._view:removeEventListener(DayRechargeEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(DayRechargeEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW_DAYRECHARGE, self, self.renderPanel)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.renderPanel)  --充值变化 
end

function DayRechargeModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function DayRechargeModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function DayRechargeModule:onOpenModule(extraMsg)
    DayRechargeModule.super.onOpenModule(self)
end

function DayRechargeModule:renderPanel()
    self._view:renderPanel()
end
