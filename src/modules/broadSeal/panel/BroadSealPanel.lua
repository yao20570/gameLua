-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-06
--  * @Description: 限时活动-国之重器
--  */
BroadSealPanel = class("BroadSealPanel", BasicPanel)
BroadSealPanel.NAME = "BroadSealPanel"

function BroadSealPanel:ctor(view, panelName)
    BroadSealPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function BroadSealPanel:finalize()
	if self.ComposeBtnEffect ~= nil then
        self.ComposeBtnEffect:finalize()
        self.ComposeBtnEffect = nil
	end
    if self._uiSoldierInfo ~= nil then
        self._uiSoldierInfo:finalize()
        self._uiSoldierInfo = nil
    end
    BroadSealPanel.super.finalize(self)
end
function BroadSealPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local topAdaptivePanel = self:topAdaptivePanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, topAdaptivePanel)

    local freeLab = self:getChildByName("topPanel/onceBtnPanel/freeLab")
    
    local onceBtnPanel=topPanel:getChildByName("onceBtnPanel")
    local once_Btn=onceBtnPanel:getChildByName("btn")
    local once_icon=onceBtnPanel:getChildByName("iconImg")
    local once_num=onceBtnPanel:getChildByName("numLab")
    NodeUtils:centerNodes(once_Btn, {once_icon,once_num})

    local tenBtnPanel=topPanel:getChildByName("tenBtnPanel")
    local ten_Btn=tenBtnPanel:getChildByName("btn")
    local ten_icon=tenBtnPanel:getChildByName("iconImg")
    local ten_num=tenBtnPanel:getChildByName("numLab")
    NodeUtils:centerNodes(ten_Btn, {ten_icon,ten_num})

    freeLab:setPositionX(once_Btn:getPositionX())
end

function BroadSealPanel:initPanel()
	BroadSealPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true, "broadSeal", true)
	self:setBgType(ModulePanelBgType.ACTIVITY)
	self.proxy = self:getProxy(GameProxys.Activity)
	local descLab = self:getChildByName("topPanel/infoPanel/descLab")
	descLab:setString(self:getTextWord(440000))
    --descLab:setFontSize(18)	
end

function BroadSealPanel:registerEvents()
	BroadSealPanel.super.registerEvents(self)
	for i=1,9 do
		local touch = self:getChildByName("topPanel/composePanel/segmentPanel/touch" .. i)
		touch.tag = i 
		self:addTouchEventListener(touch,self.segmentTouchHandler)
	end
	local composeBtn = self:getChildByName("topPanel/composePanel/composeBtn")
	self:addTouchEventListener(composeBtn,self.composeBtnHandler)
	local onceBtn = self:getChildByName("topPanel/onceBtnPanel/btn")
	self:addTouchEventListener(onceBtn,self.onceBtnHandler)
	local tenBtn = self:getChildByName("topPanel/tenBtnPanel/btn")
	self:addTouchEventListener(tenBtn,self.tenBtnHandler)
	local tipsBtn = self:getChildByName("topPanel/composePanel/tipsBtn")
	self:addTouchEventListener(tipsBtn,self.tipsBtnHandler)
end
function BroadSealPanel:onShowHandler()
	self:updateBroadSealView()
