-------------------------排行榜界面------------------------------------
PartsGodRankPanel = class("PartsGodRankPanel", BasicPanel)
PartsGodRankPanel.NAME = "PartsGodRankPanel"

function PartsGodRankPanel:ctor(view, panelName)
    PartsGodRankPanel.super.ctor(self, view, panelName)

end

function PartsGodRankPanel:finalize()
	if self._watchPlayInfoPanel ~= nil then
		self._watchPlayInfoPanel:finalize()
	end
	self._watchPlayInfoPanel = nil
    PartsGodRankPanel.super.finalize(self)
end

function PartsGodRankPanel:onClosePanelHandler()
    PartsGodRankPanel.super.onClosePanelHandler(self)
    self:hide()
end

function PartsGodRankPanel:initPanel()
	PartsGodRankPanel.super.initPanel(self)
	
	--self._top_panel = self:getChildByName("top_panel")
	---- self._tipInfo_panel = self:getChildByName("tipInfo_panel")
	--local down_panel = self._top_panel:getChildByName("down_panel")
	--local bottom_panel = self:getChildByName("bottom_panel")
    --
	--self._gift_btn = down_panel:getChildByName("gift_btn")
	--self._top_panel:setVisible(true)
	----self._tipInfo_panel:setVisible(false)
	--self:adjustBootomBg(bottom_panel, self._top_panel,true)
	--self._selectItem = nil
    --
	--self:initPanelInfo()
end

-- 初始化隐藏
--function PartsGodRankPanel:initPanelInfo()
--	local count_label = self._top_panel:getChildByName("count_label")
--	local level_label = self._top_panel:getChildByName("level_label")
--	local score_label = self._top_panel:getChildByName("score_label")
--	local listview = self._top_panel:getChildByName("listView")
--	local item = listView:getItem(0)
--	item:setVisible(false)
--
--	count_label:setString("")
--	level_label:setString("")
--	score_label:setString("")
--end

--function PartsGodRankPanel:registerEvents()
--	PartsGodRankPanel.super.registerEvents(self)
--
--	self._tip_btn = self._top_panel:getChildByName("tip_btn")
--	--self:addTouchEventListener(self._tipInfo_panel,self.onShowTipInfoPanelHandle)
--	self:addTouchEventListener(self._tip_btn,self.onShowTipInfoPanelHandle)
--	self:addTouchEventListener(self._gift_btn,self.onShowRankRewardPanelHandle)
--end

