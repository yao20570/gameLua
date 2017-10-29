-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-08
--  * @Description: 春节活动-爆竹酉礼
--  */
SpringSquibModule = class("SpringSquibModule", BasicModule)

function SpringSquibModule:ctor()
    SpringSquibModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function SpringSquibModule:initRequire()
    require("modules.springSquib.event.SpringSquibEvent")
    require("modules.springSquib.view.SpringSquibView")
end

function SpringSquibModule:finalize()
    SpringSquibModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function SpringSquibModule:initModule()
    SpringSquibModule.super.initModule(self)
    self._view = SpringSquibView.new(self.parent)

    self:addEventHandler()
end

function SpringSquibModule:addEventHandler()
    self._view:addEventListener(SpringSquibEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(SpringSquibEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --230026客户端爆竹位置信息更新
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_SQUIBINFO, self, self.updatePosInfo)
    --20007充值更新属性刷新页面
    self:addProxyEventListener(GameProxys.Role,AppEvent.POWER_VALUE_UPDATE, self, self.powerValueUpdate)
    --230026爆竹点燃通知特效
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_SQUIB_AFTER_KINDLE, self, self.afterKindle)

end

function SpringSquibModule:removeEventHander()
    self._view:removeEventListener(SpringSquibEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(SpringSquibEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_SQUIBINFO, self, self.updatePosInfo)
    self:removeEventListener(GameProxys.Role,AppEvent.POWER_VALUE_UPDATE, self, self.powerValueUpdate)
    self:removeEventListener(GameProxys.Activity, AppEvent.PROXY_SQUIB_AFTER_KINDLE, self, self.afterKindle)

end

function SpringSquibModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function SpringSquibModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function SpringSquibModule:updatePosInfo()
    self._view:updatePosInfo()
end
function SpringSquibModule:powerValueUpdate()
    self._view:updatePosInfo()
end
function SpringSquibModule:afterKindle(pos)
    self._view:afterKindle(pos)
end




