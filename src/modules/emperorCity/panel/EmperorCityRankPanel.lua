-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorCityRankPanel = class("EmperorCityRankPanel", BasicPanel)
EmperorCityRankPanel.NAME = "EmperorCityRankPanel"

function EmperorCityRankPanel:ctor(view, panelName)
    EmperorCityRankPanel.super.ctor(self, view, panelName)

end

function EmperorCityRankPanel:finalize()
    EmperorCityRankPanel.super.finalize(self)
end

function EmperorCityRankPanel:initPanel()
	EmperorCityRankPanel.super.initPanel(self)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    self._showIndex = 1 -- 默认选择界面1
end

function EmperorCityRankPanel:registerEvents()
	EmperorCityRankPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._bottomPanel = self:getChildByName("bottomPanel")

    self._indexBtn1    = self._mainPanel:getChildByName("indexBtn1")
    self._indexBtn2    = self._mainPanel:getChildByName("indexBtn2")
    self._listView1    = self:getChildByName("listView1")
    self._listView2    = self:getChildByName("listView2")
    self._titleNameTxt = self._mainPanel:getChildByName("titleNameTxt")
    self._powerTitleTxt= self._mainPanel:getChildByName("powerTitleTxt")


    self._rewardBtn    = self._bottomPanel:getChildByName("rewardBtn")


    self:addTouchEventListener(self._indexBtn1, self.onIndexBtn1)
    self:addTouchEventListener(self._indexBtn2, self.onIndexBtn2)

    self:addTouchEventListener(self._rewardBtn, self.onRewardBtn)
end

function EmperorCityRankPanel:doLayout()
    local tabsPanel = self:getTabsPanel()

    NodeUtils:adaptiveTopPanelAndListView(self._mainPanel, self._listView1, self._bottomPanel, tabsPanel, 0)
    NodeUtils:adaptiveTopPanelAndListView(self._mainPanel, self._listView2, self._bottomPanel, tabsPanel, 0)

    local lineImg = self:getChildByName("Image_51")
    lineImg:setPositionY(self._listView1:getPositionY() - 2)
end

function EmperorCityRankPanel:onShowHandler()
    -- 发送消息号
    self._emperorCityProxy:onTriggerNet550003Req({})

    self._listView1:setVisible(false)
    self._listView2:setVisible(false)
    -- 回调刷新todocity
    -- self:onUpdateRankPanel()
end


-- 回调刷新todocity
function EmperorCityRankPanel:onUpdateRankPanel()
    self._listView1:setVisible(true)
    self._listView2:setVisible(true)

    self:setShowListView(self._showIndex)
end

-- 点击领取排名奖励
function EmperorCityRankPanel:onUpdateRankReward()
    local btnState = self._emperorCityProxy:getRewardState() -- 0不可领取，1可领取，2已领取
    -- 刷新界面上的红点
    if self._uiRankToRewardPanel then
        self._uiRankToRewardPanel:setRewardBtnState(btnState)
    end

    -- 刷新按钮上的红点
    local redImg = self._rewardBtn:getChildByName("redImg")
    if btnState == 1 then -- 可领取则显示红点
        redImg:setVisible(true)
    else
        redImg:setVisible(false)
    end
end 


function EmperorCityRankPanel:onIndexBtn1(sender)
    self._showIndex = 1
    self:setShowListView(self._showIndex)
end


function EmperorCityRankPanel:onIndexBtn2(sender)
    self._showIndex = 2
    self:setShowListView(self._showIndex)
end

function EmperorCityRankPanel:onRewardBtn(sender)
    logger:info("显示奖励界面")
    local configInfo = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, 25) -- 皇城战奖励类型

    local rewardGroupId = configInfo.rankingreward -- 奖励组id 26
     
    local listData = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rewardGroupId)
    
    local btnState = self._emperorCityProxy:getRewardState() -- 0不可领取，1可领取，2已领取
    self:onUpdateRewardPanel(listData, btnState)
end

function EmperorCityRankPanel:onUpdateRewardPanel(listData, btnState)
    self._uiRankToRewardPanel = UIRankToRewardPanel.new(self, self.getRewardHandler)
    self._uiRankToRewardPanel:setRewardList(listData)
    self._uiRankToRewardPanel:setRewardBtnState(btnState)
