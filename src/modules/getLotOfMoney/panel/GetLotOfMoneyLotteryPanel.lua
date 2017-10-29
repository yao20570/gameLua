-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
GetLotOfMoneyLotteryPanel = class("GetLotOfMoneyLotteryPanel", BasicPanel)
GetLotOfMoneyLotteryPanel.NAME = "GetLotOfMoneyLotteryPanel"

function GetLotOfMoneyLotteryPanel:ctor(view, panelName)
    GetLotOfMoneyLotteryPanel.super.ctor(self, view, panelName)
    self.currentActivityId = nil
end

function GetLotOfMoneyLotteryPanel:finalize()
    GetLotOfMoneyLotteryPanel.super.finalize(self)
end

function GetLotOfMoneyLotteryPanel:initPanel()
	GetLotOfMoneyLotteryPanel.super.initPanel(self)

	self._mainPanel = self:getChildByName("mainPanel")
	self._activityProxy = self:getProxy(GameProxys.Activity)
end

function GetLotOfMoneyLotteryPanel:registerEvents()
	GetLotOfMoneyLotteryPanel.super.registerEvents(self)
end

function GetLotOfMoneyLotteryPanel:onShowHandler()
	print("onShowHandler  GetLotOfMoneyLotteryPanel ")
	local panel = self:getPanel(GetLotOfMoneyPanel.NAME)
	self.currentActivityId = panel:getCurrentActivityId()
	self:updateListView()
end

function GetLotOfMoneyLotteryPanel:doLayout()
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

function GetLotOfMoneyLotteryPanel:updateListView()
	local listView = self._mainPanel:getChildByName("listView")

	local activityInfo = self._activityProxy:getLimitActivityInfoById(self.currentActivityId) --活动信息
	if activityInfo then
		local effectId = activityInfo.effectId
		local activityConfigInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.BullionProportionConfig,"effectID",effectId)
		if activityConfigInfo then
			local getlotOfMoneyInfo = self._activityProxy:getGetLotOfMoneyInfo(self.currentActivityId)
			local listInfo = ConfigDataManager:getInfosFilterByOneKey(ConfigData.LuckyLotteryDrawConfig,"lotteryID",activityConfigInfo.lotteryID)

			--整理已经搏一搏过的信息
			local lotteryedInfo = {}
			for k,v in pairs(getlotOfMoneyInfo.lotteryInfo) do
				lotteryedInfo[v.id] = v
			end

			for k,v in pairs(listInfo) do
				if lotteryedInfo[v.ID] then --当前有已经兑换的数据
					v.lotteryedInfo = lotteryedInfo[v.ID]
				end 
			end 
			table.sort( listInfo, sortFunc )
			self:renderListView(listView, listInfo, self, self.renderTemplate)
		end
	end  
end 

function GetLotOfMoneyLotteryPanel:renderTemplate(template,data)
	local tryBtn = template:getChildByName("tryBtn") --搏一搏按钮
	local needValueLab = template:getChildByName("needValueLab")
	local moneyImage = template:getChildByName("moneyImage")

	local preview = StringUtils:jsonDecode(data.preview)
	local lotteryPrice = StringUtils:jsonDecode(data.lotteryPrice)
	needValueLab:setString(lotteryPrice[2]) --需要的数量

	local tryNum --已经搏一搏的次数
	if data.lotteryedInfo then
		tryNum = data.lotteryedInfo.times
	else
		tryNum = 0
	end

	local moneyUrl
	if data.level == 1 then
		moneyUrl = "images/getLotOfMoney/copper.png"
	elseif data.level == 2 then
		moneyUrl = "images/getLotOfMoney/silver.png"
	elseif data.level == 3 then
		moneyUrl = "images/getLotOfMoney/gold.png"
	end
	TextureManager:updateImageView(moneyImage,moneyUrl)

	for i = 1,6 do
		local icon = template:getChildByName("icon_"..i)
		if i <= #preview then
			icon:setVisible(true)
			local iconData = {
		        power = preview[i][1],
		        typeid = preview[i][2],
		        num = preview[i][3],
		    }
		    if not icon.itemIcon then
		        icon.itemIcon = UIIcon.new(icon, iconData, true,self)
		    else
		        icon.itemIcon:updateData( iconData )
		    end
		else
			icon:setVisible(false)
		end 
	end

	local function tryBtnTap()
		if tryNum >= data.dayTimes then
			self:showSysMessage(self:getTextWord(560304))
			return
		end 

		local itemProxy = self:getProxy(GameProxys.Item)
	    local itemNum = itemProxy:getItemNumByType(4703) --金锭数量
	   	if itemNum < lotteryPrice[2] then
	   		self:showSysMessage(self:getTextWord(560303))
	   		return 
	   	end

		local params = {}
		params.activityId = self.currentActivityId
		params.lotteryId = data.ID
		self._activityProxy:onTriggerNet600000Req(params)
	end
	self:addTouchEventListener(tryBtn,tryBtnTap)
end

--停留在界面上时数据更新
function GetLotOfMoneyLotteryPanel:activityInfoUpdate()
	self:updateListView()
end 