-- 拜访名匠
LotteryEquipPanel = class("LotteryEquipPanel", BasicPanel)
LotteryEquipPanel.NAME = "LotteryEquipPanel"

function LotteryEquipPanel:ctor(view, panelName)
    LotteryEquipPanel.super.ctor(self, view, panelName,true)
    local lotteryProxy = self:getProxy(GameProxys.Lottery)
    self._allInfos = lotteryProxy:onGetUpdateTimeInfos()  --getLotteryInfos()
end

function LotteryEquipPanel:finalize()
    LotteryEquipPanel.super.finalize(self)
end

function LotteryEquipPanel:initPanel()
	LotteryEquipPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true,"zhaomu",true)

	self._currType = 3
	self._allPos = {}
	for index = 1,3 do
		local item = self:getChildByName("topPanel/item"..index)
		item.pos = index
		item.type = index
		self._allPos[index] = {x= item:getPositionX(),y = item:getPositionY()}
		if index ~= self._currType then
		  item:setScale(0.65)
		end
	end
	self:registerEvent()
	self:setPanelStatus(true,false)
end

function LotteryEquipPanel:setPanelStatus(isShow,noShow)
	local downPanel = self:getChildByName("downPanel")
	local topPanel = self:getChildByName("topPanel")
	local Image_130 = self:getChildByName("Image_130")
	local downPanel9 = self:getChildByName("downPanel9")
	downPanel:setVisible(isShow)
	topPanel:setVisible(isShow)
	Image_130:setVisible(noShow)
	downPanel9:setVisible(noShow)
end

function LotteryEquipPanel:setNinePictStatus(isShow)
	local Image_130 = self:getChildByName("Image_130")
	for index = 1,9 do
		local item = Image_130:getChildByName("item"..index)
		item:setVisible(isShow)
	end
	local item = Image_130:getChildByName("item5")
	item:setVisible(true)
end

function LotteryEquipPanel:registerEvent()
	self._leftBtn = self:getChildByName("topPanel/leftBtn")
	self._rightBtn = self:getChildByName("topPanel/rightBtn")
	self._leftBtn.type = -1
	self._rightBtn.type = 1
	self:addTouchEventListener(self._leftBtn,self.setTurnHandle1)
	self:addTouchEventListener(self._rightBtn,self.setTurnHandle1)

	self._tenBtn = self:getChildByName("downPanel/tenBtn")
	self._tenBtn.type = 4
	local lookBtn = self:getChildByName("downPanel/lookBtn")
	self._normalBtn = self:getChildByName("downPanel/normalBtn")
	
	self:addTouchEventListener(self._tenBtn,self.onNormalLotteryHandle)
	self:addTouchEventListener(self._normalBtn,self.onNormalLotteryHandle)
	self:addTouchEventListener(lookBtn,self.onLookEquipHandler)

	local exitBtn = self:getChildByName("downPanel9/exitBtn")
	self._nineAgainBtn = self:getChildByName("downPanel9/nineAgainBtn")
	self._nineAgainBtn.type = 4
	self._onceAgainBtn = self:getChildByName("downPanel9/onceAgainBtn")

	self:addTouchEventListener(exitBtn,self.onExitChoose)
	self:addTouchEventListener(self._nineAgainBtn,self.onNormalLotteryHandle)
	self:addTouchEventListener(self._onceAgainBtn,self.onNormalLotteryHandle)
	self:registerTopPanel()
end

function LotteryEquipPanel:registerTopPanel()
	local topPanel = self:getChildByName("topPanel")
	local function onNodePosExchange(pos)
		local pos = topPanel:getParent():convertToNodeSpace(cc.p(pos.x, pos.y))
		return pos.x
	end

	local sender = {}
	sender.type = -1
	local function onTouchHandler(sender, eventType)
        if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        	-- if self._posTime >= 2 then
        	-- 	self._posTime = 0
        	-- else
        	-- 	return
        	-- end
            local pos = sender:getTouchEndPosition()
            local endPosX = onNodePosExchange(pos)
            if endPosX - self._beginPosX  >= 5 then
            	sender.type = 1
            	self:setTurnHandle(sender)
            elseif endPosX - self._beginPosX  <= -5 then
            	sender.type = -1
            	self:setTurnHandle(sender)
            end
        elseif eventType == ccui.TouchEventType.began then
        	local pos = sender:getTouchBeganPosition()
            self._beginPosX = onNodePosExchange(pos)
        end
    end
    topPanel:setTouchEnabled(true)
    topPanel:addTouchEventListener(onTouchHandler)
