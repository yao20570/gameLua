-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-12-02 14:16:00
--  * @Description: 叛军排名
--  */
RebelsRankPanel = class("RebelsRankPanel", BasicPanel)
RebelsRankPanel.NAME = "RebelsRankPanel"

function RebelsRankPanel:ctor(view, panelName)
    RebelsRankPanel.super.ctor(self, view, panelName)

end


function RebelsRankPanel:finalize()
    RebelsRankPanel.super.finalize(self)
end


function RebelsRankPanel:initPanel()
    RebelsRankPanel.super.initPanel(self)

    self.proxy = self:getProxy(GameProxys.Rebels)

    -- top面板
    self.panelTop = self:getChildByName("panelTop")

    self.panelMyRankInfo = self.panelTop:getChildByName("panelMyRankInfo")
    self.panelLegionRankInfo = self.panelTop:getChildByName("panelLegionRankInfo")
    local btnTip = self.panelTop:getChildByName("btnTip")
    self:addTouchEventListener(btnTip, self.onTip)



    -- 叛军切换按钮面板
    self.imgBtnRank = { }
    for i = 1, 2 do
        self.imgBtnRank[i] = self.panelTop:getChildByName("imgBtnRank" .. i)
        self.imgBtnRank[i].tag = i
        self:addTouchEventListener(self.imgBtnRank[i], self.onSwitchRankList)
    end
    self.imgBtnRank[2]:setVisible(false)  --暂时屏蔽

    -- 排名列表
    self._svRank = self:getChildByName("svRank")
    self._ItemUIIndex = 1


    -- 切换到玩家排名
    self:switchRankList(RebelsProxy.RANK_TYPE_PLAYER);
end


function RebelsRankPanel:registerEvents()
    RebelsRankPanel.super.registerEvents(self)
end


function RebelsRankPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self.panelTop, nil, nil, tabsPanel, 0)
    NodeUtils:adaptiveListView(self._svRank, GlobalConfig.downHeight, self.panelTop, 0)

    self:createScrollViewItemUIForDoLayout(self._svRank)
end

function RebelsRankPanel:onClosePanelHandler()
    self:dispatchEvent(RebelsEvent.HIDE_SELF_EVENT)
end


function RebelsRankPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end

    self.curRankType = RebelsProxy.RANK_TYPE_PLAYER

    -- self.proxy:TestData()
    -- self:updateUI()

    self.proxy:onTriggerNet400001Req( { })

    self._ItemUIIndex = 1
end


function RebelsRankPanel:updateUI()
    self:updatePanelTop()
    self:updateListView()
end


function RebelsRankPanel:updatePanelTop()

    local rebelsActivityInfo = self.proxy:getActivityInfo()

    if self.curRankType == RebelsProxy.RANK_TYPE_PLAYER then

        self.panelMyRankInfo:setVisible(true);
        self.panelLegionRankInfo:setVisible(false);

        local labKillNum = self.panelMyRankInfo:getChildByName("labKillNum")
        if labKillNum.richLabel == nil then
            labKillNum.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            labKillNum.richLabel:setPosition(labKillNum:getPosition())
            labKillNum:getParent():addChild(labKillNum.richLabel)
        end

        local richInfo = self.proxy:getRichTextInfoByPlayerKillInfo()
        labKillNum.richLabel:setString(richInfo)

        local labScore = self.panelMyRankInfo:getChildByName("labScore")
        labScore:setString(self.proxy:getPlayerKillScore())

        local labRank = self.panelMyRankInfo:getChildByName("labRank")
        if rebelsActivityInfo.myRank == -1 then
            labRank:setString(self:getTextWord(401203))
        else
            labRank:setString(rebelsActivityInfo.myRank)
        end


    else
        self.panelMyRankInfo:setVisible(false);
        self.panelLegionRankInfo:setVisible(true);

        local labLegionName = self.panelLegionRankInfo:getChildByName("labLegionName")
        labLegionName:setString(self.proxy:getMyLegionName())

        local labKillNum = self.panelLegionRankInfo:getChildByName("labKillNum")
        if labKillNum.richLabel == nil then
            labKillNum.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            labKillNum.richLabel:setPosition(labKillNum:getPosition())
            labKillNum:getParent():addChild(labKillNum.richLabel)
        end
        local richInfo = self.proxy:getRichTextInfoByLegionKillInfo()
        labKillNum.richLabel:setString(richInfo)

        local labScore = self.panelLegionRankInfo:getChildByName("labScore")
        labScore:setString(self.proxy:getLegionKillScore())

        local labRank = self.panelLegionRankInfo:getChildByName("labRank")
        if rebelsActivityInfo.legionRank == -1 then
            labRank:setString(self:getTextWord(401203))
        else
            labRank:setString(rebelsActivityInfo.legionRank)
        end
    end
