-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-4-7
--  * @Description: 酒令
--  */
PubShopPanel = class("PubShopPanel", BasicPanel)
PubShopPanel.NAME = "PubShopPanel"

function PubShopPanel:ctor(view, panelName)
    PubShopPanel.super.ctor(self, view, panelName)

end

function PubShopPanel:finalize()
    PubShopPanel.super.finalize(self)
end

function PubShopPanel:initPanel()
	PubShopPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Pub)
	self._topPanel 			= self:getChildByName("topPanel")	
	self._listView 			= self:getChildByName("listView")	
	self._playerJiulingLab 	= self:getChildByName("topPanel/numLab")

	self._jiulingNum    = 0       --酒令 显示数量
end
function PubShopPanel:onShowHandler()

    self.view:setBgType(ModulePanelBgType.NONE)

    self.proxy:onTriggerNet450011Req()
	self:updatePubShopView()
end
function PubShopPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    -- NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil, nil, tabsPanel)
    NodeUtils:adaptiveUpPanel(self._topPanel,nil,GlobalConfig.tabsHeight-80)
    NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, tabsPanel,GlobalConfig.topTabsHeight)
end
function PubShopPanel:registerEvents()
	PubShopPanel.super.registerEvents(self)
end

function PubShopPanel:updatePubShopView()
	local roleProxy = self:getProxy(GameProxys.Role)
    self._jiulingNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_jiuling)
	self._playerJiulingLab:setString(self._jiulingNum)

    local info = ConfigDataManager:getConfigData(ConfigData.DrinkChangeConfig)
    table.sort( info, function (a,b)
    	return a.order < b.order
    end )
    self:renderListView(self._listView, info, self, self.renderItemPanel)
end
function PubShopPanel:renderItemPanel(itemPanel, info, index)
    local iconImg = itemPanel:getChildByName("iconImg")
    local nameLab = itemPanel:getChildByName("nameLab")
    local descLab = itemPanel:getChildByName("descLab")
    local needNumLab = itemPanel:getChildByName("needNumLab")
	local titleLab = itemPanel:getChildByName("titleLab")

    --//null
    local lab1=itemPanel:getChildByName("lab1")
    local lab2=itemPanel:getChildByName("lab2")
    local lab3=itemPanel:getChildByName("lab3")
    local lab4=itemPanel:getChildByName("lab4")

    local btn = itemPanel:getChildByName("btn")

    local target = StringUtils:jsonDecode(info.target)
    local iconData = {}
    iconData.typeid = target[1][2]
    iconData.power = target[1][1]
    iconData.num = target[1][3]
    if iconImg.uiIcon == nil then
        iconImg.uiIcon = UIIcon.new(iconImg,iconData,true,self)
    else
        iconImg.uiIcon:updateData(iconData)
    end
    --拼接字符�?�?道具名（0/1�?    
    local fullStr
    local playerNum = self.proxy:getPubShopTimesByID(info.ID)
    if info.daymax ~= 0 then
        --fullStr = string.format(self:getTextWord(366016), iconImg.uiIcon._data.name, playerNum, info.daymax)
        lab1:setVisible(true)
        lab2:setVisible(true)
        lab2:setString(tostring(playerNum))
        lab3:setVisible(true)
        lab4:setVisible(true)
        lab3:setString("/"..tostring(info.daymax))
    else
        --fullStr = iconImg.uiIcon._data.name
        lab1:setVisible(false)
        lab2:setVisible(false)
        lab3:setVisible(false)
        lab4:setVisible(false)
    end

    NodeUtils:alignNodeL2R(nameLab,lab1,lab2,lab3,lab4)

    fullStr=iconImg.uiIcon._data.name
    nameLab:setString(fullStr)
    
    ----[[
    local quality = iconImg.uiIcon._data.color
    nameLab:setColor(ColorUtils:getColorByQuality(quality))
    --]]
    --描述
    descLab:setString(info.describe)
    --合成需要的数量
    local consume = StringUtils:jsonDecode(info.consume)
    local needNum = consume[1][3]
    needNumLab:setString(needNum)
    --按钮
    btn.info = info
    btn.index = info.index
    self:addTouchEventListener(btn, self.onItemBtnHandler)

    self["item" .. index] = btn

    --条件限制
    local canDo = false
    local condition = StringUtils:jsonDecode(info.condition)
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerValue = roleProxy:getRoleAttrValue(condition[1])
    if playerValue >= condition[2] and playerValue  <= condition[3] then
    	canDo = true
    end
    if canDo == false then
    	descLab:setVisible(true)
		local resConfig = ConfigDataManager:getConfigById(ConfigData.ResourceConfig ,condition[1])
		local name = resConfig.name
    	descLab:setString(string.format(self:getTextWord(366004),name, condition[2]))
    	descLab:setColor(ColorUtils.wordRedColor)
    	NodeUtils:setEnable(btn, false)
    else
    	NodeUtils:setEnable(btn, true)
		descLab:setColor(ColorUtils.wordYellowColor03)
    	
    end
    --酒令不足
    if needNum > self._jiulingNum then
        NodeUtils:setEnable(btn, false)
    else
        NodeUtils:setEnable(btn, true)
    end
    


end
function PubShopPanel:onItemBtnHandler(sender)
	print("onItemBtnHandler````````",sender.index)
    local consume = StringUtils:jsonDecode(sender.info.consume)
    local needNum = consume[1][3]
    if self._jiulingNum < needNum then
        self:showSysMessage(self:getTextWord(366010))
        return
    end
	local sendData = {}
	sendData.typeId = sender.info.ID
	self.proxy:onTriggerNet450008Req(sendData)
end