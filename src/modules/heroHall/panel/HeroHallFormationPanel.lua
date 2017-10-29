--
-- Author: zlf
-- Date: 2016年9月1日15:11:33
-- 武将府战法界面


HeroHallFormationPanel = class("HeroHallFormationPanel", BasicPanel)
HeroHallFormationPanel.NAME = "HeroHallFormationPanel"

function HeroHallFormationPanel:ctor(view, panelName)
	HeroHallFormationPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function HeroHallFormationPanel:initPanel()
	HeroHallFormationPanel.super.initPanel(self)
	self.listView = self:getChildByName("ListView_3")

	
	self.proxy = self:getProxy(GameProxys.Hero)
	self.Config = {}
	for i=1,5 do
		self.Config[i] = {id = i*100}
	end

end

function HeroHallFormationPanel:doLayout()
	local tabsPanel = self:getTabsPanel()

	NodeUtils:adaptiveListView(self.listView, GlobalConfig.downHeight, tabsPanel, 0)
end

function HeroHallFormationPanel:finalize()
    HeroHallFormationPanel.super.finalize(self)
end

function HeroHallFormationPanel:registerEvents()
end

function HeroHallFormationPanel:onShowHandler()
	self:renderListView(self.listView, self.Config, self, self.renderItemPanel)
end

function HeroHallFormationPanel:onClosePanelHandler()
    self:dispatchEvent(HeroHallEvent.HIDE_SELF_EVENT)
end

function HeroHallFormationPanel:renderItemPanel(item, data, index)
	local nameLab = item:getChildByName("nameLab")
	nameLab:setString((index+1)..TextWords:getTextWord(290007))
	for i=1,4 do
		local iconImg = item:getChildByName("iconImg"..i)
		local lab = iconImg:getChildByName("nameLab")
		local lockImg = iconImg:getChildByName("lockImg")
		local ID = data.id + i
		local info = self.proxy:getFormationById(ID)

		local configInfo = ConfigDataManager:getConfigById(ConfigData.FormationsConfig, ID)

		--info为空，表示阵法未解锁
		-- lockImg:setVisible(info == nil)

		local url = info == nil and "images/newGui2/Icon_lock.png" or string.format("images/heroFormation/%d.png", ID)
		TextureManager:updateImageView(lockImg, url)
		local labStr = info == nil and configInfo.info or configInfo.name .. info .. TextWords:getTextWord(290008)
		lab:setString(labStr)
		iconImg:setTouchEnabled(info ~= nil)
		iconImg.data = configInfo
		self:addTouchEventListener(iconImg, self.showLvUpPanel)
	end
end

function HeroHallFormationPanel:showLvUpPanel(sender)
	local data = sender.data
	local level = self.proxy:getFormationById(data.ID)
	if level == nil then
		return
	end
	local maxLevel = data.lvmax
	local panelName = HeroFormationLvUpPanel.NAME
	if level ~= nil and level >= maxLevel then
		panelName = HeroFormationCheckPanel.NAME
	end
	local panel = self:getPanel(panelName)
	panel:show(data)
end

function HeroHallFormationPanel:onZfLvUpdateSuccess()
	-- local panel = self:getPanel(HeroFormationLvUpPanel.NAME)
	-- panel:hide()
	self:onShowHandler()
	local panel = self:getPanel(HeroFormationLvUpPanel.NAME)
	panel:onUpdateView()
end

function HeroHallFormationPanel:onUpdateView()

end