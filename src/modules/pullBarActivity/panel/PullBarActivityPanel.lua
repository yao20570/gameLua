
PullBarActivityPanel = class("PullBarActivityPanel", BasicPanel)
PullBarActivityPanel.NAME = "PullBarActivityPanel"

function PullBarActivityPanel:ctor(view, panelName)
    PullBarActivityPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
    self.isCanDraw = false
    self.isfirstDraw = true
    self.rewardData = {}
    self.isThisList = false
end

function PullBarActivityPanel:finalize()
	if self._UIResourceGet then
		self._UIResourceGet:removeFromParent()
		self._UIResourceGet = nil
	end

	for i=1,3 do
		if self["effect"..i] ~= nil then
			self["effect"..i]:finalize()
			self["effect"..i] = nil
		end

		if self["_uiMoveNode"..i] ~= nil then
			self["_uiMoveNode"..i]:finalize()
			self["_uiMoveNode"..i] = nil
		end
	end
    
    if self._effectLeftBg then 
        self._effectLeftBg:finalize()
        self._effectLeftBg = nil
    end
    
    if self._effectLeftBg_d then
        self._effectLeftBg_d:finalize()
        self._effectLeftBg_d = nil
    end
    
    if self._effectRightBg then
        self._effectRightBg:finalize()
        self._effectRightBg = nil
    end

    if self._effectRightBg_d then
        self._effectRightBg_d:finalize()
        self._effectRightBg_d = nil
    end

    PullBarActivityPanel.super.finalize(self)

end

local offsetY = -20  --子控件偏移量
local IntervalNum = 1.5 --间隔系数  大于1出现间隙  小于1出现重叠

function PullBarActivityPanel:initPanel()
	PullBarActivityPanel.super.initPanel(self)
	self:setTitle(true, "junduilaba", true)
	self:setBgType(ModulePanelBgType.ACTIVITY)

	self.allImg = {}
	for i=1,4 do
		-- self.allImg[i] = string.format("images/pullBarActivity/0%d.png", i)
		self.allImg[i] = "images/newGui1/IconPinZhi1.png"
	end

    local effectBg = self:getChildByName("Image_14/leftEffectBg")
    if self._effectLeftBg == nil then
        self._effectLeftBg = self:createUICCBLayer("rgb-zzq-bashou", effectBg)
        self._effectLeftBg:setLocalZOrder(10)
        --self._effectLeftBg:setDir(-1)
    end
    
    if self._effectLeftBg_d == nil then
        self._effectLeftBg_d = self:createUICCBLayer("rgb-zzq-bashoud", effectBg)
        self._effectLeftBg_d:setLocalZOrder(10)
        self._effectLeftBg_d:setVisible(false)
    end
    
    effectBg = self:getChildByName("Image_14/rightEffectBg")
    if self._effectRightBg == nil then
        self._effectRightBg = self:createUICCBLayer("rgb-zzq-bashou", effectBg)
        self._effectRightBg:setLocalZOrder(10)
    end
    --local dir = {x = 1, y = -1}
    --self._effectRightBg:setDirection(dir)
    if self._effectRightBg_d == nil then
        self._effectRightBg_d = self:createUICCBLayer("rgb-zzq-bashoud", effectBg)
        self._effectRightBg_d:setLocalZOrder(10)
        self._effectRightBg_d:setVisible(false)
    end
    effectBg:setScaleX(-1)

	for i=1,3 do
		local idx = 140 + i - 1
		local panel = self:getChildByName("Image_14/Panel_".. idx)

		local x, y = panel:getPosition()
		local size = panel:getContentSize()
		self["effect"..i] = self:createUICCBLayer("rgb-laba-zhixu", panel:getParent())
		self["effect"..i]:setPosition(x+size.width/2, y+size.height/2 + 8)
		self["effect"..i]:setVisible(false)
		local callbk = nil
		if i == 3 then
			callbk = function()
				self:showReward()
                self._effectLeftBg_d:setVisible(false)
                self._effectLeftBg:setVisible(true)
                self._effectRightBg_d:setVisible(false)
                self._effectRightBg:setVisible(true)
			end
		end
		self["_uiMoveNode"..i] = UIMoveNode.new(self.allImg, panel, 60, callbk, IntervalNum, offsetY)
		local allChild = self["_uiMoveNode"..i]:getAllChild()
		for k,v in pairs(allChild) do
			if allChild[k].img == nil then
				local url = string.format("images/pullBarActivity/0%d.png", k)
				allChild[k].img = TextureManager:createImageView(url)
				local size = v:getContentSize()
				allChild[k].img:setPosition(size.width*0.5, size.height*0.5)
				allChild[k]:addChild(allChild[k].img)
			end
		end
	end
