-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionCityModule = class("LegionCityModule", BasicModule)

function LegionCityModule:ctor()
    LegionCityModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER  
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil

    self:initRequire()
end

function LegionCityModule:initRequire()
    require("modules.legionCity.event.LegionCityEvent")
    require("modules.legionCity.view.LegionCityView")
end

function LegionCityModule:finalize()
    LegionCityModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionCityModule:initModule()
    LegionCityModule.super.initModule(self)
    self._view = LegionCityView.new(self.parent)

    self:addEventHandler()
end

function LegionCityModule:addEventHandler()
	self._view:addEventListener(LegionCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
	self._view:addEventListener(LegionCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(LegionCityEvent.GOTO_MAPPOS_REQ, self, self.onGoToMapReq)


	self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220800_TOWN, self, self.onUpdateTown)
	self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220803_CAPITAL, self, self.onUpdateCapital)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220804_IMPERIAL, self, self.onUpdateImperial)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220802_CITYINFO, self, self.updateInfo)

    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220810_REWARDREDPOINT, self, self.updateRedPoint)
     self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_GET_REPORT, self, self.onOpenReport) -- 打开报告界面
end

function LegionCityModule:removeEventHander()
	self._view:removeEventListener(LegionCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
	self._view:removeEventListener(LegionCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(LegionCityEvent.GOTO_MAPPOS_REQ, self, self.onGoToMapReq)

	self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220800_TOWN, self, self.onUpdateTown)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220803_CAPITAL, self, self.onUpdateCapital)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220804_IMPERIAL, self, self.onUpdateImperial)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220802_CITYINFO, self, self.updateInfo)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220810_REWARDREDPOINT, self, self.updateRedPoint)
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_GET_REPORT, self, self.onOpenReport)
end

function LegionCityModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionCityModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionCityModule:onUpdateTown(data)
    self._view:onUpdateTown(data)
end

function LegionCityModule:onUpdateCapital(data)
    self._view:onUpdateCapital(data)
end

function LegionCityModule:onUpdateImperial(data)
    self._view:onUpdateImperial(data)
end

function LegionCityModule:onGoToMapReq(data)  
    self:sendNotification(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, {tileX = data.extraMsg.tileX,
    tileY = data.extraMsg.tileY})
    self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = "LegionSceneModule"})
    self:onHideSelfHandler()
end

function LegionCityModule:updateInfo(data)
    self._view:updateInfo(data)

end

function LegionCityModule:updateRedPoint(data)
    self._view:updateRedPoint(data)

end

function LegionCityModule:onOpenModule(extraMsg)
       local systemProxy = self:getProxy(GameProxys.System)
       systemProxy:onTriggerNet30105Req( { type = 0, scene = GlobalConfig.Scene[5]}) 
end

function LegionCityModule:onHideModule()
        local systemProxy = self:getProxy(GameProxys.System)
        systemProxy:onTriggerNet30105Req( { type = 1, scene = GlobalConfig.Scene[5]})
end


function LegionCityModule:onOpenReport()
    ModuleJumpManager:jump(ModuleName.EmperorReportModule,"EmperorLegionPanel")
    --local data = {}
    --data.moduleName = ModuleName.EmperorReportModule
    --self:dispatchEvent(EmperorCityEvent.SHOW_OTHER_EVENT, data)
    
end
