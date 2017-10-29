
ConsigliereRecruitsPanel = class("ConsigliereRecruitsPanel", BasicPanel)
ConsigliereRecruitsPanel.NAME = "ConsigliereRecruitsPanel"

function ConsigliereRecruitsPanel:ctor(view, panelName)
    ConsigliereRecruitsPanel.super.ctor(self, view, panelName)
    self.info = {}
	-- self._skin = UISkin.new(self._panelName, initHandler, doLayoutHanlder, self:getModuleName())
	-- self._uiPanelBg = UIPanelBg.new(self._skin:getRootNode())

    self:setUseNewPanelBg(true)
end

function ConsigliereRecruitsPanel:finalize()
	if self._eftlv then
		self._eftlv:finalize()
		self._eftlv = nil
	end
	if self._eftlan then
		self._eftlan:finalize()
		self._eftlan = nil
	end
	if self._uiRecharge then
		self._uiRecharge:finalize()
		self._uiRecharge = nil
	end
    ConsigliereRecruitsPanel.super.finalize(self)
end

function ConsigliereRecruitsPanel:initPanel()
	ConsigliereRecruitsPanel.super.initPanel(self)
	self._proxy = self:getProxy(GameProxys.Consigliere)

	self._roleProxy = self:getProxy(GameProxys.Role)

	self._panel = self:getChildByName("Panel_1")

	-- local image_1 = self:getChildByName("Panel_1/image_1")
	-- TextureManager:updateImageView(image_1, "images/roleInfo/hz9006.png")

    -- self.Img_bg = self:getChildByName("Img_bg")
    -- TextureManager:updateImageViewFile( self.Img_bg,"bg/consigliere/room.jpg")
    -- self:initUi()
    -- self:setBgType(ModulePanelBgType.ROOM)
	-- self.fiveCb = self:getChildByName("Panel_1/fiveCb")
	-- self:addTouchEventListener(self.fiveCb, self.fiveTouch)

	local dimesImg = self:getChildByName("Panel_1/Image_91_0")
	local coinImg = self:getChildByName("Panel_1/Image_91_0_1")

	--多行描述
	local desc1 = self._panel:getChildByName( "desc1" )
	local desc2 = self._panel:getChildByName( "desc2" )
	local oy = desc1:getPositionY()
	local dHeight = math.abs(oy - desc2:getPositionY())

	local desWords = self:getTextWord( 270081 )
	for i, word in ipairs(desWords) do
		local desc = self._panel:getChildByName("desc"..i)
		if not desc then
			desc = desc1:clone()
			self._panel:addChild( desc )
		end
		desc:setString( word )
		desc:setPositionY( oy-dHeight*(i-1) )
	end

	dimesImg.type = 2
	coinImg.type = 1

	local function onTouchHandler( sender, evenType )
		if evenType == ccui.TouchEventType.began then
			sender:setScale(0.93)
		elseif evenType>=ccui.TouchEventType.ended then
			sender:setScale(1)
			if evenType==ccui.TouchEventType.ended then
				self:buyConsigliere( sender )
			end
		end
	end
	-- self:addTouchEventListener(dimesImg, self.buyConsigliere )
	-- self:addTouchEventListener(coinImg, self.buyConsigliere )
	coinImg:addTouchEventListener(onTouchHandler)
	dimesImg:addTouchEventListener(onTouchHandler)


	if not self._eftlv then
		local size = dimesImg:getContentSize()
		self._eftlv = UICCBLayer.new("rgb-jsf-tixinglv", dimesImg)
		self._eftlv:setPosition( size.width*0.5, size.height*0.5 )
	end

	if not self._eftlan then
		local size = coinImg:getContentSize()
		self._eftlan = UICCBLayer.new("rgb-jsf-tixinglan", coinImg)
		self._eftlan:setPosition( size.width*0.5, size.height*0.5 )
	end
end


