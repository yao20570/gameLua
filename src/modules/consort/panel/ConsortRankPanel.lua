
ConsortRankPanel = class("ConsortRankPanel", BasicPanel)
ConsortRankPanel.NAME = "ConsortRankPanel"

function ConsortRankPanel:ctor(view, panelName)
    ConsortRankPanel.super.ctor(self, view, panelName)

end

function ConsortRankPanel:finalize()
    ConsortRankPanel.super.finalize(self)
end

function ConsortRankPanel:initPanel()
    ConsortRankPanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.Consort)

    
    -- panelTop
    self._panelTop = self:getChildByName("panelTop")
    self._txtRank = self._panelTop:getChildByName("txtRank")
	self._txtLevel = self._panelTop:getChildByName("txtLevel")
	self._txtScore = self._panelTop:getChildByName("txtScore")

    local btnTip = self._panelTop:getChildByName("btnTip")
    self:addTouchEventListener(btnTip, self.onTip)

    -- listview
    self._listview = self:getChildByName("listview")

    -- panelDown
    self._panelDown = self:getChildByName("panelDown")
    local btnReward = self._panelDown:getChildByName("btnReward")
    self:addTouchEventListener(btnReward, self.onReward)

end

function ConsortRankPanel:registerEvents()
    ConsortRankPanel.super.registerEvents(self)
end

function ConsortRankPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._panelTop, nil, GlobalConfig.downHeight, tabsPanel, 3)
    NodeUtils:adaptiveListView(self._listview, self._panelDown, self._panelTop, 0, 3)
    
end

function ConsortRankPanel:onClosePanelHandler()
    self:dispatchEvent(ConsortEvent.HIDE_SELF_EVENT)
end

function ConsortRankPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end
    
    self:updateUI()
end

function ConsortRankPanel:updateUI()

	local rankInfo = self._proxy:getConsortRankServerDatas()
	if rankInfo.myRankInfo then		
		if rankInfo.myRankInfo.rank == -1 then
			self._txtRank:setString(self:getTextWord(360006))
		else
			self._txtRank:setString(rankInfo.myRankInfo.rank)
		end
        self._txtLevel:setString(rankInfo.myRankInfo.level)		

        local consortId = self._proxy:getCurActivityId()
        local consortData = self._proxy:getConsortInfoData(consortId)
        self._txtScore:setString(consortData.score)
	else
		self._txtScore:setString("")
		self._txtRank:setString("")
		self._txtLevel:setString("")
	end

	
	self:renderListView(self._listview, rankInfo.activityRankInfos or {}, self, self.renderItemPanel, false, true, 0)

    local num = #rankInfo.activityRankInfos
    if num > 0 then
        local listHeight = self._listview:getContentSize().height
        local offsetHeight = num * 60
        if offsetHeight > listHeight then
            offsetHeight = listHeight
        end
        local posY = self:getChildByName("panelTop/Image_24"):getPositionY()
        self:getChildByName("panelTop/imgBottomLine"):setPositionY(posY - offsetHeight - 23)
    end
end

function ConsortRankPanel:renderItemPanel(item, itemInfo, index)

    local txtRank = item:getChildByName("txtRank")
    local txtName = item:getChildByName("txtName")
    local txtLevel = item:getChildByName("txtLevel")
    local txtScore = item:getChildByName("txtScore")
    local itemBgImg = item:getChildByName("imgBg")
    local rankImg = item:getChildByName("imgRank")
    rankImg:setVisible(false)
    if itemInfo.rank < 4 then 
        rankImg:setVisible(true)
	    TextureManager:updateImageView(rankImg, "images/newGui2/IconNum_" .. itemInfo.rank .. ".png")
    end
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end
    
    txtRank:setString(itemInfo.rank)
    txtName:setString(itemInfo.name)
    txtLevel:setString(itemInfo.level)
    txtScore:setString(itemInfo.rankValue)

    --local imgBg = item:getChildByName("imgBg")
    --imgBg:setVisible(index%2 == 0)
end

function ConsortRankPanel:onTip(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    -- local lines = { }
    -- for i = 0, 2 do
    --     lines[i] = { { content = TextWords:getTextWord(430006 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } }
    -- end
    -- uiTip:setAllTipLine(lines)
    local proxy = self:getProxy(GameProxys.Activity)
    local curActData = proxy:getCurActivityData()
    local rankId = curActData.rankId
    local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankId)
    local content = string.format(self:getTextWord(430009),config.ntegralcondition,config.number)
    local text = {{{content = content, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
    uiTip:setTitle(TextWords:getTextWord(7500))
    uiTip:setAllTipLine(text)


end

function ConsortRankPanel:onReward(sender)
    local panel = self:getPanel(ConsortRewardPanel.NAME)
    panel:show() 
end