
LionTurntableView = class("LionTurntableView", BasicView)

function LionTurntableView:ctor(parent)
    LionTurntableView.super.ctor(self, parent)
end

function LionTurntableView:finalize()
    LionTurntableView.super.finalize(self)
end

function LionTurntableView:registerPanels()
    LionTurntableView.super.registerPanels(self)

    require("modules.lionTurntable.panel.LionTurntablePanel")
    self:registerPanel(LionTurntablePanel.NAME, LionTurntablePanel)
end

function LionTurntableView:initView()
    local panel = self:getPanel(LionTurntablePanel.NAME)
    panel:show()
end

function LionTurntableView:afterConscript(data)
    local panel = self:getPanel(LionTurntablePanel.NAME)
    panel:afterConscript(data)
end
function LionTurntableView:updateLionTurnView()
    local panel = self:getPanel(LionTurntablePanel.NAME)
    panel:updateLionTurnView()
end
