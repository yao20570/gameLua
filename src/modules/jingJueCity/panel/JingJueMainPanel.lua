-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-22
--  * @Description: 限时活动_精绝古城_女王馈赠
--  */
JingJueMainPanel = class("JingJueMainPanel", BasicPanel)
JingJueMainPanel.NAME = "JingJueMainPanel"

function JingJueMainPanel:ctor(view, panelName)
    JingJueMainPanel.super.ctor(self, view, panelName)

end

function JingJueMainPanel:finalize()
	if self.bgEffect ~= nil then
		self.bgEffect:finalize()
		self.bgEffect = nil
	end
    JingJueMainPanel.super.finalize(self)
end

function JingJueMainPanel:initPanel()
	JingJueMainPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Activity)
	--记录状态 1初次进或重置后 2已经单次开启过且还没全部点完 3点击了全部开启后 4点击了单次开启却没有点开奖励特殊状态
	self.status = 0
	--触摸屏蔽层
	self.coverPanel = self:getChildByName("topPanel/coverPanel")
	-- self.coverPanel:setVisible(false)
	-- self.coverPanel:setEnabled(false)
	self.maskPanel = self:getChildByName("topPanel/mainPanel/maskPanel")
	--存特效
	self.onePosEffectTable = {}
	--活动描述
	local descLab = self:getChildByName("topPanel/headPanel/descLab")
	descLab:setString(string.format("%s\n%s", self:getTextWord(460003),self:getTextWord(260006)))
    descLab:setColor(cc.c3b(244,244,244))
	-- descLab:setString(self:getTextWord(460003))

end
function JingJueMainPanel:onShowHandler()
	--[[
	-- local mainPanel = self:getChildByName("topPanel/mainPanel")
	local doorImg5 = self:getChildByName("topPanel/mainPanel/doorImgPanel/doorImg5")
	local aEffect = self:createUICCBLayer("rgb-jjgc-qian", doorImg5, nil, nil, true)
    local size = doorImg5:getContentSize()
    aEffect:setPosition(size.width*0.5,size.height*0)
    aEffect:setLocalZOrder(10)
    --]]

	self:updateJingJueView()

