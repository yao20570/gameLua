---------军团排行榜
WarlordsRankLegionPanel = class("WarlordsRankLegionPanel", BasicPanel)
WarlordsRankLegionPanel.NAME = "WarlordsRankLegionPanel"

function WarlordsRankLegionPanel:ctor(view, panelName)
    WarlordsRankLegionPanel.super.ctor(self, view, panelName)

end

function WarlordsRankLegionPanel:finalize()
    WarlordsRankLegionPanel.super.finalize(self)
end

function WarlordsRankLegionPanel:initPanel()
	WarlordsRankLegionPanel.super.initPanel(self)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
	self._Label_count  = self:getChildByName("PanelDown/Label_count")
	self._Label_fight  = self:getChildByName("PanelDown/Label_fight")
	self._Label_rank  = self:getChildByName("PanelDown/Label_rank")
	self._btnReward  = self:getChildByName("PanelDown/btnReward")
	self._listView = self:getChildByName("listView")

	local item = self._listView:getItem(0)
	if item ~= nil then
		item:setVisible(false)
	end
    
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)

end

function WarlordsRankLegionPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
    local upWidget = self:getChildByName("PanelTop")
    local downWidget = self:getChildByName("PanelDown")
    NodeUtils:adaptiveTopPanelAndListView(upWidget, self._listView, downWidget, tabsPanel)
end

function WarlordsRankLegionPanel:registerEvents()
	WarlordsRankLegionPanel.super.registerEvents(self)
	self:addTouchEventListener(self._btnReward, self.onGetRewardHandle)
end

function WarlordsRankLegionPanel:onGetRewardHandle()
	local panel = self:getPanel(WarlordsRankRewardPanel.NAME)
	if self._rankingreward then
		panel:show(self._rankingreward)
	end
end

function WarlordsRankLegionPanel:onGetWinsRankLegionInfos(serverData)
	--local serverData = self._battleActivityProxy:getWarlordsSerialWins()
	self._rankingreward = serverData.rankingreward
	local myInfos = serverData.myInfos
	local memberInfos = serverData.memberInfos

	if myInfos.rank <= 0 then  --未上榜
		self._Label_rank:setString("未上榜")
	else
		self._Label_rank:setString(myInfos.rank)
	end
	self._Label_count:setString(myInfos.memberNum)
	self._Label_fight:setString(StringUtils:formatNumberByK(myInfos.capacity))
	--self._playerId = myInfos.playerId

	self:renderListView(self._listView, memberInfos, self, self.registerItemEvents, false, false, 0)

    local posY = self:getChildByName("PanelTop/Image_15"):getPositionY()
    local num = #memberInfos
    local offsetHeight = num * 60
    local listHeight = self._listView:getContentSize().height
    if offsetHeight > listHeight then
        offsetHeight = listHeight 
    end
    self:getChildByName("PanelTop/imgBottomLine"):setPositionY(posY -  offsetHeight - 21)
end

function WarlordsRankLegionPanel:onShowHandler()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	self._battleActivityProxy:onTriggerNet330008Req({activityId = id})
end
	

function WarlordsRankLegionPanel:registerItemEvents(item,data,index)
	item:setVisible(true)
	local Label_count = item:getChildByName("Label_count")
	local Label_fight  = item:getChildByName("Label_fight")
	local Label_rank  = item:getChildByName("Label_rank")
	local Label_name  = item:getChildByName("Label_name")
	local itemBgImg  = item:getChildByName("bgImg")
    local rankImg = item:getChildByName("imgRank")
    rankImg:setVisible(false)
    if data.rank < 4 then 
        rankImg:setVisible(true)
	    TextureManager:updateImageView(rankImg, "images/newGui2/IconNum_" .. data.rank .. ".png")
    end
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end

	Label_count:setString(data.memberNum)
	Label_name:setString(data.name)
	Label_fight:setString(StringUtils:formatNumberByK(data.capacity))
	Label_rank:setString(data.rank)

end