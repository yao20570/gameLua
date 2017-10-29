-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-03-17
--  * @Description: 热卖礼包
--  */
GiftBagPanel = class("GiftBagPanel", BasicPanel)
GiftBagPanel.NAME = "GiftBagPanel"

local MaxGiftCount = 8 

function GiftBagPanel:ctor(view, panelName)
    GiftBagPanel.super.ctor(self, view, panelName,100)

end

function GiftBagPanel:finalize()
    if self.leftEct ~= nil then
        self.leftEct:finalize()
        self.leftEct = nil
    end
    if self.rightEct ~= nil then
        self.rightEct:finalize()
        self.rightEct = nil
    end
    if self.discountEct ~= nil then
        self.discountEct:finalize()
        self.discountEct = nil
    end
    if self.bugBtnEct ~= nil then
        self.bugBtnEct:finalize()
        self.bugBtnEct = nil
    end
    if self.giftNameImgEct ~= nil then
        self.giftNameImgEct:finalize()
        self.giftNameImgEct = nil
    end
    if self.sunEffect ~= nil then
        self.sunEffect:finalize()
        self.sunEffect = nil
    end
    GiftBagPanel.super.finalize(self)
end

function GiftBagPanel:initPanel()
	GiftBagPanel.super.initPanel(self)

	self.proxy = self:getProxy(GameProxys.GiftBag)
	self._bigPanel 		= self:getChildByName("mainPanel/bigPanel")--主容器
	self._topPanel 		= self:getChildByName("mainPanel/bigPanel/topPanel")--上部容器
    self._bigImg 		= self:getChildByName("mainPanel/bigPanel/topPanel/bigImg")--礼包显示大图
    self._countDownLab	= self:getChildByName("mainPanel/bigPanel/topPanel/countDownLab")--顶部倒计时文本
    self._timeIconImg	= self:getChildByName("mainPanel/bigPanel/topPanel/timeIconImg")--顶部倒计图标
    self._limitDescLab 	= self:getChildByName("mainPanel/bigPanel/topPanel/limitTimeBgImg/limitDescLab")--限购次数显示文本
    self._giftNameImg	= self:getChildByName("mainPanel/bigPanel/topPanel/giftNameImg")--礼包名称图片
    self._goldNumLLab	= self:getChildByName("mainPanel/bigPanel/middlePanel/LAtlasLab")--中部元宝数艺术字文本
    self._goldNumRLab 	= self:getChildByName("mainPanel/bigPanel/middlePanel/RAtlasLab")--中部额外赠送元宝数艺术字文本
	self._bugBtnLab 	= self:getChildByName("mainPanel/bigPanel/bottomPanel/buyBtn/btnLab")--底部购买按钮显示价格文本
	self._bugBtn 		= self:getChildByName("mainPanel/bigPanel/bottomPanel/buyBtn")--底部购买按钮
	self._listView		= self:getChildByName("mainPanel/bigPanel/bottomPanel/ListView")--底部物品listView
	self._leftBtn		= self:getChildByName("mainPanel/bigPanel/topPanel/leftBtn")--切换左按钮
	self._rightBtn 		= self:getChildByName("mainPanel/bigPanel/topPanel/rightBtn")--切换右按钮
	self._discountImg 	= self:getChildByName("mainPanel/bigPanel/middlePanel/discountImg")--打折图
	self._discountLab 	= self:getChildByName("mainPanel/bigPanel/middlePanel/discountImg/discountLab")--折扣文本
	self._dotPanel 		= self:getChildByName("mainPanel/bigPanel/topPanel/dotPanel")--切换小白点的父节点
	self._curDotImg 	= self:getChildByName("mainPanel/bigPanel/topPanel/dotPanel/curDotImg")--当前小黄点
	self._touchPanel 	= self:getChildByName("mainPanel/touchPanel")--覆盖的触摸层
	local tipsLab 	 	= self:getChildByName("mainPanel/bigPanel/tipsLab")--底部提示
	tipsLab:setString(self:getTextWord(480003))
	--切换小白点
	self._dotArr = {}
	for i=1, MaxGiftCount do
		local dotImg = self:getChildByName("mainPanel/bigPanel/topPanel/dotPanel/dotImg" .. i)
		table.insert(self._dotArr, dotImg)
	end

	self.numStrArr = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
	self.index 			= 1 	--当前显示礼包标记（数据下标）
	self.curGiftBagNum 	= 1  	--记录当前礼包的个数
	self.giftBagInfos 	= {}	--记录当前所以礼包数据

	
	self._mainPanel		= self:getChildByName("mainPanel")		--main
	self._item 	= self:getChildByName("mainPanel/bigPanel")
	-- self._item:setVisible(false)

	self._allItem = {}

    self._canMove = true
    self._isAddTouch = false
    --记录当前显示礼包的type
    self.curType = nil
    
    --防止多次点击充值按钮
    self._isCanCharge = true

