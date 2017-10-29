
HeadAndPendantModule = class("HeadAndPendantModule", BasicModule)

function HeadAndPendantModule:ctor()
    HeadAndPendantModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeadAndPendantModule:initRequire()
    require("modules.headAndPendant.event.HeadAndPendantEvent")
    require("modules.headAndPendant.view.HeadAndPendantView")
end

function HeadAndPendantModule:finalize()
    HeadAndPendantModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeadAndPendantModule:initModule()
    HeadAndPendantModule.super.initModule(self)
    self._view = HeadAndPendantView.new(self.parent)

    self:addEventHandler()
end

function HeadAndPendantModule:addEventHandler()
    self._view:addEventListener(HeadAndPendantEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeadAndPendantEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(HeadAndPendantEvent.HEAD_SET_REQ, self, self.onHeadSettingReq)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onHeadSettingResp)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_CUSTOM_HEAD, self, self.onCustomHeadUpResp)
    self:addProxyEventListener(GameProxys.Title, AppEvent.PROXY_TITLE_CHANGE, self, self.updateTitleListView) -- 称号选择[20802]
    self:addProxyEventListener(GameProxys.Title, AppEvent.PROXY_TITLE_ADD_GOT, self, self.updateTitleListView) -- 称号获得[20800]
    
    self:addProxyEventListener(GameProxys.Frame, AppEvent.PROXY_FRAME_CHANGE, self,  self.updateFrameListView) --
    self:addProxyEventListener(GameProxys.Frame, AppEvent.PROXY_FRAME_ADD_GOT, self, self.updateFrameListView) --
end

function HeadAndPendantModule:removeEventHander()
    self._view:removeEventListener(HeadAndPendantEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeadAndPendantEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(HeadAndPendantEvent.HEAD_SET_REQ, self, self.onHeadSettingReq)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onHeadSettingResp)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_CUSTOM_HEAD, self, self.onCustomHeadUpResp)
    self:removeProxyEventListener(GameProxys.Title, AppEvent.PROXY_TITLE_CHANGE, self, self.updateTitleListView) -- 称号选择[20802]
    self:removeProxyEventListener(GameProxys.Title, AppEvent.PROXY_TITLE_ADD_GOT, self, self.updateTitleListView) -- 称号获得[20800]

    self:removeProxyEventListener(GameProxys.Frame, AppEvent.PROXY_FRAME_CHANGE, self,  self.updateFrameListView) --
    self:removeProxyEventListener(GameProxys.Frame, AppEvent.PROXY_FRAME_ADD_GOT, self, self.updateFrameListView) --
end

function HeadAndPendantModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeadAndPendantModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function HeadAndPendantModule:onHeadSettingReq(data)
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20012, data)
end
-- 设置头像
function HeadAndPendantModule:onHeadSettingResp(data)
    -- body
    if data.rs == 0 then
        -- self._view:onHeadSettingResp(data)
        -- 设置成功飘字
        self:showSysMessage(self:getTextWord(1428))

        --[[
        local roleProxy = self:getProxy(GameProxys.Role)
        if data.iconId ~= 0 then
            roleProxy:setHeadId(data.iconId)
        end
        if data.pendantId ~= 0 then
            roleProxy:setPendantId(data.pendantId)
        end
        self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_HEAD, {})
        ]]
        -- local sex = roleProxy:getSexByHeadId()
        -- self:showSysMessage("性别 sex="..sex)

    end

end

function HeadAndPendantModule:onCustomHeadUpResp(data)
    local panel = self:getPanel(HeadSettingPanel.NAME)
    panel:selectCustomHead()
end

------
-- 刷新称号listView
function HeadAndPendantModule:updateTitleListView()
    local panel = self:getPanel(TitleSettingPanel.NAME)
    panel:updateTitleListView()
end

------
-- 刷新头像框listView
function HeadAndPendantModule:updateFrameListView()
    local panel = self:getPanel(TopFramePanel.NAME)
    panel:updateFrameListView()
end

