
CreateRoleModule = class("CreateRoleModule", BasicModule)

function CreateRoleModule:ctor()
    CreateRoleModule .super.ctor(self)
    
--    self.isFullScreen = false
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_POP_LAYER
    -- self.uiLayerName = ModuleLayer.UI_3_LAYER
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function CreateRoleModule:initRequire()
    require("modules.createRole.event.CreateRoleEvent")
    require("modules.createRole.view.CreateRoleView")
end

function CreateRoleModule:finalize()
    CreateRoleModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CreateRoleModule:initModule()
    CreateRoleModule.super.initModule(self)
    self._view = CreateRoleView.new(self.parent)

    self:addEventHandler()

    self:setLocalZOrder(1000) --最高了

    --TODO 这里会有问题，如果还没有返回世界坐标的时候
    --先打开世界地图
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MapModule, isPerLoad = true})
end

function CreateRoleModule:addEventHandler()
    self._view:addEventListener(CreateRoleEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CreateRoleEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:addEventListener(CreateRoleEvent.CREATE_ROLE_REQ, self, self.onCreateRoleReq)
    
    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20008, self, self.onCreateRoleResp)
end

function CreateRoleModule:removeEventHander()
    self._view:removeEventListener(CreateRoleEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CreateRoleEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:removeEventListener(CreateRoleEvent.CREATE_ROLE_REQ, self, self.onCreateRoleReq)
    
    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20008, self, self.onCreateRoleResp)
end

function CreateRoleModule:onCreateRoleReq(data)
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20008, data)
    
    --//如果创建了角色 就证明是第一次登录  7316
    local redProxy =  self:getProxy(GameProxys.RedPoint)
    redProxy._isFirst = true
    redProxy:checkActivityRedPoint()
end

function CreateRoleModule:onCreateRoleResp(data)
    if data.rs == 0 then --TODO 这里可以要全部释放掉，只有出现一次而已

        GameConfig.roleCreateTime = data.roleCreateTime
        
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MapModule, isPerLoad = true})
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MapModule, isPerLoad = true})

        self:onHideSelfHandler()
        
        --103新版新手引导 这里就可以触发了
        GuideManager:trigger(GuideManager.EndGuideId) 

        --创角成功，发送日志        
        local roleProxy = self:getProxy(GameProxys.Role)
        local actorInfo = roleProxy:getActorInfo()
        GameConfig.actorid = actorInfo.playerId
        GameConfig.actorName = data.name--actorInfo.name
        GameConfig.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        local userMoney = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
        SDKManager:sendExtendDataRoleCreate(userMoney)
        
    end
end

function CreateRoleModule:delayFinalize()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_FINALIZE_EVENT, {moduleName = self.name})
end

function CreateRoleModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
   
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.DramaModule})
    
    TimerManager:addOnce(30, self.delayFinalize, self)
end

function CreateRoleModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end