end

function PullBarActivityPanel:doLayout()
    --local ImageBg = self:getChildByName("ImageBg")
	--TextureManager:updateImageViewFile(ImageBg,"bg/pullBarActivity/bg.pvr.ccz")
	local bestTopPanel = self:topAdaptivePanel()
	--NodeUtils:adaptiveTopPanelAndListView(ImageBg, nil, nil, bestTopPanel)

	local ImageBg = self:getChildByName("ImageBg")
	NodeUtils:adaptiveUpPanel(ImageBg, bestTopPanel, GlobalConfig.topAdaptive + 30)
end

function PullBarActivityPanel:onShowHandler()
	self.isCanDraw = true
	self:updateInfo()
end

function PullBarActivityPanel:updateInfo(isUpdate)
	local activityProxy = self:getProxy(GameProxys.Activity)
	local actData = activityProxy.curActivityData
	local curId = actData.effectId
	self.data = activityProxy.labaXinxi[curId]
	self:showOtherInfo(isUpdate)
end

function PullBarActivityPanel:renderItemPanel(item, itemInfo, index)
	if item.isRender == true then return end
	item.isRender = true
	local container = item:getChildByName("Image_15")
 	local url = string.format("images/pullBarActivity/0%d.png",itemInfo[1])
 	container:setScaleX(1.25)
 	container:setScaleY(1.275)
    TextureManager:updateImageView(container,url)
end

function PullBarActivityPanel:showOtherInfo(isUpdate)
	local describeText = self:getChildByName("ImageBg/describeText")
    describeText:setFontSize(18)
    describeText:setColor(cc.c3b(244,244,244))
	local activityProxy = self:getProxy(GameProxys.Activity)
	local allList = activityProxy.curActivityData
	describeText:setString(string.format("%s\n%s", self:getTextWord(260000), allList.info))
	if not self.data then
		logger:error("获取不到拉霸的信息")
	end

	local drawBtn = self:getChildByName("bottom/drawBtn")--
    drawBtn.times = 1
    local lab1 = drawBtn:getChildByName("lab1")
    local lab2 = drawBtn:getChildByName("lab2")
	local num = drawBtn:getChildByName("num")
    
	local drawTenBtn = self:getChildByName("bottom/drawTenBtn")--
    drawTenBtn.times = 10
    local labTen1 = drawTenBtn:getChildByName("lab1")
    local labTen2 = drawTenBtn:getChildByName("lab2")
	local numTen = drawTenBtn:getChildByName("num")

    
	numTen:setString(self.data.tenPrice)
	labTen1:setString(TextWords:getTextWord(1877))
    local strTen = string.format(TextWords:getTextWord(1874), 10)
    labTen2:setString(strTen)

    --//null
    num:setAnchorPoint(0,0.5)

    lab1:setVisible(self.data.free <=0)
    lab2:setVisible(self.data.free <=0)
	if self.data.free == 1 then
		drawBtn:setTitleText(self:getTextWord(1818))
		--self.choiceType:setVisible(false)
        self._isFree = true
		num:setString("0")
	else
        ---- TODO:这里的self.data.type是0，跟10没毛钱关系啊，有空理下这关系
        --local times = 1
		--self.choiceType:setVisible(true)
		--if self.data.type == 10 then
        --    times = 10
		--else
		--	self.choiceType:setSelectedState(false)
        --    times = 1
		--end
        
        self._isFree = false
		drawBtn:setTitleText("")

		num:setString(self.data.price)
		lab1:setString(TextWords:getTextWord(1873))
        local str = string.format(TextWords:getTextWord(1874), 1)
        lab2:setString(str)
	end
	local timeText = self:getChildByName("ImageBg/timeText")
	local startTime = TimeUtils:setTimestampToString(self.data.startTime)
	local endTime = TimeUtils:setTimestampToString(self.data.endTime)
	-- timeText:setString(startTime.." - "..endTime)
	timeText:setString(TimeUtils.getLimitActFormatTimeString(self.data.startTime,self.data.endTime))
	if isUpdate then
		local info = ConfigDataManager:getConfigData("LaBaRewardConfig")
		local needData = info[self.data.rewardgroupId]
		local needImgData = StringUtils:jsonDecode(needData.typegroup)
		self.rewardData = needData
		local len = #needImgData
    	for i = 1, len do
        	local randomIndex = math.random(1, len)
        	needImgData[i], needImgData[randomIndex] = needImgData[randomIndex], needImgData[i]
    	end
		TimerManager:addOnce(100, self.setDrawState, self, needImgData)
	end
