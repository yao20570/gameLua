
CountryView = class("CountryView", BasicView)

function CountryView:ctor(parent)
    CountryView.super.ctor(self, parent)
end

function CountryView:finalize()
    CountryView.super.finalize(self)
end

function CountryView:registerPanels()
    CountryView.super.registerPanels(self)

    require("modules.country.panel.CountryPanel")
    self:registerPanel(CountryPanel.NAME, CountryPanel)

    require("modules.country.panel.CountryRoyalPanel")
    self:registerPanel(CountryRoyalPanel.NAME, CountryRoyalPanel)
    require("modules.country.panel.CountryDynastyPanel")
    self:registerPanel(CountryDynastyPanel.NAME, CountryDynastyPanel)

    require("modules.country.panel.CountryCheckPanel")
    self:registerPanel(CountryCheckPanel.NAME, CountryCheckPanel)

    require("modules.country.panel.CountryPrisonPanel")
    self:registerPanel(CountryPrisonPanel.NAME, CountryPrisonPanel)

    require("modules.country.panel.CountryPrisonCheckPanel")
    self:registerPanel(CountryPrisonCheckPanel.NAME, CountryPrisonCheckPanel)
end

function CountryView:initView()
    local panel = self:getPanel(CountryPanel.NAME)
    panel:show()
end