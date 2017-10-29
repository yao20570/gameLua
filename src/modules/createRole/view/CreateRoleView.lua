
CreateRoleView = class("CreateRoleView", BasicView)

function CreateRoleView:ctor(parent)
    CreateRoleView.super.ctor(self, parent)
end

function CreateRoleView:finalize()
    CreateRoleView.super.finalize(self)
end

function CreateRoleView:registerPanels()
    CreateRoleView.super.registerPanels(self)
    
    require("modules.createRole.view.NameLibrary")

    require("modules.createRole.panel.CreateRolePanel")
    self:registerPanel(CreateRolePanel.NAME, CreateRolePanel)
end

function CreateRoleView:initView()
    local panel = self:getPanel(CreateRolePanel.NAME)
    panel:show()
end