end

function LotteryEquipPanel:update(dt)
	--print("time===",dt)
	--self._oneSeconds = not self._oneSeconds
	--if  self._oneSeconds then
		self:updateTime()
	--end
	-- self._posTime = self._posTime + 1.5
	-- if self._posTime > 10000 then
	-- 	self._posTime = 0
	-- end
end

function LotteryEquipPanel:onExitChoose(sender)
	self:setCloseBtnStatus(true)
	self:setPanelStatus(true,false)
end

function LotteryEquipPanel:onNormalLotteryHandle(sender)
	local type = sender.type
	local totalMoney = 0
	if type == 4 then  --9连抽没有免费的
		totalMoney = self._tenBtn.money
	else
		totalMoney = self._normalBtn.money
	end
	local data = {}
	data.type = sender.type
	if totalMoney > 0 then
		-- 元宝招募
		local function okcallbk()
			AudioManager:playEffect("yx_equip")
			-- self:dispatchEvent(LotteryEquipEvent.CHOOSE_LOTTERY_REQ,data)

			local function callFunc()
			    -- 请求
			    local lotteryProxy = self:getProxy(GameProxys.Lottery)
			    -- lotteryProxy:onGetLotteryReq(data)
			    lotteryProxy:onTriggerNet150001Req(data)
				--self:dispatchEvent(LotteryEquipEvent.CHOOSE_LOTTERY_REQ,data)
			end
			sender.callFunc = callFunc
			sender.money = totalMoney
			self:isShowRechargeUI(sender)
		end

		-- local str = "你确定要花费"..totalMoney.."元宝吗?"
		local str = string.format(self:getTextWord(1817), totalMoney)

		local messageBox = self:showMessageBox(str,okcallbk)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)

	else
		AudioManager:playEffect("yx_equip")

		local lotteryProxy = self:getProxy(GameProxys.Lottery)
	    -- lotteryProxy:onGetLotteryReq(data)
	    lotteryProxy:onTriggerNet150001Req(data)

		--self:dispatchEvent(LotteryEquipEvent.CHOOSE_LOTTERY_REQ,data)
	end
end

-- 是否弹窗元宝不足
function LotteryEquipPanel:isShowRechargeUI(sender)
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
--打开武将 panel
function LotteryEquipPanel:onLookEquipHandler()
--	self:onClosePanelHandler()
	self:dispatchEvent(LotteryEquipEvent.OPEN_EQUIP_MODULE)
end

function LotteryEquipPanel:onClosePanelHandler()
	--self:reSetTurn()
	self:onBeginFreeSetHandle()
    self.view:hideModuleHandler()
end

function LotteryEquipPanel:setTurnHandle(sender)
	
	 if self._oldMove then
		for index = 1 ,3 do
			local item = self:getChildByName("topPanel/item"..index)
			item:stopAllActions()
			self:stopActionsToSetPosition(item)
		end
	end

	local move = -1
	if sender.type == -1 then
		move = -1
	else
		move = 1
	end
	self._oldMove = move
	if self._currType +  0 - move > 3 then
		self._currType = 1
	elseif self._currType +  0 - move < 1 then
		self._currType = 3
	else
		self._currType = self._currType +  0 - move
	end
	for index = 1 ,3 do
		local item = self:getChildByName("topPanel/item"..index)
		self:onMoveItem(item,move)
	end
	self:updateBtnInfo()
end

function LotteryEquipPanel:setTurnHandle1(sender)
	-- if self._posTime >= 1 then
 --        self._posTime = 0
 --    else
 --        return
 --    end
 	if self._oldMove then
		for index = 1 ,3 do
			local item = self:getChildByName("topPanel/item"..index)
			item:stopAllActions()
			self:stopActionsToSetPosition(item)
		end
	end


	local move = -1
	if sender.type == -1 then
		move = -1
	else
		move = 1
	end
	self._oldMove = move
	if self._currType +  0 - move > 3 then
		self._currType = 1
	elseif self._currType +  0 - move < 1 then
		self._currType = 3
	else
		self._currType = self._currType +  0 - move
	end
	for index = 1 ,3 do
		local item = self:getChildByName("topPanel/item"..index)
		self:onMoveItem(item,move)
	end
	self:updateBtnInfo()
