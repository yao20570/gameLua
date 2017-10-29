-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-04-28
--  * @Description: 限时活动_充值返利大放送转盘
--  */
RechargeRebatePanel = class("RechargeRebatePanel", BasicPanel)
RechargeRebatePanel.NAME = "RechargeRebatePanel"

function RechargeRebatePanel:ctor(view, panelName)
    RechargeRebatePanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function RechargeRebatePanel:finalize()

    if self._rewardEffect then
	    self._rewardEffect:finalize()
        self._rewardEffect = nil
    end

    RechargeRebatePanel.super.finalize(self)
end

function RechargeRebatePanel:initPanel()
	RechargeRebatePanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.ACTIVITY)
	self:setTitle(true, "rechargeRebate", true)
	self.proxy = self:getProxy(GameProxys.Activity)
	--开始按钮
	self._startBtn = self:getChildByName("topPanel/mainPanel/startBtn")
	--外盘
	self.circleImg = self:getChildByName("topPanel/mainPanel/turnTableImg")
	--选中标框
	self.pointer = self:getChildByName("topPanel/mainPanel/selectImg")
	--内盘
	self.innerCircle = self:getChildByName("topPanel/mainPanel/innerTurnPanel")
	--累计充值进度条
	self.totalProgressBar = self:getChildByName("topPanel/mainPanel/btnPanel/totalProgressBar")
	--累计充值进度条上面的文本(累计充值:20.0k/30.0k)
	self.progressBarLab = self:getChildByName("topPanel/mainPanel/btnPanel/progressBarLab")
	--返还元宝数
	self.backNumLab = self:getChildByName("topPanel/mainPanel/btnPanel/receiveBtnPanel/numLab")
	--剩余次数
	self.remainTimeLab = self:getChildByName("topPanel/mainPanel/remainTimeLab")
	--今日总次数
	-- self.allTimeLab = self:getChildByName("topPanel/mainPanel/AllTimeLab")
	--活动描述
	local descLab = self:getChildByName("topPanel/headPanel/descLab")
	descLab:setString(self:getTextWord(393002))
    descLab:setColor(cc.c3b(244,244,244))
	--领取按钮上的小红点
	self.redPointImg = self:getChildByName("topPanel/mainPanel/btnPanel/receiveBtnPanel/tipImg")

	--外盘位置对应角度数组
	self.staticAngleAry = {360,324,288,252,216,180,144,108,72,36}
	--内盘位置对应角度数组
	self.staticInnerAngleAry = {-360,-36,-72,-108,-144,-180,-216,-252,-288,-324}
    --宏定义内外盘加速转动的时间（内外盘同时停）
	self.turnTime = 5
end

function RechargeRebatePanel:registerEvents()
	RechargeRebatePanel.super.registerEvents(self)
	local rechargeBtn = self:getChildByName("topPanel/mainPanel/btnPanel/rechargeBtnPanel/btn")
	self:addTouchEventListener(rechargeBtn, self.onRechargeBtnHandler)
	local receiveBtn = self:getChildByName("topPanel/mainPanel/btnPanel/receiveBtnPanel/btn")
	self:addTouchEventListener(receiveBtn, self.onReceiveBtnHandler)
	local startBtn = self:getChildByName("topPanel/mainPanel/startBtn")
	self:addTouchEventListener(startBtn, self.onStartBtnHandler,nil,nil,500)
end
function RechargeRebatePanel:onShowHandler()
    self:updateRechargeRebateView()
    
	self:rotatePointer(1)
	
