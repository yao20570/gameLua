-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-12-04 19:16:00
--  * @Description: 叛军奖励
--  */
RebelsRewardPanel = class("RebelsRewardPanel", BasicPanel)
RebelsRewardPanel.NAME = "RebelsRewardPanel"

function RebelsRewardPanel:ctor(view, panelName)
    RebelsRewardPanel.super.ctor(self, view, panelName)

end


function RebelsRewardPanel:finalize()
    RebelsRewardPanel.super.finalize(self)
end


function RebelsRewardPanel:initPanel()
    RebelsRewardPanel.super.initPanel(self)

    self.proxy = self:getProxy(GameProxys.Rebels)

    -- top面板
    self.panelTop = self:getChildByName("panelTop")
    self.panelMyInfo = self.panelTop:getChildByName("panelMyInfo")
    self.panelLegionInfo = self.panelTop:getChildByName("panelLegionInfo")
    local btnTip = self.panelTop:getChildByName("btnTip")
    self:addTouchEventListener(btnTip, self.onTip)

    self.imgBtnReward = { }
    for i = 1, 2 do
        self.imgBtnReward[i] = self.panelTop:getChildByName("imgBtnReward" .. i)
        self.imgBtnReward[i].tag = i
        self:addTouchEventListener(self.imgBtnReward[i], self.onSwitchRewardList)
    end
    self.imgBtnReward[2]:setVisible(false)  --暂时屏蔽同盟按钮


    -- 排名列表
    self._svReward = self:getChildByName("svReward")    
    self._ItemUIIndex = 1

    -- bottom面板
    self.panelBottom = self:getChildByName("panelBottom")
    self.btnNone = self.panelBottom:getChildByName("btnNone")
    self.btnHasGot = self.panelBottom:getChildByName("btnHasGot")
    self.btnCanGet = self.panelBottom:getChildByName("btnCanGet")
    self:addTouchEventListener(self.btnCanGet, self.onGetReward)

    -- 切换到玩家排名
    self:switchRewardList(RebelsProxy.RANK_TYPE_PLAYER);
end


function RebelsRewardPanel:registerEvents()
    RebelsRewardPanel.super.registerEvents(self)
end


function RebelsRewardPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self.panelTop, nil, nil, tabsPanel, 3)
    NodeUtils:adaptiveListView(self._svReward, self.panelBottom, self.panelTop, 3)
    self:createScrollViewItemUIForDoLayout(self._svReward)
end


function RebelsRewardPanel:onClosePanelHandler()
    self:dispatchEvent(RebelsEvent.HIDE_SELF_EVENT)
end


function RebelsRewardPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end

    self.curRankType = RebelsProxy.RANK_TYPE_PLAYER

    -- self.proxy:TestData()
    -- self:updateUI()

    self.proxy:onTriggerNet400002Req( { })

    self._ItemUIIndex = 1
end


function RebelsRewardPanel:updateUI()
    self:updatePanelTop()
    self:updateListView()
    self:updatePanelBottom()
end

