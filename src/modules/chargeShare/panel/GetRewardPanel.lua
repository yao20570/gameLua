
GetRewardPanel = class("GetRewardPanel", BasicPanel)
GetRewardPanel.NAME = "GetRewardPanel"

function GetRewardPanel:ctor(view, panelName)
    GetRewardPanel.super.ctor(self, view, panelName)
    self.allItem = {}
end

function GetRewardPanel:finalize()
    GetRewardPanel.super.finalize(self)
end

function GetRewardPanel:initPanel()
	GetRewardPanel.super.initPanel(self)
    self.proxy = self:getProxy(GameProxys.Activity)
    self.list = self:getChildByName("ListView_2")
   
    local item = self.list:getItem(0)
    self.list:setItemModel(item)
    item:setVisible(false)

end

function GetRewardPanel:doLayout()
     local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self.list, GlobalConfig.downHeight, tabsPanel)
end

function GetRewardPanel:update(dt)
    for k,v in pairs(self.allItem) do
        local time = self.proxy:getRemainTime(self.proxy:getScheduKey(self.proxy.pkgKey, v.pos))
        if time ~= 0 then
            local newTime = TimeUtils:getStandardFormatTimeString6(time)
            v.lab:setString(newTime..self:getTextWord(249993))
        end
    end
end

function GetRewardPanel:initView(data)
    self.allItem = {}
    self:renderListView(self.list, data, self, self.renderItemPanel)
end

function GetRewardPanel:renderItemPanel(item, data)
    local allChild = self:getAllChild(item)
    allChild.lab_name:setString(data.player)

    local rewardData = self:getNameById(data.id)
    allChild.pkgName:setString(rewardData.name)
    allChild.pkgName:setColor(self.mPanel:getColor(rewardData.color))

    allChild.btn_get.id = data.id
    allChild.btn_get.item = item
    allChild.btn_get.pos = data.pos
    self:addTouchEventListener(allChild.btn_get, self.getReward)

    local itemData = {}
    itemData.lab = allChild.lab_time
    itemData.item = item
    itemData.pos = data.pos
    itemData.time = data.timeLeft - (os.time() - data.time)
    table.insert(self.allItem, itemData)

    local time = TimeUtils:getStandardFormatTimeString6(data.timeLeft - (os.time() - data.time))
    allChild.lab_time:setString(time..self:getTextWord(249993))

    local iconData = {}
    iconData.num = rewardData.num
    iconData.power = rewardData.power
    iconData.typeid = rewardData.typeid

    local uiIcon = allChild.img_icon.uiIcon
    if not uiIcon then
        uiIcon = UIIcon.new(allChild.img_icon,iconData,true,self)
        allChild.img_icon.uiIcon = uiIcon
    else
        uiIcon:updateData(iconData)
    end
    uiIcon:setPosition(allChild.img_icon:getContentSize().width/2, allChild.img_icon:getContentSize().height/2)

end

function GetRewardPanel:getReward(sender)
    self.removeId = self.list:getIndex(sender.item)
    self.pos = sender.pos
    self.proxy:onTriggerNet230006Req({id = sender.id})
end

function GetRewardPanel:removeItem()
    self:showSysMessage(self:getTextWord(1118))
    for k,v in pairs(self.allItem) do
        if v.pos == self.pos then
            table.remove(self.allItem, k)
            break
        end
    end
    self.proxy:removeInfo(self.pos)
    self.mPanel:updateRad()
    self.allItem = {}
    self:renderListView(self.list, self.proxy:returnInfo(), self, self.renderItemPanel)
end

function GetRewardPanel:getNameById(id)
    local ConfigData = ConfigDataManager:getConfigData(ConfigData.LegionShareConfig)
    local data = ConfigData[id]
    local allId = StringUtils:jsonDecode(data.reward)
    local rewardInfo = ConfigDataManager:getRewardConfigById(tonumber(allId[1]))
    return rewardInfo
end

function GetRewardPanel:registerEvents()
	GetRewardPanel.super.registerEvents(self)
end

function GetRewardPanel:getAllChild(item)
    local allChild = {}
    allChild.pkgName = item:getChildByName("pkg_name")
    allChild.lab_time = item:getChildByName("lab_time")
    allChild.lab_name = item:getChildByName("lab_name")
    allChild.img_icon = item:getChildByName("img_icon")
    allChild.btn_get = item:getChildByName("Button_15")
    allChild.btn_get:setTitleText(self:getTextWord(249994))
    return allChild
end

function GetRewardPanel:onShowHandler()
    self.mPanel = self:getPanel(ChargeSharePanel.NAME)
    local data = self.proxy:returnInfo()
    self:initView(data)
end