function ConsigliereRecruitsPanel:registerEvents()
	ConsigliereRecruitsPanel.super.registerEvents(self)
	local buyas=self:getChildByName("Panel_1/buyas")
	buyas.type=2
	self:addTouchEventListener(buyas, self.onbuya )
	local buyts=self:getChildByName("Panel_1/buyts")
	buyts.type=2
	self:addTouchEventListener(buyts, self.onbuyt )
	local buyay=self:getChildByName("Panel_1/buyay")
	buyay.type=1
	self:addTouchEventListener(buyay, self.onbuya )
	local buyty=self:getChildByName("Panel_1/buyty")
	buyty.type=1
	self:addTouchEventListener(buyty, self.onbuyt )

end
function ConsigliereRecruitsPanel:onbuya( sender)
self._sender=sender:getName()=="buyas" and  self:getChildByName("Panel_1/Image_91_0") or self:getChildByName("Panel_1/Image_91_0_1")
self:buyConsig(sender.type,1)
end
function ConsigliereRecruitsPanel:onbuyt( sender)
self._sender=sender:getName()=="buyts" and  self:getChildByName("Panel_1/Image_91_0") or self:getChildByName("Panel_1/Image_91_0_1")
self:buyConsig(sender.type,5)
end

function ConsigliereRecruitsPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	local panel = self:getChildByName("Panel_1")
	NodeUtils:adaptiveTopPanelAndListView(panel, nil, nil, tabsPanel)
    -- NodeUtils:adaptivePanelBg( self.Img_bg,0 --[[GlobalConfig.downHeight-25]], tabsPanel) --遮罩  


end

function ConsigliereRecruitsPanel:onShowHandler()
	self:getPanel(ConsiglierePanel.NAME):setblacklayer(true)
    self._silverDiscount = self._proxy:getSilverDiscount() 
    self._goldDiscount   = self._proxy:getGoldDiscount()
	self.isDoing = nil
	self.curNumType = 1
	self:showBg( true )
	-- self.fiveCb:setSelectedState(false)
	self:updateView()
end

function ConsigliereRecruitsPanel:updateView()
	--判断是否居中排序标记
	local isBtnAlign = {
		false,false,false,false,
	}

	local buyas=self:getChildByName("Panel_1/buyas")--抽一次
	local buyts=self:getChildByName("Panel_1/buyts")--抽5次
	local buyay=self:getChildByName("Panel_1/buyay")--抽一次
	local buyty=self:getChildByName("Panel_1/buyty")--抽5次

	local image_1 = self:getChildByName("Panel_1/image_1")--第一个按钮:银币
	local image_1_0 = self:getChildByName("Panel_1/image_1_0")--第二个按钮:银币
	local image_2 = self:getChildByName("Panel_1/image_2")--第三个按钮:元宝
	local image_2_0 = self:getChildByName("Panel_1/image_2_0")--第四个按钮:元宝

	local dimesLab = self:getChildByName("Panel_1/text_1")--第一个按钮:优惠价格
	local coinLab = self:getChildByName("Panel_1/text_2")--第三个按钮:优惠价格
	-- local point1 = self:getChildByName("Panel_1/imgPoint1")
	-- local point2 = self:getChildByName("Panel_1/imgPoint2")

    -- 打折文本
    local offText01 = self:getChildByName("Panel_1/offText01")--第一个按钮:免费
    local offText02 = self:getChildByName("Panel_1/offText02")--第三个按钮:免费
    offText01:setVisible(false)
    offText02:setVisible(false)
    local textLine01 = dimesLab:getChildByName("textLine01")
    local textLine02 = coinLab:getChildByName("textLine02")
    textLine01:setVisible(false)
    textLine02:setVisible(false)

    local dimesLab5 = self:getChildByName("Panel_1/text_1_0")----第二个按钮:优惠价格
	local coinLab5 = self:getChildByName("Panel_1/text_2_0")----第四个按钮:优惠价格
    -- 打折文本
    local offText501 = self:getChildByName("Panel_1/offText01_0")
    local offText502 = self:getChildByName("Panel_1/offText02_0")
    offText501:setVisible(false)
    offText502:setVisible(false)
    local textLine501 = dimesLab5:getChildByName("textLine01")
    local textLine502 = coinLab5:getChildByName("textLine02")
    textLine501:setVisible(false)
    textLine502:setVisible(false)

	local buyData = self._proxy:getRecruitInfo()--一倍
	local needRes = buyData[2]["onceprice"]
	local resText = StringUtils:formatNumberByK(needRes)
	dimesLab:setString(resText)
	if needRes == 0 then
		dimesLab:setString(self:getTextWord(8404)) 
	end
	local needCoin = buyData[1]["onceprice"]
	local coinText = StringUtils:formatNumberByK(needCoin)
	coinLab:setString(coinText)
	if needCoin == 0 then
		coinLab:setString(self:getTextWord(8404))
	end

	local needRes5 = buyData[2]["fiveprice"]--5倍
	local resText5 = StringUtils:formatNumberByK(needRes5)
	dimesLab5:setString(resText5)
	-- point1:setVisible( needRes==0 )
	if needRes5 == 0 then
		dimesLab5:setString(self:getTextWord(8404)) 
	end

	local needCoin5 = buyData[1]["fiveprice"]
	local coinText5 = StringUtils:formatNumberByK(needCoin5)
	coinLab5:setString(coinText5)
	-- point2:setVisible( needCoin==0 )
	if needCoin5 == 0 then
		coinLab5:setString(self:getTextWord(8404))
	end

