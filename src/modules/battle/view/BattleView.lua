
BattleView = class("BattleView", BasicView)

function BattleView:ctor(parent)
    BattleView.super.ctor(self, parent)
end

function BattleView:finalize()
    BattleView.super.finalize(self)
end

function BattleView:registerPanels()
    BattleView.super.registerPanels(self)

    require("modules.battle.panel.BattlePanel")
    self:registerPanel(BattlePanel.NAME, BattlePanel)
    
    require("modules.battle.panel.BattleResultPanel")
    self:registerPanel(BattleResultPanel.NAME, BattleResultPanel)

    require("modules.battle.panel.BattleEnterPanel")
    self:registerPanel(BattleEnterPanel.NAME, BattleEnterPanel)

    
    require("modules.battle.panel.BattleBossResultPanel")
    self:registerPanel(BattleBossResultPanel.NAME, BattleBossResultPanel)
end

function BattleView:initView()
    local panel = self:getPanel(BattlePanel.NAME)
    panel:show()
end

function BattleView:showBattleResultPanel(data)

    local curBtType = data.battle.type
    -- 世界boss战斗中的数值显示
    if curBtType == GameConfig.battleType.world_boss then
        local panel = self:getPanel(BattleBossResultPanel.NAME)
        panel:show()
        panel:onUpdateBattleResult(data)
    else
        local panel = self:getPanel(BattleResultPanel.NAME)
        panel:show()
        panel:onUpdateBattleResult(data)
    end
end

function BattleView:onCloseView()
    local panel = self:getPanel(BattleResultPanel.NAME)
    panel:hide()

    panel = self:getPanel(BattleBossResultPanel.NAME)
    panel:hide()
    
    local panel = self:getPanel(BattlePanel.NAME)
    panel:onRestPanel()
end

function BattleView:getMapPanel()
    local panel = self:getPanel(BattlePanel.NAME)
    local mapPanel = panel:getChildByName("mapPanel")
    return mapPanel
end

function BattleView:onBattleEndOpenFun()
    local panel = self:getPanel(BattleResultPanel.NAME)
    panel:onBattleEndOpenFun()
end