end
function RechargeRebatePanel:updateRechargeRebateView()
	self.canTurn = true
	self.myData = self.proxy:getCurActivityData()
	local controlConf = ConfigDataManager:getInfoFindByOneKey(ConfigData.RechargeRebateConfig, "effectID", self.myData.effectId)
	local conditionConf = ConfigDataManager:getInfosFilterByOneKey(ConfigData.RechargeConditionConfig, "conditionID", controlConf.conditionID)
	local scaleConf = ConfigDataManager:getInfosFilterByOneKey(ConfigData.RechargeScaleConfig, "rewardID", controlConf.rewardID)

	for i=1,10 do
		local perLab = self.circleImg:getChildByName("perLab" .. i)
		perLab:setString(string.format(self:getTextWord(393000), scaleConf[i].reward))
        local targetLab = self.innerCircle:getChildByName("targetLab" .. i)
		targetLab:setString(StringUtils:formatNumberByK3(conditionConf[i].conditionTime))
	end
	local rechargeRebateInfo = self.proxy:getRechargeRebateInfoById(self.myData.activityId)
	--活动时间显示
	local timeDescLab = self:getChildByName("topPanel/headPanel/timeDescLab")
	timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
	--进度条
	local perNum = rechargeRebateInfo.currentGold / rechargeRebateInfo.condition * 100 
	perNum = perNum > 100 and 100 or perNum
	self.totalProgressBar:setPercent(perNum)

	--累计充值进度条上面的文本(累计充值:20.0k/30.0k)
	self.progressBarLab:setString(string.format(self:getTextWord(393001), rechargeRebateInfo.currentGold, rechargeRebateInfo.condition))
	self.backNumLab:setString(rechargeRebateInfo.condition * rechargeRebateInfo.rebate / 100)

	self.redPointImg:setVisible(perNum == 100)
	--剩余次数
	self.remainTimeLab:setString(controlConf.freeTime - rechargeRebateInfo.freeTime)
	local color = controlConf.freeTime - rechargeRebateInfo.freeTime > 0 and ColorUtils.commonColor.c3bGreen or ColorUtils.commonColor.c3bRed
	self.remainTimeLab:setColor(color)
	--今日总次数
	-- self.allTimeLab:setString("/" .. controlConf.freeTime)

	--玩家无目标充值条件，此时两个盘转动
	if rechargeRebateInfo.condition == 0 then
		self.circleImg:stopAllActions()
		self.circleImg:setRotation(0)
		local action = cc.Sequence:create(cc.RotateBy:create(0.1, 1) ,cc.CallFunc:create(function()
			self:rotateBg()
		end))
		self.circleImg:runAction(action)

		self.innerCircle:stopAllActions()
		self.innerCircle:setRotation(0)
		local innerAction = cc.Sequence:create(cc.RotateBy:create(0.1, -1) ,cc.CallFunc:create(function()
			self:rotateBgInner()
		end))
		self.innerCircle:runAction(innerAction)
	else
		--有目标条件，内外盘位置固定
		--内圈角度根据目标
		local innerCircleAngle = self:getInnerCircleAngleByCondition(rechargeRebateInfo.condition)
		--外圈角度根据返利比例
		local circleAngle = self:getCircleAngleByRebate(rechargeRebateInfo.rebate)

		self.innerCircle:stopAllActions()
		self.innerCircle:setRotation(innerCircleAngle)
		self.circleImg:stopAllActions()
		self.circleImg:setRotation(circleAngle)
	end

	--[[
	--确认内盘的角度（根据最后一次确定的兵种，若无，禁止锁定内盘）
	-- logger:info("lionTurnInfo.lastSoldierType--------------------")
	-- logger:info(lionTurnInfo.lastSoldierType)
	self.lastSoldierTypeId = lionTurnInfo.lastSoldierType
	if self.lastSoldierTypeId == 0 then
		--活动刚开启第一次进入，不存在最后一次兵种id
		self.canLock = false
	else
		self.canLock = true
		local innerAngle = self:getInnerAngleByPos(self.soldierAry[self.lastSoldierTypeId])
		self.innerCircle:setRotation(innerAngle)

	end
	]]
end
--230050Resp转盘成功返回
function RechargeRebatePanel:afterTurn(rechargeInfo)
	--计算准确角度
	local circleAngle = self:getCircleAngleByRebate(rechargeInfo.rebate)
	local innerCircleAngle = self:getInnerCircleAngleByCondition(rechargeInfo.condition)
	self.exactAngle = circleAngle
	self.exactInnerAngle = innerCircleAngle
	self.afterStartTurnTag = true
	self.afterStartInnerTurnTag = true


	self.circleImg:stopAllActions()
	self.innerCircle:stopAllActions()
    self:rotateBg()
    self:rotateBgInner()
end
function RechargeRebatePanel:after230050(rs)
	if rs < 0 then
		self.canTurn = true
	end