--
	-- local key = self.curNumType == 1 and "onceprice" or "fiveprice"
	
	-- local needRes = buyData[2][key]
	-- local resText = StringUtils:formatNumberByK(needRes)
	-- dimesLab:setString(resText)
	-- -- point1:setVisible( needRes==0 )
	-- if needRes == 0 then
	-- 	dimesLab:setString(self:getTextWord(8404)) 
	-- end

	-- local needCoin = buyData[1][key]
	-- local coinText = StringUtils:formatNumberByK(needCoin)
	-- coinLab:setString(coinText)
	-- -- point2:setVisible( needCoin==0 )
	-- if needCoin == 0 then
	-- 	coinLab:setString(self:getTextWord(8404))
	-- end

    -- 打折设置
    if self._silverDiscount ~= 1 and needRes ~= 0 then
        offText01:setVisible(true)
        textLine01:setVisible(true)
        textLine01:setContentSize(dimesLab:getContentSize().width, textLine01:getContentSize().height)
        
        local disCountNum = StringUtils:formatNumberByK( math.ceil(needRes*self._silverDiscount))
        offText01:setString(disCountNum)
        NodeUtils:alignNodeL2R(dimesLab, offText01, 5)
        NodeUtils:centerNodesGlobal(buyas,{image_1,dimesLab, offText01})
        isBtnAlign[1] = true
    end

    if self._goldDiscount ~= 1 and needCoin ~= 0 then
        offText02:setVisible(true)
        textLine02:setVisible(true)
        textLine02:setContentSize(coinLab:getContentSize().width, textLine02:getContentSize().height)

        local disCountNum = StringUtils:formatNumberByK( math.ceil(needCoin*self._goldDiscount))
        offText02:setString(disCountNum)
        NodeUtils:alignNodeL2R(coinLab, offText02, 10)
        NodeUtils:centerNodesGlobal(buyay,{image_2,coinLab, offText02})
        isBtnAlign[2] = true
    end

    -- 打折设置
    if self._silverDiscount ~= 1 and needRes5 ~= 0 then
        offText501:setVisible(true)
        textLine501:setVisible(true)
        textLine501:setContentSize(dimesLab5:getContentSize().width, textLine501:getContentSize().height)
        
        local disCountNum5 = StringUtils:formatNumberByK( math.ceil(needRes5*self._silverDiscount))
        offText501:setString(disCountNum5)
        NodeUtils:alignNodeL2R(dimesLab5, offText501, 5)
        NodeUtils:centerNodesGlobal(buyts,{image_1_0,dimesLab5, offText501})
        isBtnAlign[3] = true
    end

    if self._goldDiscount ~= 1 and needCoin5 ~= 0 then
        offText502:setVisible(true)
        textLine502:setVisible(true)
        textLine502:setContentSize(coinLab5:getContentSize().width, textLine502:getContentSize().height)

        local disCountNum5 = StringUtils:formatNumberByK( math.ceil(needCoin5*self._goldDiscount))
        offText502:setString(disCountNum5)
        NodeUtils:alignNodeL2R(coinLab5, offText502, 10)
        NodeUtils:centerNodesGlobal(buyty,{image_2_0,coinLab5, offText502})
        isBtnAlign[4] = true
    end

    if not isBtnAlign[1] then
        NodeUtils:centerNodesGlobal(buyas,{image_1,dimesLab})
    end
    if not isBtnAlign[2] then
        NodeUtils:centerNodesGlobal(buyay,{image_2,coinLab, })
    end
    if not isBtnAlign[3] then
        NodeUtils:centerNodesGlobal(buyts,{image_1_0,dimesLab5, })
    end
    if not isBtnAlign[4] then
        NodeUtils:centerNodesGlobal(buyty,{image_2_0,coinLab5, })
    end
