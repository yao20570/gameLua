---------奖励面板
WarlordsRankRewardPanel = class("WarlordsRankRewardPanel", BasicPanel)
WarlordsRankRewardPanel.NAME = "WarlordsRankRewardPanel"

function WarlordsRankRewardPanel:ctor(view, panelName)
    WarlordsRankRewardPanel.super.ctor(self, view, panelName,768)
end

function WarlordsRankRewardPanel:finalize()
    WarlordsRankRewardPanel.super.finalize(self)
end

function WarlordsRankRewardPanel:initPanel()
	WarlordsRankRewardPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1325))
    self._listView = self:getChildByName("rewardPanel/listview")
end

function WarlordsRankRewardPanel:onShowHandler(rankingreward)
    if self._rankingreward ~= rankingreward then
        self._rankingreward = rankingreward
        local data = {}
        local index = 1
        for _,v in pairs(ConfigDataManager:getConfigData(ConfigData.CRankingRewardConfig)) do
            if v.rankingreward == rankingreward then
                data[index] = v
                index = index + 1
            end
        end

        self:renderListView(self._listView, data, self, self.registerItemEvents)
    end
end

function WarlordsRankRewardPanel:registerItemEvents(item,data,index)
    for count = 1,3 do
        local reIwItem = item:getChildByName("itemImg"..count)
        reIwItem:setVisible(false)
    end

    local index_str = ""
    if data.ranking == data.rankingii then
        index_str = string.format(self:getTextWord(250027), data.ranking)
    else
        index_str = string.format(self:getTextWord(250028), data.ranking,data.rankingii)
    end

    local indexLabel = item:getChildByName("indexLabel")
    indexLabel:setString(index_str)

    local countTb = StringUtils:jsonDecode(data.reward)
    local i = 1
    for _,v in pairs(countTb) do
        local reIwItem = item:getChildByName("itemImg"..i)
        local name = reIwItem:getChildByName("name_label")
        local num = reIwItem:getChildByName("num_label")
        local config = ConfigDataManager:getConfigByPowerAndID(v[1],v[2])

        local color = ColorUtils:getColorByQuality(config.color)
        name:setColor(color)        
        name:setString(config.name)

        local iconInfo = {}
        iconInfo.power = v[1]
        iconInfo.typeid = v[2]
        iconInfo.num = v[3]

        local iconSprite = item["item"..i]
        if iconSprite == nil then
            local icon = UIIcon.new(reIwItem, iconInfo, true,self)
            item["item"..i] = icon
        else
            iconSprite:updateData(iconInfo)
        end
        reIwItem:setVisible(true)
        i = i + 1
    end
end