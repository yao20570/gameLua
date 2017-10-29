
HeroView = class("HeroView", BasicView)

function HeroView:ctor(parent)
    HeroView.super.ctor(self, parent)
end

function HeroView:finalize()
    HeroView.super.finalize(self)
end

function HeroView:registerPanels()
    HeroView.super.registerPanels(self)

    require("modules.hero.panel.HeroPanel")
    self:registerPanel(HeroPanel.NAME, HeroPanel)

    require("modules.hero.panel.HeroTeamPanel")
    self:registerPanel(HeroTeamPanel.NAME, HeroTeamPanel)

    require("modules.hero.panel.HeroInfoPanel")
    self:registerPanel(HeroInfoPanel.NAME, HeroInfoPanel)

    require("modules.hero.panel.HeroTreasurePanel")
    self:registerPanel(HeroTreasurePanel.NAME, HeroTreasurePanel)
end

function HeroView:initView()
    -- local panel = self:getPanel(HeroPanel.NAME)
    -- panel:show()
end

function HeroView:onShowView(extraMsg,isInit)
	HeroView.super.onShowView(self,extraMsg, false)
	local panel = self:getPanel(HeroPanel.NAME)
    panel:show()
    panel:setHtmlStr("html/help_equip.html")
end

function HeroView:updatePosView()
    local panel = self:getPanel(HeroPanel.NAME)
    panel:initPosData()
end

function HeroView:heroInfoChange()
    local panel = self:getPanel(HeroPanel.NAME)
    panel:updateView()
end

function HeroView:onClosePanel()
    local panel = self:getPanel(HeroPanel.NAME)
    panel:onClosePanel()
end

function HeroView:onPosChangeUpdate(data)
    local panel = self:getPanel(HeroTeamPanel.NAME)
    panel:onPosChangeUpdate(data)
end

function HeroView:updateHeroImg()
    local panel = self:getPanel(HeroPanel.NAME)
    panel:updateHeroImg()
end