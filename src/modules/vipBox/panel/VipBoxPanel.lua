--require("component.VipBoxEffect")
VipBoxPanel = class("VipBoxPanel", BasicPanel)
VipBoxPanel.NAME = "VipBoxPanel"

function VipBoxPanel:ctor(view, panelName)
    VipBoxPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)

    self._UIIcons = {}
end
function VipBoxPanel:finalize()
    if self._huangJinPanel.effect then
		self._huangJinPanel.effect:finalize()
		self._huangJinPanel.effect = nil
    end
    if self._baiYinPanel.effect then
		self._baiYinPanel.effect:finalize()
		self._baiYinPanel.effect = nil
    end
    if self._huangTongPanel.effect then
		self._huangTongPanel.effect:finalize()
		self._huangTongPanel.effect = nil
    end
    if self._huangJinPanel.effectH then
		self._huangJinPanel.effectH:finalize()
		self._huangJinPanel.effectH = nil
    end
    if self._baiYinPanel.effectH then
		self._baiYinPanel.effectH:finalize()
		self._baiYinPanel.effectH = nil
    end
    if self._huangTongPanel.effectH then
		self._huangTongPanel.effectH:finalize()
		self._huangTongPanel.effectH = nil
    end

    if self._leftEffect then
		self._leftEffect:finalize()
		self._leftEffect = nil
    end
    if self._rightEffect then
		self._rightEffect:finalize()
		self._rightEffect = nil
    end

    VipBoxPanel.super.finalize(self)
end

function VipBoxPanel:initPanel()
	VipBoxPanel.super.initPanel(self)
    self:setTitle(true,"vipBox",true)
    self:setBgType(ModulePanelBgType.ACTIVITY)
    
	self._huangTongBoxType = 101
	self._baiYinBoxType = 102
	self._huangJinBoxType = 103

    self._selectedBoxType = 0
    
    local topPanel = self:getChildByName("totalPanel")
	self._nilPanel = self:getChildByName("nilPanel")
	self:adjustBootomBg(self._nilPanel, topPanel,true)
------------top---------------------------
	self._txtActivityTime = self:getChildByName("totalPanel/topPanel/timeLab")
	self._txtActivityDescLab = self:getChildByName("totalPanel/topPanel/descLab")
    self._txtActivityDescLab:setColor(cc.c3b(244,244,244))
	self._btnTips = self:getChildByName("totalPanel/topPanel/tipsBtn")
	self._txtVipLevel = self:getChildByName("totalPanel/topPanel/vipLevelLab")
	self._txtCanBuyTime = self:getChildByName("totalPanel/topPanel/canBuyTimesLab")
------------mid---------------------------
    self._huangJinPanel = self:getChildByName("totalPanel/midPanel/huangJinPanel")
    self._baiYinPanel = self:getChildByName("totalPanel/midPanel/baiYinPanel")
    self._huangTongPanel = self:getChildByName("totalPanel/midPanel/huangTongPanel")
    
    --滑动处理
    self._TouchPanel = self:getChildByName("totalPanel/midPanel/TouchPanel")
    self._oldPositionX = 0
    self._right = 1
    self._left = 0
    --特效
    self._leftEffect = self:createUICCBLayer("rgb-fanye", topPanel:getChildByName("leftEffectPanel"))

    self._rightEffect = self:createUICCBLayer("rgb-fanye", topPanel:getChildByName("rightEffectPanel"))
    self._rightEffect:setScale(-1)

    self._huangJinPanel.posX, self._huangJinPanel.posY = self._huangJinPanel:getPosition()
    self._baiYinPanel.posX, self._baiYinPanel.posY = self._baiYinPanel:getPosition()
    self._huangTongPanel.posX, self._huangTongPanel.posY = self._huangTongPanel:getPosition()
    self._boxPositionArr = {} 
    --table.insert(self._boxPositionArr, self._huangTongPanel:getPosition())
    --table.insert(self._boxPositionArr, self._baiYinPanel:getPosition())
    --table.insert(self._boxPositionArr, self._huangJinPanel:getPosition())
    local pos = {}
    pos.x, pos.y = self._huangTongPanel:getPosition()
    self._boxPositionArr[1] = pos--self._huangTongPanel:getPosition()
    local pos1 = {}
    pos1.x, pos1.y = self._baiYinPanel:getPosition()
    self._boxPositionArr[2] = pos1--self._baiYinPanel:getPosition()
    local pos2 = {}
    pos2.x, pos2.y = self._huangJinPanel:getPosition()
    self._boxPositionArr[3] = pos2--self._huangJinPanel:getPosition()
    self._huangTongPanel.pos = 1--中间
    self._baiYinPanel.pos = 2--右边
    self._huangJinPanel.pos = 3--左边
    self._boxArr = {}
    --table.insert(self._boxArr, self._huangTongPanel)
    --table.insert(self._boxArr, self._baiYinPanel)
    --table.insert(self._boxArr, self._huangJinPanel)
	self._huangTongPanel.boxType = self._huangTongBoxType
	self._baiYinPanel.boxType = self._baiYinBoxType
	self._huangJinPanel.boxType = self._huangJinBoxType
    self._boxArr[1] = self._huangTongPanel
    self._boxArr[2] = self._baiYinPanel
    self._boxArr[3] = self._huangJinPanel
    self._currentSelectedBoxId = 1

    self._distance = 640--pos1.x - pos.x
    self._centerX = 300--pos1.x
    self._boxDistance = 230--pos1.x - pos.x


	self._imgHuangtongBox = self:getChildByName("totalPanel/midPanel/huangTongPanel/huangtongImg")
	self._imgHuangtongBox0 = self:getChildByName("totalPanel/midPanel/huangTongPanel/huangtongImg_0")
	self._imgBaiyinBox = self:getChildByName("totalPanel/midPanel/baiYinPanel/baiyinImg")
	self._imgBaiyinBox0 = self:getChildByName("totalPanel/midPanel/baiYinPanel/baiyinImg_0")
	self._imgHuangjinBox = self:getChildByName("totalPanel/midPanel/huangJinPanel/huangjinImg")
	self._imgHuangjinBox0 = self:getChildByName("totalPanel/midPanel/huangJinPanel/huangjinImg_0")
	self._imgHuangtongBox.boxType = self._huangTongBoxType
	self._imgBaiyinBox.boxType = self._baiYinBoxType
	self._imgHuangjinBox.boxType = self._huangJinBoxType
	self._imgHuangtongBox0.boxType = self._huangTongBoxType
	self._imgBaiyinBox0.boxType = self._baiYinBoxType
	self._imgHuangjinBox0.boxType = self._huangJinBoxType
	self._iconContainer = self:getChildByName("totalPanel/midPanel/showGoodsPanel")
	self._boxInfoLab = self:getChildByName("totalPanel/midPanel/boxInfoLab")
