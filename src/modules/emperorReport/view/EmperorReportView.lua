
EmperorReportView = class("EmperorReportView", BasicView)

function EmperorReportView:ctor(parent)
    EmperorReportView.super.ctor(self, parent)
end

function EmperorReportView:finalize()
    EmperorReportView.super.finalize(self)
end

function EmperorReportView:registerPanels()
    EmperorReportView.super.registerPanels(self)

    require("modules.emperorReport.panel.EmperorReportPanel")
    self:registerPanel(EmperorReportPanel.NAME, EmperorReportPanel)

    require("modules.emperorReport.panel.EmperorLegionPanel")
    self:registerPanel(EmperorLegionPanel.NAME, EmperorLegionPanel)

    require("modules.emperorReport.panel.EmperorPersonPanel")
    self:registerPanel(EmperorPersonPanel.NAME, EmperorPersonPanel)
end

function EmperorReportView:initView()
    local panel = self:getPanel(EmperorReportPanel.NAME)
    panel:show()
end

function EmperorReportView:onShowView(extraMsg, isInit)
    EmperorReportView.super.onShowView(self, extraMsg, isInit, true)
end