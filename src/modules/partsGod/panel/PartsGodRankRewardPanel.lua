-------------------------排行榜奖励界面------------------------------------
PartsGodRankRewardPanel = class("PartsGodRankRewardPanel", BasicPanel)
PartsGodRankRewardPanel.NAME = "PartsGodRankRewardPanel"

function PartsGodRankRewardPanel:ctor(view, panelName)
    PartsGodRankRewardPanel.super.ctor(self, view, panelName, 750)
end

function PartsGodRankRewardPanel:finalize()
    PartsGodRankRewardPanel.super.finalize(self)
end

function PartsGodRankRewardPanel:initPanel()
	PartsGodRankRewardPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(1325))
	self:initPanelInfo()
	self:onShowRewardPanel()
end

-- 初始化隐藏
function PartsGodRankRewardPanel:initPanelInfo()
	local listview = self:getChildByName("rewardPanel/listView")
	local item = listView:getItem(0)
	item:setVisible(false)
end

function PartsGodRankRewardPanel:registerEvents()
    PartsGodRankRewardPanel.super.registerEvents(self)
end

function PartsGodRankRewardPanel:onShowRewardPanel()
	local rewardPanel = self:getChildByName("rewardPanel")
	rewardPanel:setVisible(true)
	local listview = rewardPanel:getChildByName("listview")
	local rankingID = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID",1).rankingID
	local rankingreward = ConfigDataManager:getInfoFindByOneKey("CurrentRankingConfig","ID",rankingID).rankingreward
	local config = ConfigDataManager:getConfigData("CRankingRewardConfig")
	local data = {}
	for _,v in pairs(config) do
		if v.rankingreward == rankingreward then
			table.insert(data,v)
		end
	end
	self:renderListView(listview, data, self, self.registerRewardItemEvents)
end

function PartsGodRankRewardPanel:registerRewardItemEvents(item,data)
	if item == nil or data == nil then
		return
	end
	local index_label = item:getChildByName("index_label")
	local index_str = ""
	if data.ranking == data.rankingii then
		index_str = string.format(self:getTextWord(250027), data.ranking)
	else
		index_str = string.format(self:getTextWord(250028), data.ranking,data.rankingii)
	end
	index_label:setString(index_str)

	for count = 1,3 do
		local reIwItem = item:getChildByName("itemImg"..count)
		reIwItem:setVisible(false)
	end

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