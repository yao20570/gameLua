-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-08
--  * @Description: 春节活动-爆竹酉礼奖励页
--  */
SpringSquibRewardPanel = class("SpringSquibRewardPanel", BasicPanel)
SpringSquibRewardPanel.NAME = "SpringSquibRewardPanel"

function SpringSquibRewardPanel:ctor(view, panelName)
    SpringSquibRewardPanel.super.ctor(self, view, panelName)

end

function SpringSquibRewardPanel:finalize()
    SpringSquibRewardPanel.super.finalize(self)
end

function SpringSquibRewardPanel:initPanel()
	SpringSquibRewardPanel.super.initPanel(self)
	self._listview = self:getChildByName("ListView")
    local item = self._listview:getItem(0)
    self._listview:setItemModel(item)

    local infoLab = self:getChildByName("topPanel/infoLab")
    infoLab:setString(self:getTextWord(390003))

end
function SpringSquibRewardPanel:onShowHandler()
	self:updateListView()
end
function SpringSquibRewardPanel:updateListView()
	local activityProxy = self:getProxy(GameProxys.Activity)

    --获得获得数据
    local myData = activityProxy:getCurActivityData()
    local posInfo = activityProxy:getSquibPosInfos(myData.activityId)


    local config = ConfigDataManager:getConfigData(ConfigData.FirecrackerConfig)
    for k,v in pairs(config) do
    	config[k]["got"] = false
    end
    if #posInfo > 0 then
    	for i=1,#posInfo do
    		config[i]["got"] = true
    	end
    end
    
    self:renderListView(self._listview, config, self, self.renderItemPanel,false)
end
function SpringSquibRewardPanel:renderItemPanel(item, itemInfo, index)
	local gotImg = item:getChildByName("Image_53")
	gotImg:setVisible(itemInfo["got"])


	for i=1,4 do
		local iconPanel = item:getChildByName("item".. i)
        local nameLab = iconPanel:getChildByName("nameLab")
        nameLab:setString("")
	end

    local rewardArr = RewardManager:jsonRewardGroupToArray(itemInfo.reward)
    for i, v in ipairs(rewardArr) do
        local iconPanel = item:getChildByName("item".. i)
        local iconContainer = iconPanel:getChildByName("Img")
        local nameLab = iconPanel:getChildByName("nameLab")

        
        if iconContainer.icon then
            iconContainer.icon:updateData(v)
        else
            iconContainer.icon = UIIcon.new(iconContainer, v, true, self, nil,  true)

            local txt =  iconContainer.icon:getNameChild()
            txt:setFontSize(20)
        end
    end


end
function SpringSquibRewardPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, self._listview, GlobalConfig.downHeight, tabsPanel)
end

function SpringSquibRewardPanel:registerEvents()
	SpringSquibRewardPanel.super.registerEvents(self)
end