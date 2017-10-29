
RealNameView = class("RealNameView", BasicView)

function RealNameView:ctor(parent)
    RealNameView.super.ctor(self, parent)
end

function RealNameView:finalize()
    RealNameView.super.finalize(self)
end

function RealNameView:registerPanels()
    RealNameView.super.registerPanels(self)

    require("modules.realName.panel.RealNamePanel")
    self:registerPanel(RealNamePanel.NAME, RealNamePanel)

    require("modules.realName.panel.RealNameDonePanel")
    self:registerPanel(RealNameDonePanel.NAME, RealNameDonePanel)
end

function RealNameView:initView()
    -- local panel = self:getPanel(RealNamePanel.NAME)
    -- panel:show()
end