end
function BroadSealPanel:updateBroadSealView()
	self.myData = self.proxy:getCurActivityData()
	local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", self.myData.effectId)
	local broadSealInfo = self.proxy:getBroadSealInfobyId(self.myData.activityId)
	--活动时间与描述
	local timeDescLab = self:getChildByName("topPanel/infoPanel/timeDescLab")
	-- local startTime = self:timestampToString(self.myData.startTime)
	-- local endTime = self:timestampToString(self.myData.endTime)
	-- if startTime == 0 or endTime == 0 then
	-- 	timeDescLab:setString("")
	-- else
		timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
	-- 	timeDescLab:setString(string.format("%s%s%s%s", self:getTextWord(420003),startTime,self:getTextWord(420004),endTime))
	-- end
	--收集按钮
	local iconImg = self:getChildByName("topPanel/onceBtnPanel/iconImg")
	local numLab = self:getChildByName("topPanel/onceBtnPanel/numLab")
	local freeLab = self:getChildByName("topPanel/onceBtnPanel/freeLab")
	local freeTime  = self.proxy:getBroadSealFreeTime(self.myData.activityId)
	if freeTime > 0 then
		iconImg:setVisible(false)
		numLab:setVisible(false)
		freeLab:setVisible(true)
	else
		iconImg:setVisible(true)
		numLab:setVisible(true)
		freeLab:setVisible(false)
	end
	
	local lotteryPriceAry = StringUtils:jsonDecode(broadSealConfig.lotteryPrice)
	self.PriceAry = {}
	self.PriceAry[lotteryPriceAry[1][1]] = lotteryPriceAry[1][2]
	self.PriceAry[lotteryPriceAry[2][1]] = lotteryPriceAry[2][2]
	numLab:setString(self.PriceAry[1])
	local tenNumLab = self:getChildByName("topPanel/tenBtnPanel/numLab")
	tenNumLab:setString(self.PriceAry[10])
	--兵种标题与属性(血量，攻击，载重)
	self.showTypeId = broadSealConfig.showID
	local armKindsConfig = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",broadSealConfig.showID)
	local soldierNameLab = self:getChildByName("topPanel/composePanel/soldierNameLab")
	soldierNameLab:setString(armKindsConfig.name)
	local hpmaxLab = self:getChildByName("topPanel/composePanel/attPanel/numLab1")
	local atkLab = self:getChildByName("topPanel/composePanel/attPanel/numLab2")
	local loadLab = self:getChildByName("topPanel/composePanel/attPanel/numLab3")
	hpmaxLab:setString(armKindsConfig.hpmax)
	atkLab:setString(armKindsConfig.atk)
	loadLab:setString(armKindsConfig.load)
	--九个拼图
	for i=1,9 do
		local needLab = self:getChildByName("topPanel/composePanel/segmentPanel/touch" .. i .."/needLab")
		local haveLab = self:getChildByName("topPanel/composePanel/segmentPanel/touch" .. i .."/haveLab")
		local haveNum = 0
		for _,v in pairs(broadSealInfo.broadPostInfos) do
			if v.pos == i then
				haveNum = v.num
			end
		end
		needLab:setString("/" .. broadSealConfig.costTime)
		haveLab:setString(haveNum)
        local needLabX = needLab:getPositionX()
        local needLabWidth = needLab:getContentSize().width
        haveLab:setPositionX(needLabX-needLabWidth)
		local color = haveNum >= broadSealConfig.costTime and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)
		haveLab:setColor(color)
		local img = self:getChildByName("topPanel/composePanel/segmentPanel/img" .. i)
		TextureManager:updateImageView(img, string.format("images/broadSeal/%d_%d.png", broadSealConfig.showID,i))
		if haveNum <= 0 then
			img:setColor(cc.c3b(100,100,100))
		else
			img:setColor(cc.c3b(255,255,255))
		end
	end
	--满足组装条件时的特效
	local isShowComposeBtnEffect  = self.proxy:getBroadSealIsCanCompose(self.myData.activityId)
	if isShowComposeBtnEffect == true then
		if self.ComposeBtnEffect == nil then
			local composeBtn = self:getChildByName("topPanel/composePanel/composeBtn")
			self.ComposeBtnEffect = self:createUICCBLayer("rgb-gzzq-anniu", composeBtn)
            local size = composeBtn:getContentSize()
            self.ComposeBtnEffect:setPosition(size.width*0.5,size.height*0.5)
            self.ComposeBtnEffect:setLocalZOrder(10)
		end
	
	else
		if self.ComposeBtnEffect ~= nil then
            self.ComposeBtnEffect:finalize()
            self.ComposeBtnEffect = nil
		end

	end
	
	--玩家当前可以合成多少组提示描述
	local tipLab = self:getChildByName("topPanel/tipLab")
	tipLab:setString(self:getTextWord(440007))
	local canComTipLab = self:getChildByName("topPanel/composePanel/canComTipLab")
	if isShowComposeBtnEffect == true then
		canComTipLab:setVisible(true)
		local canComTipNum  = self.proxy:getBroadSealIsCanComposeNum(self.myData.activityId)
		local baseNum = StringUtils:jsonDecode(broadSealConfig.reward)[3]
		local realNum = canComTipNum*baseNum
		canComTipLab:setString(string.format(self:getTextWord(440006),realNum,armKindsConfig.name))
	else
		canComTipLab:setVisible(false)
	end
	
