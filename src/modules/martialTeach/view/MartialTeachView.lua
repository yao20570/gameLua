
MartialTeachView = class("MartialTeachView", BasicView)

function MartialTeachView:ctor(parent)
    MartialTeachView.super.ctor(self, parent)
end

function MartialTeachView:finalize()
    MartialTeachView.super.finalize(self)
end

function MartialTeachView:registerPanels()
    MartialTeachView.super.registerPanels(self)

    require("modules.martialTeach.panel.MartialTeachPanel")
    self:registerPanel(MartialTeachPanel.NAME, MartialTeachPanel)
    require("modules.martialTeach.panel.MartialMainPanel")
    self:registerPanel(MartialMainPanel.NAME, MartialMainPanel)
    require("modules.martialTeach.panel.MartialRankPanel")
    self:registerPanel(MartialRankPanel.NAME, MartialRankPanel)
    require("modules.martialTeach.panel.MartialRewardPanel")
    self:registerPanel(MartialRewardPanel.NAME, MartialRewardPanel)
end

function MartialTeachView:initView()
    local panel = self:getPanel(MartialTeachPanel.NAME)
    panel:show()
end
function MartialTeachView:updateMartialinfo()
    local martialMainPanel = self:getPanel(MartialMainPanel.NAME)
    martialMainPanel:updateMartialView()
    local martialRankPanel = self:getPanel(MartialRankPanel.NAME)
    martialRankPanel:showView()
end
function MartialTeachView:updateRankData()
    local martialMainPanel = self:getPanel(MartialMainPanel.NAME)
    martialMainPanel:updateRankData()
    local martialRankPanel = self:getPanel(MartialRankPanel.NAME)
    martialRankPanel:showView()
end
function MartialTeachView:afterMartiallearn(rewardList)
    local martialMainPanel = self:getPanel(MartialMainPanel.NAME)
    martialMainPanel:afterMartiallearn(rewardList)
end





