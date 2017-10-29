
SettingView = class("SettingView", BasicView)

function SettingView:ctor(parent)
    SettingView.super.ctor(self, parent)
end

function SettingView:finalize()
    SettingView.super.finalize(self)
end

function SettingView:registerPanels()
    SettingView.super.registerPanels(self)

    require("modules.setting.panel.SettingPanel")
    self:registerPanel(SettingPanel.NAME, SettingPanel)

    require("modules.setting.panel.GameSettingPanel")
    self:registerPanel(GameSettingPanel.NAME, GameSettingPanel)
    
    require("modules.setting.panel.ContactPanel")
    self:registerPanel(ContactPanel.NAME, ContactPanel)

end

function SettingView:initView()
    local panel = self:getPanel(SettingPanel.NAME)
    panel:show()
end

function SettingView:onShowOtherPanel(panelName)
	-- body
    local panel = self:getPanel(panelName)
    panel:show()
end


function SettingView:onHeadSettingReq(data)
    -- body
    self:dispatchEvent(SettingEvent.HEAD_SET_REQ,data)
end

function SettingView:onHeadSettingResp(data)
    -- body
    local panel = self:getPanel(HeadSettingPanel.NAME)
    -- panel:onHeadSettingResp(data)
end

-- 按钮的刷新需求
function SettingView:onShowView(extraMsg, isInit)
    SettingView.super.onShowView(self,extraMsg, isInit, true)
end