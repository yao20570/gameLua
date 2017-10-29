-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-01-25 17:57:42
--  * @Description: 探险奖励预览
--  */
LimitExpRewardPanel = class("LimitExpRewardPanel", BasicPanel)
LimitExpRewardPanel.NAME = "LimitExpRewardPanel"

function LimitExpRewardPanel:ctor(view, panelName)
    LimitExpRewardPanel.super.ctor(self, view, panelName, 700)
    
    self:setUseNewPanelBg(true)
end

function LimitExpRewardPanel:finalize()
    LimitExpRewardPanel.super.finalize(self)
end

function LimitExpRewardPanel:initPanel()
	LimitExpRewardPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(1325))
	self.config = ConfigDataManager:getConfigData(ConfigData.XiyuSpConfig)
end

function LimitExpRewardPanel:onShowHandler(data)
    -- body
    self:onShowRewardPanel(data)
end

function LimitExpRewardPanel:onShowRewardPanel(info)
	local rewardPanel = self:getChildByName("rewardPanel")
	rewardPanel:setVisible(true)
	local ListView_50 = rewardPanel:getChildByName("ListView_50")
	self:renderListView(ListView_50, self.config, self, self.registerRewardItemEvents)
end

function LimitExpRewardPanel:registerRewardItemEvents(item,data)
	if item == nil or data == nil then
		return
	end
	local index = item:getChildByName("index")
	index:setString(string.format(self:getTextWord(4000), data.layer))

	local rewardData = StringUtils:jsonDecode(data.reward)
	local iconData = {}
	for i=1,#rewardData do
		local id = rewardData[i]
		iconData[i] = ConfigDataManager:getRewardConfigById(id)
	end
	for i = 1,3 do
		local reIwItem = item:getChildByName("item"..i)
		local name = reIwItem:getChildByName("name")
		local oneData = iconData[i]
		reIwItem:setVisible(oneData ~= nil)
		if oneData ~= nil then
			if reIwItem.uiIcon == nil then
				reIwItem.uiIcon = UIIcon.new(reIwItem, oneData, true, self)
				name:setString(oneData.name)
				local color = ColorUtils:getColorByQuality(oneData.color)
				name:setColor(color)
			else
				reIwItem.uiIcon:updateData(oneData)
			end
		end
	end

end

function LimitExpRewardPanel:registerEvents()
    LimitExpRewardPanel.super.registerEvents(self)
    
    -- local closeBtn = self:getChildByName("rewardPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouche)
end

function LimitExpRewardPanel:onCloseBtnTouche(sender)
    self:hide()
end
