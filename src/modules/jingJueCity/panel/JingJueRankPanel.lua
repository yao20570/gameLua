-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-22
--  * @Description: 限时活动_精绝古城_排行榜
--  */
JingJueRankPanel = class("JingJueRankPanel", BasicPanel)
JingJueRankPanel.NAME = "JingJueRankPanel"

function JingJueRankPanel:ctor(view, panelName)
    JingJueRankPanel.super.ctor(self, view, panelName)

end

function JingJueRankPanel:finalize()
    JingJueRankPanel.super.finalize(self)
end

function JingJueRankPanel:initPanel()
	JingJueRankPanel.super.initPanel(self)
	self.listview = self:getChildByName("topPanel/listView")
	self.proxy = self:getProxy(GameProxys.Activity)

    local tipsBtn = self:getChildByName("topPanel/tip_btn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)
end
function JingJueRankPanel:onShowHandler()
	self:updateJingJueRankView()
end
function JingJueRankPanel:updateJingJueRankView()
	local myRankLab = self:getChildByName("topPanel/count_label")
	local myScoreLab = self:getChildByName("topPanel/score_label")
	local myLevelLab = self:getChildByName("topPanel/level_label")
            --获得获得数据
    local actData = self.proxy:getCurActivityData()
    local jingJueInfo = self.proxy:getJingJueInfoById(actData.activityId)
    myScoreLab:setString(jingJueInfo.integral)

	local rankInfo = self.proxy:getRankInfoById()
	if rankInfo.myRankInfo then
		-- myScoreLab:setString(rankInfo.myRankInfo.rankValue)
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
		self:renderListView(self.listview, rankInfo.activityRankInfos, self, self.renderItemPanel, false, true, 0)
        local posY = self:getChildByName("topPanel/Image_30"):getPositionY()
        local num = #rankInfo.activityRankInfos
        local offsetHeight = num * 60
        local listHeight = self.listview:getContentSize().height
        if offsetHeight > listHeight then
            offsetHeight = listHeight 
        end
        self:getChildByName("topPanel/imgBottomLine"):setVisible(true)
        self:getChildByName("topPanel/imgBottomLine"):setPositionY(posY - offsetHeight - 23)
	else
		self:renderListView(self.listview, {}, self, self.renderItemPanel, false)
        self:getChildByName("topPanel/imgBottomLine"):setVisible(false)
	end


end
function JingJueRankPanel:renderItemPanel(item, itemInfo, index)

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
function JingJueRankPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel,nil, GlobalConfig.downHeight, tabsPanel)
end

function JingJueRankPanel:registerEvents()
	JingJueRankPanel.super.registerEvents(self)
    local rewardBtn = self:getChildByName("bottonPanel/rewardBtn")
    self:addTouchEventListener(rewardBtn, self.onRewardBtnHandler)
end
function JingJueRankPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)

    -- local rankingID = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig,1).rankingID
    -- local actData = self.proxy:getCurActivityData()
    -- local rankingID = actData.rankId
    -- local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)

    -- local lines = {}
    -- for i=1,3 do
    --     lines[i] = {{content = self:getTextWord(460100+i), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    -- end
    -- uiTip:setAllTipLine(lines)
    local proxy = self:getProxy(GameProxys.Activity)
    local curActData = proxy:getCurActivityData()
    local rankId = curActData.rankId
    local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankId)
    local content = string.format(self:getTextWord(460104),config.ntegralcondition,config.number)
    local text = {{{content = content, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
    uiTip:setAllTipLine(text)

end
function JingJueRankPanel:onRewardBtnHandler(sender)
    local panel = self:getPanel(JingJueRewardPanel.NAME)
    panel:show() 
end