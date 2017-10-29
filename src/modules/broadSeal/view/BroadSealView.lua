
BroadSealView = class("BroadSealView", BasicView)

function BroadSealView:ctor(parent)
    BroadSealView.super.ctor(self, parent)
end

function BroadSealView:finalize()
    BroadSealView.super.finalize(self)
end

function BroadSealView:registerPanels()
    BroadSealView.super.registerPanels(self)

    require("modules.broadSeal.panel.BroadSealPanel")
    self:registerPanel(BroadSealPanel.NAME, BroadSealPanel)
end

function BroadSealView:initView()
    local panel = self:getPanel(BroadSealPanel.NAME)
    panel:show()
end
function BroadSealView:updateBroadSealInfo()
    local panel = self:getPanel(BroadSealPanel.NAME)
    panel:updateBroadSealView()
end
function BroadSealView:afterCollect(infoTable)
    local panel = self:getPanel(BroadSealPanel.NAME)
    panel:afterCollect(infoTable)
end
function BroadSealView:afterCompose(rewardList)
    local panel = self:getPanel(BroadSealPanel.NAME)
    panel:afterCompose(rewardList)
end

