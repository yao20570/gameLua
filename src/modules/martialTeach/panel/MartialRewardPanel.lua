-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-23
--  * @Description: 武学讲堂奖励页
--  */
MartialRewardPanel = class("MartialRewardPanel", BasicPanel)
MartialRewardPanel.NAME = "MartialRewardPanel"

function MartialRewardPanel:ctor(view, panelName)
    MartialRewardPanel.super.ctor(self, view, panelName,690)

end

function MartialRewardPanel:finalize()
    MartialRewardPanel.super.finalize(self)
end

function MartialRewardPanel:initPanel()
	MartialRewardPanel.super.initPanel(self)
	self._listview = self:getChildByName("centerPanel/ListView")
    self:setTitle(true, self:getTextWord(392002))
end
function MartialRewardPanel:onShowHandler()
    MartialRewardPanel.super.onShowHandler(self)
    self:updateListView()
end 

function MartialRewardPanel:updateListView()

	-- local rankingID = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig,1).rankingID
    local proxy = self:getProxy(GameProxys.Activity)
    local rankingID = proxy:getCurActivityData().rankId
	local rankingreward = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID).rankingreward
	local config = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rankingreward)
    self:renderListView(self._listview, config, self, self.renderItemPanel)
end


function MartialRewardPanel:renderItemPanel(itemPanel, info, index)
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
-- function MartialRewardPanel:doLayout()
--     local topPanel = self:getChildByName("topPanel")
--     local tabsPanel = self:getTabsPanel()
--     NodeUtils:adaptiveTopPanelAndListView(topPanel, self._listview, GlobalConfig.downHeight, tabsPanel)
-- end

function MartialRewardPanel:registerEvents()
	MartialRewardPanel.super.registerEvents(self)

end
---------------------

