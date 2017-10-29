
HeroPokedexView = class("HeroPokedexView", BasicView)

function HeroPokedexView:ctor(parent)
    HeroPokedexView.super.ctor(self, parent)
end

function HeroPokedexView:finalize()
    HeroPokedexView.super.finalize(self)
end

function HeroPokedexView:registerPanels()
    HeroPokedexView.super.registerPanels(self)

    require("modules.heroPokedex.panel.HeroPokedexPanel")
    self:registerPanel(HeroPokedexPanel.NAME, HeroPokedexPanel)

    require("modules.heroPokedex.panel.HeroWhitePanel")
    self:registerPanel(HeroWhitePanel.NAME, HeroWhitePanel)

    require("modules.heroPokedex.panel.HeroVioletPanel")
    self:registerPanel(HeroVioletPanel.NAME, HeroVioletPanel)

    require("modules.heroPokedex.panel.HeroBluePanel")
    self:registerPanel(HeroBluePanel.NAME, HeroBluePanel)

    require("modules.heroPokedex.panel.HeroGreenPanel")
    self:registerPanel(HeroGreenPanel.NAME, HeroGreenPanel)
end

function HeroPokedexView:initView()
    local panel = self:getPanel(HeroPokedexPanel.NAME)
    panel:show()
end

function HeroPokedexView:onShowView(extraMsg,isInit)
    HeroPokedexView.super.onShowView(self,extraMsg, isInit)
    local panel = self:getPanel(HeroPokedexPanel.NAME)
    panel:onShowHandler()
end
