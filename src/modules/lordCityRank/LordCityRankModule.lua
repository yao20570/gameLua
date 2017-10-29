-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-11-15 14:06:30
--  * @Description: 城主战 攻城排行模块
--  */
LordCityRankModule = class("LordCityRankModule", BasicModule)

function LordCityRankModule:ctor()
    LordCityRankModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LordCityRankModule:initRequire()
    require("modules.lordCityRank.event.LordCityRankEvent")
    require("modules.lordCityRank.view.LordCityRankView")
end

function LordCityRankModule:finalize()
    LordCityRankModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LordCityRankModule:initModule()
    LordCityRankModule.super.initModule(self)
    self._view = LordCityRankView.new(self.parent)

    self:addEventHandler()
end

function LordCityRankModule:addEventHandler()
    self._view:addEventListener(LordCityRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LordCityRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRANK_SINGLE, self, self.onSingleRankMapUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRANK_LEGION, self, self.onLegionRankMapUpdate)
end

function LordCityRankModule:removeEventHander()
    self._view:removeEventListener(LordCityRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LordCityRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRANK_SINGLE, self, self.onSingleRankMapUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITYRANK_LEGION, self, self.onLegionRankMapUpdate)
end

function LordCityRankModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LordCityRankModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

-------------------------------------------------------------------------------
function LordCityRankModule:onSingleRankMapUpdate(data)
    self._view:onSingleRankMapUpdate(data)
end

function LordCityRankModule:onLegionRankMapUpdate(data)
    self._view:onLegionRankMapUpdate(data)
end
-------------------------------------------------------------------------------
function LordCityRankModule:onOpenModule(extraMsg)
    LordCityRankModule.super.onOpenModule(self)
    -- local lordCityProxy = self:getProxy(GameProxys.LordCity)
    -- local cityId = lordCityProxy:getSelectCityId()
    -- local data = {cityId = cityId}
    -- lordCityProxy:onTriggerNet360032Req(data)
    -- lordCityProxy:onTriggerNet360033Req(data)
end