end

-- function ConsigliereRecruitsPanel:fiveTouch(sender)
-- 	local state = sender:getSelectedState()

-- 	if state then
-- 		self.curNumType = 1
-- 	else
-- 		self.curNumType = 5
-- 	end
-- 	self:updateView()
-- end

-- function ConsigliereRecruitsPanel:buyConsigliere(sender)
-- 	if self.isDoing then return end
	

-- 	local buyType = sender.type
-- 	self._sender = sender
-- 	local function buy()
-- 		self.isDoing = true
-- 		self._proxy:onTriggerNet260005Req({type = buyType, num = self.curNumType})
-- 	end

-- 	local buyData = self._proxy:getRecruitInfo()
-- 	local key = self.curNumType == 1 and "onceprice" or "fiveprice"
-- 	local needCoin = buyData[buyType][key]
-- 	local function callback()
-- 		self:isShowRechargeUI({money = needCoin, callFunc = buy})
-- 	end
-- 	local function callbackCent()
-- 		-- self.isDoing = nil
-- 	end
--     -- 1 元宝， 2银币
-- 	local context = buyType == 1 and TextWords:getTextWord(270077) or TextWords:getTextWord(270078)
--     -- 无打折
--     needCoin = buyType == 1 and needCoin*self._goldDiscount or needCoin*self._silverDiscount
--     -- 向上取整
--     needCoin = math.ceil(needCoin)
-- 	if buyType == 1 then
--         local numString = StringUtils:formatNumberByK(needCoin)
-- 		self:showMessageBox( string.format(context, numString), callback, callbackCent) -- -%d 会向上取整
-- 	else
-- 		buy()
-- 	end
-- end
function ConsigliereRecruitsPanel:buyConsigliere(sender)
self._sender=sender
self:buyConsig(sender.type,1)
end

function ConsigliereRecruitsPanel:buyConsig(buyType,curNumType)
	if self.isDoing then return end
	local function buy()
		self.isDoing = true
		self._proxy:onTriggerNet260005Req({type = buyType, num = curNumType})
	end
	local buyData = self._proxy:getRecruitInfo()
	local key = curNumType == 1 and "onceprice" or "fiveprice"
	local needCoin = buyData[buyType][key]
	local function callback()
		self:isShowRechargeUI({money = needCoin, callFunc = buy})
	end
	local function callbackCent()
		-- self.isDoing = nil
	end
    -- 1 元宝， 2银币
	local context = buyType == 1 and TextWords:getTextWord(270077) or TextWords:getTextWord(270078)
    -- 无打折
    needCoin = buyType == 1 and needCoin*self._goldDiscount or needCoin*self._silverDiscount
    -- 向上取整
    needCoin = math.ceil(needCoin)
	if buyType == 1 then
        local numString = StringUtils:formatNumberByK(needCoin)
		local messageBox = self:showMessageBox( string.format(context, numString), callback, callbackCent) -- -%d 会向上取整
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	else
		buy()
	end