end

function LotteryEquipPanel:stopActionsToSetPosition(item)
	item:setPosition(item.oldPosition)
	item:setScale(item.oldScalevar)
end


function LotteryEquipPanel:onMoveItem(item,type)
	if item.pos + type > 3 then
		item.pos = 1
	elseif item.pos + type < 1 then
		item.pos = 3
	else
		item.pos = item.pos + type
	end
	local scaleVar
	if item.type == self._currType then
		item:setLocalZOrder(10)
		--item:setScale(1.0)
		scaleVar = 1.0	
	else
		-- item:setScale(0.65)
		scaleVar = 0.65
		item:setLocalZOrder(5)
	end
	local scaleAction = cc.ScaleTo:create(0.2, scaleVar)
	item.oldScalevar = scaleVar
	item.oldPosition = cc.p(self._allPos[item.pos].x,self._allPos[item.pos].y)
	local action = cc.MoveTo:create(0.2, cc.p(self._allPos[item.pos].x,self._allPos[item.pos].y))
	local spawn = cc.Spawn:create(scaleAction, action)
	item:runAction(spawn)
end

function LotteryEquipPanel:reSetTurn(pos)
	if pos == nil then
		if self._currType == 1 then
			self:setTurnHandle(self._rightBtn)
		elseif self._currType == 2 then
			self:setTurnHandle(self._leftBtn)
		end
	else
		if pos == 1 then
			if self._currType == 2 then
				self:setTurnHandle(self._rightBtn)
			elseif self._currType == 3 then
				self:setTurnHandle(self._leftBtn)
			end
		elseif pos == 2 then
			if self._currType == 1 then
				self:setTurnHandle(self._leftBtn)
			elseif self._currType == 3 then
				self:setTurnHandle(self._rightBtn)
			end
		end		
	end
end

function LotteryEquipPanel:updateItemInfo()
	for _,v in pairs(self._allInfos) do
		local item = self:getChildByName("topPanel/item"..v.type)
		local Image_23 = item:getChildByName("Image_23")
		local Label_25 = Image_23:getChildByName("Label_25")
		local freeCount = Image_23:getChildByName("freeCount")
		if v.freeTimes <= 0 then
			Label_25.time = v.time
			Label_25:setVisible(true)
			freeCount:setVisible(false)
			if Label_25.time <= 0 then
				Label_25:setVisible(false)
				freeCount:setVisible(true)
				freeCount:setString(self:getTextWord(1831))
			end
		else
			Label_25.time = nil
			Label_25:setVisible(false)
			freeCount:setVisible(true)
			--freeCount:setString("免费抽"..v.freeTimes.."次")
			freeCount:setString(self:getTextWord(1818)..v.freeTimes..self:getTextWord(1819))
		end
		if v.type == 3 then
			local Label_18 = item:getChildByName("Label_18")
			local str
			if v.willNum > 0 then
				str = self:getTextWord(1803)..v.willNum..self:getTextWord(1801)
			else
				str = self:getTextWord(1802)..self:getTextWord(1801)
			end
			Label_18:setString(str)
		end
	end
end



