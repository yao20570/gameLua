
CheckTeamView = class("CheckTeamView", BasicView)

function CheckTeamView:ctor(parent)
    CheckTeamView.super.ctor(self, parent)
end

function CheckTeamView:finalize()
    CheckTeamView.super.finalize(self)
end

function CheckTeamView:registerPanels()
    CheckTeamView.super.registerPanels(self)

    require("modules.checkTeam.panel.CheckTeamPanel")
    self:registerPanel(CheckTeamPanel.NAME, CheckTeamPanel)

end

function CheckTeamView:initView()
    -- local panel = self:getPanel(CheckTeamPanel.NAME)
    -- panel:show()
end

function CheckTeamView:onShowView(extraMsg,isInit)
	local panel = self:getPanel(CheckTeamPanel.NAME)
    panel:show(extraMsg)
end