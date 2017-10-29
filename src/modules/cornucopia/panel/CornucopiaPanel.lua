-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CornucopiaPanel = class("CornucopiaPanel", BasicPanel)
CornucopiaPanel.NAME = "CornucopiaPanel"

function CornucopiaPanel:ctor(view, panelName)
    CornucopiaPanel.super.ctor(self, view, panelName,true)
    self:setUseNewPanelBg(true)
    self.activityId = nil --当前所在的聚宝盆面板对应的活动id

    self.chargeList = nil
    self.rewardList = nil
    self.rewardListTab = nil
    self.cloneCutLineList = {}
    self.maxValue = nil
    self.isInAction = nil

    self.ccbName = {
    	[1] = "rgb-jbp-daijihuo",
    	[2] = "rgb-jbp-daijiqian", --中心圈
    	[3] = "rgb-jbp-huo", --下落元宝（抽奖动作）
    	[4] = "rgb-jbp-qian", --聚宝盆聚字亮（抽奖动作）
	}

	self.ccbEffect = {}

end

function CornucopiaPanel:finalize()
	for k,v in pairs(self.cloneCutLineList) do
		v:removeFromParent()
	end
	self.cloneCutLineList = {}

	for k,v in pairs(self.rewardListTab) do
		v:stopAllActions()
		v.icon:finalize()
		v.icon = nil
		v:removeFromParent(true)
	end
	self.rewardListTab = {}
	self.isInAction = nil

    CornucopiaPanel.super.finalize(self)
end

function CornucopiaPanel:initPanel()
	CornucopiaPanel.super.initPanel(self)

	self:setTitle(true, "cornucopia", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)

    self._mainPanel = self:getChildByName("mainPanel")
    self._activityProxy = self:getProxy(GameProxys.Activity)

    local helpBtn = self._mainPanel:getChildByName("helpBtn")
    helpBtn:setVisible(false)
    -- local lotteryBtn = self._mainPanel:getChildByName("lotteryBtn")
    -- self:addTouchEventListener(lotteryBtn,self.runCCBLotteryAction)
end

function CornucopiaPanel:registerEvents()
	CornucopiaPanel.super.registerEvents(self)
end

function CornucopiaPanel:onClosePanelHandler()
    self:dispatchEvent(CornucopiaEvent.HIDE_SELF_EVENT)
end

function CornucopiaPanel:doLayout()
	local topPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveUpPanel(self._mainPanel, topPanel,0)
end

function CornucopiaPanel:onShowHandler()
	self:update()
	self:updatePanel()
	self:runCCBAction()
end

function CornucopiaPanel:setCurrentActivityId(activityId)
	self.activityId = activityId
	self:update()
	self:initData()
	self:updatePanel()
end

function CornucopiaPanel:runCCBAction()
	local juBaoPen = self._mainPanel:getChildByName("juBaoPen")
	local actionNode = self._mainPanel:getChildByName("actionNode")
	for i = 1,2 do
		if not self.ccbEffect[i] then 
			local positionX,positionY = juBaoPen:getContentSize().width/2,juBaoPen:getContentSize().height/2
			if i == 1 then --后
				positionX = 0
				positionY = 0
				self.ccbEffect[i] = self:createUICCBLayer(self.ccbName[i],actionNode)
			elseif i == 2 then --前
				self.ccbEffect[i] = self:createUICCBLayer(self.ccbName[i],juBaoPen)
			end 	
			self.ccbEffect[i]:setPosition(positionX,positionY)
		end 
	end

	--进入界面时清除抽奖动画
	for i = 3,4 do
		if self.ccbEffect[i] then
			self.ccbEffect[i]:finalize()
			self.ccbEffect[i] = nil
			self.isInAction = false
		end 
	end 
end

--播放抽奖动画
function CornucopiaPanel:runCCBLotteryAction(callBack)
	local juBaoPen = self._mainPanel:getChildByName("juBaoPen")
	local actionNode = self._mainPanel:getChildByName("actionNode")
	local positionX,positionY = juBaoPen:getContentSize().width/2,juBaoPen:getContentSize().height/2
	self.ccbEffect[3] = self:createUICCBLayer(self.ccbName[3],actionNode,nil,callBack)
	self.ccbEffect[3]:setPosition(0,0)

	self.ccbEffect[4] = self:createUICCBLayer(self.ccbName[4],juBaoPen)
	self.ccbEffect[4]:setPosition(positionX,positionY - 16)