end
function JingJueMainPanel:updateJingJueView()
	self.isUpdate = true
	--获得获得数据
	self.myData = self.proxy:getCurActivityData()

	local jingJueInfo = self.proxy:getJingJueInfoById(self.myData.activityId)
	self.jsonConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.TombCityConfig, "effectID", self.myData.effectId)
	--已经开启了多少个位置
	local openNum = self.proxy:getJingJueCurOpenNum(self.myData.activityId)
	--状态判断逻辑
	if jingJueInfo.buy == 1 then
		--点击了单次，已扣费状态（去掉蒙板）
		self.status = 4
	else
		
		-- logger:info(openNum)
		if openNum == 0 then
			self.status = 1
		elseif openNum >= 9 then
			self.status = 3
		else
			self.status = 2
		end

	end
	--显示还能点多少次单次开启
	local timeLab = self:getChildByName("topPanel/mainPanel/timeLab")
	local remainNum = self.jsonConfig.upperLimit - openNum
	remainNum = remainNum > 0 and remainNum or 0
	timeLab:setString(remainNum)
	--按钮上免费字样显示控制
	local freeTime = self.proxy:getJingJueFreeTime(self.myData.activityId)
	--蒙板已经按钮控制
	self:setFuncBtnShowStatus( self.status ,freeTime)
	--活动时间
	local timeDescLab = self:getChildByName("topPanel/headPanel/timeDescLab")
	-- local startTime = self:timestampToString(self.myData.startTime - 1)
	-- local endTime = self:timestampToString(self.myData.endTime - 1)
	-- if startTime == 0 or endTime == 0 then
	-- 	timeDescLab:setString("")
	-- else
		timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
		-- timeDescLab:setString(string.format("%s%s%s%s", self:getTextWord(392006),startTime,self:getTextWord(392008),endTime))
	-- end
	--按钮上的价格
	local pos2numPanelLab = self:getChildByName("topPanel/mainPanel/maskPanel/pos2/numPanel/lab")
	local pos1numPanelLab = self:getChildByName("topPanel/mainPanel/maskPanel/pos1/numPanel/lab")
	local pos3numPanelLab = self:getChildByName("topPanel/mainPanel/maskPanel/pos3/numPanel/lab")
	--单次价格
	pos2numPanelLab:setString(self.jsonConfig.onePrice)
	pos1numPanelLab:setString(self.jsonConfig.onePrice)
	pos3numPanelLab:setString(self.jsonConfig.allPrice)

	--四个奖励预览
	local rewardShowjson =  self.jsonConfig.rewardShow
    local rewardAry = StringUtils:jsonDecode(rewardShowjson)

    for i=1,4 do
		local rewardImg = self:getChildByName("topPanel/mainPanel/infoPanel/rewardImg" .. i)
	    local iconData = {}
	    iconData.typeid = rewardAry[i][2]
	    iconData.num = rewardAry[i][3]
	    iconData.power = rewardAry[i][1]
	    if rewardImg.uiIcon == nil then
	        rewardImg.uiIcon = UIIcon.new(rewardImg,iconData,true,self,nil,true)
	    else
	        rewardImg.uiIcon:updateData(iconData)
	    end
    end
	--存储开启的门
	self.OpenDoorAry = {} 
	--已经开启的门的icon显示
	local doorImgPanel = self:getChildByName("topPanel/mainPanel/doorImgPanel")
	for k,val in pairs(jingJueInfo.itemList) do
		if val.pos ~= 0 then
			local pos = val.pos
			self.OpenDoorAry[pos] = val
			--隐藏门
			local doorImg = self:getChildByName("topPanel/mainPanel/doorImgPanel/doorImg" .. pos)
			doorImg:setVisible(false)
			local doorIcon = self:getChildByName("topPanel/mainPanel/doorIconPanel/doorIcon" .. pos)
			local doorIconSize = doorIcon:getContentSize()
		    if doorIcon.uiIcon == nil then
		        doorIcon.uiIcon = UIIcon.new(doorIcon,val.rewardInfo,true,self,nil,true)
				doorIcon.uiIcon:setPosition(doorIconSize.width*0.5,doorIconSize.height*0.84)
		    else
		        doorIcon.uiIcon:updateData(val.rewardInfo)
		    end
		end
	
	end
	for i=1,9 do
		if self.OpenDoorAry[i] == nil then
			local doorImg = self:getChildByName("topPanel/mainPanel/doorImgPanel/doorImg" .. i)
			doorImg:setVisible(true)
			local doorIcon = self:getChildByName("topPanel/mainPanel/doorIconPanel/doorIcon" .. i)
		    if doorIcon.uiIcon ~= nil then
		        doorIcon.uiIcon:finalize()
		        doorIcon.uiIcon = nil
		    end
		end
	end


	--如果闪烁屏蔽层可视，关掉
	local coverVisible = self.coverPanel:isVisible()
	if coverVisible == true then
		self:onCoverPanelHandler()
	end
	--每次都清掉
	--清除九个icon
	for i=1,9 do
		local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. i)
		if rewardPos.uiIcon ~= nil then
			rewardPos.uiIcon:finalize()
			rewardPos.uiIcon = nil
		end
	end
	--恢复无全开特效
	self.allOpenEffeting = false
	--循环背景特效
	local doorIconPanel = self:getChildByName("topPanel/mainPanel/doorIconPanel")
	if self.bgEffect == nil then
		local size = doorIconPanel:getContentSize()
		self.bgEffect = self:createUICCBLayer("rgb-jjgc-daiji", doorIconPanel)
		self.bgEffect:setPosition(size.width*0.45,size.height*0.9)
	end


end

function JingJueMainPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, tabsPanel, 3)
end

