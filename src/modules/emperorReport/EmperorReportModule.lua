-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorReportModule = class("EmperorReportModule", BasicModule)

function EmperorReportModule:ctor()
    EmperorReportModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function EmperorReportModule:initRequire()
    require("modules.emperorReport.event.EmperorReportEvent")
    require("modules.emperorReport.view.EmperorReportView")
end

function EmperorReportModule:finalize()
    EmperorReportModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EmperorReportModule:initModule()
    EmperorReportModule.super.initModule(self)
    self._view = EmperorReportView.new(self.parent)

    self:addEventHandler()
end

function EmperorReportModule:addEventHandler()
    self._view:addEventListener(EmperorReportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EmperorReportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_READ_REPORT, self, self.setTabRedPoint) -- 阅读战报
end

function EmperorReportModule:removeEventHander()
    self._view:removeEventListener(EmperorReportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EmperorReportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_READ_REPORT, self, self.setTabRedPoint) -- 阅读战报
end

function EmperorReportModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function EmperorReportModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function EmperorReportModule:setTabRedPoint()
    local panel = self:getPanel(EmperorReportPanel.NAME)
    panel:setTabRedPoint()
end