end

-- function ConsigliereRecruitsPanel:buyConsigliere(sender,sender, value, dir,buyType,curNumType)
-- 	if self.isDoing then return end
	
-- 	if buyType==nil then
-- 	buyType = sender.type
-- 	end
-- 	if curNumType~=nil then
-- 		self.curNumType=curNumType
-- 	end
-- 	self._sender = sender
-- 	local function buy()
-- 		self.isDoing = true
-- 		self._proxy:onTriggerNet260005Req({type = buyType, num = self.curNumType})
-- 	end

-- 	local buyData = self._proxy:getRecruitInfo()
-- 	local key = self.curNumType == 1 and "onceprice" or "fiveprice"
-- 	local needCoin = buyData[buyType][key]
-- 	local function callback()
-- 		self:isShowRechargeUI({money = needCoin, callFunc = buy})
-- 	end
-- 	local function callbackCent()
-- 		-- self.isDoing = nil
-- 	end
--     -- 1 元宝， 2银币
-- 	local context = buyType == 1 and TextWords:getTextWord(270077) or TextWords:getTextWord(270078)
--     -- 无打折
--     needCoin = buyType == 1 and needCoin*self._goldDiscount or needCoin*self._silverDiscount
--     -- 向上取整
--     needCoin = math.ceil(needCoin)
-- 	if buyType == 1 then
--         local numString = StringUtils:formatNumberByK(needCoin)
-- 		self:showMessageBox( string.format(context, numString), callback, callbackCent) -- -%d 会向上取整
-- 	else
-- 		buy()
-- 	end
-- end

function ConsigliereRecruitsPanel:onRecruitingResp(data)
	if data.rs == 0 then
		self:updateView()
		local panel = self:getPanel(ConsigliereRewardPanel.NAME)
		if self._sender ~= nil and panel:isVisible() == false then
			panel:show()
			local name = self._sender.type == 1 and "rgb-jsf-zhaomuhuang" or "rgb-jsf-zhaomulan"
			local effect = UICCBLayer.new(name, self._sender, nil, function()
				panel:showUI(data)
			    self:showBg( false )
			    TimerManager:addOnce(100, function()
			    	self.isDoing = nil
			    end, self)
			end, true)
			local size = self._sender:getContentSize()
			local addX = self._sender.type==1 and 23 or 0
			local addY = self._sender.type==1 and 20 or 10
			effect:setPosition( size.width*0.5+addX, size.height*0.5+addY-8 )
		else
			panel:showUI(data)
			self:showBg(false)
			self.isDoing = nil
		end
	else
		self.isDoing = nil
	end
end

function ConsigliereRecruitsPanel:showBg( flag )
	local childs = self._panel:getChildren()
	for i, child in ipairs( childs ) do
		if child~=self.Img_bg then
			child:setOpacity( flag and 255 or 0 )
		end
	end

	self._eftlv:setVisible( flag )
	self._eftlan:setVisible( flag )
end

function ConsigliereRecruitsPanel:isShowRechargeUI(sender)
    local needMoney = sender.money
    local haveGold = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()

        self._uiRecharge = self._uiRecharge or UIRecharge.new(parent, self)
        self._uiRecharge:show()

        -- local panel = parent.panel
        -- if panel == nil then
        --     local panel = 
        --     parent.panel = panel
        -- else
        --     panel:show()
        -- end

    else
        sender.callFunc()
    end
end
