-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-20
--  * @Description: 雄狮轮盘
--  */
LionTurntablePanel = class("LionTurntablePanel", BasicPanel)
LionTurntablePanel.NAME = "LionTurntablePanel"

function LionTurntablePanel:ctor(view, panelName)
    LionTurntablePanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function LionTurntablePanel:finalize()
	if self.pointerEffect ~= nil then
		self.pointerEffect:finalize()
		self.pointerEffect = nil
	end
	if self.circleEffect ~= nil then
		self.circleEffect:finalize()
		self.circleEffect = nil
	end
    LionTurntablePanel.super.finalize(self)
end

function LionTurntablePanel:initPanel()
	LionTurntablePanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.ACTIVITY)
	self:setTitle(true, "lionTurntable", true)

	self.proxy = self:getProxy(GameProxys.Activity)
	self.circleImg = self:getChildByName("topPanel/mainPanel/turnTableImg")
	self.pointer = self:getChildByName("topPanel/mainPanel/selectImg")
	self.innerCircle = self:getChildByName("topPanel/mainPanel/innerTurnPanel")
	-- 记录锁定状态
	self.lockStatus = false
	--活动描述
	local descLab = self:getChildByName("topPanel/headPanel/descLab")
	descLab:setString(string.format("%s\n%s", self:getTextWord(450000),self:getTextWord(260008)))
    descLab:setColor(cc.c3b(244,244,244))
	-- descLab:setString(self:getTextWord(450000))
	--记录价格
	self.PriceAry = {}
	--宏定义内外盘加速转动的时间（内外盘同时停）
	self.turnTime = 4
end
function LionTurntablePanel:onShowHandler()
	--[[
	local topPanel = self:getChildByName("topPanel")
	local aEffect = self:createUICCBLayer("rgb-tjxs-zhizhen", topPanel, nil, nil, true)
    local size = topPanel:getContentSize()
    aEffect:setPosition(size.width*0.5,size.height*0.5)
    aEffect:setLocalZOrder(10)
    --]]

    self:updateLionTurnView()
    
	--初始化使用轮盘转起来
	self.canClose = true

	self.rotated = 0
	-- self.speed = 400
	self.circleImg:stopAllActions()
	self.circleImg:setRotation(0)
	-- self:rotatePointer(1)
	self:rotateInnerCircle(0.8)
	self.finish = true
	self.Stop = false
	
	local action = cc.Sequence:create(cc.RotateBy:create(0.1, 1) ,cc.CallFunc:create(function()
		self:rotateBg()
	end))
	self.circleImg:runAction(action)
end
function LionTurntablePanel:updateLionTurnView()
	self.myData = self.proxy:getCurActivityData()
	self.lionTurnConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.LionCoronaConfig, "effectID", self.myData.effectId)
	local lionSoldierConfig = ConfigDataManager:getConfigData(ConfigData.LionSoldierConfig)
	local lionTurnInfo = self.proxy:getLionTurnInfoById(self.myData.activityId)
	--活动时间显示
	local timeDescLab = self:getChildByName("topPanel/headPanel/timeDescLab")
	-- local startTime = self:timestampToString(self.myData.startTime)
	-- local endTime = self:timestampToString(self.myData.endTime)
	-- if startTime == 0 or endTime == 0 then
	-- 	timeDescLab:setString("")
	-- else
		timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
		-- timeDescLab:setString(string.format("%s%s%s%s", self:getTextWord(420003),startTime,self:getTextWord(420004),endTime))
	-- end
	--价格
	if self.lockStatus == true then
		local extraPriceAry = StringUtils:jsonDecode(self.lionTurnConfig.extraPrice)
		self.PriceAry[extraPriceAry[1][1]] = extraPriceAry[1][2]
		self.PriceAry[extraPriceAry[2][1]] = extraPriceAry[2][2]
	else
		local commonPriceAry = StringUtils:jsonDecode(self.lionTurnConfig.commonPrice)
		self.PriceAry[commonPriceAry[1][1]] = commonPriceAry[1][2]
		self.PriceAry[commonPriceAry[2][1]] = commonPriceAry[2][2]
	end
	self:setBtnPrice()
	--按钮免费显示
	local btnIconImg = self:getChildByName("topPanel/mainPanel/btnPanel/onceBtnPanel/iconImg")
	local btnNumLab = self:getChildByName("topPanel/mainPanel/btnPanel/onceBtnPanel/numLab")
	local btnFreeLab = self:getChildByName("topPanel/mainPanel/btnPanel/onceBtnPanel/freeLab")
	local freeTime  = self.proxy:getLionTurnFreeTime(self.myData.activityId)
	if freeTime > 0 then
		btnIconImg:setVisible(false)
		btnNumLab:setVisible(false)
		btnFreeLab:setVisible(true)
	else
		btnIconImg:setVisible(true)
		btnNumLab:setVisible(true)
		btnFreeLab:setVisible(false)
	end
	--初始化内盘兵种并且记录
	self.soldierAry = {}
	for i=1,4 do
		self.soldierAry[lionSoldierConfig[i].soldierType] = i
		local iconImg = self:getChildByName("topPanel/mainPanel/innerTurnPanel/img" .. i .. "/iconImg")
        local tempData = {}
        -- tempData.num =  1
        tempData.power =  GamePowerConfig.Soldier
        tempData.typeid =  lionSoldierConfig[i].soldierType
	    if iconImg.uiIcon == nil then
	        iconImg.uiIcon = UIIcon.new(iconImg,tempData,false,self)
	    else
	        iconImg.uiIcon:updateData(tempData)
	    end

	end



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
	