end

function EmperorCityRankPanel:setShowListView(index)
    for i = 1, 2 do
        local listView = self:getChildByName("listView"..i)
        if i == index then 
            listView:setVisible(true)
            self:setListView(listView, index)
        else
            listView:setVisible(false)
        end
    end

    -- 奖励按钮只在个人排名显示
    local btnState = self._emperorCityProxy:getRewardState()
    local redImg = self._rewardBtn:getChildByName("redImg")
    if btnState == 1 then -- 可领取则显示红点
        redImg:setVisible(true)
    else
        redImg:setVisible(false)
    end
    
    -- --
    if index == 1 then
        self._rewardBtn:setVisible(true)
    else
        self._rewardBtn:setVisible(false)
    end

    self:setTabBtnState(index)
    self:setTitleName(index)
end

function EmperorCityRankPanel:getRewardHandler()
    logger:info("点击领取奖励")
    self._emperorCityProxy:onTriggerNet551003Req({})
end

------
-- 设置按钮显示状态
function EmperorCityRankPanel:setTabBtnState(index)
    for i = 1, 2 do
        local btn = self._mainPanel:getChildByName("indexBtn"..i)
        if i == index then
            btn:loadTextures("images/newGui2/BtnTab_selected.png", "images/newGui2/BtnTab_normal.png", "", 1)
            btn:setTouchEnabled(false)
            btn:setTitleColor(ColorUtils.wordWhiteColor)
        else
            btn:loadTextures("images/newGui2/BtnTab_normal.png", "images/newGui2/BtnTab_selected.png", "", 1)
            btn:setTouchEnabled(true)
            btn:setTitleColor(ColorUtils.wordYellowColor03)
        end
    end
end

------
-- 设置标题变化
function EmperorCityRankPanel:setTitleName(index)
    if index == 1 then
        self._titleNameTxt:setString(self:getTextWord(401011)) -- "玩家名称"
        self._powerTitleTxt:setString(self:getTextWord(136)) -- "国力"
    elseif index == 2 then
        self._titleNameTxt:setString(self:getTextWord(401012)) -- "同盟名称"
        self._powerTitleTxt:setString(self:getTextWord(144)) -- 
    end
end 



function EmperorCityRankPanel:setListView(listView, index)
    local listData = {}
    if index == 1 then
        listData = self._emperorCityProxy:getPersonRankList()
    else
        listData = self._emperorCityProxy:getLegionRankList()
    end

    table.sort(listData,
    function(item1, item2)
        return item1.rank < item2.rank
    end)


    self:renderListView(listView, listData, self, self.renderItem, nil, nil, 0)
end

function EmperorCityRankPanel:renderItem(itemImg, data, index)
    index = index + 1

    local rankImg  = itemImg:getChildByName("rankImg")
    local rankTxt  = itemImg:getChildByName("rankTxt")
    local nameTxt  = itemImg:getChildByName("nameTxt")
    local powerTxt = itemImg:getChildByName("powerTxt")
    local militaryValueTxt = itemImg:getChildByName("militaryValueTxt")

    -- 排名
    local rank = data.rank
    if rank <= 3 then
        rankImg:setVisible(true)
        rankTxt:setVisible(false)
        local rankUrl = string.format("images/newGui2/IconNum_%s.png", rank)
        TextureManager:updateImageView(rankImg, rankUrl)
    else
        rankImg:setVisible(false)
        rankTxt:setVisible(true)
        rankTxt:setString(rank)
    end

    -- 玩家名称
    local name = data.name
    nameTxt:setString(name)

    -- 战力
    local capacity = data.capacity
    powerTxt:setString(StringUtils:formatNumberByK3(capacity))

    -- 军功
    local militaryValue = data.militaryValue
    militaryValueTxt:setString(militaryValue)

    -- 颜色
    local bgUrl = "images/newGui9Scale/S9Gray.png"
    if index %2 == 0 then
        bgUrl = "images/newGui9Scale/S9Bg.png"
    end
    TextureManager:updateImageView(itemImg, bgUrl)
end