end 

local function sortFunc(a,b)
	return a.sort < b.sort
end 

--初始化活动数据
function CornucopiaPanel:initData()
	local activityInfo = self._activityProxy:getLimitActivityInfoById(self.activityId) --获取服务端下推的活动信息
	if activityInfo then
		local effectId = activityInfo.effectId
		local CornucopiaInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.CornucopiaConfig,"effectID",effectId) --获取活动对应的配置信息

		--所有充值阶段
		self.chargeList = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CornucopiaChargeConfig,"chargeID",CornucopiaInfo.chargeID)
		--所有奖励物品
		self.rewardList = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CornucopiaRewardConfig,"rewardID",CornucopiaInfo.rewardID)

		table.sort( self.chargeList, sortFunc )
	end

	if self.chargeList then
		self:initProgressBar()
		self:updateProgressBar(0)
	end

	if self.rewardList then
		self:initRewardInfo()
	end 
end 

--更新面板里的信息
function CornucopiaPanel:updatePanel()

	local activityDetailInfo = self._activityProxy:getCornucopiaInfoById(self.activityId)
	if activityDetailInfo then 
		local progressBg = self._mainPanel:getChildByName("progressBg")
		local allValueLab = progressBg:getChildByName("allValueLab") --全服充值额度
		local leftTimeLab = self._mainPanel:getChildByName("leftTimeLab")

		local totalCharge = activityDetailInfo.totalCharge --全服当前充值额度
		local leftTimes = activityDetailInfo.times   --剩余抽奖次数

		allValueLab:setString(string.format(TextWords:getTextWord(560310),totalCharge))
		leftTimeLab:setString(leftTimes)

		local function lotteryBtnTap()
			if self.isInAction then
				self:showSysMessage(TextWords:getTextWord(560312))
				return 
			end 
			if leftTimes > 0 then
				--请求抽奖
				self.isInAction = true
				local function endCallBack()
					self.isInAction = false
					local param = {}
					param.activityId = self.activityId
					self._activityProxy:onTriggerNet610000Req(param)
				end 
				self:runCCBLotteryAction(endCallBack)
			else
				--跳转到充值
				ModuleJumpManager:jump(ModuleName.RechargeModule)
			end 
		end 

		local lotteryBtn = self._mainPanel:getChildByName("lotteryBtn")
    	self:addTouchEventListener(lotteryBtn,lotteryBtnTap)

    	self:updateProgressBar(totalCharge)
	end
	-- end 
end 

