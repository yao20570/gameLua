
TownReportView = class("TownReportView", BasicView)

function TownReportView:ctor(parent)
    TownReportView.super.ctor(self, parent)
end

function TownReportView:finalize()
    TownReportView.super.finalize(self)
end

function TownReportView:registerPanels()
    TownReportView.super.registerPanels(self)

    require("modules.townReport.panel.TownReportPanel")
    self:registerPanel(TownReportPanel.NAME, TownReportPanel)

    require("modules.townReport.panel.TownAllReportPanel")
    self:registerPanel(TownAllReportPanel.NAME, TownAllReportPanel)

    require("modules.townReport.panel.TownLegionReportPanel")
    self:registerPanel(TownLegionReportPanel.NAME, TownLegionReportPanel)

    require("modules.townReport.panel.TownSpareTeamPanel")
    self:registerPanel(TownSpareTeamPanel.NAME, TownSpareTeamPanel)

    require("modules.townReport.panel.TownMyTeamPanel")
    self:registerPanel(TownMyTeamPanel.NAME, TownMyTeamPanel)
end

function TownReportView:initView()
--    local panel = self:getPanel(TownReportPanel.NAME)
--    panel:show()
end

function TownReportView:onShowView(extraMsg, isInit)
    TownReportView.super.onShowView(self, msg, isInit, true)
    local panel = self:getPanel(TownReportPanel.NAME)
    panel:show()
end

function TownReportView:hideModuleHandler()
    self:dispatchEvent(TownReportEvent.HIDE_SELF_EVENT, {})
end