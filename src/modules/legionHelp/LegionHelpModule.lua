
LegionHelpModule = class("LegionHelpModule", BasicModule)

function LegionHelpModule:ctor()
    LegionHelpModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionHelpModule:initRequire()
    require("modules.legionHelp.event.LegionHelpEvent")
    require("modules.legionHelp.view.LegionHelpView")
end

function LegionHelpModule:finalize()
    LegionHelpModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionHelpModule:initModule()
    LegionHelpModule.super.initModule(self)
    self._view = LegionHelpView.new(self.parent)

    self:addEventHandler()
end

function LegionHelpModule:addEventHandler()
    self._view:addEventListener(LegionHelpEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionHelpEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220500, self, self.updateBuildHelpInfos)
    -- self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220501, self, self.removeHelpedInfos)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_EXIT_INFO, self, self.onLegionExit)
end

function LegionHelpModule:removeEventHander()
    self._view:removeEventListener(LegionHelpEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionHelpEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220500, self, self.updateBuildHelpInfos)
    -- self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220501, self, self.removeHelpedInfos)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_EXIT_INFO, self, self.onLegionExit)
end

function LegionHelpModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionHelpModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionHelpModule:onOpenModule()
    local legionHelp = self:getProxy(GameProxys.LegionHelp)
    legionHelp:onTriggerNet220500Req()
end

function LegionHelpModule:updateBuildHelpInfos(data)
    if data.rs == 0 then
        self._view:updateBuildHelpInfos(data.infos)
    end    
end

-- function LegionHelpModule:removeHelpedInfos(data)
--     if data.rs == 0 then
--         self:showSysMessage("帮助成功！")
--     end
-- end

function LegionHelpModule:onLegionExit()
    self:onHideSelfHandler()
end