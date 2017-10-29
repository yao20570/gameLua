UILordCityVote = class("UILordCityVote")

UILordCityVote.OPEN_SRC_MAP = 2
UILordCityVote.OPEN_SRC_LORD_CITY = 1

--isMap  从map模块调用进来，要特殊处理
function UILordCityVote:ctor(panel)
    self._uiSkin = UISkin.new("UILordCityVote")
    self._uiSkin:setParent(panel)
    self._panel = panel   
    
    self:init()
    self:registerEvents()

end

function UILordCityVote:init()
	self._lordCityProxy = self._panel:getProxy(GameProxys.LordCity)

    local uiSkin = self._uiSkin 

    self._rewardBtn = uiSkin:getChildByName("mainPanel/downPanel/rewardBtn")
	self._voteBtn = uiSkin:getChildByName("mainPanel/downPanel/voteBtn")

    local listView = uiSkin:getChildByName("mainPanel/listView")
	local itemPanel = listView:getItem(0)
	itemPanel:setVisible(false)


end

function UILordCityVote:finalize()
    UILordCityVote.super.finalize(self)
end

function UILordCityVote:registerEvents()
	self._panel:addTouchEventListener(self._rewardBtn, self.onRewardBtnTouch, nil, self)
	self._panel:addTouchEventListener(self._voteBtn, self.onVoteBtnTouch, nil, self)
end

function UILordCityVote:setCallbackReward(callback)
    self._callbackReward = callback
end

function UILordCityVote:onClosePanelHandler()
	self._panel:hide()
end

function UILordCityVote:onLordCityVoteUpdate()
	self._listView = {}
	self._cityId = self._lordCityProxy:getSelectCityId()
	self._voteLegionId = self._lordCityProxy:getVoteLegionId()  --已投票的军团id
	local data = self._lordCityProxy:getVoteLegionMap()
	local listView = self._uiSkin:getChildByName("mainPanel/listView")
	self._panel:renderListView(listView, data, self, self.renderItem)

	-- 投票按钮状态更新
	if self._voteLegionId > 0 then
		self._voteBtn:setTitleText(self._panel:getTextWord(370034))  --已投票
		NodeUtils:setEnable(self._voteBtn, false)
	else
		self._voteBtn:setTitleText(self._panel:getTextWord(370027))  --未投票
		NodeUtils:setEnable(self._voteBtn, true)
	end

	self:updateRewardBtnState()
end

-- 领奖按钮小红点更新
function UILordCityVote:updateRewardBtnState()
	local dotBg = self._rewardBtn:getChildByName("dotBg")
	local dot = dotBg:getChildByName("dot")
	local state = self._lordCityProxy:getVoteRewardState()
	local legionId = self._lordCityProxy:getVoteLegionId()
	if state == 0 and legionId > 0 then
		dotBg:setVisible(true)
		dot:setString(1)
	else
		dotBg:setVisible(false)
	end
end

-- 协议更新列表信息
function UILordCityVote:onVoteInfoUpdate()
	self._panel:onShowHandler()
end

-- 渲染
function UILordCityVote:renderItem(itemPanel,info)
	if itemPanel == nil or info == nil then
		return
	end
	table.insert(self._listView,itemPanel)

	itemPanel:setVisible(true)
	local nameTxt = itemPanel:getChildByName("nameTxt")
	local fightCapTxt = itemPanel:getChildByName("fightCapTxt")
	local voteTxt = itemPanel:getChildByName("voteTxt")
	local voteCheckBtn = itemPanel:getChildByName("voteCheckBtn")
	local coverPanel = itemPanel:getChildByName("coverPanel")


	nameTxt:setString(info.legionName)
	fightCapTxt:setString(StringUtils:formatNumberByK3(info.capacity))
	voteTxt:setString(string.format(self._panel:getTextWord(370029),info.votes))
	
	local state = self._voteLegionId == info.legionId

	voteCheckBtn.info = info
	voteCheckBtn:setSelectedState(state)
	coverPanel:setTouchEnabled(self._voteLegionId > 0)  --已投票则屏蔽点击勾选
	itemPanel.voteCheckBtn = voteCheckBtn

	if itemPanel.addEvent == nil then
		itemPanel.addEvent = true
		self._panel:addTouchEventListener(voteCheckBtn, self.onVoteCheckBtnTouch, nil, self)
		return
	end

end

-- 投票勾选按钮
function UILordCityVote:onVoteCheckBtnTouch(sender)
	local state = sender:getSelectedState()

	-- 列表项先全部清除勾选
	for k,itemPanel in pairs(self._listView) do
		if itemPanel then
			if itemPanel.voteCheckBtn then
				itemPanel.voteCheckBtn:setSelectedState(false)
			end
		end
	end

	-- 然后再设置当前项勾选
	sender:setSelectedState(state)
	if state then
		self._selectedLegionId = nil
	else
		self._selectedLegionId = sender.info.legionId
	end
end


-- 投票
function UILordCityVote:onVoteBtnTouch(sender)
	if self._selectedLegionId == nil then
		self._panel:showSysMessage(self._panel:getTextWord(370030))  --未勾选任何军团
		return
	end

	if self._voteLegionId > 0 then
		self._panel:showSysMessage(self._panel:getTextWord(370094))  --已投票
		return
	end

	local prepareTime = self._lordCityProxy:getBattleReadyRemainTime(self._cityId)
	if prepareTime <= 0 then
		self._panel:showSysMessage(self._panel:getTextWord(370071))  --准备阶段已过，投票已结束
		return
	end
	
	local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
	if cityHost.cityState == 0 then
		self._panel:showSysMessage(self._panel:getTextWord(370076))  --活动未开启
		return
	end

	
	local roleProxy = self._panel:getProxy(GameProxys.Role)
	local playerLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
	if playerLv < 20 then  --等级低于20
		self._panel:showSysMessage(self._panel:getTextWord(370061))
		return
	end

	-- print(".... 投票 ",self._cityId,self._selectedLegionId)

	local data = {}
	data.cityId = self._cityId
	data.legionId = self._selectedLegionId
	self._lordCityProxy:onTriggerNet360015Req(data)
end

-- 领取奖励
function UILordCityVote:onRewardBtnTouch(sender)
--	local panel = self._panel:getPanel(LordCityVoteRewardPanel.NAME)
--	panel:show()

    if self._callbackReward == nil then
        logger:error("===========>self._callbackReward is nil")
    else
        self._callbackReward()
    end

	self._panel:onClosePanelHandler()
end


