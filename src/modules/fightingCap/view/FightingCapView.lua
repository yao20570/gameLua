
FightingCapView = class("FightingCapView", BasicView)

function FightingCapView:ctor(parent)
    FightingCapView.super.ctor(self, parent)
end

function FightingCapView:finalize()
    FightingCapView.super.finalize(self)
end

function FightingCapView:registerPanels()
    FightingCapView.super.registerPanels(self)

    -- require("modules.fightingCap.panel.FightingCapPanel")
    -- self:registerPanel(FightingCapPanel.NAME, FightingCapPanel)
    
    --
    require("modules.fightingCap.panel.FightingCapMainPanel")
    self:registerPanel(FightingCapMainPanel.NAME, FightingCapMainPanel)
end

function FightingCapView:initView()
    -- local panel = self:getPanel(FightingCapPanel.NAME)
    -- panel:show()
    local mainPanel = self:getPanel(FightingCapMainPanel.NAME)
    mainPanel:show()
end
--数据更新
function FightingCapView:updateData(data)
    local mainPanel = self:getPanel(FightingCapMainPanel.NAME)
    mainPanel:updateData()
end 
function FightingCapView:updateRankHandler()
    
    local panel = self:getPanel(FightingCapMainPanel.NAME)
    panel:updateRankHandler()

end

function FightingCapView:onShowView(extraMsg, isInit)
    FightingCapView.super.onShowView(self,extraMsg, isInit, true)
end

--关闭系统
function FightingCapView:onCloseView()
    FightingCapView.super.onCloseView(self)
end