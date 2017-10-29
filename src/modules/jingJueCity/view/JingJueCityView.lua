
JingJueCityView = class("JingJueCityView", BasicView)

function JingJueCityView:ctor(parent)
    JingJueCityView.super.ctor(self, parent)
end

function JingJueCityView:finalize()
    JingJueCityView.super.finalize(self)
end

function JingJueCityView:registerPanels()
    JingJueCityView.super.registerPanels(self)

    require("modules.jingJueCity.panel.JingJueCityPanel")
    self:registerPanel(JingJueCityPanel.NAME, JingJueCityPanel)
	require("modules.jingJueCity.panel.JingJueMainPanel")
    self:registerPanel(JingJueMainPanel.NAME, JingJueMainPanel)
	require("modules.jingJueCity.panel.JingJueShopPanel")
    self:registerPanel(JingJueShopPanel.NAME, JingJueShopPanel)
	require("modules.jingJueCity.panel.JingJueRankPanel")
    self:registerPanel(JingJueRankPanel.NAME, JingJueRankPanel)
    require("modules.jingJueCity.panel.JingJueRewardPanel")
    self:registerPanel(JingJueRewardPanel.NAME, JingJueRewardPanel)
    
end

function JingJueCityView:initView()
    local panel = self:getPanel(JingJueCityPanel.NAME)
    panel:show()
end
function JingJueCityView:afterOpen(data)
    local panel = self:getPanel(JingJueMainPanel.NAME)
    panel:afterOpen(data)
end
function JingJueCityView:afterOpenOnePos(data)
    local panel = self:getPanel(JingJueMainPanel.NAME)
    panel:afterOpenOnePos(data)
end
function JingJueCityView:updateJingJueView()
    local panel = self:getPanel(JingJueMainPanel.NAME)
    panel:updateJingJueView()
    local shopPanel = self:getPanel(JingJueShopPanel.NAME)
    shopPanel:updateJingJueShopView()
end
function JingJueCityView:openSeverback()
    local panel = self:getPanel(JingJueMainPanel.NAME)
    panel:openSeverback()
end