function JingJueMainPanel:registerEvents()
	JingJueMainPanel.super.registerEvents(self)
	for i=1,3 do
		local btn = self:getChildByName("topPanel/mainPanel/maskPanel/pos" .. i .. "/btn")
		btn.tag = i
		self:addTouchEventListener(btn, self.onFunBtnHandler,nil,nil,500)
	end
	for i=1,9 do
		local touchPos = self:getChildByName("topPanel/mainPanel/doorImgPanel/touchPos" .. i)
		touchPos.tag = i
		self:addTouchEventListener(touchPos, self.onDoorTouchHandler,nil,nil,1000)
	end
	local coverPanel = self:getChildByName("topPanel/coverPanel")
	self:addTouchEventListener(coverPanel, self.onCoverPanelHandler)
	--新的紅色重置按鈕
	local resetBtn = self:getChildByName("topPanel/mainPanel/maskPanel/pos4/resetBtn")
	resetBtn.tag = 4
	self:addTouchEventListener(resetBtn, self.onFunBtnHandler,nil,nil,500)
end
--根据状态显示蒙板上按钮的显示状态（1初次进或重置后 2已经单次开启过且还没全部点完 3点击了全部开启后 4点击了单次开启却没有点开奖励特殊状态）
function JingJueMainPanel:setFuncBtnShowStatus( statusNum ,freeTime)
	local maskPanel = self:getChildByName("topPanel/mainPanel/maskPanel")
	if statusNum == 4 then
		maskPanel:setVisible(false)
		local tipsLab = self:getChildByName("topPanel/mainPanel/tipsLab")
		tipsLab:setString(self:getTextWord(460011))
		tipsLab:setVisible(true)
		--一闪一闪提示
		tipsLab:stopAllActions()
		local action1 = cc.FadeIn:create(1)
		local action2 = cc.FadeOut:create(1)
		tipsLab:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
		--预览的四个奖励也隐藏掉
		local infoPanel = self:getChildByName("topPanel/mainPanel/infoPanel")
		infoPanel:setVisible(false)
		return
	end
	local tipsLab = self:getChildByName("topPanel/mainPanel/tipsLab")
	tipsLab:setVisible(false)
	maskPanel:setVisible(true)
	local infoPanel = self:getChildByName("topPanel/mainPanel/infoPanel")
	infoPanel:setVisible(true)


	local pos1 = self:getChildByName("topPanel/mainPanel/maskPanel/pos1")
	local pos2 = self:getChildByName("topPanel/mainPanel/maskPanel/pos2")
	local pos3 = self:getChildByName("topPanel/mainPanel/maskPanel/pos3")
	local pos1numPanel = self:getChildByName("topPanel/mainPanel/maskPanel/pos1/numPanel")
	local pos2numPanel = self:getChildByName("topPanel/mainPanel/maskPanel/pos2/numPanel")
	local btn2 = self:getChildByName("topPanel/mainPanel/maskPanel/pos2/btn")
	local pos1freeLab = self:getChildByName("topPanel/mainPanel/maskPanel/pos1/freeLab")
	local pos2freeLab = self:getChildByName("topPanel/mainPanel/maskPanel/pos2/freeLab")
	local pos4 = self:getChildByName("topPanel/mainPanel/maskPanel/pos4")
	if statusNum == 1 then
		pos1:setVisible(false)
		pos3:setVisible(false)
		btn2:setTitleText(self:getTextWord(460004))
		pos2numPanel:setVisible(true)
		pos4:setVisible(false)

		pos2numPanel:setVisible(freeTime <= 0)
		pos2freeLab:setVisible(freeTime > 0)
	elseif statusNum == 2 then
		pos1:setVisible(true)
		pos3:setVisible(true)
		btn2:setTitleText(self:getTextWord(460005))
		pos2numPanel:setVisible(false)
		pos2freeLab:setVisible(false)
		pos4:setVisible(true)

		pos1numPanel:setVisible(freeTime <= 0)
		pos1freeLab:setVisible(freeTime > 0)
	elseif statusNum == 3 then
		pos1:setVisible(false)
		pos3:setVisible(false)
		btn2:setTitleText(self:getTextWord(460005))
		pos2numPanel:setVisible(false)
		pos4:setVisible(true)
	end
