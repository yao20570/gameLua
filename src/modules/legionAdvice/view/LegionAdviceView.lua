
LegionAdviceView = class("LegionAdviceView", BasicView)

function LegionAdviceView:ctor(parent)
    LegionAdviceView.super.ctor(self, parent)
end

function LegionAdviceView:finalize()
    LegionAdviceView.super.finalize(self)
end

function LegionAdviceView:registerPanels()
    LegionAdviceView.super.registerPanels(self)

    require("modules.legionAdvice.panel.LegionAdvicePanel")
    self:registerPanel(LegionAdvicePanel.NAME, LegionAdvicePanel)

    require("modules.legionAdvice.panel.LegionAdviceArmyPanel")
    self:registerPanel(LegionAdviceArmyPanel.NAME, LegionAdviceArmyPanel)

    require("modules.legionAdvice.panel.LegionAdviceHonourPanel")
    self:registerPanel(LegionAdviceHonourPanel.NAME, LegionAdviceHonourPanel)

    require("modules.legionAdvice.panel.LegionAdvicePeoplePanel")
    self:registerPanel(LegionAdvicePeoplePanel.NAME, LegionAdvicePeoplePanel)
end

function LegionAdviceView:initView()
    -- local panel = self:getPanel(LegionAdviceArmyPanel.NAME)
    -- panel:show()
    local panel = self:getPanel(LegionAdvicePanel.NAME)
    panel:show()
end

function LegionAdviceView:onShowView(extraMsg, isInit, isAutoUpdate)
    LegionAdviceView.super.onShowView(self,extraMsg, isInit,false)
    
    --TODO 这里要看一下为什么要调要
    --local panel = self:getPanel(LegionAdvicePanel.NAME)
    --panel:show()
end

function LegionAdviceView:updateAdvice(data)
    local panel1 = self:getPanel(LegionAdviceArmyPanel.NAME)
    local panel2 = self:getPanel(LegionAdvicePeoplePanel.NAME)
    local panel3 = self:getPanel(LegionAdviceHonourPanel.NAME)
    panel1:updateAdviceInfo()

    panel2:updateAdviceInfo()

    panel3:updateHonourInfo()
end