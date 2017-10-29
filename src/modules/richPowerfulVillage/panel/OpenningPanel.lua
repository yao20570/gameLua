-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
OpenningPanel = class("OpenningPanel", BasicPanel)
OpenningPanel.NAME = "OpenningPanel"

function OpenningPanel:ctor(view, panelName)
    OpenningPanel.super.ctor(self, view, panelName)
    self.activityId = nil
    self.leftTimes = nil
    self.activityInfo = nil
    self.haveItemNum = nil
    self.materialName = nil
    self.changeLimitTimes = nil
    self.gold = nil --拥有元宝数量
    self.needExpand = nil --单价
    self.isStart = nil --是否开局
    self.sum = nil --统计骰子为6的个数
    self.isInAction = nil --是否正在动画
    self.reward = 0 --奖励彩豆的数量

    --记录骰子状态
    self.status = {
    	[1] = nil,
    	[2] = nil,
    	[3] = nil,
    	[4] = nil,
    	[5] = nil,
    	[6] = nil,
	}

	self.ineffect = {
		[1] = nil,
    	[2] = nil,
    	[3] = nil,
    	[4] = nil,
    	[5] = nil,
    	[6] = nil,
	}

	self.zhongEffect = nil	
	self.zhongdiEffect = nil
	self.zhongtingEffect = nil

	self.outeffect = {
		[1] = nil,
    	[2] = nil,
    	[3] = nil,
    	[4] = nil,
    	[5] = nil,
    	[6] = nil,
	}

	self.liuEffect = {
		[1] = nil,
    	[2] = nil,
    	[3] = nil,
    	[4] = nil,
    	[5] = nil,
    	[6] = nil,
	}

	self.liubaoEffect = {
		[1] = nil,
    	[2] = nil,
    	[3] = nil,
    	[4] = nil,
    	[5] = nil,
    	[6] = nil,
	}

	self.caiDou = nil
end

function OpenningPanel:finalize()
	self.leftTimes = nil
	self.activityId = nil
	self.activityInfo = nil
	self.needExpand = nil
	self.haveItemNum = nil
	self.materialName = nil
	self.changeLimitTimes = nil
	self.gold = nil
	self.isStart = nil
	self.sum = nil
	self.isInAction = nil
    self.reward = 0
	self.status = {
    	[1] = nil,
    	[2] = nil,
    	[3] = nil,
    	[4] = nil,
    	[5] = nil,
    	[6] = nil,
	}

	if self.zhongEffect then
		self.zhongEffect:removeFromParent()
		self.zhongEffect = nil
	end
	if self.zhongdiEffect then
		self.zhongdiEffect:removeFromParent()
		self.zhongdiEffect = nil
	end

	if self.zhongtingEffect then
		self.zhongtingEffect:removeFromParent()
		self.zhongtingEffect = nil
	end
	
	for k,v in pairs(self.ineffect) do
		if v then
			v:removeFromParent() 
			self.ineffect[k] = nil
		end 
	end 

	for k,v in pairs(self.outeffect) do
		if v then
			v:removeFromParent()
			self.outeffect[k] = nil
		end 
	end

	for k,v in pairs(self.liuEffect) do
		if v then
			v:removeFromParent()
			self.liuEffect[k] = nil
		end 
	end

	for k,v in pairs(self.liubaoEffect) do
		if v then
			v:removeFromParent()
			self.liubaoEffect[k] = nil
		end 
	end

	if self.caiDou then
		self.caiDou:finalize()
		self.caiDou = nil
	end

    OpenningPanel.super.finalize(self)
end

function OpenningPanel:initPanel()
	OpenningPanel.super.initPanel(self)
	self._mainPanel = self:getChildByName("mainPanel")
	-- self._mainPanel = self._mainPanel:getChildByName("myValuePanel")
	-- self._mainPanel = self._mainPanel:getChildByName("panelTop")
	-- self._mainPanel = self:getChildByName("diceCupPanel")
	-- self.leftTimesPanel = self._mainPanel:getChildByName("leftTimesPanel")
	-- self.dicePanel = self._mainPanel:getChildByName("dicePanel")
	-- self._mainPanel = self._mainPanel:getChildByName("buttonPanel")

	--改命按钮
	local changeBtn = self._mainPanel:getChildByName("changeBtn")
	--确定按钮
	local comfirmBtn = self._mainPanel:getChildByName("sureBtn")

	local startBtn = self._mainPanel:getChildByName("startBtn")

	local helpBtn = self._mainPanel:getChildByName("detailBtn")
	self:addTouchEventListener(helpBtn, self.helpBtnOnTap)

	self:addTouchEventListener(changeBtn, self.startOrChangeReq)
	self:addTouchEventListener(comfirmBtn, self.comfirmBtnEvent)
	self:addTouchEventListener(startBtn, self.startOrChangeReq)

	-- local scale = NodeUtils:getAdaptiveScale()
	-- self._mainPanel:setScale(1/scale)
	-- local centerX,centerY = NodeUtils:getCenterPosition()
 --    self._mainPanel:setPositionY(centerY)
