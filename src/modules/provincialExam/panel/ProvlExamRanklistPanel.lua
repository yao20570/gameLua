
ProvlExamRanklistPanel = class("ProvlExamRanklistPanel", BasicPanel)
ProvlExamRanklistPanel.NAME = "ProvlExamRanklistPanel"

function ProvlExamRanklistPanel:ctor(view, panelName)
    ProvlExamRanklistPanel.super.ctor(self, view, panelName)

end

function ProvlExamRanklistPanel:finalize()
    ProvlExamRanklistPanel.super.finalize(self)

end

function ProvlExamRanklistPanel:initPanel()
	ProvlExamRanklistPanel.super.initPanel(self)
    self._listView = self:getChildByName("top_panel/listView")
	self.proxy = self:getProxy(GameProxys.ExamActivity)

    local tipsBtn = self:getChildByName("top_panel/tip_btn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)

end
function ProvlExamRanklistPanel:onShowHandler()
    ProvlExamRanklistPanel.super.onShowHandler(self)
    self.proxy:onTriggerNet370003Req()
    
end
function ProvlExamRanklistPanel:showView()
    local provExamRankInfos = self.proxy:getProvExamRankInfos()
    self:renderListView(self._listView, provExamRankInfos, self, self.renderItemPanel, false, false, 0)
    
    local posY = self:getChildByName("top_panel/Image_37"):getPositionY()
    local num = #provExamRankInfos
    local offsetHeight = num * 60
    local listHeight = self._listView:getContentSize().height
    if offsetHeight > listHeight then
        offsetHeight = listHeight 
    end
    self:getChildByName("top_panel/imgBottomLine"):setPositionY(posY - offsetHeight - 21)


    local provExamRankInfos = self.proxy:getMyProvExamRankInfo()
    local myScorelab = self:getChildByName("top_panel/score_label")
    local myRanklab = self:getChildByName("top_panel/count_label")
    myScorelab:setString(provExamRankInfos.vlaue)
    if provExamRankInfos.rank == -1 then
        myRanklab:setString(self:getTextWord(360006))
    else
        myRanklab:setString(provExamRankInfos.rank)
    end

end
function ProvlExamRanklistPanel:renderItemPanel(item, itemInfo, index)

    local rankLab = item:getChildByName("rank_label")
    local nameLab = item:getChildByName("name_label")
    local timeLab = item:getChildByName("level_label")
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
    timeLab:setString(itemInfo.time)
    scoreLab:setString(itemInfo.value)




end
function ProvlExamRanklistPanel:doLayout()
    local panelBg = self:getChildByName("top_panel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(panelBg, nil, GlobalConfig.downHeight, tabsPanel, 3)
end

function ProvlExamRanklistPanel:registerEvents()
	ProvlExamRanklistPanel.super.registerEvents(self)
end

function ProvlExamRanklistPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}
    for i=1,5 do
        lines[i] = {{content = TextWords:getTextWord(362000 + i), foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    end
    uiTip:setAllTipLine(lines)
end