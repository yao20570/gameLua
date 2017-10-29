--
-- Author: zlf
-- Date: 2016年9月1日15:09:40
-- 武将府主界面


HeroHallPanel = class("HeroHallPanel", BasicPanel)
HeroHallPanel.NAME = "HeroHallPanel"

function HeroHallPanel:ctor(view, panelName)
    HeroHallPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function HeroHallPanel:finalize()
    HeroHallPanel.super.finalize(self)
end

function HeroHallPanel:initPanel()
	HeroHallPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)

    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(HeroHallTrainPanel.NAME, self:getTextWord(290065))
    -- tabControl:addTabPanel(HeroHallFormationPanel.NAME, self:getTextWord(290001))  --7.4版本暂时不上
    tabControl:addTabPanel(HeroPatchPanel.NAME, self:getTextWord(290011))
    tabControl:setTabSelectByName(HeroHallTrainPanel.NAME)

    self.allPanel = {HeroHallTrainPanel.NAME, HeroHallFormationPanel.NAME}

    self._tabControl = tabControl

    self:setTitle(true,"jiangjunfu",true)
end

function HeroHallPanel:registerEvents()
	HeroHallPanel.super.registerEvents(self)
end

function HeroHallPanel:onClosePanelHandler()
    self:dispatchEvent(HeroHallEvent.HIDE_SELF_EVENT)
end

function HeroHallPanel:onUpdateView(data)
    for k,v in pairs(self.allPanel) do
        local panel = self:getPanel(v)
        if panel:isVisible() then
            panel:onUpdateView()
        end
    end
end