-- /**
--  * @DateTime:    2016-01-14 11:05:42
--  * @Description: 军团管理（军团信息）
--  */
LegionModule = class("LegionModule", BasicModule)

function LegionModule:ctor()
    LegionModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self.isFullScreen = true
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionModule:initRequire()
    require("modules.legion.event.LegionEvent")
    require("modules.legion.view.LegionView")
end

function LegionModule:finalize()
    LegionModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionModule:initModule()
    LegionModule.super.initModule(self)
    self._view = LegionView.new(self.parent)

    self:addEventHandler()
end

function LegionModule:addEventHandler()
    self._view:addEventListener(LegionEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(LegionEvent.LEGION_RECRUIT_REQ, self, self.onRecruitReq)

    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220210, self, self.onLegionEditResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220220, self, self.onLegionJobEditResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220211, self, self.onLegionSaveResp)

    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_UPDATE, self, self.onLegionInfoUpdate)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_MEMBER_UPDATE, self, self.onLegionMemberUpdate)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_EXIT_INFO, self, self.onLegionExit)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
end

function LegionModule:removeEventHander()
    self._view:removeEventListener(LegionEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(LegionEvent.LEGION_RECRUIT_REQ, self, self.onRecruitReq)

    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220210, self, self.onLegionEditResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220220, self, self.onLegionJobEditResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220211, self, self.onLegionSaveResp)

    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_UPDATE, self, self.onLegionInfoUpdate)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_MEMBER_UPDATE, self, self.onLegionMemberUpdate)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_EXIT_INFO, self, self.onLegionExit)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
end

------------------------------------
function LegionModule:onOpenModule(extraMsg)
    LegionModule.super.onOpenModule(self, extraMsg)
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220200, {}) -- 发送军团信息
end

------------------------------------

function LegionModule:onLegionInfoUpdate(data)
        self._view:onLegionInfoUpdate()
end

function LegionModule:onLegionMemberUpdate(data)
    self._view:onLegionMemberUpdate()
end





function LegionModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

-- 退出军团
function LegionModule:onLegionExit()
    logger:info("···退出军团 legion")
    self:onHideSelfHandler()
end

function LegionModule:updateRoleInfoHandler()
    -- body
    local roleProxy = self:getProxy(GameProxys.Role)
    local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
    if legionId == nil or legionId <= 0 then
        logger:info("···我被踢出军团了 legion")
        self:onHideSelfHandler()
    end
end

function LegionModule:onLegionEditResp(data)
    -- body
    if data.rs == 0 then
        self._view:onLegionEditResp()
        self:onHideSelfHandler()
    end
end

-- 职位编辑成功提示
function LegionModule:onLegionJobEditResp(data)
    -- body
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(3005))
    end
end

-- 保存内部公告成功
function LegionModule:onLegionSaveResp(data)
    -- body
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(3119))
    end    
end


function LegionModule:onRecruitReq()  --招募
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220400, {}) --军团招募
end

