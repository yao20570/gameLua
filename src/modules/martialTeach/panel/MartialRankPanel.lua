-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-23
--  * @Description: 武学讲堂排行榜
--  */
MartialRankPanel = class("MartialRankPanel", BasicPanel)
MartialRankPanel.NAME = "MartialRankPanel"

function MartialRankPanel:ctor(view, panelName)
    MartialRankPanel.super.ctor(self, view, panelName)

end

function MartialRankPanel:finalize()
    MartialRankPanel.super.finalize(self)
end

function MartialRankPanel:initPanel()
	MartialRankPanel.super.initPanel(self)
    self._listView = self:getChildByName("top_panel/listView")
	self.proxy = self:getProxy(GameProxys.Activity)

    local tipsBtn = self:getChildByName("top_panel/tip_btn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)
end
function MartialRankPanel:onShowHandler()
    MartialRankPanel.super.onShowHandler(self)
    self:showView()
    
end
function MartialRankPanel:showView()
	local myRankLab = self:getChildByName("top_panel/count_label")
	local myScoreLab = self:getChildByName("top_panel/score_label")
	local myLevelLab = self:getChildByName("top_panel/level_label")
            --获得获得数据
    local actData = self.proxy:getCurActivityData()
    local martialInfo = self.proxy:getMartialInfoById(actData.activityId)
    myScoreLab:setString(martialInfo.learnTimes)

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
		self:renderListView(self._listView, rankInfo.activityRankInfos, self, self.renderItemPanel, false, false, 0)
        local posY = self:getChildByName("top_panel/Image_40"):getPositionY()
        local num = #rankInfo.activityRankInfos
        local offsetHeight = num * 60
        local listHeight = self._listView:getContentSize().height
        if offsetHeight > listHeight then
            offsetHeight = listHeight 
        end
        self:getChildByName("top_panel/imgBottomLine"):setVisible(true)
        self:getChildByName("top_panel/imgBottomLine"):setPositionY(posY -  offsetHeight - 23)
	else
		self:renderListView(self._listView, {}, self, self.renderItemPanel, false)
        self:getChildByName("top_panel/imgBottomLine"):setVisible(false)
	end


end
function MartialRankPanel:renderItemPanel(item, itemInfo, index)
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

function MartialRankPanel:doLayout()
    local top_panel = self:getChildByName("top_panel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(top_panel, nil, GlobalConfig.downHeight, tabsPanel)
end

function MartialRankPanel:registerEvents()
	MartialRankPanel.super.registerEvents(self)
    local btn = self:getChildByName("bottomPanel/btn")
    self:addTouchEventListener(btn, self.onRewardBtnHandler)
end
function MartialRankPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    -- local rankingID = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig,1).rankingID
    local actData = self.proxy:getCurActivityData()
    local rankingID = actData.rankId
    local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
    local lines = {}


    lines[1] = {{content = string.format("%s%s%s", self:getTextWord(392101),config.number,self:getTextWord(392102)), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    lines[2] = {{content = string.format("%s%s%s", self:getTextWord(392103),config.ntegralcondition,self:getTextWord(392104)), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    lines[3] = {{content = string.format("%s%s%s", self:getTextWord(392105),config.levelcondition,self:getTextWord(392106)), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}

    uiTip:setAllTipLine(lines)
end
function MartialRankPanel:onRewardBtnHandler(sender)
    local panel = self:getPanel(MartialRewardPanel.NAME)
    panel:show() 
end


---------------

