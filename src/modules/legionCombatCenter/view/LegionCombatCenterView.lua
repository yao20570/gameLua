
LegionCombatCenterView = class("LegionCombatCenterView", BasicView)

function LegionCombatCenterView:ctor(parent)
    LegionCombatCenterView.super.ctor(self, parent)
end

function LegionCombatCenterView:finalize()
    LegionCombatCenterView.super.finalize(self)
end

function LegionCombatCenterView:registerPanels()
    LegionCombatCenterView.super.registerPanels(self)

    require("modules.legionCombatCenter.panel.LegionCombatCenterPanel")
    self:registerPanel(LegionCombatCenterPanel.NAME, LegionCombatCenterPanel)
    require("modules.legionCombatCenter.panel.LegionCapterPanel")
    self:registerPanel(LegionCapterPanel.NAME, LegionCapterPanel)

    require("modules.legionCombatCenter.panel.LegionActivityPanel")
    self:registerPanel(LegionActivityPanel.NAME, LegionActivityPanel)
end

function LegionCombatCenterView:initView()
    local panel = self:getPanel(LegionCombatCenterPanel.NAME)
    panel:show()
end

function LegionCombatCenterView:setFirstPanelShow()
    local panel = self:getPanel(LegionCombatCenterPanel.NAME)
    panel:setFirstPanelShow()
end

function LegionCombatCenterView:hideModuleHandler()
    self:dispatchEvent(LegionCombatCenterEvent.HIDE_SELF_EVENT, {})
end

function LegionCombatCenterView:onChapterUpdate()
    -- body
    local panel = self:getPanel(LegionCapterPanel.NAME)
    if panel:isVisible() then
        panel:onChapterUpdate()
    end
    -- 标签的红点刷新
    local centerPanel = self:getPanel(LegionCombatCenterPanel.NAME)
    centerPanel:updateTabItemCount()
end

--------------------------------------------------------------------
-- 重写onShowView(),用于每次打开panel都执行onShowHandler()
function LegionCombatCenterView:onShowView(extraMsg, isInit)
    LegionCombatCenterView.super.onShowView(self,extraMsg, isInit, true)
end

function LegionCombatCenterView:newBattleActivity()
    local panel = self:getPanel(LegionActivityPanel.NAME)
    if panel:isInitUI() and panel:isVisible() then
        panel:onShowHandler()
    end
end

function LegionCombatCenterView:isShowActivityTab()
    local panel = self:getPanel(LegionCombatCenterPanel.NAME)
    panel:isShowActivityTab()
end
