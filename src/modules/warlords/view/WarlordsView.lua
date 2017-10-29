
WarlordsView = class("WarlordsView", BasicView)

function WarlordsView:ctor(parent)
    WarlordsView.super.ctor(self, parent)
end

function WarlordsView:finalize()
    WarlordsView.super.finalize(self)
end

function WarlordsView:registerPanels()
    WarlordsView.super.registerPanels(self)

    require("modules.warlords.panel.WarlordsPanel")
    self:registerPanel(WarlordsPanel.NAME, WarlordsPanel)
    require("modules.warlords.panel.WarlordsLegionJoinPanel")
    self:registerPanel(WarlordsLegionJoinPanel.NAME, WarlordsLegionJoinPanel)
    require("modules.warlords.panel.WarlordsSignPanel")
    self:registerPanel(WarlordsSignPanel.NAME, WarlordsSignPanel)
    require("modules.warlords.panel.WarlordsTeamPanel")
    self:registerPanel(WarlordsTeamPanel.NAME, WarlordsTeamPanel)
    require("modules.warlords.panel.WarlordsTeamInfoPanel")
    self:registerPanel(WarlordsTeamInfoPanel.NAME, WarlordsTeamInfoPanel)
end

function WarlordsView:initView()
    local panel = self:getPanel(WarlordsPanel.NAME)
    panel:show()
end

function WarlordsView:onWarlordsOpen()
    local panel = self:getPanel(WarlordsPanel.NAME)
    panel:onWarlordsOpen()

    panel = self:getPanel(WarlordsSignPanel.NAME)
    if panel:isVisible() then
        panel:onGetMylegionsList()
    end
end

function WarlordsView:onCloseView()
    self.super.onCloseView(self)
    local panel = self:getPanel(WarlordsPanel.NAME)
    panel:onWarlordsClose()
end

function WarlordsView:onGetlegionsList()
    local panel = self:getPanel(WarlordsLegionJoinPanel.NAME)
    panel:onGetlegionsList()
end

function WarlordsView:onGetMylegionsList()
    local panel = self:getPanel(WarlordsSignPanel.NAME)
    panel:show(nil,WarlordsPanel.NAME)
end

function WarlordsView:onGetFightInfos()
    local panel = self:getPanel(WarlordsTeamInfoPanel.NAME)
    panel:show()
end

function WarlordsView:onSetSignHandle()
    local panel = self:getPanel(WarlordsSignPanel.NAME)
    if panel:isVisible() then
        panel:onGetMylegionsList()
    else
        panel:show()
    end
end

function WarlordsView:onWarlordsFailedHandle()  --活动开启失败
    local panel = self:getPanel(WarlordsPanel.NAME)
    panel:onWarlordsOpen()
end