
HeroHallView = class("HeroHallView", BasicView)

function HeroHallView:ctor(parent)
    HeroHallView.super.ctor(self, parent)
end

function HeroHallView:finalize()
    HeroHallView.super.finalize(self)
end

function HeroHallView:registerPanels()
    HeroHallView.super.registerPanels(self)

    require("modules.heroHall.panel.HeroHallPanel")
    self:registerPanel(HeroHallPanel.NAME, HeroHallPanel)

    require("modules.heroHall.panel.HeroHallTrainPanel")
    self:registerPanel(HeroHallTrainPanel.NAME, HeroHallTrainPanel)

    require("modules.heroHall.panel.HeroHallFormationPanel")
    self:registerPanel(HeroHallFormationPanel.NAME, HeroHallFormationPanel)

    require("modules.heroHall.panel.HeroFormationLvUpPanel")
    self:registerPanel(HeroFormationLvUpPanel.NAME, HeroFormationLvUpPanel)

    require("modules.heroHall.panel.HeroFormationCheckPanel")
    self:registerPanel(HeroFormationCheckPanel.NAME, HeroFormationCheckPanel)

    require("modules.heroHall.panel.HeroPatchPanel")
    self:registerPanel(HeroPatchPanel.NAME, HeroPatchPanel)

    require("modules.heroHall.panel.HeroCompoundPanel")
    self:registerPanel(HeroCompoundPanel.NAME, HeroCompoundPanel)

    require("modules.heroHall.panel.HeroResolve")
    self:registerPanel(HeroResolve.NAME, HeroResolve)

    require("modules.heroHall.panel.HeroHallSalePanel")
    self:registerPanel(HeroHallSalePanel.NAME, HeroHallSalePanel)

end

function HeroHallView:initView()
    local panel = self:getPanel(HeroHallPanel.NAME)
    panel:show()
    panel:setHtmlStr("html/help_equip.html")
end


function HeroHallView:onUpdateView(data)
    local panel = self:getPanel(HeroHallPanel.NAME)
    panel:onUpdateView(data)
end

function HeroHallView:onZfLvUpdateSuccess()
    local panel = self:getPanel(HeroHallFormationPanel.NAME)
    panel:onZfLvUpdateSuccess()
end

function HeroHallView:onUpdatePropNum()
    local panel = self:getPanel(HeroFormationLvUpPanel.NAME)
    panel:onUpdateView(true)
end

function HeroHallView:onShowResolveView(data)
    local panel = self:getPanel(HeroResolve.NAME)
    panel:show(data)
end

function HeroHallView:onResolveResp()
    local panel = self:getPanel(HeroResolve.NAME)
    panel:hide()
end

function HeroHallView:updatePieceData()
    local panel = self:getPanel(HeroPatchPanel.NAME)
    panel:onUpdateView()
end