end
function RechargeRebatePanel:rotateBg()
	if self.afterStartTurnTag then

		self.afterStartTurnTag = false


		--外圈
		local curRotation = self.circleImg:getRotation()
		if curRotation < 0 then
			curRotation = curRotation + 360
		end
		local rotateNum = curRotation%360
		local needAngle
		if rotateNum >= self.exactAngle then
			needAngle = 360 - rotateNum + self.exactAngle
		else
			needAngle = self.exactAngle - rotateNum
		end
		needAngle = needAngle + 1440

		local effectfunc = cc.CallFunc:create(function()
			--self:rotatePointer(0.3)
			--if self.pointerEffect == nil then
			--	self.pointerEffect = self:createUICCBLayer("rpg-chongzhifanli", self.pointer, nil, nil, false)
			--    local size = self.pointer:getContentSize()
			--    self.pointerEffect:setPosition(0,130)
			--    self.pointerEffect:setLocalZOrder(10)
			--end
			-- if self.circleEffect == nil then
			-- 	self.circleEffect = self:createUICCBLayer("rgb-tjxs-quan", self.circleImg, nil, nil, false)
			--     local size = self.circleImg:getContentSize()
			--     self.circleEffect:setPosition(0,0)
			--     self.circleEffect:setLocalZOrder(10)
			-- end
			local effect = self:createUICCBLayer("rpg-chongzhifanli", self._startBtn, nil, nil, false)
			local size = self._startBtn:getContentSize()
			effect:setPosition(size.width * 0.5, size.height * 0.5)
			effect:setLocalZOrder(10)
	
		end)
		local act = cc.EaseSineInOut:create(cc.RotateBy:create(self.turnTime, needAngle))
		-- local act = cc.EaseSineInOut:create(cc.RotateBy:create(needAngle/self.speed, needAngle))
		local rotate = cc.Sequence:create(effectfunc,act, cc.CallFunc:create(function()
				-- self:showReward()			
				-- self.rotated = self.circleImg:getRotation()%360
				self.finish = true
				-- logger:info("finish!!")
				self.circleImgRotating = false
				-- self:rotatePointer(1)
				-- self:rotateBg()
				if self.pointerEffect ~= nil then
					self.pointerEffect:finalize()
					self.pointerEffect = nil
				end
				-- if self.circleEffect ~= nil then
				-- 	self.circleEffect:finalize()
				-- 	self.circleEffect = nil
				-- end
				-- self.pointer:setRotation(0)
				-- self.pointer:stopAllActions()

				local affect = self:createUICCBLayer("rpg-cjfl-guang", self.pointer, nil, nil, true)
			    local size = self.pointer:getContentSize()
			    affect:setPosition(0,156)
			    affect:setLocalZOrder(10)

			    --进度条刷新特效
				local tixingAffect = self:createUICCBLayer("rgb-czfl-tixing", self.totalProgressBar, nil, nil, true)
			    tixingAffect:setPosition(190,5)
			    tixingAffect:setLocalZOrder(10)
			    --金币返还刷新特效
				local tixingAffect2 = self:createUICCBLayer("rgb-czfl-tixing2", self.backNumLab, nil, nil, true)
			    tixingAffect2:setPosition(-40,15)
			    tixingAffect2:setLocalZOrder(10)
                
                self:playRewardAction()

			    --标记
			    self.canTurn = true
                
                TextureManager:updateButtonNormal(self._startBtn, "images/rechargeRebate/startBtn_selected.png")
                self:updateRechargeRebateView()
		end),cc.DelayTime:create(0.5),cc.CallFunc:create(function ( )
			-- self:showReward()
            --self:playRewardAction()
		end))
		self.circleImgRotating = true
		self.circleImg:runAction(rotate)
		-- self:rotatePointer(0.4)

		return

	end

	local action = cc.Sequence:create(cc.RotateBy:create(0.1, 1) ,cc.CallFunc:create(function()
		self:rotateBg()
	end))
	self.circleImg:runAction(action)
	-- self.innerCircle:runAction(cc.RotateBy:create(0.1, -2))
end
function RechargeRebatePanel:rotateBgInner()
	if self.afterStartInnerTurnTag then

		self.afterStartInnerTurnTag = false

		--内圈
		local curRotation = self.innerCircle:getRotation()
		if curRotation > 0 then
			curRotation = curRotation - 360
		end
		local rotateInnerNum = curRotation%-360
		-- logger:info("11111111·····rotateInnerNum")
		-- logger:info(rotateInnerNum)
		-- logger:info("22222222·····self.exactInnerAngle")
		-- logger:info(self.exactInnerAngle)
		local needInnerAngle
		if rotateInnerNum >= self.exactInnerAngle then
			needInnerAngle = -360 + self.exactInnerAngle - rotateInnerNum
		else
			needInnerAngle = self.exactInnerAngle - rotateInnerNum
		end
		-- logger:info("needInnerAngle")
		-- logger:info(needInnerAngle)
		needInnerAngle = needInnerAngle - 1440

		local actInner = cc.EaseSineInOut:create(cc.RotateBy:create(self.turnTime, needInnerAngle))
		-- local actInner = cc.EaseSineInOut:create(cc.RotateBy:create(math.abs(needInnerAngle)/self.speed, needInnerAngle))
		local rotateInner = cc.Sequence:create(actInner, cc.CallFunc:create(function()
				-- self:showReward()			
				-- self.rotated = self.circleImg:getRotation()%360
				-- self.finish = true
				-- self.afterStartInnerTurnTag = false
				-- self:rotatePointer(1)
				-- self:rotateBg()
				-- logger:info("after rotateInner ")
				-- self:rotateInnerCircle(0.8)
		end))
		self.innerCircle:stopAllActions()
		self.innerCircle:runAction(rotateInner)
	    return
		


	end

	local innerAction = cc.Sequence:create(cc.RotateBy:create(0.1, -1) ,cc.CallFunc:create(function()
		self:rotateBgInner()
	end))
	self.innerCircle:runAction(innerAction)
	-- self.innerCircle:runAction(cc.RotateBy:create(0.1, -2))
