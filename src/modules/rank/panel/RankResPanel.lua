-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016年12月15日10:22:31
--  * @Description: 征矿榜
--  */
RankResPanel = class("RankResPanel", BasicPanel)
RankResPanel.NAME = "RankResPanel"

function RankResPanel:ctor(view, panelName)
    RankResPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function RankResPanel:finalize()
    RankResPanel.super.finalize(self)
end

function RankResPanel:initPanel()
	RankResPanel.super.initPanel(self)
	self._listview = self:getChildByName("ListView_rank")
	self._topPanel = self:getChildByName("Panel_title")
	self._proxy = self:getProxy(GameProxys.Rank)

	local items = self._listview:getItems()
	for k,v in pairs(items) do
		v:setVisible(false)
	end
end

function RankResPanel:doLayout()
	local bestTopPanel = GlobalConfig.topHeight - 6

	NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil, nil, bestTopPanel)

	NodeUtils:adaptiveListView(self._listview, GlobalConfig.downHeight + 5, self._topPanel)
end

function RankResPanel:onShowHandler()
	local data = self._proxy:getResRankInfo()
	if data == nil then
		return
	end
	local roleProxy = self:getProxy(GameProxys.Role)
	self._myName = roleProxy:getRoleName()
	self:renderListView(self._listview, data, self, self.renderMethod)
end

function RankResPanel:renderMethod(item, data, index)
	item:setVisible(true)
	local resLab = item:getChildByName("resLab")
	local Image_line = item:getChildByName("Image_line")
	local nameImg = item:getChildByName("Image_16")
	Image_line:setVisible(index%2 == 0)
	local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ResourcePointConfig, "type", data.type, "level", data.lv)
	resLab:setString(config.name)
	local rankData = data.rankPlayerInfos or {}
	nameImg:setVisible(false)
	for i=1,3 do
		local nameLab = item:getChildByName("nameLab"..i)
		local v = rankData[i]
		nameLab:setVisible(v ~= nil)
		nameLab:setTouchEnabled(v ~= nil)
		if v ~= nil then
			nameLab:setString(v.name)
			nameLab.id = v.playerId
			nameImg:setVisible(self._myName == v.name)
			if self._myName == v.name then
				nameImg:setPositionX(nameLab:getPositionX())
			end
			self:addTouchEventListener(nameLab, self.onWatchInfo)
		end
	end
end

function RankResPanel:onWatchInfo(sender)
	local mainPanel = self:getPanel(RankPanel.NAME)
	mainPanel:onPlayerInfoReq(sender.id)
end