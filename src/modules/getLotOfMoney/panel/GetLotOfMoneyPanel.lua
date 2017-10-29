-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
GetLotOfMoneyPanel = class("GetLotOfMoneyPanel", BasicPanel)
GetLotOfMoneyPanel.NAME = "GetLotOfMoneyPanel"

function GetLotOfMoneyPanel:ctor(view, panelName)
    GetLotOfMoneyPanel.super.ctor(self, view, panelName,true)
    self:setUseNewPanelBg(true)

    self.currentIndex = nil

    self.currentActivityId = nil

    self.panelTab = {}
end

function GetLotOfMoneyPanel:finalize()
    GetLotOfMoneyPanel.super.finalize(self)
end

function GetLotOfMoneyPanel:initPanel()
	GetLotOfMoneyPanel.super.initPanel(self)

	self:setTitle(true, "caiyuanguangjin", true)
    self:setBgType(ModulePanelBgType.GETLOTOFMONEY)

    self._mainPanel = self:getChildByName("mainPanel")
    self._topPanel = self._mainPanel:getChildByName("topPanel")

    self._activityProxy = self:getProxy(GameProxys.Activity)

    for i = 1,2 do
    	local tab = self._topPanel:getChildByName("tab_".. i)
    	tab.index = i
    	self:addTouchEventListener(tab,self.onTapTabbar)
    end

    self.panelTab = {
    	[1] = self:getPanel(GetLotOfMoneyLotteryPanel.NAME), --博彩
    	[2] = self:getPanel(GetLotOfMoneyExchangePanel.NAME), --兑换
	}

	local function chargeBtnTap()
		ModuleJumpManager:jump( ModuleName.RechargeModule)
	end 

	local chargeBtn = self._topPanel:getChildByName("goToCharge") --去充值按钮
	self:addTouchEventListener(chargeBtn,chargeBtnTap)
end

function GetLotOfMoneyPanel:registerEvents()
	GetLotOfMoneyPanel.super.registerEvents(self)
end

function GetLotOfMoneyPanel:onClosePanelHandler()
    self:dispatchEvent(GetLotOfMoneyEvent.HIDE_SELF_EVENT)
end

function GetLotOfMoneyPanel:doLayout()
	local topPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveUpPanel(self._mainPanel, topPanel, GlobalConfig.topAdaptive + 20)
end

function GetLotOfMoneyPanel:onShowHandler()
	self:judgeTabbarState()
	self:update()
	self:updateMoney()
end

--点击tabbar  
function GetLotOfMoneyPanel:onTapTabbar(sender)
	if sender.index == self.currentIndex then --当前选择的标签和上一个标签相同
		return
	end 

	self.currentIndex = sender.index
	self:setTabbarState(self.currentIndex)
end 

function GetLotOfMoneyPanel:setTabbarState(currentIndex)
	for i=1,2 do
		local tab = self._topPanel:getChildByName("tab_".. i)
		local tabUrl
		local textColor
		if currentIndex == i then
			tabUrl = "images/getLotOfMoney/selected.png"
			textColor = ColorUtils.wordNameColor

			self.panelTab[i]:show()
		else
			tabUrl = "images/getLotOfMoney/normal.png"
			textColor = ColorUtils.wordYellowColor03
			self.panelTab[i]:hide()
		end
		TextureManager:updateImageView(tab,tabUrl)
		local text = tab:getChildByName("tabText")
		text:setColor(textColor)
	end 
end 

--进入上次的界面
function GetLotOfMoneyPanel:judgeTabbarState()
	if not self.currentIndex then
		self.currentIndex = 1
	end

	self:setTabbarState(self.currentIndex)
end

--更新当前拥有的金锭数量
function GetLotOfMoneyPanel:updateMoney()
	local haveMoneyValue = self._topPanel:getChildByName("haveMoneyValue")
	local itemProxy = self:getProxy(GameProxys.Item)
	local itemNum = itemProxy:getItemNumByType(4703)
	haveMoneyValue:setString(StringUtils:formatNumberByK4(itemNum))

	self:activityInfoUpdate()

	local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setGetLotOfMoneyRed()
end

function GetLotOfMoneyPanel:setCurrentActivityId(activityId)
	self.currentActivityId = activityId
end

function GetLotOfMoneyPanel:getCurrentActivityId()
	return self.currentActivityId
end

--更新倒计时
function GetLotOfMoneyPanel:update(dt)
	local activityTimeLab = self._topPanel:getChildByName("activityTimeLab") --剩余时间描述
	local desLab_1 = self._topPanel:getChildByName("desLab_1")
	local contentLab = self._topPanel:getChildByName("contentLab") --活动描述
    contentLab:setColor(cc.c3b(244,244,244))
    local activityInfo = self._activityProxy:getLimitActivityInfoById(self.currentActivityId)
    if activityInfo then
		local endTime = activityInfo.endTime --活动结束时间
		-- local serverTime = os.time()
		-- local leftTime = endTime - serverTime
		local startTime = activityInfo.startTime 
		activityTimeLab:setVisible(false)
		contentLab:setVisible(true)
		desLab_1:setVisible(true)
		desLab_1:setString(TimeUtils.getLimitActFormatTimeString(startTime,endTime,true))
		-- leftTimeLab:setString(TextWords:getTextWord(250005) .. ":" .. TimeUtils:getStandardFormatTimeString(leftTime) .. TextWords:getTextWord(249993))
		contentLab:setString(activityInfo.info)
	else
		desLab_1:setVisible(false)
		activityTimeLab:setVisible(false)
		contentLab:setVisible(false)
	end 
end

--活动数据更新
function GetLotOfMoneyPanel:activityInfoUpdate()
	local currentPanel = self.panelTab[self.currentIndex] --当前所在面板
	currentPanel:activityInfoUpdate()
end 