end

function RechargeRebatePanel:doLayout()
	--local bgImg = self:getChildByName("topPanel/mainPanel/bigBgImg")
	--TextureManager:updateImageViewFile(bgImg,"bg/rechargeRebate/rechargeRebateBg.pvr.ccz")
	local topPanel = self:getChildByName("topPanel")
	NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, 0, GlobalConfig.topHeight)
end


function RechargeRebatePanel:onClosePanelHandler()
	self:dispatchEvent(RechargeRebateEvent.HIDE_SELF_EVENT, {})
end
--根据当前充值目标条件获取内圈角度
function RechargeRebatePanel:getInnerCircleAngleByCondition(condition)

	local controlConf = ConfigDataManager:getInfoFindByOneKey(ConfigData.RechargeRebateConfig, "effectID", self.myData.effectId)
	local conditionConf = ConfigDataManager:getInfosFilterByOneKey(ConfigData.RechargeConditionConfig, "conditionID", controlConf.conditionID)
	local pos
	for i=1,10 do
		if conditionConf[i].conditionTime == condition then
			pos = i
			break
		end
	end
	return self.staticInnerAngleAry[pos]
end

--根据当前充值返利比例获取外圈角度
function RechargeRebatePanel:getCircleAngleByRebate(rebate)
	local controlConf = ConfigDataManager:getInfoFindByOneKey(ConfigData.RechargeRebateConfig, "effectID", self.myData.effectId)
	local scaleConf = ConfigDataManager:getInfosFilterByOneKey(ConfigData.RechargeScaleConfig, "rewardID", controlConf.rewardID)
	local pos
	for i=1,10 do
		if scaleConf[i].reward == rebate then
			pos = i
			break
		end
	end
	return self.staticAngleAry[pos]
end

function RechargeRebatePanel:onRechargeBtnHandler(sender)
	--打开充值界面
	ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
end
function RechargeRebatePanel:onReceiveBtnHandler(sender)
	local sendData = {}
	sendData.activityId = self.myData.activityId
	self.proxy:onTriggerNet230051Req(sendData)
end
function RechargeRebatePanel:onStartBtnHandler(sender)
	if self.canTurn == false then
		return
	end
	local function sendProto()
		self.canTurn = false
		local sendData = {}
		sendData.activityId = self.myData.activityId
		self.proxy:onTriggerNet230050Req(sendData)
        if self._rewardEffect then
            self._rewardEffect:setVisible(false)
        end
        TextureManager:updateButtonNormal(self._startBtn, "images/rechargeRebate/startBtn.png")
	end

	local rechargeRebateInfo = self.proxy:getRechargeRebateInfoById(self.myData.activityId)
	--玩家无目标充值条件，直接转
	if rechargeRebateInfo.condition == 0 then
		sendProto()
	else
		--有目标条件，二次确认弹窗
		self:showMessageBox(self:getTextWord(393003), sendProto)
	end

end

function RechargeRebatePanel:rotatePointer(time)
	self.pointer:stopAllActions()
	self.pointer:setRotation(0)
	local action1 = cc.RotateBy:create(time, 3)
	local action2 = cc.RotateBy:create(time, -3)
	self.pointer:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
end


function RechargeRebatePanel:playRewardAction()
	local effectPanel = self:getChildByName("topPanel/mainPanel/effectPanel")
	local rewardEffect = self:createUICCBLayer("rpg-cjfl-g", effectPanel, nil, nil, true)
	--rewardEffect:setPosition(-40,15)
    rewardEffect:setLocalZOrder(10)
    
    effectPanel = self:getChildByName("topPanel/mainPanel/effectPanel_0")
    if self._rewardEffect == nil then
	    self._rewardEffect = self:createUICCBLayer("rpg-cjfl-guang", effectPanel)
	    --rewardEffect:setPosition(-40,15)
        rewardEffect:setLocalZOrder(10)
    else
        self._rewardEffect:setVisible(true)
    end
end