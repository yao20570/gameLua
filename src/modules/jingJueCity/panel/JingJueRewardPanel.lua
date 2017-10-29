-- /**
--  * @Author:    lizhuojian
--  * @DateTime:     2017-02-22
--  * @Description: 限时活动_精绝古城奖励页
--  */
JingJueRewardPanel = class("JingJueRewardPanel", BasicPanel)
JingJueRewardPanel.NAME = "JingJueRewardPanel"

function JingJueRewardPanel:ctor(view, panelName)
    -- JingJueRewardPanel.super.ctor(self, view, panelName,690)
    JingJueRewardPanel.super.ctor(self, view, panelName,700)

end

function JingJueRewardPanel:finalize()
    JingJueRewardPanel.super.finalize(self)
end

function JingJueRewardPanel:initPanel()
	JingJueRewardPanel.super.initPanel(self)
	self._listview = self:getChildByName("centerPanel/ListView")
    self:setTitle(true, self:getTextWord(392002))
    self.proxy = self:getProxy(GameProxys.Activity)
end

function JingJueRewardPanel:onShowHandler()
    JingJueRewardPanel.super.onShowHandler(self)
    self:updateListView()
end 

function JingJueRewardPanel:updateListView()

    self.myData = self.proxy:getCurActivityData()
    local jingJueInfo = self.proxy:getJingJueInfoById(self.myData.activityId)
    local jsonConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.TombCityConfig, "effectID", self.myData.effectId)

    local rankingID = self.myData.rankId
	-- local rankingID = jsonConfig.rankingID

	local rankingreward = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID).rankingreward

	local config = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rankingreward)
    self:renderListView(self._listview, config, self, self.renderItemPanel)
end


function JingJueRewardPanel:renderItemPanel(itemPanel, info, index)
    local nameLab = itemPanel:getChildByName("index_label")
    local itemArr  = {}
    local itemImg1 = itemPanel:getChildByName("itemImg1")
    table.insert(itemArr,itemImg1)
    local itemImg2 = itemPanel:getChildByName("itemImg2")
    table.insert(itemArr,itemImg2)
    local itemImg3 = itemPanel:getChildByName("itemImg3")
    table.insert(itemArr,itemImg3)
    local itemImg4 = itemPanel:getChildByName("itemImg4")
    table.insert(itemArr,itemImg4)
    
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
-- function JingJueRewardPanel:doLayout()
--     local topPanel = self:getChildByName("topPanel")
--     local tabsPanel = self:getTabsPanel()
--     NodeUtils:adaptiveTopPanelAndListView(topPanel, self._listview, GlobalConfig.downHeight, tabsPanel)
-- end

function JingJueRewardPanel:registerEvents()
	JingJueRewardPanel.super.registerEvents(self)

end
---------------------

