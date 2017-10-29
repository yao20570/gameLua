LordCityRankRewardPrePanel = class("LordCityRankRewardPrePanel", BasicPanel)
LordCityRankRewardPrePanel.NAME = "LordCityRankRewardPrePanel"

function LordCityRankRewardPrePanel:ctor(view, panelName)
    LordCityRankRewardPrePanel.super.ctor(self, view, panelName,720)
end

function LordCityRankRewardPrePanel:finalize()
    LordCityRankRewardPrePanel.super.finalize(self)
end

function LordCityRankRewardPrePanel:initPanel()
	LordCityRankRewardPrePanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.Consort)

	self._listview = self:getChildByName("centerPanel/ListView")
    self:setTitle(true, self:getTextWord(430004))
end

function LordCityRankRewardPrePanel:registerEvents()
	LordCityRankRewardPrePanel.super.registerEvents(self)
end

function LordCityRankRewardPrePanel:onShowHandler()
    LordCityRankRewardPrePanel.super.onShowHandler(self)
    self:updateListView()
end 

function LordCityRankRewardPrePanel:updateListView()
    local lordcityProxy = self:getProxy(GameProxys.LordCity)
    local cityId = lordcityProxy:getSelectCityId()
    local cityConfig = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig,cityId)
    local rankingreward = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, cityConfig.rankingID).rankingreward    
    local config = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rankingreward)
    self:renderListView(self._listview, config, self, self.renderItemPanel)
end

function LordCityRankRewardPrePanel:renderItemPanel(itemPanel, info, index)
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