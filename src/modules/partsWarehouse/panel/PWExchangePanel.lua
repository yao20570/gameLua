-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-5-3
--  * @Description: 晶石兑换
--  */
PWExchangePanel = class("PWExchangePanel", BasicPanel)
PWExchangePanel.NAME = "PWExchangePanel"

function PWExchangePanel:ctor(view, panelName)
    PWExchangePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PWExchangePanel:finalize()
    PWExchangePanel.super.finalize(self)
end

function PWExchangePanel:initPanel()
	PWExchangePanel.super.initPanel(self)
	self._topPanel 			= self:getChildByName("topPanel")	
	self._listView 			= self:getChildByName("listView")	
	self._playerConsumablesLab 	= self:getChildByName("topPanel/numLab")

	self._consumableNum    = 0       --晶石 显示数量
end
function PWExchangePanel:onShowHandler()
	self:updateSparExchangeView()
end
function PWExchangePanel:doLayout()
    local tabsPanel = self:getTabsPanel()

    NodeUtils:adaptiveUpPanel(self._topPanel,tabsPanel,0)

    -- NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil, nil, tabsPanel)
    NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, self._topPanel,GlobalConfig.downHeight/2)
end
function PWExchangePanel:registerEvents()
	PWExchangePanel.super.registerEvents(self)
end

function PWExchangePanel:updateSparExchangeView()
	local itemProxy = self:getProxy(GameProxys.Item)
    self._consumableNum = itemProxy:getItemNumByType(PlayerPowerDefine.POWER_PWSpar)
	self._playerConsumablesLab:setString(self._consumableNum)

    local info = ConfigDataManager:getConfigData(ConfigData.OrdnanceShopConfig)
    table.sort( info, function (a,b)
    	return a.sort < b.sort
    end )
    self:renderListView(self._listView, info, self, self.renderItemPanel)
end
function PWExchangePanel:renderItemPanel(itemPanel, info, index)
    local iconImg = itemPanel:getChildByName("iconImg")
    local nameLab = itemPanel:getChildByName("nameLab")
    local descLab = itemPanel:getChildByName("descLab")
    local needNumLab = itemPanel:getChildByName("needNumLab")
	local titileIconImg = itemPanel:getChildByName("titileIconImg")

    local labs = {}
    for i =1,4 do
        labs[i] = itemPanel:getChildByName("lab" .. i)
        labs[i]:setString("")
    end

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
    --拼接字符串 如 道具名（0/1）

    local fullStr
    local partsProxy = self:getProxy(GameProxys.Parts)
    local playerNum = partsProxy:getSparExchangeTimeByID(info.ID)
    if info.daymax ~= 0 then
        -- fullStr = string.format(self:getTextWord(8240), iconImg.uiIcon._data.name, playerNum, info.daymax)
        fullStr = iconImg.uiIcon._data.name
        labs[1]:setString(self:getTextWord(8240))
        labs[2]:setString(tostring(playerNum))
        labs[3]:setString("/" .. tostring(info.daymax))
        labs[4]:setString(self:getTextWord(8245))
        if playerNum >= info.daymax then
            labs[2]:setColor(ColorUtils.commonColor.c3bRed)
        else
            labs[2]:setColor(ColorUtils.commonColor.c3bGreen)
        end
    else
        fullStr = iconImg.uiIcon._data.name
    end
    nameLab:setString(fullStr)

    NodeUtils:alignNodeL2R(nameLab,labs[1],labs[2],labs[3],labs[4])

    local quality = iconImg.uiIcon._data.color
    nameLab:setColor(ColorUtils:getColorByQuality(quality))

    --描述
    descLab:setString(info.describe)

    --合成需要的数量
    local consume = StringUtils:jsonDecode(info.consume)
    local needNum = consume[1][3]
    needNumLab:setString(needNum)
    NodeUtils:centerNodes(btn, {needNumLab,titileIconImg})
    --按钮
    btn.info = info
    btn.index = info.index
    self:addTouchEventListener(btn, self.onItemBtnHandler)

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
    	descLab:setString(string.format(self:getTextWord(8241),name, condition[2]))
    	descLab:setColor(ColorUtils.commonColor.c3bRed)
    	NodeUtils:setEnable(btn, false)
    else
    	NodeUtils:setEnable(btn, true)
		descLab:setColor(ColorUtils.commonColor.c3bMiaoShu)
    	
    end
    --晶石不足
    if needNum > self._consumableNum then
        NodeUtils:setEnable(btn, false)
    else
        NodeUtils:setEnable(btn, true)
    end
    
    --]]

end
function PWExchangePanel:onItemBtnHandler(sender)
    local consume = StringUtils:jsonDecode(sender.info.consume)
    local needNum = consume[1][3]
    if self._consumableNum < needNum then
        self:showSysMessage(self:getTextWord(8239))
        return
    end
	local sendData = {}
	sendData.typeId = sender.info.ID

    local partsProxy = self:getProxy(GameProxys.Parts)
	partsProxy:onTriggerNet130110Req(sendData)
end