function LotteryEquipPanel:updateBtnInfo()
	local info
	for _,v in pairs(self._allInfos) do
		if v.type == self._currType then
			info = v
			break
		end
	end

	if info == nil then
		return
	end

	if self._currType == 3 then
		self._tenBtn:setVisible(true)
		self._nineAgainBtn:setVisible(true)
		self._tenBtn.money = info.cost * 9
		local Label_10 = self._tenBtn:getChildByName("Label_10")
		Label_10:setString(self._tenBtn.money)--StringUtils:formatNumberByK(self._tenBtn.money))
	else
		self._tenBtn:setVisible(false)
		self._nineAgainBtn:setVisible(false)
	end

	local Label_10_0 = self._normalBtn:getChildByName("Label_10_0")
	local Image_11_0 = self._normalBtn:getChildByName("Image_11_0")
	local freelabel = self._normalBtn:getChildByName("freelabel")

	if info.freeTimes > 0 then
		--self._normalBtn:setTitleText("免费抽")
		self._normalBtn:setTitleText(self:getTextWord(1818))
		self._normalBtn.money = 0
		Label_10_0:setVisible(false)
		Image_11_0:setVisible(false)
		freelabel:setVisible(true)
		--freelabel:setString("免费次数:"..info.freeTimes)
		freelabel:setString(self:getTextWord(1820)..info.freeTimes)
	else
		--self._normalBtn:setTitleText("抽1次")
		self._normalBtn:setTitleText(self:getTextWord(1821))
		self._normalBtn.money = info.cost
		Label_10_0:setString(StringUtils:formatNumberByK(info.cost))
		Label_10_0:setVisible(true)
		Image_11_0:setVisible(true)
		freelabel:setVisible(false)
	end
	self._normalBtn.type = self._currType
end

function LotteryEquipPanel:updateTime()
	--print("111")
	local lotteryProxy = self:getProxy(GameProxys.Lottery)
	local netInfos = lotteryProxy:getNetInfos()
	--local currentInfo = lotteryProxy:getLotteryInfos()
	for index = 1 ,3 do
		local item = self:getChildByName("topPanel/item"..index)
		local Image_23 = item:getChildByName("Image_23")
		local Label_25 = Image_23:getChildByName("Label_25")
		local Label_25_0
		if index == 3 then
			Label_25_0 = Label_25:getChildByName("Label_25_0")
		else
			Label_25_0 = Label_25:getChildByName("Label_25_0_1")
		end
		local freeCount = Image_23:getChildByName("freeCount")
		local remainTime = lotteryProxy:getRemainTime("Lottery_infos"..index)

		if Label_25.time ~= nil then
			local time = TimeUtils:getStandardFormatTimeString(remainTime)
			Label_25:setString(time)
			Label_25_0:setString(self:getTextWord(1830))
			--Label_25.time = Label_25.time - 1
			--if Label_25.time <= 0 then
			if remainTime <= 0 then
				Label_25.time = nil
				Label_25:setVisible(false)
				freeCount:setVisible(true)
				-- if self._allInfos[index].freeTimes > 0 then
				-- 	--freeCount:setString(self:getTextWord(1818)..self._allInfos[index].freeTimes..self:getTextWord(1819))
				-- else
				-- 	--freeCount:setString("今日免费抽取已达上限")
				-- end
				if netInfos[index].time > 0 and netInfos[index].freeTimes == 0 then
					lotteryProxy:onTriggerNet150000Req()
				end
			end
		end
	end
end

function LotteryEquipPanel:onBeginFreeSetHandle()
	local pos = 0
	if #self._allInfos == 0 then
		return
	end
	for _,v in pairs(self._allInfos) do
		if v.freeTimes > 0 then
			if v.type >= pos then
				pos = v.type
			end
		end
	end
	if pos == 0 or pos == 3 then
		self:reSetTurn()
	else
		self:reSetTurn(pos)
	end
end

function LotteryEquipPanel:onGetLotteryInfoResp(type)
	local lotteryProxy = self:getProxy(GameProxys.Lottery)
    self._allInfos = lotteryProxy:onGetUpdateTimeInfos()--getLotteryInfos()

	if type == true then
		self:onBeginFreeSetHandle()
	end
	self:updateItemInfo()
	self:updateBtnInfo()

	for index = 1,3 do
		local item = self:getChildByName("topPanel/item"..index)
		local Image_23 = item:getChildByName("Image_23")
		--Image_23:setVisible(false)
		local Label_25 = Image_23:getChildByName("Label_25")
		local Label_25_0
		if index == 3 then
			Label_25_0 = Label_25:getChildByName("Label_25_0")
		else
			Label_25_0 = Label_25:getChildByName("Label_25_0_1")
		end
		Label_25:setString("")
		Label_25_0:setString("")
	end
end

function LotteryEquipPanel:onUpdateGold(gold)
	local money = self:getChildByName("downPanel/money")
	money:setString(gold)
end