end
function JingJueMainPanel:onFunBtnHandler(sender)
	-- logger:info(sender.tag)
	if self.status == 1 and sender.tag == 2 then
		--点击了中间按钮单次开启
		self:sendSeverOpenOne()
        return
	end
    if sender.tag == 1 then
        --左边单次开启按钮
        self:sendSeverOpenOne()
    elseif sender.tag == 3 then
        --右边全部开启按钮
        self:sendSeverOpenAll()
	elseif sender.tag == 2 or sender.tag == 4 then
		--重置
	    local sendData = {}
        sendData.activityId = self.myData.activityId
		self.proxy:onTriggerNet230048Req(sendData)
    end
end
function JingJueMainPanel:sendSeverOpenOne()
	local freeTime = self.proxy:getJingJueFreeTime(self.myData.activityId)
	if freeTime > 0 then
		local sendData = {}
		sendData.activityId = self.myData.activityId
		self.proxy:onTriggerNet230046Req(sendData)
	else
    	local roleProxy = self:getProxy(GameProxys.Role)
	    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
	    if self.jsonConfig.onePrice > curNum then
	        local parent = self:getParent()
	        local panel = parent.panel
	        if panel == nil then
	            local panel = UIRecharge.new(parent, self)
	            parent.panel = panel
	        else
	            panel:show()
	        end
	    else
	    	local openNum = self.proxy:getJingJueCurOpenNum(self.myData.activityId)
			local remainNum = self.jsonConfig.upperLimit - openNum
	    	if remainNum > 0 then
	        	local function sureFun()
					local sendData = {}
					sendData.activityId = self.myData.activityId
					self.proxy:onTriggerNet230046Req(sendData)
	        	end
	        	local messageBox = self:showMessageBox(string.format(self:getTextWord(460009),self.jsonConfig.onePrice),sureFun)
	        	messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	        else
				self:showSysMessage(self:getTextWord(460012))
	    	end

	    end
	end

end
function JingJueMainPanel:sendSeverOpenAll()
	local roleProxy = self:getProxy(GameProxys.Role)
    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
    if self.jsonConfig.allPrice > curNum then
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
		    sendData.type = 1
			self.proxy:onTriggerNet230047Req(sendData)
    	end
    	local messageBox = self:showMessageBox(string.format(self:getTextWord(460010),self.jsonConfig.allPrice),sureFun)
    	messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
    end
end
function JingJueMainPanel:onDoorTouchHandler(sender)
	if self.allOpenEffeting == true then
		return
	end
	--对应的门没了
	local doorImg = self:getChildByName("topPanel/mainPanel/doorImgPanel/doorImg" .. sender.tag)
	local doorVisible = doorImg:isVisible()
	if doorVisible == false then
		return
	end
	--点了单抽协议没返回
	if self.touchOneDoor == true then
		return
	end
	local maskPanel = self:getChildByName("topPanel/mainPanel/maskPanel")
	local visible = maskPanel:isVisible()
	if visible == true then
		return
	end
	-- logger:info("onDoorImgHandler")
	-- logger:info(sender.tag)
	local sendData = {}
    sendData.activityId = self.myData.activityId
    sendData.type = 0
    sendData.pos = sender.tag
	self.proxy:onTriggerNet230047Req(sendData)
	self.touchOneDoor = true
