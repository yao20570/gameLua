
TellTheWorldView = class("TellTheWorldView", BasicView)

function TellTheWorldView:ctor(parent)
    TellTheWorldView.super.ctor(self, parent)
end

function TellTheWorldView:finalize()
    TellTheWorldView.super.finalize(self)
end

function TellTheWorldView:registerPanels()
    TellTheWorldView.super.registerPanels(self)

    require("modules.tellTheWorld.panel.TellTheWorldPanel")
    self:registerPanel(TellTheWorldPanel.NAME, TellTheWorldPanel)
end

function TellTheWorldView:initView()
    -- local panel = self:getPanel(TellTheWorldPanel.NAME)
    -- panel:show()
end

function TellTheWorldView:onShowView(extraMsg, isInit, isAutoUpdate)
    TellTheWorldView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
    local panel = self:getPanel(TellTheWorldPanel.NAME)
    panel:show(extraMsg)
end