end

function BroadSealPanel:onClosePanelHandler()
	self:dispatchEvent(BroadSealEvent.HIDE_SELF_EVENT, {})
end
function BroadSealPanel:timestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
	local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return tab.year .. self:getTextWord(420005) .. tab.month .. self:getTextWord(420006) .. tab.day .. self:getTextWord(420007) .. hour ..":".. min
end


function BroadSealPanel:segmentTouchHandler(sender)

    local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", self.myData.effectId)



	local function sureFun()
		local roleProxy = self:getProxy(GameProxys.Role)
    	local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
		if broadSealConfig.buyPrice > curNum then
	        local parent = self:getParent()
	        local panel = parent.panel
	        if panel == nil then
	            local panel = UIRecharge.new(parent, self)
	            parent.panel = panel
	        else
	            panel:show()
	        end
	    else
			local sendData = {}
			sendData.activityId = self.myData.activityId
			sendData.pos = sender.tag
			logger:info(sender.tag)
			self.proxy:onTriggerNet230043Req(sendData)
	    end
	end
	self:showMessageBox(string.format(self:getTextWord(440001),broadSealConfig.buyPrice),sureFun)


end
function BroadSealPanel:composeBtnHandler(sender)
	local broadSealInfo = self.proxy:getBroadSealInfobyId(self.myData.activityId)
    local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", self.myData.effectId)
    local costNum = broadSealConfig.costTime
    for _,v in pairs(broadSealInfo.broadPostInfos) do
    	if v.num <  costNum then
    		self:showSysMessage(self:getTextWord(440003))
    		return
    	end
    end
	local sendData = {}
	sendData.activityId = self.myData.activityId
	self.proxy:onTriggerNet230044Req(sendData)
end
function BroadSealPanel:onceBtnHandler(sender)
	self:sendCollect(1)
end
function BroadSealPanel:tenBtnHandler(sender)
	self:sendCollect(10)
end
function BroadSealPanel:sendCollect(time)
	local freeTime  = self.proxy:getBroadSealFreeTime(self.myData.activityId)
	if freeTime > 0 and time == 1 then
		self.proxy:setBroadSealIsUseFreeTime(true)
		time = 0
	else
		self.proxy:setBroadSealIsUseFreeTime(false)
	end

	if time == 0 then
		local sendData = {}
		sendData.activityId = self.myData.activityId
		sendData.time = time
		self.proxy:onTriggerNet230042Req(sendData)

	else
		local roleProxy = self:getProxy(GameProxys.Role)
	    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
	    if self.PriceAry[time] > curNum then
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
				sendData.time = time
				self.proxy:onTriggerNet230042Req(sendData)
	    	end
	    	local messageBox = self:showMessageBox(string.format(self:getTextWord(440002),self.PriceAry[time],time),sureFun)
            messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
    	end
	end


end

function BroadSealPanel:afterCollect(infoTable)
	local time  = infoTable.time
	self.changePosInfos  = {}
	for _,v in pairs(infoTable.changePosInfos) do
		self.changePosInfos[v] = true
	end
	self.effectPosInfos = {}
	self.effectPosInfosIndex = 1
	for i=1,9 do
		table.insert(self.effectPosInfos, i)
	end
	for i=1,9 do
		table.insert(self.effectPosInfos, i)
	end

	self.messArray(self.effectPosInfos)
	----[[
	for i=1,9 do
		local img = self:getChildByName("topPanel/composePanel/segmentPanel/img" .. i)
		img:setColor(cc.c3b(100,100,100))
	end
	--]]
	TimerManager:add(30, self.blinkOne, self, 18)