end
-- 精绝古城单次或全部开启后通知
function JingJueMainPanel:afterOpen(itemList)
	local itemList = clone(itemList)
	--判断是单抽还是全抽取
    local openNum = 0
    for _,val in pairs(itemList) do
        if val.pos > 0 then
            openNum = openNum + 1
        end
    end
    if openNum >= 9 then
    	--全抽
    	self.maskPanel:setVisible(false)
    	--记录旧数据已开次数
		self.gotNum = 0
		self.isUpdate = false
		for k,v in pairs(self.OpenDoorAry) do
			self.gotNum = self.gotNum + 1
		end
		--点了全部直接显示特效了
		self.allOpenEffeting = true
		self.openOneIndex = 1
		self.endIndex = 0
		self.effectTable = {}
		--记录新的奖励
		local jingJueInfo = self.proxy:getJingJueInfoById(self.myData.activityId)
		self.allShowRewardList = {}
	    for k,val in pairs(jingJueInfo.itemList) do
	    	if self.OpenDoorAry[val.pos] == nil then
	    		table.insert(self.allShowRewardList,val.rewardInfo)
	    	end
	    end
		local infoPanel = self:getChildByName("topPanel/mainPanel/infoPanel")
		infoPanel:setVisible(false)
		TimerManager:add(100, self.openOne, self, 9)
    else
    	--单抽
		self:afterOpenOnePos(itemList)

    end
	--[[
	if serverData.time == 1 then
		--点了单次后打开蒙板让玩家点击九个门
		logger:info("one")
	local maskPanel = self:getChildByName("topPanel/mainPanel/maskPanel")
	maskPanel:setVisible(false)
	self.coverPanel:setVisible(false)
	self.coverPanel:setEnabled(false)

	elseif serverData.time == 9 then
		--点了全部直接显示特效了
		self.openOneIndex = 1
		self.effectTable = {}
		TimerManager:add(100, self.openOne, self, 9)
		--屏蔽门触摸
		self.coverPanel:setVisible(true)
		self.coverPanel:setEnabled(true)
	end
	--]]
