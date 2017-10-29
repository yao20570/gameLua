
MilitaryView = class("MilitaryView", BasicView)

function MilitaryView:ctor(parent)
    MilitaryView.super.ctor(self, parent)
end

function MilitaryView:finalize()
    MilitaryView.super.finalize(self)
end

function MilitaryView:registerPanels()
    MilitaryView.super.registerPanels(self)

    require("modules.military.panel.MilitaryPanel")
    self:registerPanel(MilitaryPanel.NAME, MilitaryPanel)

    require("modules.military.panel.MilitaryProjectPanel")
    self:registerPanel(MilitaryProjectPanel.NAME, MilitaryProjectPanel)

    require("modules.military.panel.MilitaryLastCtrlPanel")
    self:registerPanel(MilitaryLastCtrlPanel.NAME, MilitaryLastCtrlPanel)
    
    require("modules.military.panel.MilitarySynthesislPanel")
    self:registerPanel(MilitarySynthesislPanel.NAME, MilitarySynthesislPanel)

    require("modules.military.panel.MilitarySynthesislDialogPanel")
    self:registerPanel(MilitarySynthesislDialogPanel.NAME, MilitarySynthesislDialogPanel)
end

function MilitaryView:initView()
--    local panel = self:getPanel(MilitaryPanel.NAME)
--    panel:show()
end

function MilitaryView:onShowView(extraMsg, isInit)
    MilitaryView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(MilitaryPanel.NAME)
    panel:show(extraMsg)
end
