-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-11-15 14:06:30
--  * @Description: 城主战 战斗记录模块
--  */
LordCityRecordModule = class("LordCityRecordModule", BasicModule)

function LordCityRecordModule:ctor()
    LordCityRecordModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LordCityRecordModule:initRequire()
    require("modules.lordCityRecord.event.LordCityRecordEvent")
    require("modules.lordCityRecord.view.LordCityRecordView")
end

function LordCityRecordModule:finalize()
    LordCityRecordModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LordCityRecordModule:initModule()
    LordCityRecordModule.super.initModule(self)
    self._view = LordCityRecordView.new(self.parent)

    self:addEventHandler()
end

function LordCityRecordModule:addEventHandler()
    self._view:addEventListener(LordCityRecordEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LordCityRecordEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRECORD_SINGLE, self, self.onSingleRecordMapUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRECORD_FULL, self, self.onFullRecordMapUpdate)

end

function LordCityRecordModule:removeEventHander()
    self._view:removeEventListener(LordCityRecordEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LordCityRecordEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRECORD_SINGLE, self, self.onSingleRecordMapUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRECORD_FULL, self, self.onFullRecordMapUpdate)

end

function LordCityRecordModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LordCityRecordModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

-------------------------------------------------------------------------------
function LordCityRecordModule:onSingleRecordMapUpdate(data)
    self._view:onSingleRecordMapUpdate(data)
end

function LordCityRecordModule:onFullRecordMapUpdate(data)
    self._view:onFullRecordMapUpdate(data)
end
-------------------------------------------------------------------------------
function LordCityRecordModule:onOpenModule(extraMsg)
    LordCityRecordModule.super.onOpenModule(self)
    -- local lordCityProxy = self:getProxy(GameProxys.LordCity)
    -- local cityId = lordCityProxy:getSelectCityId()
    -- local data = {cityId = cityId}
    -- lordCityProxy:onTriggerNet360025Req(data)
    -- lordCityProxy:onTriggerNet360026Req(data)
end
