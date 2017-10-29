
PalaceExamRankPanel = class("PalaceExamRankPanel", BasicPanel)
PalaceExamRankPanel.NAME = "PalaceExamRankPanel"

function PalaceExamRankPanel:ctor(view, panelName)
    PalaceExamRankPanel.super.ctor(self, view, panelName)

end

function PalaceExamRankPanel:finalize()
    -- if self.secLvBg ~= nil then
    --     self.secLvBg = nil
    -- end
    PalaceExamRankPanel.super.finalize(self)
end

function PalaceExamRankPanel:initPanel()
	PalaceExamRankPanel.super.initPanel(self)
	self._listView = self:getChildByName("topPanel/listView")
	self.proxy = self:getProxy(GameProxys.ExamActivity)

    local tipsBtn = self:getChildByName("topPanel/tip_btn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)

    local rewardBtn = self:getChildByName("bottonPanel/rewardBtn")

    local rewardPanel = self:getChildByName("rewardPanel")

    self.hasGotBtn = self:getChildByName("bottonPanel/hasGotBtn")
    self:addTouchEventListener(self.hasGotBtn , self.onHasGotBtnHandler)    
    self.getBtn = self:getChildByName("bottonPanel/getBtn")
    self:addTouchEventListener(self.getBtn, self.onGetBtnHandler)  
    self.tipImg = self:getChildByName("bottonPanel/getBtn/tipImg")  

    -- -- --start 二级弹窗 -------------------------------------------------------------------
    -- if self.secLvBg == nil then
    --     local extra = {}
    --     extra["closeBtnType"] = 1
    --     extra["callBack"] = function() rewardPanel:setVisible(false) end
    --     extra["obj"] = self

    --     self.secLvBg = UISecLvPanelBg.new(self:getSkin():getRootNode(), self, extra)
    --     self.secLvBg:setContentHeight(720)
    --     self.secLvBg:setTitle(TextWords:getTextWord(1325))
    --     self.secLvBg:setVisible(false)
    --     self.secLvBg:setLocalZOrder(2)
    --     rewardPanel:setLocalZOrder(3)   

    -- end
    -- -- --end 二级弹窗 --------
    -- local rewardList = rewardPanel:getChildByName("listview")
    -- local palaceEaxmAllRewardArray = self.proxy:getPalaceEaxmAllRewardArray()
    -- self:addTouchEventListener(rewardBtn, function()
    --     rewardPanel:setVisible(true)
    --     self.secLvBg:setVisible(true)
    --     self:renderListView(rewardList, palaceEaxmAllRewardArray, self, self.renderRewardItem)
    -- end)

    self:addTouchEventListener(rewardBtn,self.onRewardPreviewTouch)
end

function PalaceExamRankPanel:onRewardPreviewTouch()
    local panel = self:getPanel(PalaceExamRewardPanel.NAME)
    panel:show()
end

function PalaceExamRankPanel:doLayout()
    local downPanel = self:getChildByName("bottonPanel")
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, tabsPanel)
end
function PalaceExamRankPanel:onShowHandler()
    PalaceExamRankPanel.super.onShowHandler(self)
    self.proxy:onTriggerNet370103Req()
    
end
function PalaceExamRankPanel:showView()
    local palaceExamRankInfos = self.proxy:getPalaceExamRankInfos()
    self:renderListView(self._listView, palaceExamRankInfos, self, self.renderItemPanel, false, false, 0)
    
    local posY = self:getChildByName("topPanel/Image_11"):getPositionY()
    local num = #palaceExamRankInfos
    local offsetHeight = num * 60
    local listHeight = self._listView:getContentSize().height
    if offsetHeight > listHeight then
        offsetHeight = listHeight 
    end
    self:getChildByName("topPanel/imgBottomLine"):setPositionY(posY - offsetHeight - 21)

    local palaceExamRankInfos = self.proxy:getMyPalaceExamRankInfo()
    local myScorelab = self:getChildByName("topPanel/score_label")
    local myRanklab = self:getChildByName("topPanel/count_label")
    local localIntergral = self.proxy:getCurPalaceIntegral()
    if palaceExamRankInfos.vlaue < localIntergral then
        myScorelab:setString(localIntergral)
    else
        myScorelab:setString(palaceExamRankInfos.vlaue)
    end

    if palaceExamRankInfos.rank == -1 then
        myRanklab:setString(self:getTextWord(360006))
    else
        myRanklab:setString(palaceExamRankInfos.rank)
    end
    --领奖
    local state = self.proxy:getStateOfPalaceExamReward()--0不可领，1，可领，2已领取
    self.tipImg:setVisible(state == 1)
    self.getBtn:setVisible(state ~= 2)

end
function PalaceExamRankPanel:renderItemPanel(item, itemInfo, index)

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
function PalaceExamRankPanel:renderRewardItem(itemPanel, info, index)

    local nameLab = itemPanel:getChildByName("index_label")
    local itemArr  = {}
    local itemImg1 = itemPanel:getChildByName("itemImg1")
    table.insert(itemArr,itemImg1)
    local itemImg2 = itemPanel:getChildByName("itemImg2")
    table.insert(itemArr,itemImg2)
    local itemImg3 = itemPanel:getChildByName("itemImg3")
    table.insert(itemArr,itemImg3)
    if info.ranking == info.rankingii then
        nameLab:setString(string.format("%s%d%s",self:getTextWord(360015),info.ranking,self:getTextWord(360016)))
    else
        nameLab:setString(string.format("%s%d%s%d%s",self:getTextWord(360015),info.ranking,self:getTextWord(360017),info.rankingii,self:getTextWord(360016)))
    end


    local rewardArr = StringUtils:jsonDecode(info.reward)
    for i,v in ipairs(itemArr) do
        v:setVisible(false)
    end
    local materialDataTable = rewardArr
    local roleProxy = self:getProxy(GameProxys.Role)
    for i=1,#rewardArr do
        local haveNum =  roleProxy:getRolePowerValue(materialDataTable[i][1], materialDataTable[i][2])
        --self:renderChild(itemArr[i], haveNum, materialDataTable[i][3])
        local iconData = {}
        iconData.typeid = materialDataTable[i][2]
        iconData.num = materialDataTable[i][3]
        iconData.power = materialDataTable[i][1]
        if itemArr[i].uiIcon == nil then
            itemArr[i].uiIcon = UIIcon.new(itemArr[i], iconData, true, self, nil, true)
        else
            itemArr[i].uiIcon:updateData(iconData)
        end
        itemArr[i]:setVisible(true)
    end

end

function PalaceExamRankPanel:registerEvents()
	PalaceExamRankPanel.super.registerEvents(self)
end
function PalaceExamRankPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}
    for i=1,5 do
        lines[i] = {{content = TextWords:getTextWord(364000 + i), foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    end
    uiTip:setAllTipLine(lines)
end

function PalaceExamRankPanel:onHasGotBtnHandler(sender)
    self:showSysMessage(self:getTextWord(360008))
end

function PalaceExamRankPanel:onGetBtnHandler()
    self.proxy:onTriggerNet370104Req()
end