end
--点击了某个门，协议返回奖励，特效显示(单次开启)
function JingJueMainPanel:afterOpenOnePos(itemList)
	--屏蔽单击门的提示
	local doorTipsLab = self:getChildByName("topPanel/mainPanel/tipsLab")
	doorTipsLab:stopAllActions()
	doorTipsLab:setVisible(false)

	--本次开了哪个门位置
	local curOpenPosInfo = {}
    for _,val in pairs(itemList) do
        if val.pos > 0 and self.OpenDoorAry[val.pos] == nil then
            curOpenPosInfo.pos = val.pos
            curOpenPosInfo.rewardInfo = val.rewardInfo
            break
        end
    end
    --数据处理，把pos位0的物品依次分配pos
    local posInfoMap = {}
    for _,val in ipairs(itemList) do
    	if val.pos ~= 0 then
    		posInfoMap[val.pos] = val.rewardInfo
    	end
    end
	for i=1,9 do
		if posInfoMap[i] == nil then
			for k,val in pairs(itemList) do
				if val.pos == 0 then
					val.pos = i
					posInfoMap[i] = val.rewardInfo
					break
				end
			end
		end
	end

	self.openOnePos = true


	local mainPanel = self:getChildByName("topPanel/mainPanel")
	--隐藏本来门图片
	local pos = curOpenPosInfo.pos
	local doorImg = self:getChildByName("topPanel/mainPanel/doorImgPanel/doorImg" .. pos)
	doorImg:setVisible(false)
	--门抖动特效（最底层）
	local effectPos = self:getChildByName("topPanel/mainPanel/doorEffectPanel/effectPos" .. pos)
	local houEffect = self:createUICCBLayer("rgb-jjgc-hou", effectPos, nil, nil, true)
    local size = effectPos:getContentSize()
    houEffect:setPosition(size.width*0.47,size.height*0.5)
    --门前闪光（中间层）
	local qianEffect = self:createUICCBLayer("rgb-jjgc-qian", mainPanel, nil, nil, true)
	local effectPosX,effectPosY = effectPos:getPosition()
    qianEffect:setPosition(effectPosX+size.width*0.47,effectPosY+size.height*0.5 - 22)
    qianEffect:setLocalZOrder(3)

    --弹出物品特效
	local owner = {}
	owner["pause"] = function() 
		-- logger:info("wupinPause")
		--[[
		local rewardPanel = self:getChildByName("topPanel/mainPanel/rewardPanel")

		local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. pos)
		local rewardSize = rewardPos:getContentSize()
		if rewardPos.uiIcon == nil then
			rewardPos.uiIcon = UIIcon.new(rewardPos,curOpenPosInfo.rewardInfo,false, self)
			rewardPos.uiIcon:setPosition(rewardSize.width*0.5,rewardSize.height*0.84)
		else
			rewardPos.uiIcon:updateData(curOpenPosInfo.rewardInfo)
		end
		--]]

		local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. pos)
		local rewardSize = rewardPos:getContentSize()
		if rewardPos.uiIcon == nil then
			rewardPos.uiIcon = UIIcon.new(rewardPos,posInfoMap[pos],true,nil,nil,true)
			rewardPos.uiIcon:setPosition(rewardSize.width*0.5,rewardSize.height*0.84)
		else
			rewardPos.uiIcon:updateData(posInfoMap[pos])
		end

		self.openOnePos = false
	end
	owner["pause02"] = function() 
		--九个位置全部显示
		local maskVi = self.maskPanel:isVisible()
		if maskVi ~= true then
			for i=1,9 do
				local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. i)
				local rewardSize = rewardPos:getContentSize()
				if rewardPos.uiIcon == nil then
					rewardPos.uiIcon = UIIcon.new(rewardPos,posInfoMap[i],true,nil,nil,true)
					rewardPos.uiIcon:setPosition(rewardSize.width*0.5,rewardSize.height*0.84)
				else
					rewardPos.uiIcon:updateData(posInfoMap[i])
				end
				if i ~= curOpenPosInfo.pos and self.OpenDoorAry[i] == nil then
					-- rewardPos.uiIcon._iconBg:setColor(cc.c3b(100,100,100))
					if rewardPos.uiIcon._imgBg then
						rewardPos.uiIcon._imgBg:setColor(cc.c3b(100,100,100))
					end
				end
			end
			self.coverPanel:setVisible(true)
			self.coverPanel:setEnabled(true)
			local tipsLab = self:getChildByName("topPanel/coverPanel/tipsLab")
			tipsLab:setVisible(true)
			local action1 = cc.FadeIn:create(1)
			local action2 = cc.FadeOut:create(1)
			tipsLab:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))

			
			--单抽飘奖励
	    	local data = {}
	    	data.rewards = {}
	    	table.insert(data.rewards, posInfoMap[pos]) 
	    	AnimationFactory:playAnimationByName("BagFreshFly", data)
		end

	end
	owner["complete"] = function()
		self.touchOneDoor = false

		if self.onePosEffectTable[1] then
			self.onePosEffectTable[1]:finalize()
			table.remove(self.onePosEffectTable,1)
			--清除九个icon
			-- for i=1,9 do
			-- 	local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. i)
			-- 	if rewardPos.uiIcon ~= nil then
			-- 		rewardPos.uiIcon:finalize()
			-- 		rewardPos.uiIcon = nil
			-- 	end
			-- end
			-- self:updateJingJueView()
			--物品获取
		 --    local rewardList = {}
			-- table.insert(rewardList,curOpenPosInfo.rewardInfo)
			-- AnimationFactory:playAnimationByName("GetGoodsEffect", rewardList)
		end	
	end
	local wupinEffect = self:createUICCBLayer("rgb-jjgc-wupin", mainPanel, owner)
	wupinEffect:setPosition(effectPosX+size.width*0.47,effectPosY+size.height*0.5 - 20)
	wupinEffect:setLocalZOrder(7)
	table.insert(self.onePosEffectTable, wupinEffect)
	