end

function PullBarActivityPanel:showReward()
	local function callblack()
		local tmp = {}
		tmp.rewards = {}
		local info = ConfigDataManager:getConfigData("FixRewardConfig")
		local realRewardData = StringUtils:jsonDecode(self.rewardData.reward)
		for i = 1,#realRewardData do
			local oneReward = info[realRewardData[i]]
			local reData = StringUtils:jsonDecode(oneReward.reward)
			local currentNum = reData[1][3]
			if self.data.type == 10 then
				currentNum = reData[1][3] * 10
			end
			local oneTmp = {power = reData[1][1], typeid = reData[1][2], num = currentNum}
			table.insert(tmp.rewards,oneTmp)
		end
		local lastData = tmp.rewards
	 	if self._UIResourceGet == nil then --判nil防止重复创建面板
	        local parent = self:getParent()
	        local UIResourceGet = UIGetProp.new(parent, self, true)
	        self._UIResourceGet = UIResourceGet
	    end
	   self._UIResourceGet:show(lastData)--显示
	   self.isCanDraw = true
	end

	local panel = self:getChildByName("Image_14")

    local delayAct = cc.DelayTime:create(1.0)
    local act = cc.Sequence:create(delayAct, cc.CallFunc:create(function()		
        callblack()
	end))
    panel:runAction(act)

	for i=1,3 do
		self["effect"..i]:setVisible(false)
		local effect = self:createUICCBLayer("rpg-zp-hq", panel, nil, nil, true)
		local x, y = self["effect"..i]:getPosition()
		effect:setPosition(x, y - 15)
	end
    
end

function PullBarActivityPanel:registerEvents()
	PullBarActivityPanel.super.registerEvents(self)

	--self.choiceType = self:getChildByName("Image_14/choiceType")
	--self:addTouchEventListener(self.choiceType,self.setSelectState)

	local drawBtn = self:getChildByName("bottom/drawBtn")
	self:addTouchEventListener(drawBtn,self.drawReward)
    
	local drawTenBtn = self:getChildByName("bottom/drawTenBtn")
	self:addTouchEventListener(drawTenBtn,self.drawReward)

	local helpBtn = self:getChildByName("Image_14/helpBtn")
	self:addTouchEventListener(helpBtn,self.touchHelpBtn)

	local tipBtn = self:getChildByName("ImageBg/tipBtn")
	self:addTouchEventListener(tipBtn,self.touchTipBtn)
end

function PullBarActivityPanel:onClosePanelHandler()
    self:dispatchEvent(PullBarActivityEvent.HIDE_SELF_EVENT)
end