-------------down-------------------------
	self._btnBuy = self:getChildByName("downPanel/buyBtn")
	self._txtUseGold = self:getChildByName("downPanel/useGoldLab")
-------------------------------------------
	local temp ={}
	temp.num = 1
	temp.power = 401
	temp.typeid = 2071
	self._UIIcons = {}
	for i=1, 4 do
		local node = cc.Node:create()
	    self._iconContainer:addChild(node)
		self._UIIcons[i] = UIIcon.new(node, temp, true, self, nil, true)
		node:setPosition((i - 1) * 100 + 25, self._iconContainer:getContentSize().height/2)
	end
end

function VipBoxPanel:doLayout()
	local topPanel = self:getChildByName("totalPanel")
	local downPanel = self:getChildByName("downPanel")
    local bestTopPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveUpPanel(topPanel, bestTopPanel, GlobalConfig.topAdaptive - 20)
	NodeUtils:adaptiveUpPanel(downPanel, topPanel, GlobalConfig.topAdaptive - 30)
end


function VipBoxPanel:registerEvents()
	VipBoxPanel.super.registerEvents(self)

    self:initTouchEvent()
	--self:addTouchEventListener(self._imgHuangtongBox,self.onBoxTouch)
	--self:addTouchEventListener(self._imgBaiyinBox,self.onBoxTouch)
	--self:addTouchEventListener(self._imgHuangjinBox,self.onBoxTouch)
	--self:addTouchEventListener(self._imgHuangtongBox0,self.onBoxTouch)
	--self:addTouchEventListener(self._imgBaiyinBox0,self.onBoxTouch)
	--self:addTouchEventListener(self._imgHuangjinBox0,self.onBoxTouch)
	self:addTouchEventListener(self._btnBuy,self.buyBox)
	self:addTouchEventListener(self._btnTips, self.onBtnTipsTouch)
end

