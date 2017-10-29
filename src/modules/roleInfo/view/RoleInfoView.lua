
RoleInfoView = class("RoleInfoView", BasicView)

function RoleInfoView:ctor(parent)
    RoleInfoView.super.ctor(self, parent)
end

function RoleInfoView:finalize()
    RoleInfoView.super.finalize(self)
end

function RoleInfoView:registerPanels()
    RoleInfoView.super.registerPanels(self)

    require("modules.roleInfo.panel.RoleInfoPanel")
    self:registerPanel(RoleInfoPanel.NAME, RoleInfoPanel)
end

function RoleInfoView:initView()
    local panel = self:getPanel(RoleInfoPanel.NAME)
    panel:show()
end

function RoleInfoView:showOtherModule(moduleName)
	self:dispatchEvent(RoleInfoEvent.SHOW_OTHER_EVENT,moduleName)
end

function RoleInfoView:onRoleInfoUpdateResp(updatePowerList)
	local RoleInfoPanel = self:getPanel(RoleInfoPanel.NAME)
    RoleInfoPanel:onRoleInfoUpdateResp(updatePowerList)
end

function RoleInfoView:onRoleNameUpdateResp()
    local roleInfoPanel = self:getPanel(RoleInfoPanel.NAME)
    roleInfoPanel:onRoleNameUpdate()
end

function RoleInfoView:onRoleHeadUpdate()
    local roleInfoPanel = self:getPanel(RoleInfoPanel.NAME)
    roleInfoPanel:onRoleHeadUpdate()
end

function RoleInfoView:updateRolePowerHandler(data)
    -- body 
    local panel = self:getPanel(RoleInfoPanel.NAME)
    if panel:isVisible() then
        panel:updateRolePowerHandler(data)
    end
end

function RoleInfoView:onMoveScene(data)
    -- body
    local panel = self:getPanel(RoleInfoPanel.NAME)
    panel:onMoveScene(data)
end

function RoleInfoView:onEndGuide()
    local panel = self:getPanel(RoleInfoPanel.NAME)
    panel:onShowHandler()
end