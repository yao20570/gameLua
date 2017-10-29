
WorldHelpView = class("WorldHelpView", BasicView)

function WorldHelpView:ctor(parent)
    WorldHelpView.super.ctor(self, parent)
end

function WorldHelpView:finalize()
    WorldHelpView.super.finalize(self)
end

function WorldHelpView:registerPanels()
    WorldHelpView.super.registerPanels(self)

    require("modules.worldHelp.panel.WorldHelpPanel")
    self:registerPanel(WorldHelpPanel.NAME, WorldHelpPanel)
end

function WorldHelpView:initView()
    local panel = self:getPanel(WorldHelpPanel.NAME)
    panel:show()
end