end
--刚开始一直在转动的函数，递归调用，累计转动的角度，协议返回时跳出递归。开始加速并计算要转的角度
function LionTurntablePanel:rotateBg()
	if self.afterConscriptTag then

		self.afterConscriptTag = false

		--内圈
		if self.lockStatus == false then
			local rotateInnerNum = self.innerCircle:getRotation()%-360
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
			needInnerAngle = needInnerAngle - 720 * 5

			local actInner = cc.EaseSineInOut:create(cc.RotateBy:create(self.turnTime, needInnerAngle))
			-- local actInner = cc.EaseSineInOut:create(cc.RotateBy:create(math.abs(needInnerAngle)/self.speed, needInnerAngle))
			local rotateInner = cc.Sequence:create(actInner, cc.CallFunc:create(function()
					-- self:showReward()			
					-- self.rotated = self.circleImg:getRotation()%360
					-- self.finish = true
					-- self.afterConscriptTag = false
					-- self:rotatePointer(1)
					-- self:rotateBg()
					-- logger:info("after rotateInner ")
					self:rotateInnerCircle(0.8)
			end))
			self.innerCircle:stopAllActions()
			self.innerCircle:runAction(rotateInner)

		end
		--外圈
		local rotateNum = self.circleImg:getRotation()%360              
		local needAngle
		if rotateNum >= self.exactAngle then
			needAngle = 360 - rotateNum + self.exactAngle
		else
			needAngle = self.exactAngle - rotateNum
		end
		needAngle = needAngle + 720 * 5

		local effectfunc = cc.CallFunc:create(function()
			self:rotatePointer(0.3)
			if self.pointerEffect == nil then
				self.pointerEffect = self:createUICCBLayer("rgb-tjxs-zhizhen", self.pointer, nil, nil, false)
			    local size = self.pointer:getContentSize()
			    self.pointerEffect:setPosition(size.width*0.5,size.height*0.87 + 15)
			    self.pointerEffect:setLocalZOrder(10)

			end
			if self.circleEffect == nil then
				self.circleEffect = self:createUICCBLayer("rgb-tjxs-quan", self.circleImg, nil, nil, false)
			    local size = self.circleImg:getContentSize()
			    self.circleEffect:setPosition(size.width*0.5,size.height*0.5)
			    self.circleEffect:setLocalZOrder(10)
			end
            
            local btn = self:getChildByName("topPanel/mainPanel/LockBtn")
                local size = btn:getContentSize()
            if self.lockStatus == false then
			    local roundEffect = self:createUICCBLayer("rgb-tjxs-quanz", btn, nil, nil, true)
			    roundEffect:setPosition(size.width*0.5,size.height*0.5)
			    roundEffect:setLocalZOrder(11)
            end
            
			local pointEffect = self:createUICCBLayer("rgb-tjxs-zhizhens", btn, nil, nil, true)
			pointEffect:setPosition(size.width*0.5,size.height + 188)
			pointEffect:setLocalZOrder(11)
	
		end)
		local act = cc.EaseSineInOut:create(cc.RotateBy:create(self.turnTime, needAngle))
		-- local act = cc.EaseSineInOut:create(cc.RotateBy:create(needAngle/self.speed, needAngle))
		local rotate = cc.Sequence:create(effectfunc,act, cc.CallFunc:create(function()
				-- self:showReward()			
				-- self.rotated = self.circleImg:getRotation()%360
				-- logger:info("finish!!")
				self.circleImgRotating = false
				-- self:rotatePointer(1)
				-- self:rotateBg()
				if self.pointerEffect ~= nil then
					self.pointerEffect:finalize()
					self.pointerEffect = nil
				end
				if self.circleEffect ~= nil then
					self.circleEffect:finalize()
					self.circleEffect = nil
				end
				self.pointer:setRotation(0)
				self.pointer:stopAllActions()

                if self._EffectOver == nil then
				    self._EffectOver = self:createUICCBLayer("rgb-tjxs-jiesu", self.pointer, nil, nil, true)
			        local size = self.pointer:getContentSize()
			        self._EffectOver:setPosition(size.width*0.5,size.height*0.66 + 95)
			        self._EffectOver:setLocalZOrder(10)
                    
				    local rewardEffect = self:createUICCBLayer("rgb-tjxs-wupin", self.pointer, nil, nil, true)
			        rewardEffect:setPosition(size.width*0.5,size.height*0.66 + 100)
			        rewardEffect:setLocalZOrder(11)
                    
                end

                self:updateLionTurnView()
		end),cc.DelayTime:create(1),cc.CallFunc:create(function ( )
			self.finish = true
			self:showReward()
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
function LionTurntablePanel:rotatePointer(time)
	self.pointer:stopAllActions()
	self.pointer:setRotation(0)
	local action1 = cc.RotateBy:create(time, 3)
	local action2 = cc.RotateBy:create(time, -3)
	self.pointer:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
end
function LionTurntablePanel:rotateInnerCircle(time)
	self.innerCircle:stopAllActions()
	-- self.innerCircle:setRotation(0)
	local action1 = cc.RotateBy:create(time, -2)
	local action2 = cc.RotateBy:create(time, 2)
	self.innerCircle:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
end
function LionTurntablePanel:doLayout()
	--local bgImg = self:getChildByName("topPanel/mainPanel/bigBgImg")
	--TextureManager:updateImageViewFile(bgImg,"bg/lionTurntable/lionTurntableBg.pvr.ccz")
	local topPanel = self:getChildByName("topPanel")
    local bestTopPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveUpPanel(topPanel, bestTopPanel)
end
function LionTurntablePanel:registerEvents()
	LionTurntablePanel.super.registerEvents(self)
	local onceBtn = self:getChildByName("topPanel/mainPanel/btnPanel/onceBtnPanel/btn")
	self:addTouchEventListener(onceBtn, self.onOnceBtnHandler)
	local tenBtn = self:getChildByName("topPanel/mainPanel/btnPanel/tenBtnPanel/btn")
	self:addTouchEventListener(tenBtn, self.onTenBtnHandler)
	local lockBtn = self:getChildByName("topPanel/mainPanel/LockBtn")
	self:addTouchEventListener(lockBtn, self.onLockBtnHandler,nil,nil,500)

end
function LionTurntablePanel:onClosePanelHandler()
    if self.finish == false then
		self:showSysMessage(self:getTextWord(520001))
        return
    end
	if self.effectQueueManager == true then
		EffectQueueManager:completeEffect()
		self.effectQueueManager = false
	end
	self:dispatchEvent(LionTurntableEvent.HIDE_SELF_EVENT, {})
end
--征召一次
function LionTurntablePanel:onOnceBtnHandler(sender)
	if self.circleImgRotating == true then
		self:showSysMessage(self:getTextWord(450002))
		return
	end
	local freeTime  = self.proxy:getLionTurnFreeTime(self.myData.activityId)
	if freeTime > 0 then
		local sendData = {}
		sendData.activityId = self.myData.activityId
		sendData.draftType = 1
		if self.lockStatus == true then
			sendData.lockType = self.lastSoldierTypeId
		end
		self.finish = false
		self.proxy:onTriggerNet230045Req(sendData)
	else
    	local roleProxy = self:getProxy(GameProxys.Role)
	    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
	    if self.PriceAry[1] > curNum then
	        local parent = self:getParent()
	        local panel = parent.panel
	        if panel == nil then
	            local panel = UIRecharge.new(parent, self)
	            parent.panel = panel
	        else
	            panel:show()
	        end
	    else
        	local function sureFun()
				local sendData = {}
				sendData.activityId = self.myData.activityId
				sendData.draftType = 1
				if self.lockStatus == true then
					sendData.lockType = self.lastSoldierTypeId
				end
			    self.finish = false
				self.proxy:onTriggerNet230045Req(sendData)
        	end
        	local messageBox = self:showMessageBox(string.format(self:getTextWord(450003),self.PriceAry[1]),sureFun)
            messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	    end
	end

end
--征召十次
function LionTurntablePanel:onTenBtnHandler(sender)
	if self.circleImgRotating == true then
		self:showSysMessage(self:getTextWord(450002))
		return
	end
	local roleProxy = self:getProxy(GameProxys.Role)
    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
    if self.PriceAry[10] > curNum then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end
    else
    	local function sureFun()
			local sendData = {}
			sendData.activityId = self.myData.activityId
			sendData.draftType = 10
			if self.lockStatus == true then
				sendData.lockType = self.lastSoldierTypeId
			end
			self.finish = false
			self.proxy:onTriggerNet230045Req(sendData)
    	end
    	local messageBox = self:showMessageBox(string.format(self:getTextWord(450003),self.PriceAry[10]),sureFun)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
    end

end
--锁定
function LionTurntablePanel:onLockBtnHandler(sender)
	if self.canLock ~= true then
		self:showSysMessage(self:getTextWord(450001))
		return
	end
	if self.circleImgRotating == true then
		self:showSysMessage(self:getTextWord(450002))
		return
	end
	-- logger:info("onLockBtnHandler")
	local rotateInnerNum = self.innerCircle:getRotation()
	local staticAngle,staticTag = self.returnExactAngleAndTag(rotateInnerNum)
	-- self.innerCircle:setRotation(staticAngle)
	if self.lockStatus == false then
		-- logger:info("onLockBtnHandler--lockStatus == false")
		local callfunc = cc.CallFunc:create(function()
		self.innerCircle:setRotation(staticAngle)
		end)
		self.innerCircle:stopAllActions()
		self.innerCircle:setRotation(staticAngle)

		local scalefunc = cc.CallFunc:create(function()
			for i=1,4 do
				if i ~= staticTag then
					local img = self:getChildByName("topPanel/mainPanel/innerTurnPanel/img" .. i)
                    TextureManager:updateImageView(img, "images/lionTurntable/neipan2.png")
					img:setColor(cc.c3b(128,128,128))
					local scaleTo = cc.ScaleTo:create(0.1, 0.95)
					img:runAction(scaleTo)
				end
			end
		end)
		local endCallFunc = cc.CallFunc:create(function ()
			--修改价格
			local extraPriceAry = StringUtils:jsonDecode(self.lionTurnConfig.extraPrice)
			self.PriceAry[extraPriceAry[1][1]] = extraPriceAry[1][2]
			self.PriceAry[extraPriceAry[2][1]] = extraPriceAry[2][2]
			self:setBtnPrice()
			--按钮上的图改成解锁
			local lockBtnImg = self:getChildByName("topPanel/mainPanel/LockBtn/btnImg")
			local unlockImgUrl = "images/lionTurntable/unlock.png"
			TextureManager:updateImageView(lockBtnImg, unlockImgUrl)
			--状态改变
			self.lockStatus = true
		end)
		local lockImg = self:getChildByName("topPanel/mainPanel/LockImg")
		local moveby = cc.MoveBy:create(0.1, cc.p(0,40))
		local scaleTo = cc.ScaleTo:create(0.1, 0.95)

	    local action = cc.Sequence:create(moveby,scalefunc,scaleTo,endCallFunc)
	        
	    lockImg:runAction(action)

	
	elseif self.lockStatus == true then
		-- logger:info("onLockBtnHandler--lockStatus == true")
		local scalefunc = cc.CallFunc:create(function()
			for i=1,4 do
				if i ~= staticTag then
					-- logger:info(i)
					local img = self:getChildByName("topPanel/mainPanel/innerTurnPanel/img" .. i)
                    TextureManager:updateImageView(img, "images/lionTurntable/neipan.png")
					local scaleTo = cc.ScaleTo:create(0.1, 1)
					img:setColor(cc.c3b(255,255,255))
					img:runAction(scaleTo)
				end
			end
		end)
		local lockImg = self:getChildByName("topPanel/mainPanel/LockImg")
		local moveby = cc.MoveBy:create(0.2, cc.p(0,-40))
		local scaleTo = cc.ScaleTo:create(0.1, 1)
		local endCallFunc = cc.CallFunc:create(function ()
			--修改价格
			local commonPriceAry = StringUtils:jsonDecode(self.lionTurnConfig.commonPrice)
			self.PriceAry[commonPriceAry[1][1]] = commonPriceAry[1][2]
			self.PriceAry[commonPriceAry[2][1]] = commonPriceAry[2][2]
			self:setBtnPrice()
			--按钮上的图改成解锁
			local lockBtnImg = self:getChildByName("topPanel/mainPanel/LockBtn/btnImg")
			local unlockImgUrl = "images/lionTurntable/lock.png"
			TextureManager:updateImageView(lockBtnImg, unlockImgUrl)
			--状态改变
			self.lockStatus = false
            self:rotateInnerCircle(0.8)
		end)
	    local action = cc.Sequence:create(moveby,scalefunc,scaleTo,endCallFunc)
	        
	    lockImg:runAction(action)

	end
end
--根据现在的角度获取固定位置的角度和位置标记(计算内环)
function LionTurntablePanel.returnExactAngleAndTag( nowAngle )
	if nowAngle < 0 then
		local angle = nowAngle%-360
		if angle > -45 then
			return 0,1
		elseif angle > -135 then
			return -90,2
		elseif angle > -225 then
			return -180,3
		elseif angle > -315 then
			return -270,4
		else
			return 0,1
		end
	else
		local angle = nowAngle%360
		if angle < 45 then
			return 0,1
		elseif angle < 135 then
			return 90,4
		elseif angle < 225 then
			return 180,3
		elseif angle < 315 then
			return 270,2
		else
			return 0,1
		end
	end

end

--征召协议返回通知
function LionTurntablePanel:afterConscript(data)
	--外圈需要停在的准确角度
	self.exactAngle = 0
	if data.soldierNum == 1 then
		self.exactAngle = 0
	elseif data.soldierNum == 3 then
		self.exactAngle = 240
	elseif data.soldierNum == 5 then
		self.exactAngle = 120
	end
	--内圈需要停在的准确角度
	-- logger:info("----------------------")
	-- logger:info(self.soldierAry[data.lastSoldierType])
	-- logger:info(data.lastSoldierType)
	-- logger:info("----------------------")
	self.exactInnerAngle = 0
	if self.soldierAry[data.lastSoldierType] == 1 then
		self.exactInnerAngle = 0
	elseif self.soldierAry[data.lastSoldierType] == 2 then
		self.exactInnerAngle = -90
	elseif self.soldierAry[data.lastSoldierType] == 3 then
		self.exactInnerAngle = -180
	elseif self.soldierAry[data.lastSoldierType] == 4 then
		self.exactInnerAngle = -270
	end
	--存储本次的奖励
	local rewardInfo = {}
	rewardInfo.power = GamePowerConfig.Soldier
	rewardInfo.typeid = data.lastSoldierType
	rewardInfo.num = data.soldierNum * data.draftType
	self.rewardInfo = rewardInfo
	self.afterConscriptTag = true

	local function handler()
	end
	self.effectQueueManager = true
	EffectQueueManager:addEffect(EffectQueueType.TREASURE_ADVANCE, handler,nil,false)

end
--根据内圈位置编号返回应该转动的角度
function LionTurntablePanel:getInnerAngleByPos(pos)
	if pos == 1 then
		return 0
	elseif pos == 2 then
		return -90
	elseif pos == 3 then
		return -180
	else
		return -270
	end
end
function LionTurntablePanel:timestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
	local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return tab.year .. self:getTextWord(420005) .. tab.month .. self:getTextWord(420006) .. tab.day .. self:getTextWord(420007) .. hour ..":".. min
end
--根据self.PriceAry修改按钮上的元宝价格
function LionTurntablePanel:setBtnPrice()
	local onceNumLab = self:getChildByName("topPanel/mainPanel/btnPanel/onceBtnPanel/numLab")
	onceNumLab:setString(self.PriceAry[1])
	local tenNumLab = self:getChildByName("topPanel/mainPanel/btnPanel/tenBtnPanel/numLab")
	tenNumLab:setString(self.PriceAry[10])
end

function LionTurntablePanel:showReward()
	if (not self.rewardInfo) then return end

	local parent = self:getParent()
	function callback()
		self.circleImg:stopAllActions()
		local action = cc.Sequence:create(cc.RotateBy:create(0.1, 0.5) ,cc.CallFunc:create(function()
			self:rotateBg()
            if self._EffectOver then
                self._EffectOver:finalize()
                self._EffectOver = nil
            end
		end))
		self.circleImg:runAction(action)
		if self.effectQueueManager == true then
			EffectQueueManager:completeEffect()
			self.effectQueueManager = false
		end
	end
	if not self.uiResourceGet then
		self.uiResourceGet = UIGetProp.new(parent, self, true, callback)
	end
	local rewardData = {}
	table.insert(rewardData, self.rewardInfo)
	self.uiResourceGet:show(rewardData, callback)
end
