-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-09
--  * @Description: 限时活动_同盟致富_奖励预览弹窗
--  */
LegionRichRewardPanel = class("LegionRichRewardPanel", BasicPanel)
LegionRichRewardPanel.NAME = "LegionRichRewardPanel"

function LegionRichRewardPanel:ctor(view, panelName)
    LegionRichRewardPanel.super.ctor(self, view, panelName,690)

end

function LegionRichRewardPanel:finalize()
    LegionRichRewardPanel.super.finalize(self)
end

function LegionRichRewardPanel:initPanel()
	LegionRichRewardPanel.super.initPanel(self)
	self._listview = self:getChildByName("centerPanel/ListView")
    self:setTitle(true, self:getTextWord(394003))
end

function LegionRichRewardPanel:registerEvents()
	LegionRichRewardPanel.super.registerEvents(self)
end
function LegionRichRewardPanel:onShowHandler()
    LegionRichRewardPanel.super.onShowHandler(self)
    self:updateListView()
end 
function LegionRichRewardPanel:updateListView()

	-- local rankingID = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig,1).rankingID
    local proxy = self:getProxy(GameProxys.Activity)
    local rankingID = proxy:getCurActivityData().rankId
    rankingID = rankingID == 0 and 1 or rankingID
	local rankingreward = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID).rankingreward
	local config = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rankingreward)
    self:renderListView(self._listview, config, self, self.renderItemPanel)
end
function LegionRichRewardPanel:renderItemPanel(itemPanel, info, index)
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