end
function BroadSealPanel:blinkOne()
	
	local img = self:getChildByName("topPanel/composePanel/segmentPanel/img" .. self.effectPosInfos[self.effectPosInfosIndex])
	img:setColor(cc.c3b(255,255,255))
	local cafunc = cc.CallFunc:create(function ()
		img:setColor(cc.c3b(100,100,100))
		-- logger:info(self.effectPosInfosIndex)
		
		if self.effectPosInfosIndex >= 18 then
			self:blinkChangePos()
		else
			self.effectPosInfosIndex = self.effectPosInfosIndex + 1
		end
	end)
	local dt = cc.DelayTime:create(0.1)
	img:runAction(cc.Sequence:create(dt,cafunc))


end
function BroadSealPanel:blinkChangePos()
	local broadSealInfo = self.proxy:getBroadSealInfobyId(self.myData.activityId)
	for i=1,9 do
		local haveNum = 0
		for _,v in pairs(broadSealInfo.broadPostInfos) do
			if v.pos == i then
				haveNum = v.num
			end
		end
		local img = self:getChildByName("topPanel/composePanel/segmentPanel/img" .. i)
		if haveNum <= 0 then
			img:setColor(cc.c3b(100,100,100))
		else
			img:setColor(cc.c3b(255,255,255))
		end
	end
	for i=1,9 do
		if self.changePosInfos[i] == true then
			-- logger:info(i)
			local img = self:getChildByName("topPanel/composePanel/segmentPanel/img" .. i)
			local touch = self:getChildByName("topPanel/composePanel/segmentPanel/touch" .. i)
			local grayCafunc = cc.CallFunc:create(function ()
				img:setColor(cc.c3b(100,100,100))
			end)
			local brightCafunc = cc.CallFunc:create(function ()
				img:setColor(cc.c3b(255,255,255))
			end)
			local endCafunc = cc.CallFunc:create(function ()
				local aEffect = self:createUICCBLayer("rgb-gzzq-shuzi", touch, nil, nil, true)
                local size = touch:getContentSize()
                aEffect:setPosition(size.width*0.8,size.height*0.1)
                aEffect:setLocalZOrder(10)
				self:updateBroadSealView()
			end)
			local dt = cc.DelayTime:create(0.1)
			local dt2 = cc.DelayTime:create(0.3)
			img:runAction(cc.Sequence:create(brightCafunc,dt,grayCafunc,dt,brightCafunc,dt,grayCafunc,dt,brightCafunc,dt2,endCafunc))
		end
	end
end

function BroadSealPanel:afterCompose(rewardList)
    local function complete(  )
    	self:updateBroadSealView()
    	if _G.next(rewardList) ~= nil then
    		AnimationFactory:playAnimationByName("GetGoodsEffect", rewardList)
    	end
    end
	local segmentPanel = self:getChildByName("topPanel/composePanel/segmentPanel")
	local aEffect = self:createUICCBLayer("rgb-gzzq-zhuzhuang", segmentPanel, nil,complete,true)
	local size = segmentPanel:getContentSize()
	aEffect:setPosition(size.width*0.5,size.height*0.5 + 13)
	aEffect:setLocalZOrder(10)
end
function BroadSealPanel:tipsBtnHandler(sender)
    if self._uiSoldierInfo == nil then
        local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
        self._uiSoldierInfo = UISoldierInfo.new(parent, self)
    end
	local soldierProxy = self:getProxy(GameProxys.Soldier)
    local soldier = soldierProxy:getSoldier(self.showTypeId)
    self._uiSoldierInfo:updateSoldierInfo(self.showTypeId,soldier)
end
--打乱数组
function BroadSealPanel.messArray(array)
	local len = #array
	for i=1,len do
		math.randomseed(os.time())
		local randomIndex = math.random(1,len)
		array[i],array[randomIndex] = array[randomIndex],array[i]
	end
end




