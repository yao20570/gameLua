-- /**
--  * @Author:    luzhuojian
--  * @DateTime:    2017-01-06
--  * @Description: 限时活动 煮酒论英雄 排行榜
--  */
CookingWineRankPanel = class("CookingWineRankPanel", BasicPanel)
CookingWineRankPanel.NAME = "CookingWineRankPanel"

function CookingWineRankPanel:ctor(view, panelName)
    CookingWineRankPanel.super.ctor(self, view, panelName)

end

function CookingWineRankPanel:finalize()
    CookingWineRankPanel.super.finalize(self)
end

function CookingWineRankPanel:initPanel()
	CookingWineRankPanel.super.initPanel(self)

    self._listView = self:getChildByName("top_panel/listView")
	self.proxy = self:getProxy(GameProxys.Activity)

    local tipsBtn = self:getChildByName("top_panel/tip_btn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)
end

	
function CookingWineRankPanel:onShowHandler()
    CookingWineRankPanel.super.onShowHandler(self)
    self:showView()
    
end
function CookingWineRankPanel:showView()
	local myRankLab = self:getChildByName("top_panel/count_label")
	local myScoreLab = self:getChildByName("top_panel/score_label")
	local myLevelLab = self:getChildByName("top_panel/level_label")
            --获得获得数据

	local rankInfo = self.proxy:getRankInfoById()

	if rankInfo.myRankInfo then


        local myData = self.proxy:getCurActivityData()

        local cookInfo = self.proxy:getCookInfoyId(myData.activityId)
        if cookInfo.integral > rankInfo.myRankInfo.rankValue then
            myScoreLab:setString(cookInfo.integral)
        else
            myScoreLab:setString(rankInfo.myRankInfo.rankValue)
        end



		myLevelLab:setString(rankInfo.myRankInfo.level)
		
		if rankInfo.myRankInfo.rank == -1 then
			myRankLab:setString(self:getTextWord(360006))
		else
			myRankLab:setString(rankInfo.myRankInfo.rank)
		end
	else
		myScoreLab:setString("")
		myRankLab:setString("")
		myLevelLab:setString("")
	end
	if rankInfo.activityRankInfos then
		self:renderListView(self._listView, rankInfo.activityRankInfos, self, self.renderItemPanel, false, true, 0)
        local posY = self:getChildByName("top_panel/Image_22"):getPositionY()
        local num = #rankInfo.activityRankInfos
        local offsetHeight = num * 60
        local listHeight = self._listView:getContentSize().height
        if offsetHeight > listHeight then
            offsetHeight = listHeight 
        end
        self:getChildByName("top_panel/imgBottomLine"):setVisible(true)
        self:getChildByName("top_panel/imgBottomLine"):setPositionY(posY - offsetHeight - 23)
	else
		self:renderListView(self._listView, {}, self, self.renderItemPanel, false)
        self:getChildByName("top_panel/imgBottomLine"):setVisible(false)
	end


end
function CookingWineRankPanel:renderItemPanel(item, itemInfo, index)
    local rankLab = item:getChildByName("rank_label")
    local nameLab = item:getChildByName("name_label")
    local levelLab = item:getChildByName("level_label")
    local scoreLab = item:getChildByName("score_label")
    local itemBgImg = item:getChildByName("itemBgImg")
    local rankImg = item:getChildByName("imgRank")
    rankImg:setVisible(false)
    if itemInfo.rank < 4 then 
        rankImg:setVisible(true)
	    TextureManager:updateImageView(rankImg, "images/newGui2/IconNum_" .. itemInfo.rank .. ".png")
    end
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    end
    rankLab:setString(itemInfo.rank)
    nameLab:setString(itemInfo.name)
    levelLab:setString(itemInfo.level)
    scoreLab:setString(itemInfo.rankValue)

end

function CookingWineRankPanel:doLayout()
    local topPanel = self:getChildByName("top_panel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, GlobalConfig.downHeight, tabsPanel)
end

function CookingWineRankPanel:registerEvents()
	CookingWineRankPanel.super.registerEvents(self)
    local btn = self:getChildByName("bottomPanel/btn")
    self:addTouchEventListener(btn, self.onRewardBtnHandler)
end
function CookingWineRankPanel:onRewardBtnHandler(sender)
    local panel = self:getPanel(CookingRewardPanel.NAME)
    panel:show() 
end

function CookingWineRankPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)

    -- local rankingID = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig,1).rankingID
    -- local actData = self.proxy:getCurActivityData()
    -- local rankingID = actData.rankId
    -- local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
    -- local lines = {}
    -- for i = 0, 3 do
    --     lines[i] = {{content = TextWords:getTextWord(420101 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    -- end
    -- uiTip:setAllTipLine(lines)


    local proxy = self:getProxy(GameProxys.Activity)
    local curActData = proxy:getCurActivityData()
    local rankId = curActData.rankId
    local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankId)
    local content = string.format(self:getTextWord(420104),config.ntegralcondition,config.number)
    local text = {{{content = content, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
    uiTip:setTitle( TextWords:getTextWord(7500))
    uiTip:setAllTipLine(text)
end

-----------




