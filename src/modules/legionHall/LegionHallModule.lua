-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-01-12 16:00:57
--  * @Description: 军团大厅
--  */

LegionHallModule = class("LegionHallModule", BasicModule)

function LegionHallModule:ctor()
    LegionHallModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER      
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionHallModule:initRequire()
    require("modules.legionHall.event.LegionHallEvent")
    require("modules.legionHall.view.LegionHallView")
end

function LegionHallModule:finalize()
    LegionHallModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionHallModule:initModule()
    LegionHallModule.super.initModule(self)
    self._view = LegionHallView.new(self.parent)

    self:addEventHandler()
end

function LegionHallModule:addEventHandler()
    self._view:addEventListener(LegionHallEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionHallEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_CONTRIBUTE_UPDATE, self, self.onUpdateContributeResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onHallUpgrateResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220008, self, self.onHallContributeResp)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
end

function LegionHallModule:removeEventHander()
    self._view:removeEventListener(LegionHallEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionHallEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_CONTRIBUTE_UPDATE, self, self.onUpdateContributeResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onHallUpgrateResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220008, self, self.onHallContributeResp)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
end

function LegionHallModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionHallModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LegionHallModule:onOpenModule(extraMsg)
    LegionHallModule.super.onOpenModule(self, extraMsg)

    -- local data = {opt = 0}
    -- local legionProxy = self:getProxy(GameProxys.Legion)
    -- legionProxy:onTriggerNet220007Req(data)
end

-- 大厅初始化or更新
function LegionHallModule:onHallUpgrateResp(data)
    print("220007 data.rs = "..data.rs)

    if data.rs == 0 then
        self._view:onHallInfoResp(data)
    end
end

-- 大厅捐献情况刷新
function LegionHallModule:onHallContributeResp(data)
    if data.rs == 0 then
        self._view:onHallContributeResp(data)
    end
end

function LegionHallModule:updateRoleInfoHandler()
    self._view:updateRoleInfoHandler()
end