end

function OpenningPanel:helpBtnOnTap()
	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {
    	[0] = { { content = string.format(TextWords:getTextWord(540042),self.materialName), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[1] = { { content = TextWords:getTextWord(540043), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[2] = { { content = TextWords:getTextWord(540044), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[3] = { { content = TextWords:getTextWord(540045), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[4] = { { content = TextWords:getTextWord(540046), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    }
    for i = 5,10 do
    	local effectId = self.activityInfo.effectId
		local richManorInfo = ConfigDataManager:getRichManorInfo(effectId)
    	local rewardInfo = ConfigDataManager:getRichManorRewardInfo(richManorInfo.rewardGroup,i-4) 
		local reward = StringUtils:jsonDecode(rewardInfo.reward)
		lines[i] = {{content = string.format(TextWords:getTextWord(540047),TextWords:getTextWord(540048 + (i - 5)),reward[1][3]), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    end 
    uiTip:setAllTipLine(lines)
end 

function OpenningPanel:registerEvents()
	OpenningPanel.super.registerEvents(self)
end

function OpenningPanel:onShowHandler()

	local function callback(activityId)
		self.activityId = activityId
	end
	self:dispatchEvent(RichPowerfulVillageEvent.GET_CURRENT_OPEN_ACTIVITY,{callback = callback})

	local activityProxy = self:getProxy(GameProxys.Activity)
	local data = activityProxy:getRichPowerVillageInfoById(self.activityId) --富贵豪庄信息
	local activityInfo = activityProxy:getLimitActivityInfoById(self.activityId) --活动信息
	self.activityInfo = activityInfo

	self:update()
	self:onUpdateGold()
	self:updateItemNum()

	--有活动数据
	if data then
		self:updatePanel(data)
	else
		self:nodeIsShow(false)
	end
end

--更新倒计时
function OpenningPanel:update(dt)
	local leftTimeLab = self._mainPanel:getChildByName("leftTimeLab") --剩余时间描述
	local desLab = self._mainPanel:getChildByName("desLab") --活动描述
    desLab:setColor(cc.c3b(244,244,244))
    if self.activityInfo then
		local endTime = self.activityInfo.endTime --活动结束时间
		-- local serverTime = os.time()
		-- local leftTime = endTime - serverTime
		local startTime = self.activityInfo.startTime 
		leftTimeLab:setVisible(true)
		desLab:setVisible(true)
		leftTimeLab:setString(TimeUtils.getLimitActFormatTimeString(startTime - 1,endTime - 1,true))
		-- leftTimeLab:setString(TextWords:getTextWord(250005) .. ":" .. TimeUtils:getStandardFormatTimeString(leftTime) .. TextWords:getTextWord(249993))
		desLab:setString(self.activityInfo.info)
	else
		leftTimeLab:setVisible(false)
		desLab:setVisible(false)
	end 
end

-- 是否弹窗元宝不足
function OpenningPanel:isShowRechargeUI(sender)
    local needMoney = sender.money
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end
    else
        sender.callFunc()
    end
end


--改变命运按钮需要加入二次确认
function OpenningPanel:ChangeBtnReq(sender)
	local messageBox = self:showMessageBox(TextWords:getTextWord(540041),function() 
			self:startOrChangeReq(sender)
		end)
    -- return self.view:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent, isRemove)
end

--开始或改命按钮点击
function OpenningPanel:startOrChangeReq(sender)
	-- do
	-- 	self:effectIn()
	-- 	return 
	-- end 
	--骰子都为6
	if self.isInAction then
		self:showSysMessage(TextWords:getTextWord(540039))
		return
	end

	if self.sum == 6 then
		-- local messageBox = self:showMessageBox(TextWords:getTextWord(540041))
		-- messageBox:setLocalZOrder(3000)
		return
	end

	if self.leftTimes > 0 then 
		local function startChangeReq()
			self:effectIn()
			self:dispatchEvent(RichPowerfulVillageEvent.STAR_OR_CHANGE_REQ)
		end 
		local function callback()
			local des
			if not self.isStart then
				des = string.format(TextWords:getTextWord(540040),sender.money)
			else
				des = string.format(TextWords:getTextWord(540036),sender.money)
			end
			local messageBox = self:showMessageBox(des,startChangeReq)
			messageBox:setLocalZOrder(3000)
		end

		--当前背包物品数量是否满足
		local currentTime 
		if self.isStart then
			currentTime = self.changeLimitTimes - self.leftTimes + 1
		else
			currentTime = 0
		end 

		local effectId = self.activityInfo.effectId
		local richManorInfo = ConfigDataManager:getRichManorInfo(effectId)
		if richManorInfo then
			local priceInfo = ConfigDataManager:getRichManorPriceInfo(richManorInfo.priceID,currentTime)
			local itemCost = StringUtils:jsonDecode(priceInfo.itemCost)
			local needImteNum = tonumber(itemCost[1][3])
			if self.haveItemNum >= needImteNum then
				startChangeReq()
			else
				sender.money = self.needExpand * (needImteNum - self.haveItemNum)
				sender.callFunc = callback
				self:isShowRechargeUI(sender)
			end
		else
			return
		end 
	else
		-- local messageBox = self:showMessageBox(TextWords:getTextWord(540041))
		-- messageBox:setLocalZOrder(3000)
	end 
end 

--确认按钮点击
function OpenningPanel:comfirmBtnEvent(sender)
	self:showMessageBox(TextWords:getTextWord(460014),function() 
        self.reward = 0
		self:comfirmBtnTap(sender)
	end)
end



function OpenningPanel:comfirmBtnTap(sender)
	if self.caiDou then
		self.caiDou:finalize()
		self.caiDou = nil
	end

	-- do
	-- 	self.caiDou = UICCBLayer.new( "rgb-fghz-caidou", self._mainPanel:getChildByName("itemIcon"))
	-- 	self.caiDou:setPosition(15,15)
	-- 	return
	-- end 

	local function confirmReq()
		self:dispatchEvent(RichPowerfulVillageEvent.CONFIRM_RESULT_REQ)
		self.caiDou = UICCBLayer.new( "rgb-fghz-caidou", self._mainPanel:getChildByName("itemIcon"))
		self.caiDou:setPosition(15,15)
	end
	if self.isInAction then
		self:showSysMessage(TextWords:getTextWord(540054))
	else
		confirmReq()
	end 
	-- local messageBox = self:showMessageBox(TextWords:getTextWord(540035), confirmReq)
	-- messageBox:setLocalZOrder(3000)
end


function OpenningPanel:setChangeBtnEnable(enable)
    local changeBtn = self._mainPanel:getChildByName("changeBtn")
    NodeUtils:setEnable(changeBtn, enable)
end

function OpenningPanel:nodeIsShow(isShow,tag)
	--控制相关组件的显示与隐藏
	self._mainPanel:getChildByName("changeBtn"):setVisible(isShow)
	self._mainPanel:getChildByName("goldImg"):setVisible(isShow)
	self._mainPanel:getChildByName("changeExpand"):setVisible(isShow)
    self:setChangeBtnEnable(true)
	
	self._mainPanel:getChildByName("sureBtn"):setVisible(isShow)
	self._mainPanel:getChildByName("currentGet"):setVisible(isShow)
	self._mainPanel:getChildByName("currentGetValue"):setVisible(isShow)
	
	self._mainPanel:getChildByName("startBtn"):setVisible(not isShow)
	self._mainPanel:getChildByName("startGoldImg"):setVisible(not isShow)
	self._mainPanel:getChildByName("startExpand"):setVisible(not isShow)
end

--设置获得彩豆数量
function OpenningPanel:resetGetLabel(val)
	local currentGet = self._mainPanel:getChildByName("currentGet")
	local currentGetValue = self._mainPanel:getChildByName("currentGetValue")
    local sureBtn = self._mainPanel:getChildByName("sureBtn")
	currentGet:setString(string.format(TextWords:getTextWord(540033),TextWords:getTextWord(540055)))
	currentGetValue:setString(tonumber(val))
	currentGet:setPositionX(sureBtn:getPositionX() - currentGetValue:getContentSize().width/2 - 3)
	currentGetValue:setPositionX(currentGet:getPositionX() + currentGet:getContentSize().width/2 + 10)
end


function OpenningPanel:changeBtnShow(isShow)
	self._mainPanel:getChildByName("changeBtn"):setVisible(isShow)
	self._mainPanel:getChildByName("goldImg"):setVisible(isShow)
	self._mainPanel:getChildByName("changeExpand"):setVisible(isShow)
end

function OpenningPanel:effectLiu()
	for k,v in pairs(self.status) do
		if v and type(v) == "number" and v == 6 then
			local diceImage = self._mainPanel:getChildByName("dice_" .. k)
			if not self.liuEffect[k] then
				self.liuEffect[k] = UICCBLayer.new( "rgb-fghz-liu", diceImage )
				self.liuEffect[k]:setPosition(diceImage:getContentSize().width/2,diceImage:getContentSize().height/2)
			else
				self.liuEffect[k]:setVisible(true)
			end 
			if not self.liubaoEffect[k] then
				self.liubaoEffect[k] = UICCBLayer.new( "rgb-fghz-liubao", diceImage )
				self.liubaoEffect[k]:setPosition(diceImage:getContentSize().width/2,diceImage:getContentSize().height/2)
			else
				self.liubaoEffect[k]:setVisible(true)
			end 
		end 
	end 
end

function OpenningPanel:effectOut()
	for k,v in pairs(self.outeffect) do
		if v then
			v:removeFromParent()
			self.outeffect[k] = nil
		end 
	end 

	local isend = false
	for k,v in pairs(self.status) do
		if v and type(v) == "number" and v ~= 6 then

			local dice = self._mainPanel:getChildByName("dice_" .. k)
			
			local function callback()
				dice:setVisible(true)
				self.outeffect[k]:removeFromParent()
				self.outeffect[k] = nil
				-- self.leftTimesPanel:setVisible(true)
				self._mainPanel:getChildByName("leftTimeDesLab"):setVisible(true)
				self._mainPanel:getChildByName("leftTimeValueLab"):setVisible(true)
				self._mainPanel:getChildByName("bg_1"):setVisible(true)
				if not isend then
					isend = true
					self.isInAction = false
					local activityProxy = self:getProxy(GameProxys.Activity)
					local data = activityProxy:getRichPowerVillageInfoById(self.activityId) --富贵豪庄信息
					self:updatePanel(data)
					self:effectLiu()
				end 
			end

			if k ==  1 then
				self.outeffect[k] = UICCBLayer.new( "rgb-fghz-outa", self._mainPanel,nil, callback, true)
			elseif k == 2 then
				self.outeffect[k] = UICCBLayer.new( "rgb-fghz-outb", self._mainPanel,nil, callback, true)
			elseif k == 3 then
				self.outeffect[k] = UICCBLayer.new( "rgb-fghz-outc", self._mainPanel,nil, callback, true)
			elseif k == 4 then
				self.outeffect[k] = UICCBLayer.new( "rgb-fghz-outd", self._mainPanel,nil, callback, true)
			elseif k == 5 then
				self.outeffect[k] = UICCBLayer.new( "rgb-fghz-oute", self._mainPanel,nil, callback, true)
			elseif k == 6 then 
				self.outeffect[k] = UICCBLayer.new( "rgb-fghz-outf", self._mainPanel,nil, callback, true)
			end
			self.outeffect[k]:setPosition(dice:getPositionX(),dice:getPositionY())
			self.outeffect[k]:setLocalZOrder(20)
		end  
	end
end

function OpenningPanel:effectZhong()
	local diceCupUpImg = self._mainPanel:getChildByName("diceCupUpImg")
	diceCupUpImg:setVisible(false)
	local diceCupDownImg = self._mainPanel:getChildByName("diceCupDownImg")
	diceCupDownImg:setVisible(false)

	if self.zhongEffect then
		self.zhongEffect:removeFromParent()
		self.zhongEffect = nil
	end
	if self.zhongdiEffect then
		self.zhongdiEffect:removeFromParent()
		self.zhongdiEffect = nil
	end
	if self.zhongtingEffect then
		self.zhongtingEffect:removeFromParent()
		self.zhongtingEffect = nil
	end

	self.zhongEffect = UICCBLayer.new("rgb-fghz-zhong",self._mainPanel)
	self.zhongEffect:setPosition(diceCupDownImg:getPositionX() - 10,diceCupDownImg:getPositionY())
	self.zhongEffect:setLocalZOrder(15)
	self.zhongdiEffect = UICCBLayer.new("rgb-fghz-zhongdi",self._mainPanel)
	self.zhongdiEffect:setPosition(diceCupDownImg:getPositionX() - 10,diceCupDownImg:getPositionY())
	self.zhongdiEffect:setLocalZOrder(15)
	-- self.zhongtingEffect = UICCBLayer.new("rgb-fghz-zhongting",self._mainPanel)
	-- self.zhongtingEffect:setPosition(diceCupDownImg:getPositionX(),diceCupDownImg:getPositionY())

	local function delay()
      	self:effectOut()
    end
    TimerManager:addOnce(2000,delay, self)
end 

--开始  或  开局特效
function OpenningPanel:effectIn()
	self.isInAction = true
	for k,v in pairs(self.ineffect) do
		if v then
			v:removeFromParent()
			self.ineffect[k] = nil
		end 
	end 

	for k,v in pairs(self.status) do
		if v and type(v) == "number" and v ~= 6 then
			local dice = self._mainPanel:getChildByName("dice_" .. k)
			dice:setVisible(false)
			-- self.leftTimesPanel:setVisible(false)
			self._mainPanel:getChildByName("leftTimeDesLab"):setVisible(false)
			self._mainPanel:getChildByName("leftTimeValueLab"):setVisible(false)
			self._mainPanel:getChildByName("bg_1"):setVisible(false)
			if k ==  1 then
				self.ineffect[k] = UICCBLayer.new( "rgb-fghz-ina", self._mainPanel)
			elseif k == 2 then
				self.ineffect[k] = UICCBLayer.new( "rgb-fghz-inb", self._mainPanel )
			elseif k == 3 then
				self.ineffect[k] = UICCBLayer.new( "rgb-fghz-inc", self._mainPanel )
			elseif k == 4 then
				self.ineffect[k] = UICCBLayer.new( "rgb-fghz-ind", self._mainPanel )
			elseif k == 5 then
				self.ineffect[k] = UICCBLayer.new( "rgb-fghz-ine", self._mainPanel )
			elseif k == 6 then 
				self.ineffect[k] = UICCBLayer.new( "rgb-fghz-inf", self._mainPanel )
			end
			self.ineffect[k]:setPosition(dice:getPositionX(),dice:getPositionY() + 8)
			self.ineffect[k]:setLocalZOrder(20)
		end  
	end

	for k,v in pairs(self.status) do
		if v and type(v) == "number" and v ~= 6 then
			self:effectZhong()
			break
		end 
	end 
end

--更新界面
function OpenningPanel:updatePanel(data)
	if data.activityId ~= self.activityId then
		return 
	end

	local isStart = false --是否开局
	if data.state ~= 0 then 
		isStart = true
	end
	self.isStart = isStart
	
	self:nodeIsShow(isStart)

    self:resetGetLabel(self.reward)--初始化未0

	--骰子显示  以及统计
	self.sum = 0 --点数为6的骰子数量
	if self.isInAction then
		return
	end  
	for k,v in pairs(data.diceInfo) do
		--是否是有效参数
		if type(v) == "number" and (v >= 1 or v <= 6) then
			self.status[k] = v

			local url = "images/richPowerfulVillage/" .."dice_" ..tostring(v) ..".png"
			local diceImage = self._mainPanel:getChildByName("dice_" .. k)
			TextureManager:updateImageView(diceImage,url)

			if v == 6 then
				self.sum = self.sum + 1
				if self.liuEffect[k] then
					self.liuEffect[k]:setVisible(true)
				else
					self.liuEffect[k] = UICCBLayer.new( "rgb-fghz-liu", diceImage )
					self.liuEffect[k]:setPosition(diceImage:getContentSize().width/2,diceImage:getContentSize().height/2)
				end 
				if self.liubaoEffect[k] then
					self.liubaoEffect[k]:setVisible(true)
				else
					self.liubaoEffect[k] = UICCBLayer.new( "rgb-fghz-liubao", diceImage )
					self.liubaoEffect[k]:setPosition(diceImage:getContentSize().width/2,diceImage:getContentSize().height/2)
					self.liubaoEffect[k]:setVisible(false)
				end
			else
				if self.liuEffect[k] then
					self.liuEffect[k]:removeFromParent()
					self.liuEffect[k] = nil
				end
				if self.liubaoEffect[k] then
					self.liubaoEffect[k]:removeFromParent()
					self.liubaoEffect[k] = nil
				end 
			end
		end
	end

	--剩余次数显示
	self.leftTimes = data.changeTimes
	local leftTimeValueLab = self._mainPanel:getChildByName("leftTimeValueLab")
	leftTimeValueLab:setString(data.changeTimes)

	--无改命次数可用或所有骰子都为6
	if self.leftTimes <= 0 or self.sum == 6 then
		--self:changeBtnShow(false)
        self:setChangeBtnEnable(false)
	end 

	local effectId = self.activityInfo.effectId
	local richManorInfo = ConfigDataManager:getRichManorInfo(effectId)
	if richManorInfo then
		self.changeLimitTimes = richManorInfo.changeLimit
		self.needExpand = richManorInfo.priceChange

		local currentGet = self._mainPanel:getChildByName("currentGet")
		local currentGetValue = self._mainPanel:getChildByName("currentGetValue")
		local sureBtn = self._mainPanel:getChildByName("sureBtn")
		--更新奖励信息
		if self.sum > 0 then
			local rewardInfo = ConfigDataManager:getRichManorRewardInfo(richManorInfo.rewardGroup,self.sum)
			if rewardInfo then 
				local reward = StringUtils:jsonDecode(rewardInfo.reward)
				local itemConfig = ConfigDataManager:getConfigByPowerAndID(tonumber(reward[1][1]), tonumber(reward[1][2]))
				currentGet:setString(string.format(TextWords:getTextWord(540033),itemConfig.name))
				currentGetValue:setString(tonumber(reward[1][3]))
				currentGet:setPositionX(sureBtn:getPositionX() - currentGetValue:getContentSize().width/2 - 3)
				currentGetValue:setPositionX(currentGet:getPositionX() + currentGet:getContentSize().width/2 + 10)
                self.reward = reward[1][3]
			end
		else
			currentGet:setVisible(false)
			currentGetValue:setVisible(false)
		end

		--判断当前按钮显示
		local startGoldImg = self._mainPanel:getChildByName("startGoldImg") --当前开始材料（开始按钮）
		local changeExpand = self._mainPanel:getChildByName("changeExpand") --当前材料花费（开始按钮）
		local goldImg = self._mainPanel:getChildByName("goldImg") --当前材料（改命按钮）
		local startExpand = self._mainPanel:getChildByName("startExpand") --当前开始材料花费（改命按钮）

		local currentTime 
		if self.isStart then
			currentTime = self.changeLimitTimes - self.leftTimes + 1
		else
			currentTime = 0
		end 

		local priceInfo = ConfigDataManager:getRichManorPriceInfo(richManorInfo.priceID,currentTime)
		if priceInfo then 
			local itemCost = StringUtils:jsonDecode(priceInfo.itemCost)
			--物品配置信息
			local itemCostConfig = ConfigDataManager:getConfigByPowerAndID(tonumber(itemCost[1][1]), tonumber(itemCost[1][2]))
			local needImteNum = tonumber(itemCost[1][3])
			if self.haveItemNum >= needImteNum then
				--显示材料图片和花费数量
				local url = "images/richPowerfulVillage/" .. tostring(itemCostConfig.icon) ..".png"
				TextureManager:updateImageView(startGoldImg,url)
				TextureManager:updateImageView(goldImg,url)
				
				changeExpand:setString(needImteNum)
				startExpand:setString(needImteNum)
			else
				--显示元宝图片和花费元宝数量
				local url = "images/newGui1/IconYuanBao.png"
				TextureManager:updateImageView(startGoldImg,url)
				TextureManager:updateImageView(goldImg,url)
				changeExpand:setString((needImteNum - self.haveItemNum) * self.needExpand)
				startExpand:setString((needImteNum - self.haveItemNum) * self.needExpand)
			end
		end 
	end
end

--更新彩豆数量和材料数量
function OpenningPanel:updateItemNum()
	if self.activityInfo then 
		local effectId = self.activityInfo.effectId
		local richManorInfo = ConfigDataManager:getRichManorInfo(effectId)
		if richManorInfo then
			local rewardInfo = ConfigDataManager:getRichManorRewardInfo(richManorInfo.rewardGroup,1)
			local rewardItem = StringUtils:jsonDecode(rewardInfo.reward)

			local itemId = tonumber(rewardItem[1][2])

			local itemConfig = ConfigDataManager:getConfigById(ConfigData.ItemConfig,itemId)

			local myValueLab = self._mainPanel:getChildByName("myValueLab")
			local myValueDesLab = self._mainPanel:getChildByName("myValueDesLab")
			local bg = self._mainPanel:getChildByName("bg")
			local itemIcon_ex = self._mainPanel:getChildByName("itemIcon")

			--更新背包中奖励物品数量
			local itemProxy = self:getProxy(GameProxys.Item)
			local itemNum = itemProxy:getItemNumByType(itemId)
			myValueLab:setString(itemNum)
			myValueDesLab:setString(itemConfig.name .. " ")
			local url = "images/richPowerfulVillage/" .. tostring(itemConfig.icon) ..".png"
			TextureManager:updateImageView(itemIcon_ex,url)
			itemIcon_ex:setPositionX(myValueLab:getPositionX() - myValueLab:getContentSize().width - itemIcon_ex:getContentSize().width/2 - 5)
			myValueDesLab:setPositionX(itemIcon_ex:getPositionX() - itemIcon_ex:getContentSize().width/2)
			bg:setContentSize(myValueLab:getContentSize().width + myValueDesLab:getContentSize().width + 30 + itemIcon_ex:getContentSize().width,27)

			--更新背包中材料数量
			local priceInfo = ConfigDataManager:getRichManorPriceInfo(richManorInfo.priceID)
			local itemCost = StringUtils:jsonDecode(priceInfo.itemCost)
			local itemCostConfig = ConfigDataManager:getConfigByPowerAndID(tonumber(itemCost[1][1]), tonumber(itemCost[1][2]))
			local materialNum = itemProxy:getItemNumByType(tonumber(itemCost[1][2]))
			self.haveItemNum = materialNum --拥有材料数量
			self.materialName = itemCostConfig.name

			local itemNumLab = self._mainPanel:getChildByName("itemNum")
			local yuanBaoNum = self._mainPanel:getChildByName("yuanBaoNum")
			local itemIcon = self._mainPanel:getChildByName("itemIcon_1")
			local moneyBg = self._mainPanel:getChildByName("moneyBg")
			local url = "images/richPowerfulVillage/" .. tostring(itemCostConfig.icon) ..".png"
			TextureManager:updateImageView(itemIcon,url)
			itemNumLab:setString(self.haveItemNum)
		end

		local activityProxy = self:getProxy(GameProxys.Activity)
		local data = activityProxy:getRichPowerVillageInfoById(self.activityId) --富贵豪庄信息
		self:updatePanel(data)
	end
end

--更新元宝数量
function OpenningPanel:onUpdateGold()
	local proxy = self:getProxy(GameProxys.Role)
    local gold = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
   	self.gold = gold

   	local haveLab = self._mainPanel:getChildByName("haveLab")
   	local itemNum = self._mainPanel:getChildByName("itemNum")
	local yuanBaoNum = self._mainPanel:getChildByName("yuanBaoNum")
	local iconYuanBao = self._mainPanel:getChildByName("iconYuanBao")
	local itemIcon = self._mainPanel:getChildByName("itemIcon_1")
	local moneyBg = self._mainPanel:getChildByName("moneyBg")
	yuanBaoNum:setString(gold)
	itemNum:setString(self.haveItemNum)
end 

--开始或改命返回
function OpenningPanel:startOrChangeResp(param)
	-- local activityProxy = self:getProxy(GameProxys.Activity)
	-- local data = activityProxy:getRichPowerVillageInfoById(self.activityId) --富贵豪庄信息
	-- self:updatePanel(data)
end

--确定按钮点击返回
function OpenningPanel:confirmResultResp(param)
	local activityProxy = self:getProxy(GameProxys.Activity)
	local data = activityProxy:getRichPowerVillageInfoById(self.activityId) --富贵豪庄信息
	self:updatePanel(data)
end

function OpenningPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
    -- NodeUtils:adaptiveUpPanel(self._mainPanel,tabsPanel,-30)
    NodeUtils:adaptiveUpPanel(self._mainPanel,tabsPanel,1)
end