-- 更新基本信息
function RebelsRewardPanel:updatePanelTop()

    local rebelsActivityInfo = self.proxy:getActivityInfo()


    local preWeekInfo = self.proxy:getPreWeekInfo()

    if self.curRankType == RebelsProxy.RANK_TYPE_PLAYER then

        self.panelMyInfo:setVisible(true)
        self.panelLegionInfo:setVisible(false)

        TextureManager:updateImageView(self.imgBtnReward[1], "images/rebels/Bth_down_fram.png")
        TextureManager:updateImageView(self.imgBtnReward[2], "images/rebels/Bth_been_fram.png")

        local labMyScore = self.panelMyInfo:getChildByName("labMyScore")
        local labMyRank = self.panelMyInfo:getChildByName("labMyRank")
        if preWeekInfo.playerRankInfos == nil then
            labMyScore:setString(0)
            labMyRank:setString(0)
        else
            local score = self.proxy:getKillScoreByKillInfo(preWeekInfo.playerRankInfos.killInfos)
            labMyScore:setString(score)

            if (preWeekInfo.playerRankInfos.rank == -1) then
                labMyRank:setString(self:getTextWord(401203))
            else
                labMyRank:setString(preWeekInfo.playerRankInfos.rank)
            end
        end


    else
        self.panelMyInfo:setVisible(false)
        self.panelLegionInfo:setVisible(true)

        TextureManager:updateImageView(self.imgBtnReward[1], "images/rebels/Bth_been_fram.png")
        TextureManager:updateImageView(self.imgBtnReward[2], "images/rebels/Bth_down_fram.png")

        local labLogionScore = self.panelLegionInfo:getChildByName("labLegionScore")
        local labLoginRank = self.panelLegionInfo:getChildByName("labLegionRank")
        if preWeekInfo.legionRankInfos == nil then
            labLogionScore:setString(0)
            labLoginRank:setString(0)
        else
            local score = self.proxy:getKillScoreByKillInfo(preWeekInfo.legionRankInfos.killInfos)
            labLogionScore:setString(score)
            if (preWeekInfo.legionRankInfos.rank == -1) then
                labLoginRank:setString(self:getTextWord(401203))
            else
                labLoginRank:setString(preWeekInfo.legionRankInfos.rank)
            end
        end

    end
end

-- 更新奖励列表
function RebelsRewardPanel:updateListView()
    local rewardDataList = self.proxy:getRewardDataList(self.curRankType)

    self:renderScrollView(self._svReward, "panelItem", rewardDataList, self, self.renderItemUI, nil, 6)
    self._ItemUIIndex = nil
end

function RebelsRewardPanel:renderItemUI(item, data, index)
    
    -- 排名名称
    local labRankName = item:getChildByName("labRankName")
    if data.ranking == data.rankingii then
        labRankName:setString(string.format(self:getTextWord(401201), data.ranking))
    else
        labRankName:setString(string.format(self:getTextWord(401202), data.ranking, data.rankingii))
    end

    -- 奖励物品
    local items = StringUtils:jsonDecode(data.reward)

    for index = 1, 3 do
        local imgIcon = item:getChildByName("imgIcon" .. index)
        if items[index] == nil then
            imgIcon:setVisible(false)
        else
            imgIcon:setVisible(true)

            local iconData = { }
            iconData.typeid = items[index][2]
            iconData.num = items[index][3]
            iconData.power = items[index][1]
            if imgIcon.uiIcon == nil then
                imgIcon.uiIcon = UIIcon.new(imgIcon, iconData, true, self, nil, true)
            else
                imgIcon.uiIcon:updateData(iconData)
            end
        end
    end
end

function RebelsRewardPanel:updatePanelBottom()
    local preWeekInfo = self.proxy:getPreWeekInfo()
    local state = RebelsProxy.RewardStateNone
    if self.curRankType == RebelsProxy.RANK_TYPE_PLAYER then
        state = preWeekInfo.playerRewardState
    else
        state = preWeekInfo.legionRewardState
    end

    if state == nil then
        state = state == nil and RebelsProxy.RewardStateNone
    end
    self.btnNone:setVisible(state == RebelsProxy.RewardStateNone)
    self.btnCanGet:setVisible(state == RebelsProxy.RewardStateCanGet)
    self.btnHasGot:setVisible(state == RebelsProxy.RewardStateHasGot)
end



-- 切换奖励
function RebelsRewardPanel:switchRewardList(rankType)
    self.curRankType = rankType    
    self._ItemUIIndex = 1
    self:updateUI()
end


function RebelsRewardPanel:onSwitchRewardList(sender)
    self:switchRewardList(sender.tag)
end

function RebelsRewardPanel:onGetReward(sender)
    self.proxy:onTriggerNet400003Req( { type = self.curRankType })
end

function RebelsRewardPanel:onTip(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = { }
    for i = 0, 0 do
        lines[i] = { { content = TextWords:getTextWord(401420 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu} }
    end
    uiTip:setAllTipLine(lines)
end