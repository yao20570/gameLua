
SpringSquibView = class("SpringSquibView", BasicView)

function SpringSquibView:ctor(parent)
    SpringSquibView.super.ctor(self, parent)
end

function SpringSquibView:finalize()
    SpringSquibView.super.finalize(self)
end

function SpringSquibView:registerPanels()
    SpringSquibView.super.registerPanels(self)

    require("modules.springSquib.panel.SpringSquibPanel")
    self:registerPanel(SpringSquibPanel.NAME, SpringSquibPanel)

    require("modules.springSquib.panel.SpringSquibMainPanel")
    self:registerPanel(SpringSquibMainPanel.NAME, SpringSquibMainPanel)

    require("modules.springSquib.panel.SpringSquibRewardPanel")
    self:registerPanel(SpringSquibRewardPanel.NAME, SpringSquibRewardPanel)
end

function SpringSquibView:initView()
    local panel = self:getPanel(SpringSquibPanel.NAME)
    panel:show()
end
function SpringSquibView:updatePosInfo()
    local panel = self:getPanel(SpringSquibMainPanel.NAME)
    panel:updateMainPanel()
end
function SpringSquibView:afterKindle(pos)
    local panel = self:getPanel(SpringSquibMainPanel.NAME)
    panel:afterKindle(pos)
end

