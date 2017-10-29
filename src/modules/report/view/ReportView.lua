
ReportView = class("ReportView", BasicView)

function ReportView:ctor(parent)
    ReportView.super.ctor(self, parent)
end

function ReportView:finalize()
    ReportView.super.finalize(self)
end

function ReportView:registerPanels()
    ReportView.super.registerPanels(self)

    require("modules.report.panel.ReportPanel")
    self:registerPanel(ReportPanel.NAME, ReportPanel)
end

function ReportView:initView()
    self:openView()
end

function ReportView:openView( playerName )
    local panel = self:getPanel(ReportPanel.NAME)
    panel:show()
    panel:onUpdateName( playerName or "" )
end

function ReportView:updateInfo( reportInfo )
	local panel = self:getPanel(ReportPanel.NAME)
	panel:onUpdateInfo( reportInfo )
end