--初始化进度条
function CornucopiaPanel:initProgressBar()
	local progressBg = self._mainPanel:getChildByName("progressBg")
	local cutLine = progressBg:getChildByName("cutLine")
	cutLine:setVisible(false)

	if not self.cloneCutLineList then
		self.cloneCutLineList = {} 
	end 
	
	for k,v in pairs(self.chargeList) do
		if not self.cloneCutLineList[k] then 
			local cutLineClone = cutLine:clone()
			cutLineClone:setVisible(true)
			cutLineClone:setPositionX(progressBg:getContentSize().width/(#self.chargeList) * k)
			cutLineClone.configInfo = v
			if k == #self.chargeList then
				local cutLine = cutLineClone:getChildByName("cutLine")
				cutLine:setVisible(false)
			end 

			local value1 = cutLineClone:getChildByName("valueLab_1")
			value1:setString(string.format(TextWords:getTextWord(508),v.chargeAmount))
			local value2 = cutLineClone:getChildByName("valueLab_2")
			value2:setString(string.format(TextWords:getTextWord(560311),v.rewardTime))

			progressBg:addChild(cutLineClone)

			self.cloneCutLineList[k] = cutLineClone --记录当前clone的node

			--设定最大充值金额
			if not self.maxValue then
				self.maxValue = v.chargeAmount
			elseif v.chargeAmount > self.maxValue then 
				self.maxValue = v.chargeAmount
			end
		end 
	end 
end

--更新进度条(这里的进度条不是均匀分布)
function CornucopiaPanel:updateProgressBar(currentValue)
	local current = currentValue or 0
	local currentIndex = 0
	for k,v in pairs(self.chargeList) do
		--记录当前到达的节点
		if current >= v.chargeAmount then
			currentIndex = k
		end 
	end

	local percent 

	local arrive = self.cloneCutLineList[currentIndex]
	local nextArrive = self.cloneCutLineList[currentIndex + 1]
	if nextArrive then
		local isArrivePercent = 0
		local needCulculatePercent
		if arrive then
			isArrivePercent = currentIndex/#self.chargeList
			needCulculatePercent = (current - arrive.configInfo.chargeAmount)/(nextArrive.configInfo.chargeAmount - arrive.configInfo.chargeAmount)/#self.chargeList
		else
			needCulculatePercent = current/nextArrive.configInfo.chargeAmount/#self.chargeList
		end
		
		percent = (isArrivePercent + needCulculatePercent) * 100
	else
		percent = 100
	end
	local progressBg = self._mainPanel:getChildByName("progressBg")
	local progressBar = progressBg:getChildByName("ProgressBar")
	progressBar:setPercent(percent)
end

--处理奖励展示
function CornucopiaPanel:initRewardInfo()
	local rewardImg = self._mainPanel:getChildByName("rewardImg")
	local rewardListPanel = rewardImg:getChildByName("rewardListPanel")
	local iconImg = rewardListPanel:getChildByName("iconImg")
	iconImg:setVisible(false)

	local width = rewardListPanel:getContentSize().width
	local offsetX = 140
	if self.rewardList then
		-- --清除之前的动作
		-- if self.rewardListTab then 
		-- 	for k,v in pairs(self.rewardListTab) do
		-- 		v:stopAllActions()
		-- 		v.icon:finalize()
		-- 		v.icon = nil
		-- 		v:removeFromParent(true)
		-- 	end
		-- end 

		-- self.rewardListTab = {}
		if not self.rewardListTab then
			self.rewardListTab = {}
		end 

		for k,v in pairs(self.rewardList) do
			if not self.rewardListTab[v.ID] then 
				local rewardInfo = StringUtils:jsonDecode(v.reward)
				local data = {
					power = rewardInfo[1][1],
					typeid = rewardInfo[1][2],
					num = rewardInfo[1][3],
				}

				local cloneIconImg = iconImg:clone()
				cloneIconImg:setVisible(true)

				if not self.rewardListTab[v.ID] then 
					cloneIconImg.icon = UIIcon.new(cloneIconImg,data, true,self,false,true)
				else
					cloneIconImg.icon:updateData(data)
				end

				self.rewardListTab[v.ID] = cloneIconImg

				rewardListPanel:addChild(self.rewardListTab[v.ID])

				local positionX,positionY = v.ID * offsetX,50

				self.rewardListTab[v.ID]:setPosition(positionX,positionY)

				local offset = 1
				local moveTime = 2
				local move_1 = cc.MoveTo:create(v.ID * moveTime + offset * moveTime , cc.p(-offsetX * offset, 50))
				local function callback_1()
					self.rewardListTab[v.ID]:stopAllActions()
					self.rewardListTab[v.ID]:setPosition((#self.rewardList -1) * offsetX,positionY)
					local move_2 = cc.MoveTo:create((#self.rewardList -1)* moveTime + offset * moveTime,cc.p(-offsetX * offset, 50))
					local function callback_2()
						callback_1()
					end
					local moveEnd_2 = cc.CallFunc:create(callback_2)
					local actionArray_2 = cc.Sequence:create(move_2,moveEnd_2)
					self.rewardListTab[v.ID]:runAction(actionArray_2)
				end 
				local moveEnd_1 = cc.CallFunc:create(callback_1)
				local actionArray_1 = cc.Sequence:create(move_1,moveEnd_1)
				self.rewardListTab[v.ID]:runAction(actionArray_1)
			end 
		end 
	end 
end 

--更新活动面板信息（描述和时间）
function CornucopiaPanel:update(dt)
	local activityTimeLab = self._mainPanel:getChildByName("activityTimeLab") --剩余时间描述
	local contentLab = self._mainPanel:getChildByName("contentLab") --活动描述
    local activityInfo = self._activityProxy:getLimitActivityInfoById(self.activityId)
    if activityInfo then
		local endTime = activityInfo.endTime --活动结束时间
		local startTime = activityInfo.startTime 
		activityTimeLab:setVisible(true)
		contentLab:setVisible(true)
		activityTimeLab:setString(TimeUtils.getLimitActFormatTimeString(startTime,endTime,true))
		contentLab:setString(activityInfo.info)
	else
		activityTimeLab:setVisible(false)
		contentLab:setVisible(false)
	end 
end

--活动数据更新
function CornucopiaPanel:activityInfoUpdate()
	self:updatePanel()
end 