end


function RebelsRankPanel:updateListView()

    local imgColumnNameBg = self.panelTop:getChildByName("imgColumnNameBg")
    local labColumnName = imgColumnNameBg:getChildByName("labColumnName")

    local rankServerData = nil

    if self.curRankType == RebelsProxy.RANK_TYPE_PLAYER then
        labColumnName:setString(self:getTextWord(401011))

        TextureManager:updateImageView(self.imgBtnRank[1], "images/rebels/Bth_down_fram.png")
        TextureManager:updateImageView(self.imgBtnRank[2], "images/rebels/Bth_been_fram.png")

        rankServerData = self.proxy:getRanksData(RebelsProxy.RANK_TYPE_PLAYER)

    else
        labColumnName:setString(self:getTextWord(401012))
        TextureManager:updateImageView(self.imgBtnRank[1], "images/rebels/Bth_been_fram.png")
        TextureManager:updateImageView(self.imgBtnRank[2], "images/rebels/Bth_down_fram.png")

        rankServerData = self.proxy:getRanksData(RebelsProxy.RANK_TYPE_LEGION)
    end

    self:renderScrollView(self._svRank, "panelItem", rankServerData, self, self.renderItemUI, self._ItemUIIndex)
    self._ItemUIIndex = nil
    
    local posY = self:getChildByName("panelTop/imgColumnNameBg/Image_38"):getPositionY()
    local num = #rankServerData
    local offsetHeight = num * 60
    local listHeight = self._svRank:getContentSize().height
    if offsetHeight > listHeight then
        offsetHeight = listHeight
    end

    self:getChildByName("panelTop/imgColumnNameBg/imgBottomLine"):setPositionY(posY - offsetHeight - 21)
end

function RebelsRankPanel:renderItemUI(item, itemInfo, index)

    if itemInfo == nil then
        return
    end

    local imgItemBg = item:getChildByName("imgItemBg")
    local rankImg = item:getChildByName("imgRank")
    rankImg:setVisible(false)
    if itemInfo.rank < 4 then 
        rankImg:setVisible(true)
	    TextureManager:updateImageView(rankImg, "images/newGui2/IconNum_" .. itemInfo.rank .. ".png")
    end
    if index%2 == 0 then
	    TextureManager:updateImageView(imgItemBg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(imgItemBg, "images/newGui9Scale/S9Brown.png")
    end

    local labRank = item:getChildByName("labRank")
    labRank:setString(itemInfo.rank)

    local labName = item:getChildByName("labName")
    labName:setString(itemInfo.name)

    -- 击杀数量
    local labKill = item:getChildByName("labKill")
    if labKill.richLabel == nil then
        labKill.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)

        labKill:getParent():addChild(labKill.richLabel)
    end
    local richInfo = self.proxy:getRichTextInfoByKillInfo(itemInfo.killInfos)
    labKill.richLabel:setString(richInfo)

    labKill.richLabel:setPositionX(labKill:getPositionX() - labKill.richLabel:getContentSize().width / 2)
    labKill.richLabel:setPositionY(labKill:getPositionY() + labKill.richLabel:getContentSize().height / 2)

    -- 击杀积分
    local labScore = item:getChildByName("labScore")
    local score = self.proxy:getKillScoreByKillInfo(itemInfo.killInfos)
    labScore:setString(score)

end

function RebelsRankPanel:switchRankList(rankType)
    self.curRankType = rankType
    self._ItemUIIndex = 1
    self:updateUI()
end


function RebelsRankPanel:onSwitchRankList(sender)
    self:switchRankList(sender.tag)
end

function RebelsRankPanel:onTip(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = { }
    for i = 0, 0 do
        lines[i] = { { content = TextWords:getTextWord(401410 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu} }
    end
    uiTip:setAllTipLine(lines)
end