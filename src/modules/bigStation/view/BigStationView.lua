
BigStationView = class("BigStationView", BasicView)

function BigStationView:ctor(parent)
    BigStationView.super.ctor(self, parent)
end

function BigStationView:finalize()
    BigStationView.super.finalize(self)
end

function BigStationView:registerPanels()
    BigStationView.super.registerPanels(self)

    require("modules.bigStation.panel.BigStationPanel")
    self:registerPanel(BigStationPanel.NAME, BigStationPanel)
end

function BigStationView:initView()
    local panel = self:getPanel(BigStationPanel.NAME)
    panel:show()
end