
LuckTurntableView = class("LuckTurntableView", BasicView)

function LuckTurntableView:ctor(parent)
    LuckTurntableView.super.ctor(self, parent)
end

function LuckTurntableView:finalize()
    LuckTurntableView.super.finalize(self)
end

function LuckTurntableView:registerPanels()
    LuckTurntableView.super.registerPanels(self)

    require("modules.luckTurntable.panel.LuckTurntablePanel")
    self:registerPanel(LuckTurntablePanel.NAME, LuckTurntablePanel)
end

function LuckTurntableView:onShowView(extraMsg, isInit, isAutoUpdate)
    LuckTurntableView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(LuckTurntablePanel.NAME)
    panel:show()
end

function LuckTurntableView:updateLuckTurntableInfo(data)
    local panel = self:getPanel(LuckTurntablePanel.NAME)
    panel:updateActivityInfoUI(data)
end