end
function GiftBagPanel:onShowHandler()
	self._uiPanelBg:setVisible(false)
	local bgImg = self:getChildByName("mainPanel/bigPanel/bgImg")
	TextureManager:updateImageViewFile(bgImg,"bg/giftBag/giftBagBg.pvr.ccz")
	-- local isDataNew  = self.proxy:isDataNew()
	--数据显示
	self:showGiftBagInfo()
	--添加大触摸
	if self._isAddTouch == false then
		self:addTouch(self._touchPanel, self)
	end
	self.isTouch = true
	--旧的需求，多页clone滑动
	--[[
	self._uiPanelBg:setVisible(false)
	self.isTouch = true
	local isDataNew  = self.proxy:isDataNew()
	if isDataNew == true then
		self:updateAllInfo()
	else
		if self._isAddTouch == false then
			self:addTouch(self._touchPanel, self)
		end
	end
	--]]
	--切换按钮特效
    if self.leftEct == nil then
		self.leftEct = self:createUICCBLayer("rgb-rm-jiantou", self._leftBtn)
		self.leftEct:setPosition(25, 25)
    end
    if self.rightEct == nil then
		self.rightEct = self:createUICCBLayer("rgb-rm-jiantou", self._rightBtn)
		self.rightEct:setPosition(25, 25)
    end
	--折扣图标特效
	if self.discountEct == nil then
		local disSize = self._discountImg:getContentSize()
		self.discountEct = self:createUICCBLayer("rgb-rmlb-dazhe", self._discountImg)
		self.discountEct:setPosition(disSize.width*0.5,disSize.height*0.5)
    end
	--充值按钮特效
	if self.bugBtnEct == nil then
		local bugBtnSize = self._bugBtn:getContentSize()
		self.bugBtnEct = self:createUICCBLayer("rgb-daanniu-huang", self._bugBtn)
		self.bugBtnEct:setPosition(bugBtnSize.width*0.5,bugBtnSize.height*0.5)
	end
	--礼包标题特效
	if self.giftNameImgEct == nil then
		-- local redLineImg = self:getChildByName("mainPanel/bigPanel/topPanel/redLineImg")
		local redLineImgSize = self._giftNameImg:getContentSize()
		self.giftNameImgEct = self:createUICCBLayer("rgb-rmlb-biaoti", self._giftNameImg)
		self.giftNameImgEct:setPosition(redLineImgSize.width*0.5,redLineImgSize.height*0.4)
	end
	--阳光照射特效
	if self.sunEffect == nil then
		local sunEffectPanel = self:getChildByName("mainPanel/bigPanel/sunEffectPanel")
		local sunEffectPanelSize = sunEffectPanel:getContentSize()
		self.sunEffect = self:createUICCBLayer("rgb-rmlb-guang", sunEffectPanel)
		self.sunEffect:setPosition(sunEffectPanelSize.width*0.6,sunEffectPanelSize.height*0.9)
	end
	