end
--全开的时候会调用本方法九次
function JingJueMainPanel:openOne()
	if self.OpenDoorAry[self.openOneIndex] == nil  then
		local mainPanel = self:getChildByName("topPanel/mainPanel")
		--隐藏本来门图片
		local pos = self.openOneIndex
		local doorImg = self:getChildByName("topPanel/mainPanel/doorImgPanel/doorImg" .. pos)
		doorImg:setVisible(false)
		--门抖动特效（最底层）
		local effectPos = self:getChildByName("topPanel/mainPanel/doorEffectPanel/effectPos" .. pos)
		local houEffect = self:createUICCBLayer("rgb-jjgc-hou", effectPos, nil, nil, true)
	    local size = effectPos:getContentSize()
	    houEffect:setPosition(size.width*0.47,size.height*0.5)
	    --门前闪光（中间层）
		local qianEffect = self:createUICCBLayer("rgb-jjgc-qian", mainPanel, nil, nil, true)
		local effectPosX,effectPosY = effectPos:getPosition()
	    qianEffect:setPosition(effectPosX+size.width*0.47,effectPosY+size.height*0.5 - 22)
	    qianEffect:setLocalZOrder(3)

	    --弹出物品特效
		local owner = {}
		owner["pause"] = function() 
			-- logger:info("wupinPause")
			local jingJueInfo = self.proxy:getJingJueInfoById(self.myData.activityId)
		    local tempData
		    for k,val in pairs(jingJueInfo.itemList) do
		    	if val.pos == pos  then
		    		tempData = val.rewardInfo
		    		break
		    	end
		    end
			local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. pos)
			local rewardSize = rewardPos:getContentSize()
			if rewardPos.uiIcon == nil then
				rewardPos.uiIcon = UIIcon.new(rewardPos,tempData,true,self,nil,true)
				rewardPos.uiIcon:setPosition(rewardSize.width*0.5,rewardSize.height*0.84)
			else
				rewardPos.uiIcon:updateData(tempData)
			end

			self.endIndex = self.endIndex + 1
			if self.endIndex >= (9-self.gotNum) then
				if self.isUpdate == false then
					self.coverPanel:setVisible(true)
					self.coverPanel:setEnabled(true)
					local tipsLab = self:getChildByName("topPanel/coverPanel/tipsLab")
					tipsLab:setVisible(true)
					local action1 = cc.FadeIn:create(1)
					local action2 = cc.FadeOut:create(1)
					tipsLab:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
				end
	
				--icon弹出完毕显示奖励获得
				--获得物品特效
			    if #self.allShowRewardList ~= 0 then
			    	local data = {}
			    	data.rewards = self.allShowRewardList
			    	AnimationFactory:playAnimationByName("BagFreshFly", data)
			    end
				self.allOpenEffeting = false
			end

		end
		owner["pause02"] = function() 

		end

		owner["complete"] = function()
			-- logger:info("wupinComplete")
			if self.effectTable[1] then
				self.effectTable[1]:finalize()
				table.remove(self.effectTable,1)
			end

			
		end

		local wupinEffect  =  self:createUICCBLayer("rgb-jjgc-wupin", mainPanel, owner)
	   	wupinEffect:setPosition(effectPosX+size.width*0.47,effectPosY+size.height*0.5 - 20)
	    wupinEffect:setLocalZOrder(7)
	    table.insert(self.effectTable, wupinEffect)
	end

	

	self.openOneIndex = self.openOneIndex + 1
	if self.openOneIndex > 9 then
		-- logger:info(self.openOneIndex)
		-- self.coverPanel:setVisible(true)
		-- self.coverPanel:setEnabled(true)
		-- local tipsLab = self:getChildByName("topPanel/coverPanel/tipsLab")
		-- tipsLab:setVisible(true)
		-- local action1 = cc.FadeIn:create(1)
		-- local action2 = cc.FadeOut:create(1)
		-- tipsLab:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
	end
end

function JingJueMainPanel:onCoverPanelHandler( sender )
	if self.allOpenEffeting == true then
		return
	end
	if self.openOnePos == true then
		return
	end
	-- logger:info("onCoverPanelHandler")
	self:hideCoverPanel()
	--清除九个icon
	for i=1,9 do
		local rewardPos = self:getChildByName("topPanel/mainPanel/rewardPanel/rewardPos" .. i)
		if rewardPos.uiIcon ~= nil then
			rewardPos.uiIcon:finalize()
			rewardPos.uiIcon = nil
		end
	end
	self:updateJingJueView()

end
--屏蔽门触摸层
function JingJueMainPanel:hideCoverPanel()
	local tipsLab = self:getChildByName("topPanel/coverPanel/tipsLab")
	tipsLab:stopAllActions()
	tipsLab:setVisible(false)

	self.coverPanel:setVisible(false)
	self.coverPanel:setEnabled(false)
end

function JingJueMainPanel:timestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
	local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return tab.year .. self:getTextWord(392009) .. tab.month .. self:getTextWord(392010) .. tab.day .. self:getTextWord(392011) .. hour ..":".. min
end

function JingJueMainPanel:openSeverback()
	self.touchOneDoor = false
end