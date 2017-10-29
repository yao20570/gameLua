
PullBarRewardPanel = class("PullBarRewardPanel", BasicPanel)
PullBarRewardPanel.NAME = "PullBarRewardPanel"

function PullBarRewardPanel:ctor(view, panelName)
    PullBarRewardPanel.super.ctor(self, view, panelName, 750)

end

function PullBarRewardPanel:finalize()
    PullBarRewardPanel.super.finalize(self)
end

function PullBarRewardPanel:initPanel()
	PullBarRewardPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(338))
end

function PullBarRewardPanel:registerEvents()
	PullBarRewardPanel.super.registerEvents(self)
	self.listView = self:getChildByName("ListView")
end

function PullBarRewardPanel:onShowHandler(data)
	local info = self:infoTodouble(data)
	self:renderListView(self.listView, info, self, self.renderItemPanel)
end

function PullBarRewardPanel:renderItemPanel(itemPanel, info, index)
    local panelGoodsLeft = itemPanel:getChildByName("bg1")
    local infoLeft = info[1]
    self:renderItems(panelGoodsLeft, infoLeft)
    local panelGoodsRight = itemPanel:getChildByName("bg2")
    local infoRight = info[2]
    self:renderItems(panelGoodsRight, infoRight)
end

function PullBarRewardPanel:renderItems(itemPanel,info)
	if info == nil then
		itemPanel:setVisible(false)
		return
	end
    itemPanel:setVisible(true)
    local icon = itemPanel.icon
    if icon == nil then
        local iconContainer = itemPanel:getChildByName("container")
        icon = UIIcon.new(iconContainer,info,true,self)
        itemPanel.icon = icon
    else
        icon:updateData(info)
    end
    local config = ConfigDataManager:getConfigByPowerAndID(info.power,info.typeid)
    local name = itemPanel:getChildByName("descTxt")
    name:setColor(ColorUtils:getColorByQuality(config.color))
    name:setString(icon:getName() or "") 
    local num = itemPanel:getChildByName("Label_9")
    num:setString(info.num)
end

function PullBarRewardPanel:infoTodouble(info)
    local tempInfo = {}
    for k,v in pairs(info) do
        if k%2 == 1 then
            tempInfo[(k+1)/2] = {}
            tempInfo[(k+1)/2][1] = v
        else
            tempInfo[k/2][2] = v
        end
    end
    return tempInfo
end