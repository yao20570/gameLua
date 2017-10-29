
CookingWineView = class("CookingWineView", BasicView)

function CookingWineView:ctor(parent)
    CookingWineView.super.ctor(self, parent)
end

function CookingWineView:finalize()
    CookingWineView.super.finalize(self)
end

function CookingWineView:registerPanels()
    CookingWineView.super.registerPanels(self)

    require("modules.cookingWine.panel.CookingWinePanel")
    self:registerPanel(CookingWinePanel.NAME, CookingWinePanel)

    require("modules.cookingWine.panel.CookingWineMainPanel")
    self:registerPanel(CookingWineMainPanel.NAME, CookingWineMainPanel)

	require("modules.cookingWine.panel.CookingWineRankPanel")
    self:registerPanel(CookingWineRankPanel.NAME, CookingWineRankPanel)

	require("modules.cookingWine.panel.CookingSelectHeroPanel")
    self:registerPanel(CookingSelectHeroPanel.NAME, CookingSelectHeroPanel)

    require("modules.cookingWine.panel.CookingRewardPanel")
    self:registerPanel(CookingRewardPanel.NAME, CookingRewardPanel)
end

function CookingWineView:initView()
    local panel = self:getPanel(CookingWinePanel.NAME)
    panel:show()
end
function CookingWineView:updateCookInfo()
    local cookingWineMainPanel = self:getPanel(CookingWineMainPanel.NAME)
    cookingWineMainPanel:updateCookingView()

end
function CookingWineView:closeCookselectPanel()
    local cookingSelectHeroPanel = self:getPanel(CookingSelectHeroPanel.NAME)
    cookingSelectHeroPanel:hide()

end
function CookingWineView:afterToast(effectData)
    local cookingWineMainPanel = self:getPanel(CookingWineMainPanel.NAME)
    cookingWineMainPanel:afterToast(effectData)
end


