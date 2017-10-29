
ConsigliereRewardPanel = class("ConsigliereRewardPanel", BasicPanel)
ConsigliereRewardPanel.NAME = "ConsigliereRewardPanel"


local MAX_LEN = 5  --最大抽卡数

function ConsigliereRewardPanel:ctor(view, panelName)
    ConsigliereRewardPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ConsigliereRewardPanel:finalize()
    ConsigliereRewardPanel.super.finalize(self)
end

function ConsigliereRewardPanel:initPanel()
	ConsigliereRewardPanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Consigliere)
	self._roleProxy = self:getProxy(GameProxys.Role)

	self.panel = self:getChildByName( "Panel_2" )

	self.fiveTimeBtn = self:getChildByName("Panel_2/fiveTimeBtn")
	local onceBtn = self:getChildByName("Panel_2/onceBtn")
	self:addTouchEventListener(self.fiveTimeBtn, self.buyHandler)
	self:addTouchEventListener(onceBtn, function()
	    local panel = self:getPanel(ConsigliereRecruitsPanel.NAME)
	    panel:showBg( true )
		self:hide()
	end)

	for i=1,MAX_LEN do
		local item = self:getChildByName("Panel_1/consigItem_"..i)
		if item then
			local size = item:getContentSize()
			item:setPosition( item:getPositionX()+size.width*0.5, item:getPositionY()+size.height*0.5 )
			item:setAnchorPoint(0.5,0.5)
		else
			MAX_LEN = i
		end
	end

	local panel1 = self:getChildByName("Panel_1")
	local item1 = panel1:getChildByName("consigItem_1")
	local item2 = panel1:getChildByName("consigItem_"..MAX_LEN)
	self.oldX = item1:getPositionX()
	self.oldY = item1:getPositionY()
	local parent = item1:getParent()
	local box = parent:getBoundingBox()
	self.oX = box.width/2-3--320--panel1:getContentSize().width*0.5
	self.oY = item1:getPositionY()*0.5+item2:getPositionY()*0.5
end

function ConsigliereRewardPanel:buyHandler(sender)
	local buyType = sender.type
	local function buy()
		self._proxy:onTriggerNet260005Req({type = buyType, num = self.numType})
	end

	local buyData = self._proxy:getRecruitInfo()
	local key = self.numType == 1 and "onceprice" or "fiveprice"
	local needCoin = buyData[buyType][key]

	local function callback()
		self:isShowRechargeUI({money = needCoin, callFunc = buy})
	end

	local context = buyType == 1 and TextWords:getTextWord(270077) or TextWords:getTextWord(270078)
	
    local newNeedCoin = ""
    if self._offText:isVisible() then
        newNeedCoin = self._offText:getString() 
    else
        newNeedCoin = StringUtils:formatNumberByK( needCoin) -- 没折扣的时候也要转化单位
    end

	if buyType == 1 then
		local messageBox = self:showMessageBox( string.format(context, newNeedCoin), callback)
		messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	else
		buy()
	end
end

function ConsigliereRewardPanel:registerEvents()
	ConsigliereRewardPanel.super.registerEvents(self)

    self._textLine = self:getChildByName("Panel_2/numLab/textLine")
    self._offText  = self:getChildByName("Panel_2/offText")
    self._numLab   = self:getChildByName("Panel_2/numLab")
end

function ConsigliereRewardPanel:onShowHandler()
	local panel = self:getChildByName("Panel_1")
	panel:getParent():setOpacity( 0 )
end

function ConsigliereRewardPanel:showUI(data)
	AudioManager:playEffect("yx_dianbing")
	local panel = self:getChildByName("Panel_1")
	panel:getParent():setOpacity( 255 )
	self.buyType = data.type
	self.fiveTimeBtn.type = data.type
	self.numType = #data.getids

	
	self:updateView(data)
end

function ConsigliereRewardPanel:updateView(data)

	local ids = data.getids

	local titleText = self.numType == 1 and "招募一次" or "招募五次"
	self.fiveTimeBtn:setTitleText(titleText)

	self.panel:setVisible( #ids==0 )
	-- local effect = UICCBLayer.new("rgb-jsf-zhaomuchuxian", self, nil, function()
	-- 	end, true)
	-- local x, y = NodeUtils:getCenterPosition()
 --    effect:setPosition(x,y)

	local buyType = data.type

	local iconImg = self:getChildByName("Panel_2/iconImg")
	local url = buyType == 1 and "images/newGui1/IconYuanBao.png" or "images/newGui1/IconRes1.png"
	TextureManager:updateImageView(iconImg, url)

	local priceData = self._proxy:getRecruitInfo()[buyType]
	local key = self.numType == 1 and "onceprice" or "fiveprice"
	local num = StringUtils:formatNumberByK(priceData[key])
	local numLab = self:getChildByName("Panel_2/numLab")
	numLab:setString(num)
	if priceData[key] == 0 then
		numLab:setString("免费")
		self.fiveTimeBtn:setTitleText("免费")
    else
        self:setDiscount(priceData[key])
	end

	local item1 = self:getChildByName("Panel_1/consigItem_1")

	local isBuyOne = #ids < MAX_LEN
	local x = isBuyOne and self.oX or self.oldX
	local y = isBuyOne and self.oY or self.oldY
	item1:setPosition( x, y  )
	for i=1, MAX_LEN do
		local item = self:getChildByName("Panel_1/consigItem_"..i)
		item:setVisible(ids[i] ~= nil)
		if ids[i] ~= nil and item then
			item:setScale(0)
			ComponentUtils:renderConsigliereItem(item, ids[i],nil, nil, nil, nil, nil, nil, nil,true)
			item:runAction( cc.Sequence:create( 
				cc.DelayTime:create( i*0.1 ),
				cc.CallFunc:create(function()
					local effect = UICCBLayer.new("rgb-jsf-zhaomuchuxian", item:getParent(), nil, nil, true)
	    			effect:setPosition( item:getPositionX(), item:getPositionY()-75)
				end),
				cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1 ) ),
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(function()
					if i>=MAX_LEN or i>=#ids then
						self.panel:setVisible(true)
					end
				end)
			))
		end
	end
end

function ConsigliereRewardPanel:updatePrice()
	local key = self.numType == 1 and "onceprice" or "fiveprice"
	local priceData = self._proxy:getRecruitInfo()[self.buyType]
	local num = StringUtils:formatNumberByK(priceData[key])
	local numLab = self:getChildByName("Panel_2/numLab")
	numLab:setString(num)
	if priceData[key] == 0 then
		numLab:setString("免费")
		self.fiveTimeBtn:setTitleText("免费")
    else
        self:setDiscount(priceData[key])
	end
end


-- 1 元宝， 2银币self.buyType
-- 设置折扣
function ConsigliereRewardPanel:setDiscount(num)
    local discount = 1
    if self.buyType == 1 then
        discount = self._proxy:getGoldDiscount()
    elseif self.buyType == 2 then
        discount = self._proxy:getSilverDiscount() 
    end

    if discount ~= 1 then
        self._textLine:setVisible(true)
        self._offText :setVisible(true)
        self._textLine:setContentSize(self._numLab:getContentSize().width, self._textLine:getContentSize().height)
        
        local disCountNum = StringUtils:formatNumberByK( math.ceil(num *discount)) -- 向上取整

        self._offText:setString(disCountNum)
        NodeUtils:alignNodeL2R(self._numLab, self._offText, 10)
    else
        self._textLine:setVisible(false)
        self._offText :setVisible(false)
    end
end



function ConsigliereRewardPanel:isShowRechargeUI(sender)
    local needMoney = sender.money

    local haveGold = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

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