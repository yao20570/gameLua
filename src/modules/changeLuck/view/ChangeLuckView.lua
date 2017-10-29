
ChangeLuckView = class("ChangeLuckView", BasicView)

function ChangeLuckView:ctor(parent)
    ChangeLuckView.super.ctor(self, parent)
end

function ChangeLuckView:finalize()
    ChangeLuckView.super.finalize(self)
end

function ChangeLuckView:registerPanels()
    ChangeLuckView.super.registerPanels(self)

    require("modules.changeLuck.panel.ChangeLuckPanel")
    self:registerPanel(ChangeLuckPanel.NAME, ChangeLuckPanel)
end

function ChangeLuckView:onShowView(extraMsg, isInit, isAutoUpdate)
    ChangeLuckView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(ChangeLuckPanel.NAME)
    panel:show()
end

function ChangeLuckView:updateUI(awardId)
    local panel = self:getPanel(ChangeLuckPanel.NAME)
    panel:updateUI(awardId)
end