function LotteryEquipPanel:writeItem(item,itemData)
	local Image_54 = item:getChildByName("Image_54_0")
	local Image_57 = item:getChildByName("Image_118")
	local Image_166 = item:getChildByName("Image_166")
	local attr = item:getChildByName("attr")

    local config = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",itemData)

    local url = "images/general/"..config.icon..".png"
    TextureManager:updateImageView(Image_54, url)
    attr:setString(config.name)
    attr:setColor(ColorUtils:getColorByQuality(config.quality))
    if Image_166.url ~= config.quality then
        Image_166.url = config.quality
	    url = "images/gui/Frame_character"..config.quality.."_none.png"
	    TextureManager:updateImageView(Image_166, url)
	end
    local littleicon = config.littleicon
    local imgPath = "images/newGui1/none.png"
    if littleicon ~= 0 then
    	imgPath =  string.format("images/equip/type%d.png", littleicon)

    end
    TextureManager:updateImageView(Image_57, imgPath)
    self:updateMovieChip(Image_166,config)
end

function LotteryEquipPanel:updateChooseResp(data)
	self:setCloseBtnStatus(false)
	if data.type == 4 then
		self:setNinePictStatus(true)
		local index = 1
		for k,v in pairs(data.equips) do
			local function call()
				self:writeItem(self:getChildByName("Image_130/item"..k),v)
			end
			self:playAction("item"..index,call)
			call()
			index = index + 1
		end
		self._onceAgainBtn.type = 3
	else
		local item,_data
		for _,v in pairs(data.equips) do
			item = self:getChildByName("Image_130/item5")
			_data = v
		end
		self:setNinePictStatus(false)
		local function call()
			self:writeItem(item,_data)
		end
		self:playAction("item5", call)
		call()
		self._onceAgainBtn.type = data.type
	end
	local Label_106 = self:getChildByName("downPanel9/Label_106")
	local Label_108 = self:getChildByName("downPanel9/Label_108")
	local Label_109 = self:getChildByName("downPanel9/Label_109")
	if 3 == self._currType or self._currType == 4 then
		Label_106:setVisible(true)
		local currData
		for _,v in pairs(data.equipLotterInfos) do
			if v.type == 3 or v.type == 4 then
				currData = v
				--Label_106:setString("再抽"..v.willNum.."次必得紫将")
				Label_106:setString(self:getTextWord(1822)..v.willNum..self:getTextWord(1823))
				break
			end
		end
		if currData.freeTimes <= 0 then
			Label_108:setVisible(true)
			Label_109:setVisible(true)
			Label_108:setString(currData.cost * 9)
			Label_109:setString(currData.cost)
		else
			Label_108:setVisible(false)
			Label_109:setVisible(false)
		end
	else
		Label_108:setVisible(false)
		local currData
		for _,v in pairs(data.equipLotterInfos) do
			if v.type == self._currType then
				currData = v
				break
			end
		end
		if currData.freeTimes <= 0 then
			Label_109:setVisible(true)
			Label_106:setVisible(false)
			Label_109:setString(currData.cost)
		else
			Label_109:setVisible(false)
			Label_106:setVisible(true)
			--Label_106:setString("剩余免费次数"..currData.freeTimes)
			Label_106:setString(self:getTextWord(1824)..currData.freeTimes)
		end
	end
	self:setPanelStatus(false,true)
end

function LotteryEquipPanel:updateMovieChip(parent,config)
    if config.effectbigframe ~= nil then
        if parent.movieChip ~= nil then
            if parent.effectbigframe ~= config.effectbigframe then
                parent.movieChip:finalize()
                local movieChip = UIMovieClip.new(config.effectbigframe)
                movieChip:setParent(parent)
                movieChip:setNodeAnchorPoint(cc.p(0.05, 0.1))
                movieChip:setScale(1.0)
                parent.movieChip = movieChip
                parent.effectbigframe = config.effectbigframe
            end
        else
            local movieChip = UIMovieClip.new(config.effectbigframe)
            movieChip:setParent(parent)
            movieChip:setNodeAnchorPoint(0.05, 0.1)
            movieChip:play(true)
            movieChip:setScale(1.0)
            parent.movieChip = movieChip
            parent.effectbigframe = config.effectbigframe
        end
    else
        if parent.movieChip ~= nil then
            parent.movieChip:finalize()
            parent.movieChip = nil
            parent.effectbigframe = nil
        end 
    end
end