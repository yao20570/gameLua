-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownReportModule = class("TownReportModule", BasicModule)

function TownReportModule:ctor()
    TownReportModule .super.ctor(self)
    

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function TownReportModule:initRequire()
    require("modules.townReport.event.TownReportEvent")
    require("modules.townReport.view.TownReportView")
end

function TownReportModule:finalize()
    TownReportModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function TownReportModule:initModule()
    TownReportModule.super.initModule(self)
    self._view = TownReportView.new(self.parent)

    self:addEventHandler()
end

function TownReportModule:addEventHandler()
    self._view:addEventListener(TownReportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TownReportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    --self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_SPARE_TEAM, self, self.onUpdateSpareTeamPanel) 

end

function TownReportModule:removeEventHander()
    self._view:removeEventListener(TownReportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TownReportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    --self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_SPARE_TEAM, self, self.onUpdateSpareTeamPanel) 

end

function TownReportModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function TownReportModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

--function TownReportModule:onUpdateSpareTeamPanel()
--    local spareTeamPanel = self:getPanel(TownSpareTeamPanel.NAME)
--    spareTeamPanel:onUpdateSpareTeamPanel()
--end
