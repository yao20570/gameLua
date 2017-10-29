-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-04-28
--  * @Description: 限时活动_充值返利大放送转盘
--  */
RechargeRebateModule = class("RechargeRebateModule", BasicModule)

function RechargeRebateModule:ctor()
    RechargeRebateModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function RechargeRebateModule:initRequire()
    require("modules.rechargeRebate.event.RechargeRebateEvent")
    require("modules.rechargeRebate.view.RechargeRebateView")
end

function RechargeRebateModule:finalize()
    RechargeRebateModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RechargeRebateModule:initModule()
    RechargeRebateModule.super.initModule(self)
    self._view = RechargeRebateView.new(self.parent)

    self:addEventHandler()
end

function RechargeRebateModule:addEventHandler()
    self._view:addEventListener(RechargeRebateEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RechargeRebateEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --M230050
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_RECHARGEREBATE_AFTER_TURN, self, self.afterTurn)
    --M230052
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_RECHARGEREBATE_INFO_UPDATE, self, self.infosUpdate)
    --M230050
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_RECHARGEREBATE_230050, self, self.after230050)
end

function RechargeRebateModule:removeEventHander()
    self._view:removeEventListener(RechargeRebateEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RechargeRebateEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_RECHARGEREBATE_AFTER_TURN, self, self.afterTurn)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_RECHARGEREBATE_INFO_UPDATE, self, self.infosUpdate)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_RECHARGEREBATE_230050, self, self.after230050)
end

function RechargeRebateModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RechargeRebateModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function RechargeRebateModule:afterTurn(data)
    self._view:afterTurn(data)
end
function RechargeRebateModule:infosUpdate(data)
    self._view:infosUpdate(data)
end
function RechargeRebateModule:after230050(data)
    self._view:after230050(data)
end


