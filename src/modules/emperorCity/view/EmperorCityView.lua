
EmperorCityView = class("EmperorCityView", BasicView)

function EmperorCityView:ctor(parent)
    EmperorCityView.super.ctor(self, parent)
end

function EmperorCityView:finalize()
    EmperorCityView.super.finalize(self)
end

function EmperorCityView:registerPanels()
    EmperorCityView.super.registerPanels(self)

    require("modules.emperorCity.panel.EmperorCityPanel")
    self:registerPanel(EmperorCityPanel.NAME, EmperorCityPanel)

    require("modules.emperorCity.panel.EmperorCityHelpPanel")
    self:registerPanel(EmperorCityHelpPanel.NAME, EmperorCityHelpPanel)

    require("modules.emperorCity.panel.EmperorCityInfoPanel")
    self:registerPanel(EmperorCityInfoPanel.NAME, EmperorCityInfoPanel)

    require("modules.emperorCity.panel.EmperorCityRankPanel")
    self:registerPanel(EmperorCityRankPanel.NAME, EmperorCityRankPanel)
end

function EmperorCityView:initView()
    local panel = self:getPanel(EmperorCityPanel.NAME)
    panel:show()
end