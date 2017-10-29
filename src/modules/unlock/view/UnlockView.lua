
UnlockView = class("UnlockView", BasicView)

function UnlockView:ctor(parent)
    UnlockView.super.ctor(self, parent)
end

function UnlockView:finalize()
    UnlockView.super.finalize(self)
end

function UnlockView:registerPanels()
    UnlockView.super.registerPanels(self)

    -- require("modules.unlock.panel.UnlockPanel")
    -- self:registerPanel(UnlockPanel.NAME, UnlockPanel)

    require("modules.unlock.panel.UnlockNewPanel")
    self:registerPanel(UnlockNewPanel.NAME, UnlockNewPanel)
end

function UnlockView:initView()
    -- local panel = self:getPanel(UnlockPanel.NAME)
    -- panel:show()
end

function UnlockView:onShowView(extraMsg, isInit, isAutoUpdate)
    UnlockView.super.onShowView(self, extraMsg, isInit)

    local panel = self:getPanel(UnlockNewPanel.NAME)
    panel:show(extraMsg)
end