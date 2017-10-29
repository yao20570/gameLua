
LegionScienceTechModule = class("LegionScienceTechModule", BasicModule)

function LegionScienceTechModule:ctor()
    LegionScienceTechModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER    
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionScienceTechModule:initRequire()
    require("modules.legionScienceTech.event.LegionScienceTechEvent")
    require("modules.legionScienceTech.view.LegionScienceTechView")
end

function LegionScienceTechModule:finalize()
    LegionScienceTechModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionScienceTechModule:initModule()
    LegionScienceTechModule.super.initModule(self)
    self._view = LegionScienceTechView.new(self.parent)

    self:addEventHandler()
end

function LegionScienceTechModule:addEventHandler()
    self._view:addEventListener(LegionScienceTechEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionScienceTechEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_CONTRIBUTE_UPDATE, self, self.onUpdateContributeResp)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_SCITECH_UPDATE, self, self.onSciTectUpdate)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_TASKINFO_JUMPTO,self,self.donatePanelJumpSelectedPanel)
    -- self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220010, self, self.onSciUpgrateResp)
    -- self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220009, self, self.onSciContributeResp)

    --// legionHallModule 迁移过来的
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onHallUpgrateResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220008, self, self.onHallContributeResp)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

end

function LegionScienceTechModule:removeEventHander()
    self._view:removeEventListener(LegionScienceTechEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionScienceTechEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_CONTRIBUTE_UPDATE, self, self.onUpdateContributeResp)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_SCITECH_UPDATE, self, self.onSciTectUpdate)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_TASKINFO_JUMPTO,self,self.donatePanelJumpSelectedPanel)
    -- self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220010, self, self.onSciUpgrateResp)
    -- self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220009, self, self.onSciContributeResp)

    --// legionHallModule 迁移过来的
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onHallUpgrateResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220008, self, self.onHallContributeResp)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
end

function LegionScienceTechModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionScienceTechModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionScienceTechModule:onOpenModule(extraMsg)
    LegionScienceTechModule.super.onOpenModule(self, extraMsg)

    -- local data = {opt = 0}
    -- local legionProxy = self:getProxy(GameProxys.Legion)
    -- legionProxy:onTriggerNet220010Req(data)
end

-- -- 科技升级
-- function LegionScienceTechModule:onSciUpgrateResp(data)
--     if data.rs == 0 then
--         self._view:onSciUpgrateResp(data)
--     end
-- end

-- 科技捐献
function LegionScienceTechModule:onSciContributeResp(data)
    if data.rs == 0 then
        self._view:onSciContributeResp(data)
    end
end


function LegionScienceTechModule:onUpdateContributeResp(data)
    -- body
    self._view:onSciContributeResp(data)
end

-- 科技升级
function LegionScienceTechModule:onSciTectUpdate(data)
    -- body
    -- self._view:onSciTectUpdate()
    self._view:onSciUpgrateResp(data)
end



-- 大厅初始化or更新
function LegionScienceTechModule:onHallUpgrateResp(data)
    print("220007 data.rs = "..data.rs)

    if data.rs == 0 then
        self._view:onHallInfoResp(data)
    end
end

-- 大厅捐献情况刷新
function LegionScienceTechModule:onHallContributeResp(data)
    if data.rs == 0 then
        self._view:onHallContributeResp(data)
    end
end

function LegionScienceTechModule:updateRoleInfoHandler()
    self._view:updateRoleInfoHandler()
end

function LegionScienceTechModule:donatePanelJumpSelectedPanel(data)
    self._view:donatePanelJumpSelectedPanel(data)
end 

