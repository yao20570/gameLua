
SettingModule = class("SettingModule", BasicModule)

function SettingModule:ctor()
    SettingModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function SettingModule:initRequire()
    require("modules.setting.event.SettingEvent")
    require("modules.setting.view.SettingView")
end

function SettingModule:finalize()
    SettingModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function SettingModule:initModule()
    SettingModule.super.initModule(self)
    self._view = SettingView.new(self.parent)

    self:addEventHandler()
end

function SettingModule:addEventHandler()
    self._view:addEventListener(SettingEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(SettingEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --self._view:addEventListener(SettingEvent.HEAD_SET_REQ, self, self.onHeadSettingReq)
    -- self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20012, self, self.onHeadSettingResp)
    --self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onHeadSettingResp)
    --self:addProxyEventListener(GameProxys.RealName, AppEvent.PROXY_OPEN_REAL_NAME_MODULE, self, self.onRealNameOpen)
end

function SettingModule:removeEventHander()
    self._view:removeEventListener(SettingEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(SettingEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --self._view:removeEventListener(SettingEvent.HEAD_SET_REQ, self, self.onHeadSettingReq)
    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20012, self, self.onHeadSettingResp)
    --self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onHeadSettingResp)
    --self:removeProxyEventListener(GameProxys.RealName, AppEvent.PROXY_OPEN_REAL_NAME_MODULE, self, self.onRealNameOpen)

end

function SettingModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function SettingModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function SettingModule:onHeadSettingReq(data)
    -- body
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20012, data)
end

-- 设置头像
function SettingModule:onHeadSettingResp(data)
    -- body
    if data.rs == 0 then
        -- self._view:onHeadSettingResp(data)
        -- 设置成功飘字
        -- self:showSysMessage(self:getTextWord(1428))

        -- local iconId = data.iconId
        -- local pendantId = data.pendantId

        -- local roleProxy = self:getProxy(GameProxys.Role)
        --  if data.iconId ~= 0 then
        --     roleProxy:setHeadId(data.iconId)
        -- end
        -- if data.pendantId ~= 0 then
        --     roleProxy:setPendantId(pendantId)
        -- end
        
        -- self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_HEAD, {})

        -- local sex = roleProxy:getSexByHeadId()
        -- self:showSysMessage("性别 sex="..sex)

    end

end

-- 接收到消息号，打开realName
function SettingModule:onRealNameOpen()
    
    self:getPanel(SettingPanel.NAME):onRealNameOpen()
end