
RoleInfoModule = class("RoleInfoModule", BasicModule)

function RoleInfoModule:ctor()
    RoleInfoModule .super.ctor(self)
    
    self.isFullScreen = false
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_2_LAYER
    self.isLayoutNode = false
    --self.isShowAction = true
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function RoleInfoModule:initRequire()
    require("modules.roleInfo.event.RoleInfoEvent")
    require("modules.roleInfo.view.RoleInfoView")
end

function RoleInfoModule:finalize()
    RoleInfoModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RoleInfoModule:initModule()
    RoleInfoModule.super.initModule(self)
    self._view = RoleInfoView.new(self.parent)

    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_1)
    
    self:addEventHandler()
end

function RoleInfoModule:addEventHandler()
    self._view:addEventListener(RoleInfoEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RoleInfoEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_NAME, self, self.updateRoleNameHandler)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onRoleHeadUpdate)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_POWER, self, self.updateRolePowerHandler)
    self:addProxyEventListener(GameProxys.Skill, AppEvent.PROXY_UPDATE_ICON_EFFECT, self, self.updateTipEffect)           --//加一个战法升级图标显示

    self:addEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENEMAP_MOVE_UPDATE, self, self.onMoveScene)

    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetGuideRewardResp)
end

function RoleInfoModule:removeEventHander()
    self._view:removeEventListener(RoleInfoEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RoleInfoEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_NAME, self, self.updateRoleNameHandler)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onRoleHeadUpdate)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_POWER, self, self.updateRolePowerHandler)
    self:removeProxyEventListener(GameProxys.Skill,AppEvent.PROXY_UPDATE_ICON_EFFECT, self, self.updateTipEffect)

    self:removeEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENEMAP_MOVE_UPDATE, self, self.onMoveScene)

    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetGuideRewardResp)
end

function RoleInfoModule:onOpenModule(extraMsg)
    RoleInfoModule.super.onOpenModule(self, extraMsg)
    self:updateRoleInfoHandler()
end

function RoleInfoModule:updateRoleInfoHandler(data)
    self._view:onRoleInfoUpdateResp(data) 
end

function RoleInfoModule:updateRoleNameHandler(data)
    self._view:onRoleNameUpdateResp()
end

function RoleInfoModule:onRoleHeadUpdate(data)
    self._view:onRoleHeadUpdate()
end


function RoleInfoModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RoleInfoModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function RoleInfoModule:updateRolePowerHandler(data)
    logger:info("------刷新繁荣：PROXY_UPDATE_ROLE_POWER----------")
    self._view:updateRolePowerHandler(data)   --TODO 刷新繁荣
end

function RoleInfoModule:onMoveScene(data)
    -- body
    -- logger:info("RoleInfoModule 接收通知。。。11")
    self._view:onMoveScene(data)
end

function RoleInfoModule:onGetGuideRewardResp(data)
    if data.rs == 0 then
        self._view:onEndGuide()
    end
end

function RoleInfoModule:updateTipEffect()
    local panel=self._view:getPanel(RoleInfoPanel.NAME)
    panel:isShowSkillTip()
    logger:info("图标刷新提示到位")
end