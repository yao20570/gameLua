DayTurntableRankPanel = class("DayTurntableRankPanel", BasicPanel)
DayTurntableRankPanel.NAME = "DayTurntableRankPanel"

function DayTurntableRankPanel:ctor(view, panelName)
    DayTurntableRankPanel.super.ctor(self, view, panelName)

    --self:setUseNewPanelBg(true)
end

function DayTurntableRankPanel:finalize()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:finalize()
    end
    if self._uiBuilding ~= nil then
        self._uiBuilding:finalize()
    end
    DayTurntableRankPanel.super.finalize(self)
end

function DayTurntableRankPanel:initPanel()
    DayTurntableRankPanel.super.initPanel(self)


	self.proxy = self:getProxy(GameProxys.Activity)

	local rankData = self.proxy:getTurnTableInfo(self.proxy.curActivityData.activityId)
	local num = self.proxy.allJifen or rankData.jifen

	local rankInfo = self.proxy:getRankInfoById()
	local rankingID = self.proxy:getCurActivityData().rankId
	local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
	local rankingreward = configData.rankingreward

	local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)

	if self.rankPanel == nil then
		self.rankPanel = UITabRankPanel.new(self, self, nil, {rankData = rankInfo, num = num, tipText = text, rankID = rankingreward})
	else
		self.rankPanel:updateData({rankData = rankInfo, num = num, tipText = text, rankID = rankingreward})
	end
end

function DayTurntableRankPanel:doLayout()
    --local panel = self:getChildByName("Panel_14")
    --local tabsPanel = self:getTabsPanel()
    --NodeUtils:adaptiveUpPanel(panel, tabsPanel, GlobalConfig.topTabsHeight)
end

function DayTurntableRankPanel:onShowHandler()

	local rankData = self.proxy:getTurnTableInfo(self.proxy.curActivityData.activityId)
	local num = self.proxy.allJifen or rankData.jifen

	local rankInfo = self.proxy:getRankInfoById()
	local rankingID = self.proxy:getCurActivityData().rankId
	local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
	local rankingreward = configData.rankingreward
    
	local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)

	self.rankPanel:updateData({rankData = rankInfo, num = num, tipText = text, rankID = rankingreward})
end

function DayTurntableRankPanel:updateRankView()
	if self.rankPanel ~= nil and self.rankPanel._uiSkin:isVisible() then
		local rankData = self.proxy:getTurnTableInfo(self.proxy.curActivityData.activityId)
		local num = self.proxy.allJifen or rankData.jifen
        
	    local rankInfo = self.proxy:getRankInfoById()
	    local rankingID = self.proxy:getCurActivityData().rankId
	    local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
	    local rankingreward = configData.rankingreward

	    local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)

		self.rankPanel:updateData({rankData = rankInfo, num = num, tipText = text, rankID = rankingreward})
	end
end

