--
-- Author: zlf
-- Date: 2016年9月1日15:11:33
-- 武将府培养界面


HeroHallTrainPanel = class("HeroHallTrainPanel", BasicPanel)
HeroHallTrainPanel.NAME = "HeroHallTrainPanel"

function HeroHallTrainPanel:ctor(view, panelName)
	HeroHallTrainPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function HeroHallTrainPanel:initPanel()
	HeroHallTrainPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Hero)
end

function HeroHallTrainPanel:doLayout()
	-- local listView = self.uiHeroPanel:getListView()
	-- local tabsPanel = self:getTabsPanel()
	-- local bottom = self.uiHeroPanel:getBottomPanel()
	-- NodeUtils:adaptiveListView(listView, bottom, tabsPanel)
end

function HeroHallTrainPanel:finalize()
	if self.uiHeroPanel ~= nil then
    	self.uiHeroPanel:destory()
    	self.uiHeroPanel = nil
    end
    HeroHallTrainPanel.super.finalize(self)
end

function HeroHallTrainPanel:registerEvents()
end

function HeroHallTrainPanel:onShowHandler()
	self._isHave = true
	local data = clone(self.proxy:getAllHeroData())
	local panel = self:getTabsPanel()
	if self.uiHeroPanel == nil then
		self.uiHeroPanel = UIHeroPanel.new(self, data, 1, nil, panel, true)
	else
		self.uiHeroPanel:updateView(data)
	end

	
end

function HeroHallTrainPanel:onClosePanelHandler()
    self:dispatchEvent(HeroHallEvent.HIDE_SELF_EVENT)
end

function HeroHallTrainPanel:onUpdateView()
	self:onShowHandler()
end