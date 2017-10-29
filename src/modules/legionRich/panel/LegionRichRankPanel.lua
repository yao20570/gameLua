-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-09
--  * @Description: 限时活动_同盟致富_排行榜分页
--  */
LegionRichRankPanel = class("LegionRichRankPanel", BasicPanel)
LegionRichRankPanel.NAME = "LegionRichRankPanel"

function LegionRichRankPanel:ctor(view, panelName)
    LegionRichRankPanel.super.ctor(self, view, panelName)

end

function LegionRichRankPanel:finalize()
    LegionRichRankPanel.super.finalize(self)
end

function LegionRichRankPanel:initPanel()
	LegionRichRankPanel.super.initPanel(self)
	self.listview = self:getChildByName("listView")
	self.proxy = self:getProxy(GameProxys.Activity)
end

function LegionRichRankPanel:registerEvents()
	LegionRichRankPanel.super.registerEvents(self)
	local bottomBtn = self:getChildByName("bottomPanel/btn")
    self:addTouchEventListener(bottomBtn, self.onRewardBtnHandler)
    local tipsBtn = self:getChildByName("topPanel/tip_btn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)
end
function LegionRichRankPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local bottomPanel = self:getChildByName("bottomPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel,self.listview, bottomPanel, tabsPanel)

end
function LegionRichRankPanel:onShowHandler()
	self:updateLegionRichRankView()
end
function LegionRichRankPanel:updateLegionRichRankView()
    local myRankLab = self:getChildByName("topPanel/count_label")
    local myScoreLab = self:getChildByName("topPanel/score_label")
    local myLevelLab = self:getChildByName("topPanel/level_label")

    local rankInfo = self.proxy:getRankInfoById()
    if rankInfo.myRankInfo then
        myScoreLab:setString( StringUtils:formatNumberByK3(rankInfo.myRankInfo.rankValue))
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
        self:getChildByName("topPanel/Image_61"):setPositionY(-1 * (#rankInfo.activityRankInfos * 60 + 3))
    else
        self:renderListView(self.listview, {}, self, self.renderItemPanel, false)
    end
end
function LegionRichRankPanel:renderItemPanel(item, itemInfo, index)
    local rankLab = item:getChildByName("rank_label")
    local nameLab = item:getChildByName("name_label")
    local levelLab = item:getChildByName("level_label")
    local scoreLab = item:getChildByName("score_label")
    local itemBgImg = item:getChildByName("itemBgImg")
    local imgRank = item:getChildByName("imgRank")
    --itemBgImg:setVisible(index%2 == 0)
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end
    
    imgRank:setVisible(false)
    local rank = itemInfo.rank
    if rank < 4 then
        local url = "images/newGui2/IconNum_1.png"
		if rank == 1 then
			url = "images/newGui2/IconNum_1.png"
		elseif rank == 2 then
			url = "images/newGui2/IconNum_2.png"
		elseif rank == 3 then
			url = "images/newGui2/IconNum_3.png"
		end
        TextureManager:updateImageView(imgRank, url)
        imgRank:setVisible(true)
    end
    rankLab:setString(itemInfo.rank)
    nameLab:setString(itemInfo.name)
    levelLab:setString(itemInfo.level)
    scoreLab:setString( StringUtils:formatNumberByK3(itemInfo.rankValue) )

end
function LegionRichRankPanel:onRewardBtnHandler(sender)
    local panel = self:getPanel(LegionRichRewardPanel.NAME)
    panel:show() 
end
function LegionRichRankPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    -- local rankingID = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig,1).rankingID
    -- local actData = self.proxy:getCurActivityData()
    -- local rankingID = actData.rankId
    -- local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
    -- local lines = {}
    -- lines[1] = {{content = self:getTextWord(394009), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    -- lines[2] = {{content = self:getTextWord(394010), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    -- lines[3] = {{content = self:getTextWord(394011), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    -- uiTip:setAllTipLine(lines)
    local proxy = self:getProxy(GameProxys.Activity)
    local curActData = proxy:getCurActivityData()
    local rankId = curActData.rankId
    local config = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankId)
    local content = string.format(self:getTextWord(394017),config.number)
    local text = {{{content = content, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
    uiTip:setTitle( TextWords:getTextWord(7500))
    uiTip:setAllTipLine(text)
end