function VipBoxPanel:initTouchEvent()
    --self._PI = 3.1415926535898
    --self._unitAngle = 2 * self._PI / self.MAX_COUNT_MOVE_OBJ
    --self._rootSize = cc.size(GlobalConfig.Module_Size[1], GlobalConfig.Module_Size[2])    
    --self._moveCenterX = GlobalConfig.Module_Center[1]
    --self._moveCenterY = GlobalConfig.Module_Center[2]
    --self:setAngle( self._unitAngle * 3)
    --self:updatePosition()

    local function onTouchPanelHandler(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self._startMove = os.clock()
            self._startPos = sender:getTouchBeganPosition()

        elseif eventType == ccui.TouchEventType.moved then
            self:handlerMoveTouch(sender)

        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self._endMove = os.clock()
            self._endPos = sender:getTouchEndPosition()
            self._oldPositionX = 0
            self:handlerEndTouch(sender)        
        end
    end
    self._TouchPanel:setTouchEnabled(true)
    self._TouchPanel:addTouchEventListener(onTouchPanelHandler)
end

--监听手指滑动的过程
--移动组件通过偏移值计算并设置往下一个点的向量方向计算偏移位置(跟随移动)
function VipBoxPanel:handlerMoveTouch(sender)
    --判断当前手指方向
    local currentPos = sender:getTouchMovePosition()
    if self._oldPositionX == 0 then
        self._oldPositionX = self._startPos.x
    end
    if self._oldPositionX < currentPos.x then--向右
        self:calculateTargetPosition(currentPos, self._right)
    elseif self._oldPositionX > currentPos.x then--向左
        self:calculateTargetPosition(currentPos, self._left)
    else--在原来位置
    end
    self._oldPositionX = currentPos.x
end

--计算移动的目标坐标
function VipBoxPanel:calculateTargetPosition(currentPos, direction)
    --1:中 2:右 3:左
    --self._boxPositionArr[1]
    --self._currentSelectedBoxId
    --1:铜 2:银 3:金
    local slideDistance = currentPos.x - self._startPos.x
    for i = 1, #self._boxArr do
        local targetIndex = 0
        local startIndex = 0
        if self._startPos.x < currentPos.x then--在右边
            local tmp = self._boxArr[i].pos + 1
            if tmp > 3 then
                tmp = 1
            end
            if direction == self._right then--向右移动目标点为下一个的位置
                startIndex = self._boxArr[i].pos
                targetIndex = tmp
                self._boxArr[i].targetIndex = tmp
            else--向左移动目标点为自己原来位置
                startIndex = tmp
                targetIndex = self._boxArr[i].pos
                self._boxArr[i].targetIndex = self._boxArr[i].pos
            end
            self:updatePosition(self._boxArr[i], startIndex, targetIndex, slideDistance, 1)
        elseif self._startPos.x > currentPos.x then--在左边
            local tmp = self._boxArr[i].pos - 1
            if tmp < 1 then
                tmp = 3
            end
            if direction == self._right then--向右移动目标点为自己原来位置
                startIndex = tmp
                targetIndex = self._boxArr[i].pos
                self._boxArr[i].targetIndex = self._boxArr[i].pos
            else--向左移动目标点为前一个的位置
                startIndex = self._boxArr[i].pos
                targetIndex = tmp
            end
            self:updatePosition(self._boxArr[i], startIndex, targetIndex, slideDistance)
        else--在原来位置
        end
    end
end

function VipBoxPanel:updatePosition(box, startIndex, targetIndex, slideDistance, direction)
    local percent = slideDistance / self._distance
    if percent > 1 then
        percent = 1
    end
    local startPos = self._boxPositionArr[startIndex]
    local targetPos = self._boxPositionArr[targetIndex]

    local boxX = box:getPositionX()
    local distance = (targetPos.x - boxX) * percent
    --logger:error(boxX .. "----------------->>>>" .. targetPos.x)
    local posX = boxX + distance
    if direction ~= 1 then
        posX = boxX - distance
    end
    --logger:error("--------boxX + distance---------" .. posX)
    if posX > self._centerX + self._boxDistance then
        posX = self._centerX + self._boxDistance
    end
    if posX < self._centerX - self._boxDistance then
        posX = self._centerX - self._boxDistance
    end
    --logger:error("--------setPositionX---------" .. posX)
    box:setPositionX(posX)
    percent = math.abs(self._centerX - posX) / math.abs(targetPos.x - startPos.x)
    if percent > 1 then
        percent = 1
    end
    if targetIndex == 1 then
        box:setScale(1.0 - 0.4 * percent)
        box:setLocalZOrder(5)
    else
        if (targetIndex == 2 and startIndex == 3) or (targetIndex == 3 and startIndex == 2) then
            --percent = math.abs(targetPos.x - posX) / math.abs(targetPos.x - startPos.x)
            box:setScale(0.6)
            box:setLocalZOrder(1)
        else
            box:setScale(0.6 + 0.4 * (1 - percent))
            box:setLocalZOrder(3)
        end
    end
end

--监听手指离开时偏移值（移动组件复位）
function VipBoxPanel:handlerEndTouch(sender)
    local endPos = sender:getTouchMovePosition()
    local distance = endPos.x - self._startPos.x

    for i = 1, #self._boxArr do
        if distance > 50 then--往前一个位置
           local tmp = self._boxArr[i].pos + 1
           if tmp > 3 then
               tmp = 1
           end
           self._boxArr[i]:setPositionX(self._boxPositionArr[tmp].x)
           self._boxArr[i].pos = tmp
        elseif distance < -50 then--往后一个位置
           local tmp = self._boxArr[i].pos - 1
           if tmp < 1 then
               tmp = 3
           end
           self._boxArr[i]:setPositionX(self._boxPositionArr[tmp].x)
           self._boxArr[i].pos = tmp
        else--复位
           self._boxArr[i]:setPositionX(self._boxPositionArr[self._boxArr[i].pos].x)
        end
        if self._boxArr[i].pos == 1 then
            self._boxArr[i]:setScale(1.0)
            self._boxArr[i]:setLocalZOrder(5)
            self._currentSelectedBoxId = self._boxArr[i].pos
            
	        self:updatePanel(self._boxArr[i].boxType)
            self:boxMove(self._boxArr[i].boxType)
        else
            self._boxArr[i]:setScale(0.6)
            self._boxArr[i]:setLocalZOrder(3)
        end
    end

end

function VipBoxPanel:onBtnTipsTouch(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	local VipBoxTips = ConfigDataManager:getConfigData("VipBoxTipsConfig")
	local line = {}
	local lines = {}
    
	local proxy = self:getProxy(GameProxys.VIPBox)
	local effectId = proxy:getEffectId()

    local index = 0
	for k,v in pairs(VipBoxTips) do
        if effectId == v.effectgroup then
            index = index + 1
		    line[index] = {{content = v.info, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
		    table.insert(lines,line[index])
        end
	end
    uiTip:setAllTipLine(lines)
    uiTip:setTitle(TextWords:getTextWord(7501))
end

function VipBoxPanel:onBoxTouch(sender)
	if sender.boxType == self.type then return end
	self:setZorder(sender.boxType)
	self:updatePanel(sender.boxType)
	--self:boxImageChange(sender.boxType)
    --前置动画
    self:boxMove(sender.boxType)

end

function VipBoxPanel:setZorder(index)
	local function fuc(order)
   		if order == index then
   			return 5
   		else
   			return 4
   		end
   	end
	self._imgHuangtongBox:setLocalZOrder(fuc(self._huangTongBoxType))
	self._imgBaiyinBox:setLocalZOrder(fuc(self._baiYinBoxType))
	self._imgHuangjinBox:setLocalZOrder(fuc(self._huangJinBoxType))
    
end

--function VipBoxPanel:initAllEffect(index)
--	self.effectType = 0
--	if self.effect1 then
--		self.effect1:hide()
--	end
--	if self.effect2 then
--		self.effect2:hide()
--	end
--	if self.effect3 then
--		self.effect3:hide()
--	end
--	self._imgHuangtongBox:stopAllActions()
--	--self._imgHuangtongBox:setPosition(163,167)
--	self._imgHuangtongBox:setRotation(0)
--	self._imgBaiyinBox:stopAllActions()
--	self._imgBaiyinBox:setRotation(0)
--	--self._imgBaiyinBox:setPosition(318,157)
--	self._imgHuangjinBox:stopAllActions()
--	self._imgHuangjinBox:setRotation(0)
--	--self._imgHuangjinBox:setPosition(477,167)
--	self._iconContainer:stopAllActions()
--	self._boxInfoLab:setVisible(false)
--	if index == self._huangTongBoxType then
--		self._iconContainer:setPosition(163,167)
--	elseif  index == self._baiYinBoxType then
--		self._iconContainer:setPosition(318,157)
--	else
--		self._iconContainer:setPosition(477,167)
--	end
--	self._iconContainer:setScale(0.001)
--end

--function VipBoxPanel:boxImageChange(index)
--	self:initAllEffect(index)
--    local url = string.format("images/vipBox/tong1.png")
--    TextureManager:updateImageView(self._imgHuangtongBox, url)
--    url = string.format("images/vipBox/yin1.png")
--    TextureManager:updateImageView(self._imgBaiyinBox, url)
--    url = string.format("images/vipBox/jin1.png")
--    TextureManager:updateImageView(self._imgHuangjinBox, url)
--    --中间244，两边224
--	--self._iconContainer:setPositionY(477,167)
--
--    local ox1 = self._imgHuangtongBox:getPositionX()
--    local ox2 = self._imgBaiyinBox:getPositionX()
--    local ox3 = self._imgHuangjinBox:getPositionX()
--
--    if index == self._huangTongBoxType then
--    	local function callFunc1()
--    		if self.effectType ~= self._huangTongBoxType then return end
--	    	url = string.format("images/vipBox/tong2.png")
--    		TextureManager:updateImageView(self._imgHuangtongBox, url)
--    		self:actionGoods()
--    	end
--    	if not self.effect1 then
--    		self.effect1  = VipBoxEffect.new(self._imgHuangtongBox,1, ox2, ox3 )
--    	end
--    	self.effect1:play()
--    	--TimerManager:addOnce(1100,callFunc1,self)
--    	self:boxAction(self._imgHuangtongBox, callFunc1)
--    elseif index == self._baiYinBoxType then
--    	local function callFunc2()
--    		if self.effectType ~= self._baiYinBoxType then return end
--	    	url = string.format("images/vipBox/yin2.png")
--    		TextureManager:updateImageView(self._imgBaiyinBox, url)
--    		self:actionGoods()
--    	end
--    	if not self.effect2 then
--    		self.effect2  = VipBoxEffect.new(self._imgBaiyinBox,2, ox1, ox3 )
--    	end
--    	self.effect2:play()
--    	self:boxAction(self._imgBaiyinBox, callFunc2)
--    	--TimerManager:addOnce(1100,callFunc2,self)
--    elseif index == self._huangJinBoxType then
--    	local function callFunc3()
--    		if self.effectType ~= self._huangJinBoxType then return end
--	    	url = string.format("images/vipBox/jin2.png")
--    		TextureManager:updateImageView(self._imgHuangjinBox, url)
--    		self:actionGoods()
--    	end
--    	if not self.effect3 then
--    		self.effect3  = VipBoxEffect.new(self._imgHuangjinBox,3, ox1, ox2 )
--    	end
--    	self.effect3:play()
--    	self:boxAction(self._imgHuangjinBox, callFunc3)
--    	--TimerManager:addOnce(1100,callFunc3,self)
--    end
--    self.effectType = index
--end

function VipBoxPanel:actionGoods()
	local actionMove = cc.MoveTo:create(0.5,cc.p(133,-98))
	local actionScale = cc.ScaleTo:create(0.5,1)
	local actionSpawn = cc.Spawn:create(actionMove,actionScale)
	local actionSeq = cc.Sequence:create(actionSpawn,cc.CallFunc:create(
		function ()
			self._boxInfoLab:setVisible(true)
			local action1 = cc.MoveBy:create(0.5, cc.p(0,10))
			local action2 = cc.MoveBy:create(0.5, cc.p(0,-10))
			local seqAction = cc.Sequence:create(action1,action2)
			local actions =  cc.RepeatForever:create(seqAction)
			self._iconContainer:runAction(actions)

		end
	))
	self._iconContainer:runAction(actionSeq)
end

function VipBoxPanel:boxAction(box,callfunc)
	local function boxSequence(actTb)
		if #actTb < 1 then return end
		if #actTb < 2 then return actTb[1] end
		local seqAction = actTb[1]
		for i = 2, #actTb do
			seqAction = cc.Sequence:create(seqAction,actTb[i])
		end
		return seqAction
	end
	local actTb = {
		-- cc.MoveBy:create(0.1 ,cc.p(0,30)),
		-- cc.RotateBy:create(0.1,15),
		-- cc.RotateBy:create(0.1,-30),
		-- cc.RotateBy:create(0.1,30),
		-- cc.RotateBy:create(0.1,-30),
		-- cc.RotateBy:create(0.1,30),
		-- cc.RotateBy:create(0.1,-30),
		-- cc.RotateBy:create(0.1,30),
		-- cc.RotateBy:create(0.1,-30),
		-- cc.RotateBy:create(0.1,15),
		cc.CallFunc:create(callfunc)
	}
	local action = boxSequence(actTb)
	box:runAction(action)

end

function VipBoxPanel:onShowHandler()
	local vipProxy = self:getProxy(GameProxys.VIPBox)
	vipProxy:updateCurActivityData()
	local str = vipProxy:getLimitTimeStr()
	self._txtActivityTime:setString(str)
	self._txtActivityDescLab:setString(self:getTextWord(260005))
	local vipLevel = vipProxy:getVipLevel()
	self._txtVipLevel:setString(vipLevel)
	local times = vipProxy:getTimes(101)
	self._txtCanBuyTime:setString(times)
end
 
function VipBoxPanel:updatePanel(typeid)
	typeid = typeid or self.type or self._huangTongBoxType
	self.type = typeid
	local VipBox = ConfigDataManager:getConfigData("VipBoxConfig")
	local showReward = {}
	local price = 0
	local proxy = self:getProxy(GameProxys.VIPBox)
	local effectId = proxy:getEffectId()
	for k, v in pairs(VipBox) do
		if v.type == typeid and v.effectgroup ==  effectId then
			self._boxInfoLab:setString(v.info)
			price = v.price
			local jsonData = StringUtils:jsonDecode(v.showreward)
			for i=1, 4 do
				showReward[i] =  {power = jsonData[i][1],typeid = jsonData[i][2], num = jsonData[i][3]}
				self._UIIcons[i]:updateData(showReward[i])
			end
 		end
	end
	self._txtUseGold:setString(price)
	self.cost = price
	local vipProxy = self:getProxy(GameProxys.VIPBox)
	local times = vipProxy:getTimes(typeid)
	self._txtCanBuyTime:setString(times)
	self.times = times
	local vipLevel = vipProxy:getVipLevel()
	self._txtVipLevel:setString(vipLevel)
end

function VipBoxPanel:onClosePanelHandler()
	self:dispatchEvent(VipBoxEvent.HIDE_SELF_EVENT)
end

function VipBoxPanel:buyBox(sender)
	local function callFunc()
		local data = {}
		local vipBoxProxy = self:getProxy(GameProxys.VIPBox)
		data.activityId = vipBoxProxy:getActivityId()
		data.type = self.type
		vipBoxProxy:onTriggerNet230014Req(data)	
	end
	local vipProxy = self:getProxy(GameProxys.VIPBox)
	local times = vipProxy:getTimes(self.type)
	self.times = times

	if self.times < 1 then
		self:showMessageBox(self:getTextWord(230114))
	else
		local panel = self:getPanel(VipBoxBuyPanel.NAME)

		local needData = self:packageBuyPanelData(self.type)
    	panel:show(needData)
		--[[
		local function okCallBack()
			sender.callFunc = callFunc
			sender.money = self.cost
			self:isShowRechargeUI(sender)
		end
		self:showMessageBox(string.format(self:getTextWord(230115), self.cost),okCallBack)
		]]
	end
end



-- 鏄惁寮圭獥鍏冨疂涓嶈冻
function VipBoxPanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--鎷ユ湁鍏冨疂

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
--缁勮鎵归噺璐拱寮圭獥鎵�闇�瑕佺殑鏁版嵁
function VipBoxPanel:packageBuyPanelData(curType)

	local typeid = curType or self.type or self._huangTongBoxType	
	
	local vipBoxProxy = self:getProxy(GameProxys.VIPBox)

	local effectId = vipBoxProxy:getEffectId()
	local vipBoxConfig = ConfigDataManager:getInfoFindByTwoKey("VipBoxConfig","effectgroup",effectId,"type",typeid)
	--local fixRewardID = StringUtils:jsonDecode(vipBoxConfig.reward)[1]
	--local fixRewardConfig = ConfigDataManager:getConfigById("FixRewardConfig",fixRewardID)
    --
	--local rewardMap = StringUtils:jsonDecode(fixRewardConfig.reward)
	local rewardMap = StringUtils:jsonDecode(vipBoxConfig.reward)
	local reward = rewardMap[1]
	local itemConfig = ConfigDataManager:getConfigById("ItemConfig",reward[2])
	local times = vipBoxProxy:getTimes(typeid)
	local needData = {}
	needData.type = typeid
	needData.maxNum = times
	needData.power = reward[1]
	needData.shopData = {}
	needData.shopData.itemID = reward[2]
	needData.shopData.goldprice = vipBoxConfig.price
	needData.itemData = {}
	needData.itemData.name = itemConfig.name
	needData.itemData.info = itemConfig.info
	return needData
end

function VipBoxPanel:boxMove(index)
    local dy = 0.15
    --if index == self._huangTongBoxType then
    --    local act = cc.Spawn:create(cc.MoveTo:create(dy, cc.p(self._huangTongPanel.posX - 60, self._huangJinPanel.posY)), cc.ScaleTo:create(dy, 1.0))
    --    self._huangJinPanel:runAction(cc.Spawn:create(cc.ScaleTo:create(dy, 0.6), cc.MoveTo:create(dy, cc.p(self._huangJinPanel.posX - 60, self._huangJinPanel.posY))))
    --    self._baiYinPanel:runAction(cc.Spawn:create(cc.MoveTo:create(dy, cc.p(self._baiYinPanel.posX, self._baiYinPanel.posY)), cc.ScaleTo:create(dy, 0.6)))
    --    self._huangTongPanel:runAction(cc.Sequence:create(act, cc.CallFunc:create(function() self:playBoxEffect(index) end)))
    --    self._huangJinPanel:setColor(cc.c3b(125,125,125))
    --    self._baiYinPanel:setColor(cc.c3b(125,125,125))
    --    self._huangTongPanel:setColor(cc.c3b(255,255,255))
    --elseif index == self._baiYinBoxType then
    --    local act = cc.Spawn:create(cc.MoveTo:create(dy, cc.p(self._baiYinPanel.posX + 60, self._huangJinPanel.posY)), cc.ScaleTo:create(dy, 1.0))
    --    self._huangJinPanel:runAction(cc.Spawn:create(cc.ScaleTo:create(dy, 0.6), cc.MoveTo:create(dy, cc.p(self._huangJinPanel.posX + 60, self._huangJinPanel.posY))))
    --    self._baiYinPanel:runAction(cc.Sequence:create(act, cc.CallFunc:create(function() self:playBoxEffect(index) end)))
    --    self._huangTongPanel:runAction(cc.Spawn:create(cc.MoveTo:create(dy, cc.p(self._huangTongPanel.posX, self._huangTongPanel.posY)), cc.ScaleTo:create(dy, 0.6)))
    --    self._huangJinPanel:setColor(cc.c3b(125,125,125))
    --    self._baiYinPanel:setColor(cc.c3b(255,255,255))
    --    self._huangTongPanel:setColor(cc.c3b(125,125,125))
    --elseif index == self._huangJinBoxType then
    --    local act = cc.Spawn:create(cc.ScaleTo:create(dy, 1.0), cc.MoveTo:create(dy, cc.p(self._huangJinPanel.posX, self._huangJinPanel.posY)))
    --    self._huangJinPanel:runAction(cc.Sequence:create(act, cc.CallFunc:create(function() self:playBoxEffect(index) end)))
    --    self._baiYinPanel:runAction(cc.Spawn:create(cc.MoveTo:create(dy, cc.p(self._baiYinPanel.posX, self._baiYinPanel.posY)), cc.ScaleTo:create(dy, 0.6)))
    --    self._huangTongPanel:runAction(cc.Spawn:create(cc.MoveTo:create(dy, cc.p(self._huangTongPanel.posX, self._huangTongPanel.posY)), cc.ScaleTo:create(dy, 0.6)))
    --    self._huangJinPanel:setColor(cc.c3b(255,255,255))
    --    self._baiYinPanel:setColor(cc.c3b(125,125,125))
    --    self._huangTongPanel:setColor(cc.c3b(125,125,125))
    --end

    self._currentSelectedBoxId = index - 100

    if self._boxArr[self._currentSelectedBoxId].pos == 2 then--2点击的是右边，3点击的是左边
        --右转(取前一个的位置)
        for i = 1,#self._boxArr do
            local scal = 0.6
            if index == self._boxArr[i].boxType then
                scal = 1.0
            end
            local idx = self._boxArr[i].pos - 1
            if idx == 0 then
                idx = 3
            end
            local act = cc.Spawn:create(cc.ScaleTo:create(dy, scal), cc.MoveTo:create(dy, cc.p(self._boxPositionArr[idx].x, self._boxPositionArr[idx].y)))
            self._boxArr[i]:runAction(cc.Sequence:create(act, cc.CallFunc:create(function() self:playBoxEffect(index) end)))
            self._boxArr[i].pos = idx--重置新的位置
        end
    elseif self._boxArr[self._currentSelectedBoxId].pos == 3 then
        --左转(取后一个的位置)
        for i = 1,#self._boxArr do
            local scal = 0.6
            if index == self._boxArr[i].boxType then
                scal = 1.0
            end
            local idx = self._boxArr[i].pos + 1
            if idx == 4 then
                idx = 1
            end
            local act = cc.Spawn:create(cc.ScaleTo:create(dy, scal), cc.MoveTo:create(dy, cc.p(self._boxPositionArr[idx].x, self._boxPositionArr[idx].y)))
            self._boxArr[i]:runAction(cc.Sequence:create(act, cc.CallFunc:create(function() self:playBoxEffect(index) end)))
            self._boxArr[i].pos = idx--重置新的位置
        end
    else
        self:playBoxEffect(index)
    end

end

function VipBoxPanel:playBoxEffect(index)
    local effect = nil
    if index == self._huangTongBoxType then
        self._huangJinPanel:setColor(cc.c3b(125,125,125))
        self._baiYinPanel:setColor(cc.c3b(125,125,125))
        self._huangTongPanel:setColor(cc.c3b(255,255,255))
        if self._huangTongPanel.effect == nil then
            effect = self:createUICCBLayer("rgb-vipbx-tong", self._huangTongPanel)
            effect:setLocalZOrder(150)
            self._huangTongPanel.effect = effect
        else
            self._huangTongPanel.effect:setVisible(true)
        end

        if self._huangJinPanel.effect then
            self._huangJinPanel.effect:setVisible(false)
        end
        if self._baiYinPanel.effect then
            self._baiYinPanel.effect:setVisible(false)
        end
        
        if self._huangTongPanel.effectH == nil then
            effectH = self:createUICCBLayer("rgb-vipbx-tongh", self._huangTongPanel)
            effectH:setLocalZOrder(0)
            self._huangTongPanel.effectH = effectH
        else
            self._huangTongPanel.effectH:setVisible(true)
        end

        if self._huangJinPanel.effectH then
            self._huangJinPanel.effectH:setVisible(false)
        end
        if self._baiYinPanel.effectH then
            self._baiYinPanel.effectH:setVisible(false)
        end
    elseif index == self._baiYinBoxType then  
        self._huangJinPanel:setColor(cc.c3b(125,125,125))
        self._baiYinPanel:setColor(cc.c3b(255,255,255))
        self._huangTongPanel:setColor(cc.c3b(125,125,125))
        if self._baiYinPanel.effect == nil then
            effect = self:createUICCBLayer("rgb-vipbx-yin", self._baiYinPanel)
            effect:setLocalZOrder(150)
            self._baiYinPanel.effect = effect
        else
            self._baiYinPanel.effect:setVisible(true)
        end

        if self._huangJinPanel.effect then
            self._huangJinPanel.effect:setVisible(false)
        end
        if self._huangTongPanel.effect then
            self._huangTongPanel.effect:setVisible(false)
        end
        
        if self._baiYinPanel.effectH == nil then
            effectH = self:createUICCBLayer("rgb-vipbx-yinh", self._baiYinPanel)
            effectH:setLocalZOrder(0)
            self._baiYinPanel.effectH = effectH
        else
            self._baiYinPanel.effectH:setVisible(true)
        end

        if self._huangJinPanel.effectH then
            self._huangJinPanel.effectH:setVisible(false)
        end
        if self._huangTongPanel.effectH then
            self._huangTongPanel.effectH:setVisible(false)
        end
    elseif index == self._huangJinBoxType then
        self._huangJinPanel:setColor(cc.c3b(255,255,255))
        self._baiYinPanel:setColor(cc.c3b(125,125,125))
        self._huangTongPanel:setColor(cc.c3b(125,125,125))
        if self._huangJinPanel.effect == nil then
            effect = self:createUICCBLayer("rgb-vipbx-jin", self._huangJinPanel)
            effect:setLocalZOrder(150)
            self._huangJinPanel.effect = effect
        else
            self._huangJinPanel.effect:setVisible(true)
        end

        if self._baiYinPanel.effect then
            self._baiYinPanel.effect:setVisible(false)
        end
        if self._huangTongPanel.effect then
            self._huangTongPanel.effect:setVisible(false)
        end
        
        if self._huangJinPanel.effectH == nil then
            effectH = self:createUICCBLayer("rgb-vipbx-jinh", self._huangJinPanel)
            effectH:setLocalZOrder(0)
            self._huangJinPanel.effectH = effectH
        else
            self._huangJinPanel.effectH:setVisible(true)
        end

        if self._baiYinPanel.effectH then
            self._baiYinPanel.effectH:setVisible(false)
        end
        if self._huangTongPanel.effectH then
            self._huangTongPanel.effectH:setVisible(false)
        end
    end

    

end








VipBoxEffect = class("VipBoxEffect")

--prent 闇�瑕佹坊鍔犵壒鏁堢殑鑺傜偣 type 1宸?涓?鍙?
function VipBoxEffect:ctor(parent, type, ox1, ox2 )
	self.parent = parent 

	-- self.boxSideEffect = UIMovieClip.new("rpg-time")
	-- self.boxSideEffect:setParent(parent)
	-- self.boxSideEffect:setPosition(70,58)
	-- self.boxBgEffect = UIMovieClip.new("rpg-Criticalpoint")
	-- self.boxBgEffect:setParent(parent)
	-- self.boxBgEffect:setPosition(70,58+40)

	-- if type == 1  then
	-- 	self.boxRayEffect1 = UIMovieClip.new("rpg-lightspot")
	-- 	self.boxRayEffect1:setPosition(230,41)
	-- 	self.boxRayEffect2 = UIMovieClip.new("rpg-lightspot")
	-- 	self.boxRayEffect2:setPosition(390,53)
	-- elseif type == 2 then
	-- 	self.boxRayEffect1 = UIMovieClip.new("rpg-lightspot")
	-- 	self.boxRayEffect1:setPosition(-80,58)
	-- 	self.boxRayEffect2 = UIMovieClip.new("rpg-lightspot")
	-- 	self.boxRayEffect2:setPosition(235,58)
	-- else
	-- 	self.boxRayEffect1 = UIMovieClip.new("rpg-lightspot")
	-- 	self.boxRayEffect1:setPosition(-238,49)
	-- 	self.boxRayEffect2 = UIMovieClip.new("rpg-lightspot")
	-- 	self.boxRayEffect2:setPosition(-82,44)
	-- end
	-- self.boxRayEffect1:setParent(parent)
	-- self.boxRayEffect2:setParent(parent)
	local ox = parent:getPositionX()
	local oy = parent:getPositionY()
	self.boxRayEffect1 = self.boxRayEffect1 or UICCBLayer.new("rpg-baoxiang-bi", parent)
	self.boxRayEffect1:setPosition( ox1-ox+220, oy-85 )
	self.boxRayEffect2 = self.boxRayEffect2 or UICCBLayer.new("rpg-baoxiang-bi", parent)
	self.boxRayEffect2:setPosition( ox2-ox+220, oy-85 )

	self.boxRayEffect3 = self.boxRayEffect3 or UICCBLayer.new("rpg-baoxiang-kai", parent)
	self.boxRayEffect3:setPosition( 50, oy-85 )
	self.boxRayEffect3:setVisible(false)
end

function VipBoxEffect:delyFunction1()
	-- self.boxBgEffect:setVisible(true)
	-- self.boxBgEffect:play(false,function ()
	-- 	self.boxBgEffect:setVisible(false)
	-- end)
	local boxBgEffect = UICCBLayer.new("rpg-kaibaoxiang", self.parent, nil, nil, true )
	boxBgEffect:setPosition(70,58+40)
end

function VipBoxEffect:delyFunction2()
	--self.boxRayEffect1:stopAllActions()
	self.boxRayEffect1:setVisible(true)
	--self.boxRayEffect1:play(true)
	--self.boxRayEffect2:stopAllActions()
	self.boxRayEffect2:setVisible(true)
	--self.boxRayEffect2:play(true)
	self.boxRayEffect3:setVisible( true )
end

function VipBoxEffect:play()
	TimerManager:addOnce(10,self.delyFunction1,self)
	TimerManager:addOnce(200,self.delyFunction2,self)
	self.boxRayEffect1:setVisible(false)
	self.boxRayEffect2:setVisible(false)
	
	-- self.boxSideEffect:setVisible(true)
	-- self.boxSideEffect:play(false,function ()
	-- 	self.boxSideEffect:setVisible(false)
	-- 	self.boxRayEffect3:setVisible( true )
	-- end)
end

function VipBoxEffect:setVisible(isVisible)
	--self.boxSideEffect:setVisible(isVisible)
	self.boxRayEffect1:setVisible(isVisible)
	self.boxRayEffect2:setVisible(isVisible)
	-- self.boxBgEffect:setVisible(isVisible)
end

function VipBoxEffect:hide()
	self:setVisible(false)
	self.boxRayEffect3:setVisible(false)
	TimerManager:remove(self.delyFunction1, self)
	TimerManager:remove(self.delyFunction2, self)
end

function VipBoxEffect:show()
	self:setVisible(true)
end
--璐拱鎸夐挳鍥炶皟
function VipBoxEffect:VipBoxBuyPanel(sender)
    local panel = self:getPanel(VipBoxBuyPanel.NAME)
    local data = sender.data
    panel:show(data)
end 
