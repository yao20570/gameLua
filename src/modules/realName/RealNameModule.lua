-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
RealNameModule = class("RealNameModule", BasicModule)

function RealNameModule:ctor()
    RealNameModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    
    self:initRequire()
end

function RealNameModule:initRequire()
    require("modules.realName.event.RealNameEvent")
    require("modules.realName.view.RealNameView")
end

function RealNameModule:finalize()
    RealNameModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function RealNameModule:initModule()
    RealNameModule.super.initModule(self)
    self._view = RealNameView.new(self.parent)

    self:addEventHandler()
end

function RealNameModule:addEventHandler()
    self._view:addEventListener(RealNameEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RealNameEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    -- 消息号监听添加
    self:addProxyEventListener(GameProxys.RealName, AppEvent.PROXY_REALNAME_UPDATE, self, self.onUpdatePanel)

end

function RealNameModule:removeEventHander()
    self._view:removeEventListener(RealNameEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RealNameEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    -- 消息号监听移除
    self:removeProxyEventListener(GameProxys.RealName, AppEvent.PROXY_REALNAME_UPDATE, self, self.onUpdatePanel)

end

function RealNameModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RealNameModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

-- 显示不同的界面
function RealNameModule:onOpenModule()
    local realNameProxy = self:getProxy(GameProxys.RealName)
    local info = realNameProxy:getRealNameInfo()
    if info and info.state == 3 then -- 认证状态（1：未实名，2：实名未成年，3：实名已成年）
        self:getPanel(RealNameDonePanel.NAME):show()
    elseif info then
        self:getPanel(RealNamePanel.NAME):show()
    end
end

function RealNameModule:onUpdatePanel()
    if self:getPanel(RealNamePanel.NAME):isVisible() then
        self:getPanel(RealNamePanel.NAME):onUpdatePanel()
    end
end

