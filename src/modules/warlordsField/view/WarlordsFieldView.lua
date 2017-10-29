
WarlordsFieldView = class("WarlordsFieldView", BasicView)

function WarlordsFieldView:ctor(parent)
    WarlordsFieldView.super.ctor(self, parent)
end

function WarlordsFieldView:finalize()
    WarlordsFieldView.super.finalize(self)
end

function WarlordsFieldView:registerPanels()
    WarlordsFieldView.super.registerPanels(self)

    require("modules.warlordsField.panel.WarlordsFieldPanel")
    self:registerPanel(WarlordsFieldPanel.NAME, WarlordsFieldPanel)

    require("modules.warlordsField.panel.WarlordsFieldLegionPanel")
    self:registerPanel(WarlordsFieldLegionPanel.NAME, WarlordsFieldLegionPanel)

    require("modules.warlordsField.panel.WarlordsFieldPerPanel")
    self:registerPanel(WarlordsFieldPerPanel.NAME, WarlordsFieldPerPanel)

    require("modules.warlordsField.panel.WarlordsFieldAllPanel")
    self:registerPanel(WarlordsFieldAllPanel.NAME, WarlordsFieldAllPanel)

    require("modules.warlordsField.panel.WarlordsFieldPerFightPanel")
    self:registerPanel(WarlordsFieldPerFightPanel.NAME, WarlordsFieldPerFightPanel)
end

function WarlordsFieldView:initView()
    local panel = self:getPanel(WarlordsFieldPanel.NAME)
    panel:show()
end

function WarlordsFieldView:onFightInfosChange()
    local panel = self:getPanel(WarlordsFieldLegionPanel.NAME)
    if panel:isVisible() == true then
        panel:onShowHandler()
    end

    panel = self:getPanel(WarlordsFieldPerPanel.NAME)
    if panel:isVisible() == true then
        panel:onShowHandler()
    end

    panel = self:getPanel(WarlordsFieldAllPanel.NAME)
    if panel:isVisible() == true then
        panel:onShowHandler()
    end
end

function WarlordsFieldView:onOpenModule()
    -- local panel = self:getPanel(WarlordsFieldPanel.NAME)
    -- panel:onOpenModule()
end

function WarlordsFieldView:onComBatProgress()
    local panel = self:getPanel(WarlordsFieldAllPanel.NAME)
    panel:onComBatProgress()
end