function PartsGodRankPanel:onShowTipInfoPanelHandle(sender)
	-- if sender == self._tip_btn then
	-- 	self._tipInfo_panel:setVisible(true)
	-- else
	-- 	self._tipInfo_panel:setVisible(false)
	-- end

	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	-- local rankingID = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID",1).rankingID
	local proxy = self:getProxy(GameProxys.Activity)
	local curActData = proxy:getCurActivityData()
	local rankingID = curActData.rankId
	local config = ConfigDataManager:getConfigData(ConfigData.CurrentRankingConfig)
	local content = string.format(self:getTextWord(280003),config[rankingID].ntegralcondition,config[rankingID].levelcondition,config[rankingID].number)
	local text = {{{content = content, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
    uiTip:setAllTipLine(text)
end

function PartsGodRankPanel:onShowHandler() 
	local proxy = self:getProxy(GameProxys.Activity)
	local rankingID = proxy:getCurActivityData().rankId
	-- local rankingID = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID",1).rankingID
	local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
	local rankingreward = configData.rankingreward
	--proxy.rankingID = rankingreward
	local id = self.view:getActivityId()
	local rankInfo = proxy:getRankInfoById()



	local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)

	if self.rankPanel == nil then
		self.rankPanel = UITabRankPanel.new(self, self, nil, {rankData = rankInfo, num = self.view:onGetScore(), tipText = text, rankID = rankingreward})
	else
		self.rankPanel:updateData({rankData = rankInfo, num = self.view:onGetScore(), tipText = text, rankID = rankingreward})
	end
end

--function PartsGodRankPanel:onUpdateData(data)
--	local myRankData = data.myRankInfo
--	local integralInfo = data.activityRankInfos
--	if myRankData == nil or integralInfo == nil then
--		logger:error("PartsGodRankPanel error myRankData == nil or integralInfo == nil !!!")
--		return
--	end
--
--	local count_label = self._top_panel:getChildByName("count_label")
--	local level_label = self._top_panel:getChildByName("level_label")
--	local score_label = self._top_panel:getChildByName("score_label")
--	local listview = self._top_panel:getChildByName("listView")
--
--	if myRankData.rank <= 0 then
--		count_label:setString("未上榜")
--	else
--		count_label:setString(myRankData.rank)
--	end
--	level_label:setString(myRankData.level)
--
--	local score = (self.view:onGetScore()) or myRankData.rankValue
--
--	score_label:setString(score)
--	self._myName  = myRankData.name
--
--	self:renderListView(listview, integralInfo, self, self.registerItemEvents)
--end

-------是否已经有玩家的个人信息了-----------
function PartsGodRankPanel:onGetPlayInfoById(id)
	for key,v in pairs(self._targetInfoMap) do
		if key == id then
			return v
		end
	end
end

--function PartsGodRankPanel:registerItemEvents(item,data,index)
--	item:setVisible(true)
--    item.data = data
--
--    local rank_label = item:getChildByName("rank_label")
--    local name_label = item:getChildByName("name_label")
--    local level_label = item:getChildByName("level_label")
--    local score_label = item:getChildByName("score_label")
--    local select_img = item:getChildByName("select_img")
--
--    rank_label:setString(data.rank)
--    name_label:setString(data.name)
--    level_label:setString(data.level)
--    score_label:setString(data.rankValue)
--    select_img:setVisible(false)
--
--    self:onAddItemClick(item)
--end
--
--function PartsGodRankPanel:onAddItemClick(sender)
--	if sender.isAdd ~= nil then
--		return 
--	end
--	sender.isAdd = true
--	self:addTouchEventListener(sender,self.onClickPlayerInfoHandle)
--end
--
--function PartsGodRankPanel:onClickPlayerInfoHandle(sender)
--	if sender.data.name == self._myName then  --玩家本人则不显示个人信息面板
--		return
--	end
--
--	self._currPlayId = sender.data.playerId
--	if sender ~= self._selectItem then
--		if self._selectItem ~= nil then
--			local select_img = self._selectItem:getChildByName("select_img")
--			select_img:setVisible(false)
--		end
--		local select_img = sender:getChildByName("select_img")
--		select_img:setVisible(true)
--		self._selectItem = sender
--		
--		local playerInfo = self:onGetPlayInfoById(sender.data.playerId)
--		if playerInfo == nil then
--			local data = {}
--			data.playerId = sender.data.playerId
--			self:dispatchEvent(PartsGodEvent.PERSON_INFO_REQ,data)
--		else
--			self._selectItem.playerInfo = playerInfo
--			self:onChatPersonInfoResp(playerInfo)
--		end
--	else
--		self:onChatPersonInfoResp(self._selectItem.playerInfo)
--	end
--end

-------玩家的个人信息返回-----------
function PartsGodRankPanel:onChatPersonInfoResp(data)
	if self._watchPlayInfoPanel == nil then
	   	self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false)
	end
	-- self._watchPlayInfoPanel:setMialShield(true) 
	self._watchPlayInfoPanel:showAllInfo(data)
	self._targetInfoMap[self._currPlayId] = data
	self._selectItem.playerInfo = data
end

--function PartsGodRankPanel:onShowRankRewardPanelHandle(sender)
--	local panel = self:getPanel(PartsGodRankRewardPanel.NAME)
--	panel:show()
--end

function PartsGodRankPanel:updateRankData()
	if self.rankPanel ~= nil and self.rankPanel._uiSkin:isVisible() then
		local proxy = self:getProxy(GameProxys.Activity)
		local rankingID = proxy:getCurActivityData().rankId
		local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
		local rankingreward = configData.rankingreward
        
	    local rankInfo = proxy:getRankInfoById()
        
	    local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)

		self.rankPanel:updateData({rankData = rankInfo, tipText = text, rankingID = rankingreward, num = self.view:onGetScore()})
	end
end