
LegionAdvicePanel = class("LegionAdvicePanel", BasicPanel)
LegionAdvicePanel.NAME = "LegionAdvicePanel"

function LegionAdvicePanel:ctor(view, panelName)
    LegionAdvicePanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function LegionAdvicePanel:finalize()
    LegionAdvicePanel.super.finalize(self)
end

function LegionAdvicePanel:initPanel()
	LegionAdvicePanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)

	self:addTabControl()
end

function LegionAdvicePanel:doLayout()
    if self._tabControl then  
        --创建UIPanelBg的时候已经做过自适应背景图 ，这里屏蔽
        -- local tabsPanel = self._tabControl:getTabsPanel()
        -- NodeUtils:adaptivePanelBg(self._uiPanelBg._bgImg5, GlobalConfig.downHeight - 10, tabsPanel)
    end
end

function LegionAdvicePanel:addTabControl()
	self.isCanShowOtherPanel = false
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(LegionAdviceArmyPanel.NAME, self:getTextWord(3500))
    tabControl:addTabPanel(LegionAdvicePeoplePanel.NAME, self:getTextWord(3501))
     tabControl:addTabPanel(LegionAdviceHonourPanel.NAME, self:getTextWord(3502))
    tabControl:setTabSelectByName(LegionAdviceArmyPanel.NAME)
    
    self._tabControl = tabControl
 
    -- self:setTitle(true, self:getTextWord(3503))
    self:setTitle(true, "legionAdvice", true)
end

function LegionAdvicePanel:onShowHandler(data)
    
    -- local panel = self:getPanel(LegionAdviceArmyPanel.NAME)
    -- panel:show()
end

function LegionAdvicePanel:registerEvents()
	LegionAdvicePanel.super.registerEvents(self)
end

function LegionAdvicePanel:onClosePanelHandler()
    self:dispatchEvent(LegionAdviceEvent.HIDE_SELF_EVENT)
end