end
function GiftBagPanel:showGiftBagInfo(index,isSwitch)
	self.index = index or self.index or 1
	local index = self.index 
	local giftBagInfos = self.proxy:getGiftBagFilterInfos()

    print("=====================>giftBagInfos")

	--为空，关闭界面
	if #giftBagInfos == 0 then
		self:hideHandler()
		return
	end
	--index越界，递归减一
	local fact
	fact = function(n)
		if giftBagInfos[n] ~= nil then
			self.index = n
		else 
			index = index - 1
			return fact(index)
		end
	end
	fact(index)
	self.giftBagInfos = giftBagInfos
	self.curGiftBagNum = #giftBagInfos
	-- print("curGiftBagNum",self.curGiftBagNum)
	-- print("showGiftBagInfo self.index",self.index)
	self:updateSwitchDot(self.curGiftBagNum)
	local giftBagInfo = giftBagInfos[index]

	self._limitDescLab:setString(string.format(self:getTextWord(480001),self.numStrArr[giftBagInfo.buyLimit]))

	local baseGoldNum = giftBagInfo.baseRewardList[1].num
	self._goldNumLLab:setString(baseGoldNum)
	local extraGoldNum = giftBagInfo.extraRewardList[1].num	
	self._goldNumRLab:setString(extraGoldNum)
	if isSwitch == true then
		--切换是的时候元宝上闪特效
		local aLEffect = self:createUICCBLayer("rgb-rmlb-yuanbao", self._goldNumLLab, nil, nil, true)
	    local sizeL = self._goldNumLLab:getContentSize()
	    aLEffect:setPosition(sizeL.width*1.1,-sizeL.height*0.7)
		local aREffect = self:createUICCBLayer("rgb-rmlb-yuanbao", self._goldNumRLab, nil, nil, true)
	    local sizeR = self._goldNumRLab:getContentSize()
	    aREffect:setPosition(sizeR.width*1.1,-sizeR.height*0.7)
	end
	self._bugBtnLab:setString(string.format(self:getTextWord(480002),giftBagInfo.priceLimit))
	--奖励列表
	local listInfos = clone(giftBagInfo.itemRewardList)
	self:renderListView(self._listView, listInfos, self, self.renderItemPanel)
	if isSwitch == true then
		self._listView:setOpacity(80)
		local fadeIn = cc.FadeIn:create(0.3)
		self._listView:runAction(fadeIn)
	end

	local url = string.format("bg/giftBag/%03d%s", giftBagInfo.uitype,TextureManager.bg_type)
	TextureManager:updateImageViewFile(self._bigImg ,url)
	if isSwitch == true then
		self._bigImg:setOpacity(80)
		local fadeIn = cc.FadeIn:create(0.3)
		self._bigImg:runAction(fadeIn)
	end


	local giftNameImgUrl = string.format("bg/giftBag/t%03d.png", giftBagInfo.uitype)
	TextureManager:updateImageViewFile(self._giftNameImg ,giftNameImgUrl)
	--折扣
	self._discountLab:setString(giftBagInfo.discount)
	--倒计时
	if giftBagInfo.isShow == 1 then
		self._countDownLab:setVisible(false)
		self._timeIconImg:setVisible(false)
	else
		self._countDownLab:setVisible(true)
		self._timeIconImg:setVisible(true)
	end
	local remainTime = self.proxy:getRemainTime("oneGiftBag_RemainTime" .. giftBagInfo.activityDbId)
    if remainTime > 0 then
    	local timeStr = TimeUtils:getStandardFormatTimeString(remainTime)
		self._countDownLab:setString(timeStr)
	else
		self._countDownLab:setString(0)
	end
	--只有一个礼包的时候隐藏切换小点与切换按钮
	if self.curGiftBagNum == 1 then
		self._dotPanel:setVisible(false)
		self._leftBtn:setVisible(false)
		self._rightBtn:setVisible(false)
	else
		self._dotPanel:setVisible(true)
		self._leftBtn:setVisible(true)
		self._rightBtn:setVisible(true)
	end
