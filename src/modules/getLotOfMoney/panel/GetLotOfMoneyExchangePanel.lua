-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
GetLotOfMoneyExchangePanel = class("GetLotOfMoneyExchangePanel", BasicPanel)
GetLotOfMoneyExchangePanel.NAME = "GetLotOfMoneyExchangePanel"

function GetLotOfMoneyExchangePanel:ctor(view, panelName)
    GetLotOfMoneyExchangePanel.super.ctor(self, view, panelName)

    self.currentActivityId = nil
end

function GetLotOfMoneyExchangePanel:finalize()
    GetLotOfMoneyExchangePanel.super.finalize(self)
end

function GetLotOfMoneyExchangePanel:initPanel()
	GetLotOfMoneyExchangePanel.super.initPanel(self)

	self._mainPanel = self:getChildByName("mainPanel")
	self._activityProxy = self:getProxy(GameProxys.Activity)
end

function GetLotOfMoneyExchangePanel:registerEvents()
	GetLotOfMoneyExchangePanel.super.registerEvents(self)
end

function GetLotOfMoneyExchangePanel:onShowHandler()
	print("onShowHandler  GetLotOfMoneyExchangePanel")
	local panel = self:getPanel(GetLotOfMoneyPanel.NAME)
	self.currentActivityId = panel:getCurrentActivityId()
	self:updateListView()
end

function GetLotOfMoneyExchangePanel:doLayout()
	local getLotOfMoneyPanel = self:getPanel(GetLotOfMoneyPanel.NAME)
	local mainPanel = getLotOfMoneyPanel:getChildByName("mainPanel")
	local topPanel = mainPanel:getChildByName("topPanel")
	local downPanel = mainPanel:getChildByName("downPanel")
	NodeUtils:adaptiveUpPanel(self._mainPanel,topPanel,0)
	NodeUtils:adaptiveDownPanel(downPanel,nil,10)

	local listView = self._mainPanel:getChildByName("listView")
	NodeUtils:adaptiveListView(listView,downPanel,topPanel,0)
end

local function sortFunc(a,b)
	return a.order < b.order
end 

function GetLotOfMoneyExchangePanel:updateListView()
	local listView = self._mainPanel:getChildByName("listView")

	local activityInfo = self._activityProxy:getLimitActivityInfoById(self.currentActivityId) --活动信息
	if activityInfo then
		local effectId = activityInfo.effectId
		local activityConfigInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.BullionProportionConfig,"effectID",effectId)
		if activityConfigInfo then
			local getlotOfMoneyInfo = self._activityProxy:getGetLotOfMoneyInfo(self.currentActivityId)
			local listInfo = ConfigDataManager:getInfosFilterByOneKey(ConfigData.BullionExchangeConfig,"exchangeID",activityConfigInfo.exchangeID)

			--整理已经兑换的信息
			local exchangedInfo = {}
			for k,v in pairs(getlotOfMoneyInfo.exchangeInfo) do
				exchangedInfo[v.id] = v
			end 

			for k,v in pairs(listInfo) do
				if exchangedInfo[v.ID] then --当前有已经兑换的数据
					v.exchangedInfo = exchangedInfo[v.ID]
				end 
			end

			table.sort( listInfo, sortFunc )


			self:renderListView(listView, listInfo, self, self.renderTemplate)
		end
	end
end 

function GetLotOfMoneyExchangePanel:renderTemplate(template,data)
	local templateBg = template:getChildByName("templateBg")
	local icon = template:getChildByName("icon")
	local nameLab = template:getChildByName("nameLab")
	local desLab = template:getChildByName("desLab")
	local lab_1 = template:getChildByName("lab_1")
	local num = template:getChildByName("num")
	local allNum = template:getChildByName("allNum")
	local lab_2 = template:getChildByName("lab_2")
	local exchangeBtn = template:getChildByName("exchangeBtn")
	local materialImg = template:getChildByName("materialImg")
	local needValue = template:getChildByName("needValue")

	local reward = StringUtils:jsonDecode(data.reward)
	local consume = StringUtils:jsonDecode(data.consume) --这里策划配置表（其中消耗物品都是固定的）
	local condition = StringUtils:jsonDecode(data.condition) --兑换条件

	local iconData = {
        power = reward[1][1],
        typeid = reward[1][2],
        num = reward[1][3],
    }
    if not icon.itemIcon then
        icon.itemIcon = UIIcon.new(icon, iconData, true,self)
    else
        icon.itemIcon:updateData(iconData )
    end

    nameLab:setString(icon.itemIcon:getName())
    local color = ColorUtils:getColorByQuality(icon.itemIcon:getQuality())
    nameLab:setColor(color)
    local exchangedTimes--已经兑换的次数
    if data.exchangedInfo then
    	exchangedTimes = data.exchangedInfo.times
    else
    	exchangedTimes = 0
    end
    num:setString(exchangedTimes) --已经兑换的次数

    allNum:setString("/"..data.dayMax)
    desLab:setString(data.describe)

    lab_1:setPositionX(nameLab:getPositionX() + nameLab:getContentSize().width)
    num:setPositionX(lab_1:getPositionX() + lab_1:getContentSize().width)
    allNum:setPositionX(num:getPositionX() + num:getContentSize().width)
    lab_2:setPositionX(allNum:getPositionX() + allNum:getContentSize().width)

    local canDo = false
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerValue = roleProxy:getRoleAttrValue(condition[1])
    if playerValue >= condition[2] and playerValue  <= condition[3] then
    	canDo = true
    end

    local function exchangeBtnTap()
    	--次数满足
    	if exchangedTimes < data.dayMax then
    		--条件满足
    		if not canDo then
    			local resConfig = ConfigDataManager:getConfigById(ConfigData.ResourceConfig ,condition[1])
				local name = resConfig.name
		    	self:showSysMessage(string.format(self:getTextWord(560302),name, name,condition[2]))
    			return 
    		end

	    	local params = {}
			params.activityId = self.currentActivityId
			params.exchangeId = data.ID
			self._activityProxy:onTriggerNet600001Req(params)
		else
			self:showSysMessage(TextWords:getTextWord(560300))
		end 
    end 

    self:addTouchEventListener(exchangeBtn,exchangeBtnTap)
    NodeUtils:setEnable(exchangeBtn,true)

    if not canDo then
		local resConfig = ConfigDataManager:getConfigById(ConfigData.ResourceConfig ,condition[1])
		local name = resConfig.name
    	desLab:setString(string.format(self:getTextWord(560301),name,condition[2]))
    	desLab:setColor(ColorUtils.wordRedColor)
    else
    	desLab:setColor(ColorUtils.wordYellowColor03)
    end

    --材料数量不足  显示灰色不可点击
    local itemProxy = self:getProxy(GameProxys.Item)
    local itemNum = itemProxy:getItemNumByType(consume[1][2])
    needValue:setString(consume[1][3])
    
    if itemNum < consume[1][3] then
    	NodeUtils:setEnable(exchangeBtn,false)
    end
end

--停留在界面上时数据更新
function GetLotOfMoneyExchangePanel:activityInfoUpdate()
	self:updateListView()
end 