
LegionHelpView = class("LegionHelpView", BasicView)

function LegionHelpView:ctor(parent)
    LegionHelpView.super.ctor(self, parent)
end

function LegionHelpView:finalize()
    LegionHelpView.super.finalize(self)
end

function LegionHelpView:registerPanels()
    LegionHelpView.super.registerPanels(self)

    require("modules.legionHelp.panel.LegionHelpPanel")
    self:registerPanel(LegionHelpPanel.NAME, LegionHelpPanel)
end

function LegionHelpView:initView()
    local panel = self:getPanel(LegionHelpPanel.NAME)
    panel:show()
end

function LegionHelpView:updateBuildHelpInfos(infos)
    local panel = self:getPanel(LegionHelpPanel.NAME)
    panel:show()
    panel:updateBuildHelpInfos(infos)
end