end
--根据当前礼包的个数显示切换小点
function GiftBagPanel:updateSwitchDot(num)
	local dotNum = num or self.curGiftBagNum or 1
	-- local dotPanel = self:getChildByName("mainPanel/bigPanel/topPanel/dotPanel")
	--可视个数
	for i,dotImg in ipairs(self._dotArr) do
		if i <= dotNum then
			dotImg:setVisible(true)
		else
			dotImg:setVisible(false)
		end
	end
	local gap = 18
	--居中位置,点与点距离18，第一个点位置9，居中位位置的公式281-(num/2 * 18)
	local midPosX = self._topPanel:getContentSize().width/2
	self._dotPanel:setPositionX(midPosX - (dotNum/2 * gap))
	--小黄点根据index改变位置
	if self._dotArr[self.index] ~= nil then
		local x = self._dotArr[self.index]:getPosition()
	    self._curDotImg:setPositionX(x)
	end
	
end
--刷新全部礼包
function GiftBagPanel:updateAllInfo( ... )
	for k,v in pairs(self._allItem) do
		v:removeFromParent()
	end
	self._allItem = {}
	local giftBagInfos = self.proxy:getGiftBagFilterInfos()

	-- print("#giftBagInfos",#giftBagInfos)
	if #giftBagInfos == 0 then
		self:hideHandler()
	else
		if self.curType == nil then
			self.curType = giftBagInfos[1].type
		end
		self:renderAll()
		if self._isAddTouch == false then
			self:addTouch(self._touchPanel, self)
		end
	end
	
end
function GiftBagPanel:renderAll()

	local x, y = self._item:getPosition()

	local giftBagInfos = self.proxy:getGiftBagFilterInfos()
	for i=1,#giftBagInfos do
		local v = giftBagInfos[i]
		self._allItem[i] = self._item:clone()
		self._allItem[i]:setVisible(true)
		local mainPanel = self:getChildByName("mainPanel")
		self._allItem[i]:setPosition(x, y)
		self._allItem[i].itemData = v
		mainPanel:addChild(self._allItem[i])
		self:renderItem(self._allItem[i], v,i,#giftBagInfos)
	end
	-- print("renderAll()")
	self.proxy:setIsDataNew(false)
	if self._centerIndex and self._centerIndex > #giftBagInfos then
		self._centerIndex = self._centerIndex - 1
	end
	if self._centerIndex then
		self:adjustAllItem(self._allItem, self._centerX, self._centerIndex)
	else
		self:adjustAllItem(self._allItem, x, 1, true)
	end
	
end

function GiftBagPanel:renderItemPanel(itemPanel, info, index)
    local iconImg = itemPanel:getChildByName("iconImg")
    local nameLab = itemPanel:getChildByName("nameLab")
    local numLab = itemPanel:getChildByName("nubLab")

    -- local rewardArr = StringUtils:jsonDecode(info)

    if iconImg.uiIcon == nil then
        iconImg.uiIcon = UIIcon.new(iconImg, info, false,self)
    else
        iconImg.uiIcon:updateData(info)
    end
    local config = ConfigDataManager:getConfigByPowerAndID(info.power,info.typeid)
    nameLab:setString(config.name)
    numLab:setString("x " .. StringUtils:formatNumberByK3(info.num))


end
function GiftBagPanel:doLayout()
	-- local bgImg = self:getChildByName("mainPanel/bgImg")
	-- TextureManager:updateImageViewFile(bgImg,"bg/giftBag/giftBagBg.pvr.ccz")
end
function GiftBagPanel:registerEvents()
	GiftBagPanel.super.registerEvents(self)
	local closeBtn = self:getChildByName("mainPanel/bigPanel/closeBtn")
	self:addTouchEventListener(closeBtn,self.hideHandler)
	self:addTouchEventListener(self._leftBtn,self.leftImgHandler)
	self:addTouchEventListener(self._rightBtn,self.rightImgHandler)
	self:addTouchEventListener(self._bugBtn,self.buyBtnHandler,nil,nil,2000)
	
	--[[
	local closeBtn = self:getChildByName("mainPanel/closeBtn")
	self:addTouchEventListener(closeBtn,self.hideHandler)
	local leftImg = self:getChildByName("mainPanel/topPanel/leftImg")
	self:addTouchEventListener(leftImg,self.leftImgHandler)
	local RightImg = self:getChildByName("mainPanel/topPanel/RightImg")
	self:addTouchEventListener(RightImg,self.rightImgHandler)
	local buyBtn = self:getChildByName("mainPanel/bottomPanel/buyBtn")
	self:addTouchEventListener(buyBtn,self.buyBtnHandler)
	]]
end
function GiftBagPanel:hideHandler()
	self.isTouch = false
	-- self._touchPanel:removeAllEventListeners()
	if self.listenner ~= nil then
		local eventDispatcher  = self._touchPanel:getEventDispatcher()
		eventDispatcher:removeEventListener(self.listenner)
		self.listenner = nil
	end
	self._isAddTouch = false
	-- logger:info("GiftBagPanel:hideHandler")
    self.view:dispatchEvent(GiftBagEvent.HIDE_SELF_EVENT)
end
-- function GiftBagPanel:leftImgHandler()
-- 	logger:info("GiftBagPanel:leftImgHandler")
-- 	self.showTag = self.showTag - 1

-- 	self:updateGiftBagView()
-- end
-- function GiftBagPanel:rightImgHandler()
-- 	logger:info("GiftBagPanel:rightImgHandler")
-- 	self.showTag = self.showTag + 1
-- 	self:updateGiftBagView()
-- end
function GiftBagPanel:update()
	--永久礼包隐藏倒计时（配表配了十年）
	if self.giftBagInfos[self.index].isShow == 1 then
		self._countDownLab:setVisible(false)
		self._timeIconImg:setVisible(false)
	else
		self._countDownLab:setVisible(true)
		self._timeIconImg:setVisible(true)
	end
	local remainTime = self.proxy:getRemainTime("oneGiftBag_RemainTime" .. self.giftBagInfos[self.index].activityDbId)
    if remainTime > 0 then
    	local timeStr = TimeUtils:getStandardFormatTimeString(remainTime)
		self._countDownLab:setString(timeStr)
	else
		self._countDownLab:setString(0)
	end
end

--请求sdk购买
function GiftBagPanel:doBuyAction(data)
	local giftType = data.giftType
	local priceLimit = data.priceLimit
	SDKManager:charge(priceLimit, giftType)
end

--购买
function GiftBagPanel:buyBtnHandler(sender)
	logger:info("点击购买按钮")
	local amount = self.giftBagInfos[self.index].priceLimit
	local chargeType = self.giftBagInfos[self.index].type
	local data = {
		giftType = chargeType,
		priceLimit = amount,
	}
	self.proxy:onTriggerNet430002Req(data)
end

local offsetX = 640
local time = 0.15
--[[
	@param first:第一次初始化，不运行动作
	@param items:根据颜色分类的widget的合集
	@param startX:中间位置的横坐标，记录起来用于做scale的计算
	@param center:items中居中的widget的在集合中的下标
]]
function GiftBagPanel:adjustAllItem(items, startX, center, first)
	if not self._canMove then
		return
	end
	
	self._centerIndex = center
	self._centerX = self._centerX or startX
	startX = startX or 0
	for i=1,#items do
		local scale = i == center and 1 or 0.8
		items[i].index = i

		-- local color = items[i].itemData.color - 1
		-- if color > 0 then
		-- 	if items[i].effect == nil then
		-- 		-- items[i].effect = self:createUICCBLayer(self.allEffectName[color], items[i])
		-- 		items[i].effect = UICCBLayer.new(self.allEffectName[color], items[i])
		-- 		local size = items[i]:getContentSize()
		-- 		items[i].effect:setPosition(size.width*0.5, 30)
		-- 	end
		-- end

		if first then
			items[i]:setPositionX(startX + (i - center) * offsetX)
			-- items[i]:setScale(scale)
			-- if items[i].effect ~= nil then
			-- 	items[i].effect:setVisible(scale == 1)
			-- end
			-- local name = items[i]:getChildByName("heroName")
			-- name:setVisible(scale == 1)
			if scale == 1 then
				-- self:updateBottomPanel(items[i].itemData)
			end
		else
			local target = cc.p(startX + (i - center) * offsetX, items[i]:getPositionY())
			local move = cc.MoveTo:create(time, target)
			local scaleTo = cc.ScaleTo:create(time, scale)
			local action = cc.Spawn:create(move, scaleTo)
			local seq = cc.Sequence:create(move, cc.CallFunc:create(function(sender)
				-- if sender.effect ~= nil then
				-- 	sender.effect:setVisible(scale == 1)
				-- end
				-- local name = sender:getChildByName("heroName")
				-- name:setVisible(scale == 1)
				-- if scale == 1 then
				-- 	self:updateBottomPanel(sender.itemData)
				-- end
				if sender.index >= #items then
					self._canMove = true
				end
			end))
			items[i]:runAction(seq)
		end
	end
end

function GiftBagPanel:addTouch(panel, obj)
	-- print("addTouch")
	self._isAddTouch = true
	local x, ox
	if obj.listenner == nil then
		obj.listenner = cc.EventListenerTouchOneByOne:create()
		obj.listenner:setSwallowTouches(true)

		obj.listenner:registerScriptHandler(function(touch, event)    
	        local location = touch:getLocation()   
	        x = location.x
	        ox = x
	        -- print("EVENT_TOUCH_BEGAN")
	        return (obj:isVisible() and self.isTouch)   
	    end, cc.Handler.EVENT_TOUCH_BEGAN )

		obj.listenner:registerScriptHandler(function(touch, event)
			local location = touch:getLocation()
	        self:touchMoved(location.x - ox, obj)
	        ox = location.x
	    end, cc.Handler.EVENT_TOUCH_MOVED )

	    obj.listenner:registerScriptHandler(function(touch, event)
	    	local location = touch:getLocation()
	    	self:touchEnded(obj, location.x - x)
	    end, cc.Handler.EVENT_TOUCH_ENDED ) 

	    local eventDispatcher = panel:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(obj.listenner,panel)
	end
end
function GiftBagPanel:touchMoved(x, obj)
	-- local data = self:getAllItems()
	-- if data == nil then
	-- 	return
	-- end
	-- print("touchMoved")
	if self._centerIndex == 1 and x > 0 then
		return
	end

	if self.index == self.curGiftBagNum and x < 0 then
		return
	end

	--按着一直拖不松手
	-- if data[#data]:getPositionX() <= self._centerX and x < 0 then
	-- 	return
	-- end

	-- if data[1]:getPositionX() >= self._centerX and x > 0 then
	-- 	return
	-- end

	-- for k,v in pairs(data) do
	-- 	data[k]:setPositionX(data[k]:getPositionX() + x)
	-- 	local posX = data[k]:getPositionX()
	-- 	local offX = math.abs(posX - self._centerX)
	-- 	local scale = 1 - offX / self._centerX
	-- 	scale = scale < 0.8 and 0.8 or scale
	-- 	scale = scale > 1 and 1 or scale
	-- end
end
function GiftBagPanel:touchEnded(obj, dir)
	-- print("touchEnded")
	-- local data = self:getAllItems()
	-- if data == nil then
	-- 	return
	-- end
	local index = self.index
	-- local minX = 100000
	-- for k,v in pairs(data) do
	-- 	local posX = data[k]:getPositionX()
	-- 	local offSetX = math.abs(posX - self._centerX)
	-- 	if offSetX < minX then
	-- 		minX = offSetX
	-- 		index = k
	-- 	end
	-- end
	-- if index == self._centerIndex then
	-- 	local x = data[index]:getPositionX()
		if dir < 0 then
			index = index + 1
		end
		if dir > 0 then
			index = index - 1
		end
	-- end
	index = index > self.curGiftBagNum  and 1 or index
	index = index < 1 and self.curGiftBagNum or index
	if index ~= self.index then
		self:showGiftBagInfo(index,true)
	end
	
	-- self:adjustAllItem(data, self._centerX, index)
	--两边按钮的可视性
	-- local middlePanel = data[index]:getChildByName("middlePanel")
	-- local leftImg = middlePanel:getChildByName("leftImg")
	-- local RightImg = middlePanel:getChildByName("RightImg")
	-- if index == 1 then
	-- 	leftImg:setVisible(false)
	-- else
	-- 	leftImg:setVisible(true)
	-- end
	-- if index == #data then
	-- 	RightImg:setVisible(false)
	-- else
	-- 	RightImg:setVisible(true)
	-- end
	-- self.curType = data[index].itemData.type
end
--移动所有控件，计算缩放系数
function GiftBagPanel:touchMoved2(x, obj)
	local data = self:getAllItems()
	if data == nil then
		return
	end
	if self._centerIndex == 1 and x > 0 then
		return
	end

	if self._centerIndex == #data and x < 0 then
		return
	end

	--按着一直拖不松手
	if data[#data]:getPositionX() <= self._centerX and x < 0 then
		return
	end

	if data[1]:getPositionX() >= self._centerX and x > 0 then
		return
	end

	for k,v in pairs(data) do
		data[k]:setPositionX(data[k]:getPositionX() + x)
		local posX = data[k]:getPositionX()
		local offX = math.abs(posX - self._centerX)
		local scale = 1 - offX / self._centerX
		scale = scale < 0.8 and 0.8 or scale
		scale = scale > 1 and 1 or scale
		-- data[k]:setScale(scale)
	end
end

--触摸结束，调整所有item的位置
function GiftBagPanel:touchEnded2(obj, dir)
	-- print("touchEnded")
	local data = self:getAllItems()
	if data == nil then
		return
	end
	local index
	local minX = 100000
	for k,v in pairs(data) do
		local posX = data[k]:getPositionX()
		local offSetX = math.abs(posX - self._centerX)
		if offSetX < minX then
			minX = offSetX
			index = k
		end
	end
	if index == self._centerIndex then
		local x = data[index]:getPositionX()
		if dir < 0 then
			index = index + 1
		end
		if dir > 0 then
			index = index - 1
		end
	end

	index = index > #data and #data or index
	index = index < 1 and 1 or index
	self:adjustAllItem(data, self._centerX, index)
	--两边按钮的可视性
	local middlePanel = data[index]:getChildByName("middlePanel")
	local leftImg = middlePanel:getChildByName("leftImg")
	local RightImg = middlePanel:getChildByName("RightImg")
	if index == 1 then
		leftImg:setVisible(false)
	else
		leftImg:setVisible(true)
	end
	if index == #data then
		RightImg:setVisible(false)
	else
		RightImg:setVisible(true)
	end
	self.curType = data[index].itemData.type
	-- print("self.curType",self.curType)
	-- local giftBagInfos = self.proxy:getGiftBagInfos()
	-- 	local curItem =  self._allItem[self._centerIndex]
	-- local topPanel	= curItem:getChildByName("topPanel")
	-- local countDownLab= topPanel:getChildByName("countDownLab")
end
function GiftBagPanel:getAllItems()
	return self._allItem
end

function GiftBagPanel:renderItem(oneItemPanel, giftBagInfo,index,maxIndex)

	-- self.curShowInfo = giftBagInfos[self.showTag]

	local topPanel = oneItemPanel:getChildByName("topPanel")
	local limitDescLab = topPanel:getChildByName("limitDescLab")
	local limitTimeBgImg = topPanel:getChildByName("limitTimeBgImg")
	local limitDescLab = limitTimeBgImg:getChildByName("limitDescLab")
	local giftNameImg 	= topPanel:getChildByName("giftNameImg")
	local middlePanel	= oneItemPanel:getChildByName("middlePanel")
	local LAtlasLab	= middlePanel:getChildByName("LAtlasLab")
	local RAtlasLab	= middlePanel:getChildByName("RAtlasLab")
	local bottomPanel 	= oneItemPanel:getChildByName("bottomPanel")
	local buyBtn 	= bottomPanel:getChildByName("buyBtn")
	local bugBtnLab 	= buyBtn:getChildByName("btnLab")
	local listView 	= bottomPanel:getChildByName("ListView")
	local discountImg 	= middlePanel:getChildByName("discountImg")
	local discountLab 	= discountImg:getChildByName("discountLab")

	local leftImg = middlePanel:getChildByName("leftImg")
	local RightImg = middlePanel:getChildByName("RightImg")

	self:addTouchEventListener(leftImg,self.leftImgHandler)
	self:addTouchEventListener(RightImg,self.rightImgHandler)

	limitDescLab:setString(string.format(self:getTextWord(480001),self.numStrArr[giftBagInfo.buyLimit]))
	-- giftNameLab:setString(giftBagInfo.alreadyBuy .. giftBagInfo.name .. giftBagInfo.type)
	local baseGoldNum = giftBagInfo.baseRewardList[1].num
	LAtlasLab:setString(baseGoldNum)
	local extraGoldNum = giftBagInfo.extraRewardList[1].num	
	RAtlasLab:setString(extraGoldNum)
	bugBtnLab:setString(string.format(self:getTextWord(480002),giftBagInfo.priceLimit))

	local listInfos = clone(giftBagInfo.itemRewardList)
	self:renderListView(listView, listInfos, self, self.renderItemPanel)

	--礼包背景图跟新
	local bigImg 		= topPanel:getChildByName("bigImg")	
	local url = string.format("bg/giftBag/%03d%s", giftBagInfo.uitype,TextureManager.bg_type)
	TextureManager:updateImageViewFile(bigImg ,url)
	--礼包标题图片
	local giftNameImgUrl = string.format("bg/giftBag/t%03d%s.png", giftBagInfo.uitype)
	TextureManager:updateImageViewFile(giftNameImg ,url)
	--折扣
	discountLab:setString("没有")
	local bgImg = oneItemPanel:getChildByName("bgImg")
	TextureManager:updateImageViewFile(bgImg,"bg/giftBag/giftBagBg.pvr.ccz")
	local closeBtn = oneItemPanel:getChildByName("closeBtn")
	self:addTouchEventListener(closeBtn,self.hideHandler)
	self:addTouchEventListener(buyBtn,self.buyBtnHandler,nil,nil,2000)
	if index == 1 then
		leftImg:setVisible(false)
	else
		leftImg:setVisible(true)
	end
	if maxIndex == index then
		RightImg:setVisible(false)
	else
		RightImg:setVisible(true)
	end
end


function GiftBagPanel:dirBtnTouch(dir)
	local index = self.index

	if dir < 0 then
		index = index + 1
	end
	if dir > 0 then
		index = index - 1
	end
	index = index > self.curGiftBagNum  and 1 or index
	index = index < 1 and self.curGiftBagNum or index
	if index ~= self.index then
		self:showGiftBagInfo(index,true)
	end
	--防止狂点
	self._canMove = false
end

function GiftBagPanel:leftImgHandler(sender)
	self:dirBtnTouch(1)
end
function GiftBagPanel:rightImgHandler(sender)
	self:dirBtnTouch(-1)
end