function PullBarActivityPanel:drawReward(sender)

	if sender.times == 10 then
		self.currentType = 10--十连抽
		self.price = self.data.tenPrice
	else
	    if not self._isFree then
	    	self.currentType = 2--单抽
	    	self.price = self.data.price
	    else
	    	self.currentType = 1--免费抽
	    end
	end



	if not self.isCanDraw then
		self:showSysMessage("正在抽奖中，请稍候")
		return
	end

	

 	if self.data.free == 1 and sender.times == 1 then
 		self:realDraw()
 		return
 	end
 	local function draw()
 		self.isCanDraw = false
 		self:realDraw()
 	end
 	local data = {}
 	data.money = self.price
 	data.callFunc = draw
 	local function callbk()
    	self:isShowRechargeUI(data)
    end
    
    --local roleProxy = self:getProxy(GameProxys.Role)
    --local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
    --if self.price > haveGold then
    --    callbk()
    --    return
    --end

    local num = 0
    if self.currentType == 2 then
    	num = 1
    else
    	num = 10
    end
    local str = string.format(self:getTextWord(250006),self.price,num)
    local messageBox = self:showMessageBox(str,callbk)
    messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)

end

function PullBarActivityPanel:realDraw(sender)

    local delayAct = cc.DelayTime:create(0.5)
    local act = cc.Sequence:create(delayAct, cc.CallFunc:create(function()
 	    for i=1,3 do
 	    	self["effect"..i]:setVisible(true)
 	    end
        self._effectLeftBg_d:setVisible(true)
        self._effectLeftBg:setVisible(false)
        self._effectRightBg_d:setVisible(true)
        self._effectRightBg:setVisible(false)
    end))
    self:getChildByName("Image_14"):runAction(act)

 	self:lastReqDraw()
end

function PullBarActivityPanel:setDrawState(needImgData)
	local circle = 6--转几圈
	local time = 3.0--转圈所需要的时间
	local dir = 1--方向  1向上走   -1向下走
	local centerPos = 2

	for i=1,3 do
		if self["_uiMoveNode"..i] == nil then
			local callbk = nil
			local idx = 140 + i - 1
			local panel = self:getChildByName("Image_14/Panel_".. idx)
			if i == 3 then
				callbk = function()
					self:showReward()
				end
			end
			self["_uiMoveNode"..i] = UIMoveNode.new(self.allImg, panel, 60, callbk)
		end
		self["_uiMoveNode"..i]:startMove(centerPos, needImgData[i], circle, time, dir)
		dir = dir * -1
	end
end

function PullBarActivityPanel:lastReqDraw()
	self:dispatchEvent(PullBarActivityEvent.DRAW_EVENT_REQ,{activityId = self.data.activityId,type = self.currentType})
end

function PullBarActivityPanel:isShowRechargeUI(sender)
    -- body
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

--function PullBarActivityPanel:setSelectState()
--	local drawBtn = self:getChildByName("bottom/drawBtn")
--    local lab1 = drawBtn:getChildByName("lab1")
--    local lab2 = drawBtn:getChildByName("lab2")
--	local labNum = drawBtn:getChildByName("num")
--    -- 次数只能写死在这里了
--    local times = 1
--	if self.choiceType:getSelectedState() == false then
--		labNum:setString(self.data.tenPrice)
--        times = 10
--	else
--		labNum:setString(self.data.price)
--        times = 1
--	end
--    if times == 1 then
--	    local str = TextWords:getTextWord(1873)
--	    lab1:setString(str)
--	else
--		local str = TextWords:getTextWord(1877)
--	    lab1:setString(str)
--    end
--    local str = string.format(TextWords:getTextWord(1874), times)
--    lab2:setString(str)
--end

function PullBarActivityPanel:touchHelpBtn(sender)
	local panel = self:getPanel(PullBarInfo.NAME)
	local typeId = 0
	if self.data then
		typeId = self.data.rewardgroup
	end
	local activityProxy = self:getProxy(GameProxys.Activity)
	local actData = activityProxy.curActivityData
	local curId = actData.effectId
	--print("effectId===",curId)
	local curData = activityProxy.labaXinxi[curId]
	local openId = curData ~= nil and curData.rewardgroup or 101
	--print("喇叭奖励预览",openId)
    panel:show(openId)
end

function PullBarActivityPanel:touchTipBtn(sender)
	-- self._uiMoveNode:startMove(2, 2, 1, 1, 1)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
    local line = {}
    local lines = {}
    for i=1,3 do
    	line[i] = {{content = self:getTextWord(250007+i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}
    	table.insert(lines, line[i])
    end
    uiTip:setAllTipLine(lines)
end

function PullBarActivityPanel:fail()
	self.isCanDraw = true
end