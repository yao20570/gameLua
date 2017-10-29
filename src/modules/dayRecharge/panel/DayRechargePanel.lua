-- /**
--  * @Author:	fwx
--  * @DateTime:	2016/12/30
--  * @Description:  连续充值
--  */
DayRechargePanel = class("DayRechargePanel", BasicPanel)
DayRechargePanel.NAME = "DayRechargePanel"

local MAX_DAY = 7  --固定7天
local GROUP_N = 3  --翻页容器放3个item
local GREY = 110 --不可领取的 灰度

function DayRechargePanel:ctor(view, panelName)
	DayRechargePanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end
function DayRechargePanel:finalize()
	for _,eff in pairs(self.mBoxEff or {}) do
		eff:finalize()
	end
	self.mBoxEff = nil
	if self.uiResourceGet then
		self.uiResourceGet:finalize()
		self.uiResourceGet = nil
	end
	if self.uiRecharge then
		self.uiRecharge:finalize()
		self.uiRecharge = nil
	end
	DayRechargePanel.super.finalize(self)
end
function DayRechargePanel:registerEvents()
	DayRechargePanel.super.registerEvents(self)
end

--init-===================================================
function DayRechargePanel:initPanel()
	DayRechargePanel.super.initPanel(self)

    self.roleProxy  = self:getProxy(GameProxys.Role)
	self.proxy 		= self:getProxy(GameProxys.Activity)
	-- 这里的配置表要通过effect进行筛选
	local activityData = self.proxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_DAYRECHARGE_ID )
	local effectId = activityData.effectId

	self.infoConfig = ConfigDataManager:getConfigData( ConfigData.DayRechargeConfig )
	self.rewardConf = ConfigDataManager:getInfosFilterByOneKey(ConfigData.DayRewardConfig, "rewardGroup", effectId)
	self.infoConfig = self.infoConfig[effectId]
	local rewardConf = {}
	local index = 1
	for k,v in pairs(self.rewardConf) do
		rewardConf[index] = v
		index = index + 1
	end
	self.rewardConf = rewardConf

	self.mBoxs 		= {}  --天数 龙玉
	self.mMacks		= {}  --奖励翻页里的mack

	self.mTopPanel 	= self:getChildByName("topPanel")
	self.mPanel 	= self:getChildByName("middlePanel")

	self.mTime 		= self.mTopPanel:getChildByName("label_time")
	self.mlab1		= self.mPanel:getChildByName("Label_1")
	self.mlab2		= self.mPanel:getChildByName("Label_2")
	self.mlab3		= self.mPanel:getChildByName("Label_3")
	self.mlab4		= self.mPanel:getChildByName("Label_4")
	self.pGroup 	= self.mPanel:getChildByName("Panel_group"):getChildByName("Panel_items")
	self.btnOk		= self:getChildByName("downPanel/sureBtn")
	self.mCost		= self.btnOk:getChildByName("label_cost")
	self.mGold		= self.btnOk:getChildByName("img_gold")

	for i=1,MAX_DAY do
		table.insert( self.mBoxs, self.mPanel:getChildByName("dayBtn1_"..i) )
	end
	self:initView()
end

function DayRechargePanel:getRewardIndexById(id)
    for index,v in pairs(self.rewardConf) do
		if v.ID == id then
			return index
		end
	end
end

function DayRechargePanel:initView()
	self:setTitle(true,"dayRecharge",true)
	self:setBgType( ModulePanelBgType.ACTIVITY)
	--cost
	self.needCoin = self.infoConfig.rechargeLimit or 0
	self.mlab1:setString( string.format(self:getTextWord(230374), self.needCoin) )
	self.mlab4:setString( "/"..self.needCoin..")" )

	--描述
	local des1 = self.mTopPanel:getChildByName("label_des1")
    des1:setColor(cc.c3b(244,244,244))
	local des2 = self.mTopPanel:getChildByName("label_des2")
    des2:setColor(cc.c3b(244,244,244))
	--local des3 = self.mTopPanel:getChildByName("label_des3")
	des1:setString( self:getTextWord(230371) ) 
	des2:setString( self:getTextWord(230372) )
	--des3:setString( self:getTextWord(230373) )

	--前七天奖励
	local oldItemPanel = self.pGroup:getChildByName( "Panel_item1" )
	local rewardLen = #self.rewardConf
	local mItems = {}
	self.nItemWidth = oldItemPanel:getContentSize().width
	for i=1, rewardLen-1 do
		local conf = self.rewardConf[i]
		if not conf then
			break
		end
		local itemPanel = self.pGroup:getChildByName( "Panel_item"..i )
		if not itemPanel then
			itemPanel = oldItemPanel:clone()
			itemPanel:setName( "Panel_item"..i )
			self.pGroup:addChild(itemPanel)
		end
		itemPanel:setPositionX((oldItemPanel:getContentSize().width + 15) *(i-1) )
		table.insert( mItems, itemPanel )
	end
	--icon
	for i, itemPanel in ipairs( mItems ) do
		local conf = self.rewardConf[i]
		local text = itemPanel:getChildByName("lable_day")
		local item = itemPanel:getChildByName("propImg")
		local titStr = self:getTextWord(230382)
		if conf.day~=1 then
			titStr = string.format(self:getTextWord(230383), conf.day)
		end
		text:setString( titStr )
		local icon = ComponentUtils:renderIcon( item, {401, conf.chestsIcon}, self)
        icon:setNamePosition(nil, -60)
		text = icon:getNameChild()
		text:setString( conf.iconName or "" )

		table.insert( self.mMacks, itemPanel:getChildByName( "Image_mack" ) )
	end

	--7日奖励
	local pItem7 = self.mPanel:getChildByName("Panel_item7")
	local pItemWidth = pItem7:getContentSize().width-174
	local eddConfig = self.rewardConf[ rewardLen ]
	local strArr = StringUtils:jsonDecode( eddConfig.reward )

	for i, jsonArr in ipairs(strArr) do
		local item = pItem7:getChildByName("propImg"..i)
		if not item then break end
		item:setPositionX( pItemWidth/(#strArr-1)*(i-1)+87 )
		local icon = ComponentUtils:renderIcon( item, jsonArr, self )
        icon:setNamePosition(nil, -60)
	end
	table.insert( self.mMacks, pItem7:getChildByName( "Image_mack" ) )

	--左右翻页
	local btnLeft = self.mPanel:getChildByName("Button_left")
	local btnRight = self.mPanel:getChildByName("Button_right")

	local hasGroup = rewardLen>GROUP_N+1
	--btnRight:setOpacity( hasGroup and 255 or GREY )
	--btnLeft:setOpacity( GREY )
	btnRight:setVisible( hasGroup and true or false )
	btnLeft:setVisible( hasGroup and true or false )

	btnLeft:addTouchEventListener(function( sender, evenType )
		self:onTouchGroup( sender, evenType, hasGroup, btnRight )
	end )
	btnRight:addTouchEventListener(function( sender, evenType )
		local max = rewardLen-GROUP_N-1
		self:onTouchGroup( sender, evenType, hasGroup, btnLeft, max )
	end )

	--补签按钮
	self.nPuck = 0  --补签数
	self:addTouchEventListener( self.btnOk, self.onTouchBtn)
end


--事件-===================================================
function DayRechargePanel:onClosePanelHandler()
	self.view:dispatchEvent( DayRechargeEvent.HIDE_SELF_EVENT )
end
--点翻页
function DayRechargePanel:onTouchGroup( sender, evenType, hasGroup, otherBtn, max )
	local scale = evenType<ccui.TouchEventType.ended and 0.85 or 1
	sender:setScale( (sender:getScaleX()>0 and 1 or -1)*scale, scale )

	if evenType~=ccui.TouchEventType.ended or not hasGroup then return end

	self.nCurIndex = self.nCurIndex + (max and 1 or -1 )
	self.nCurIndex = math.max( self.nCurIndex, 0 )
	self.nCurIndex = math.min( self.nCurIndex, max or 99999 )

	local flag = max and self.nCurIndex>=max or self.nCurIndex<=0
	sender:setOpacity( flag and GREY or 255 )
	otherBtn:setOpacity( flag and 255 or GREY )

	self:renderPage()
end
--点补签
function DayRechargePanel:onTouchBtn()
	local activityData = self.proxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_DAYRECHARGE_ID )
	local needCoins = math.max(1, self.nPuck) * self.infoConfig.retroactivePrice
	local haveCoin = self.roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
	if self.getRewardIds then
		self:reqGetReward( self.getRewardIds )
	elseif self.nPuck<=0 then
		self:showSysMessage( self:getTextWord(230379) )  --没有可补签
	elseif haveCoin<needCoins then
		self.uiRecharge = self.uiRecharge or UIRecharge.new(parent, self) --跳转
		self.uiRecharge:show()
	elseif activityData then
		local text = string.format( self:getTextWord(230378), self.nPuck, needCoins )
		self:showMessageBox( text, function()
			self.proxy:onTriggerNet230037Req( {activityId= activityData.activityId} ) --请求补签
		end )
	end
end
--请求领奖励
function DayRechargePanel:reqGetReward( getRewardIds )
	local activityData = self.proxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_DAYRECHARGE_ID )
	if activityData and getRewardIds and #getRewardIds>0 then
		self.proxy:onTriggerNet230038Req( { activityId=activityData.activityId, getRewardId=getRewardIds} )
	elseif getRewardIds and #getRewardIds<=0 then
		self:showSysMessage( self:getTextWord(1112) )
	end
end


--刷新一次-===================================================
function DayRechargePanel:onShowHandler()
	self.nCurIndex = 0
	--time
	local curActivityData = self.proxy:getCurActivityData() or {}
	-- local timeStr = os.date("%Y年%m月%d日%H:%M", curActivityData.startTime or 0).." - "..os.date("%Y年%m月%d日%H:%M", curActivityData.endTime or 0)
	local timeStr = TimeUtils.getLimitActFormatTimeString(curActivityData.startTime,curActivityData.endTime)
	self.mTime:setString( timeStr )

  	self:renderPanel()
end
function DayRechargePanel:renderPage()
	local tox = -self.nCurIndex*self.nItemWidth
	local pos = cc.p(tox, self.pGroup:getPositionY())
	self.pGroup:stopAllActions()
	self.pGroup:runAction( cc.EaseBackOut:create(cc.MoveTo:create(0.4, pos)) )
end

function DayRechargePanel:renderPanel()

    local haveCoin = self.roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge) or 0
    local isChargeToday = haveCoin>=self.needCoin
	if isChargeToday then
    	self.proxy:updateCurDayRecharge()
    end
	self.mlab3:setString( haveCoin )
	self.mlab3:setColor( isChargeToday and ColorUtils.wordGoodColor or ColorUtils.wordBadColor )
	local width1 = self.mlab1:getContentSize().width
	local width2 = self.mlab2:getContentSize().width
	local width3 = self.mlab3:getContentSize().width
	local width4 = self.mlab4:getContentSize().width
	self.mlab1:setPositionX( (self.mPanel:getContentSize().width-(width1+width2+width3+width4))*0.5 )
	self.mlab2:setPositionX( self.mlab1:getPositionX()+width1 )
	self.mlab3:setPositionX( self.mlab2:getPositionX()+width2 )
	self.mlab4:setPositionX( self.mlab3:getPositionX()+width3 )

	local infos = self.proxy:getDayRechargeInfos() or { hasgetId={1,2,4}, day={1,2,3,4,5}, nowDay=7 }
	infos.nowDay = math.max( infos.nowDay, 1 )

	local hasgetId = {}
	local daylist = {}
	for _,id in ipairs( infos.hasgetId or {} ) do
		local index = self:getRewardIndexById(id)
		hasgetId[index] = true
	end

	for _, day in ipairs( infos.day or {} ) do
		daylist[day] = true
	end

	--七个龙玉
	self.nPuck = 0
	for i,box in ipairs(self.mBoxs) do
		local mBody = box:getChildByName("Image_1")
		local mGood = box:getChildByName("Image_85")
		local visiGod = i==infos.nowDay and (isChargeToday or daylist[i])
		local visiEff = i==infos.nowDay and not visiGod
		local bodyColor = (daylist[i] or visiEff or visiGod) and cc.c3b(255,255,255) or cc.c3b(155,155,155)
		--local bodyColor = cc.c3b(255,255,255)
		local goodUrl = (daylist[i] or visiGod) and "14.png" or "15.png"
		--TextureManager:updateImageView( mBody, "images/dayRecharge/"..bodyUrl )
        --if i < infos.nowDay then
        --    bodyColor = cc.c3b(100,100,100)
        --else
        --    bodyColor = cc.c3b(255,255,255)
        --end
        mBody:setColor(bodyColor)
		TextureManager:updateImageView( mGood, "images/dayRecharge/"..goodUrl )
		mGood:setVisible( i<=infos.nowDay and not visiEff or visiGod )
		--龙玉特效
		self.mBoxEff = self.mBoxEff or {}
		if not self.mBoxEff[i] and visiEff then
			local size = box:getContentSize()
			self.mBoxEff[i] = UICCBLayer.new("rpg-chongzhi", box)
			self.mBoxEff[i]:setPosition( size.width*0.5, size.height*0.5 )
		elseif self.mBoxEff[i] then
			self.mBoxEff[i]:setVisible(visiEff)
		end
		--补签数
		if not daylist[i] and i<infos.nowDay then
			self.nPuck = self.nPuck + 1
		end
	end

	--七日奖励状态
	for i, mMack in ipairs( self.mMacks ) do
		local conf = self.rewardConf[i] or {}
		local day = conf.day
		local canGet = day<=#infos.day and not hasgetId[i]
		mMack:setOpacity( hasgetId[i] and 255 or 0 )
		mMack:addTouchEventListener(function(_,evenType)
			if evenType~=ccui.TouchEventType.ended then return end

			local function callback()
				if canGet then
					local conf = self.rewardConf[i]
					self:reqGetReward( { conf.ID } )
				elseif not hasgetId[i] then
					self:showSysMessage( self:getTextWord(230380) )
				else
					self:showSysMessage( self:getTextWord(1112) )
				end
			end
			local strTitle = self:getTextWord( hasgetId[i] and 1112 or 1111 )
			local strReward = StringUtils:jsonDecode( conf.reward )
			local dataReward = {}
			for i,data in ipairs( strReward ) do
				table.insert( dataReward, {
					power = data[1],
					typeid = data[2],
					num = data[3],
				} )
			end
			if not self.uiResourceGet then
				self.uiResourceGet = UIShowReward.new(self:getParent(), self, true )
			end
			self.uiResourceGet:show( dataReward, nil, true )
			self.uiResourceGet:setBtnCallback( callback )
			self.uiResourceGet:setBtnState( strTitle, not canGet )
			self.uiResourceGet:setTitle( self:getTextWord(338) )
			self.uiResourceGet.secLvBg:hideCloseBtn( true )
			self.uiResourceGet._uiSkin.root:setTouchEnabled( false )
			self.uiResourceGet.secLvBg._uiSkin.root:setTouchEnabled( true )
		end)
		--自动翻页
		local max = #self.rewardConf-GROUP_N-1
		if self.nCurIndex==0 and canGet and i<max then
			self.nCurIndex = i - 1
		end
	end

  	self:renderPage()

	--补签
	local haveGold = self.roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
	local needGold = math.max(1, self.nPuck) * self.infoConfig.retroactivePrice
	
	self.mCost:setString( needGold )
	self.mCost:setColor( haveGold>=needGold and ColorUtils.wordWhiteColor or ColorUtils.wordRedColor)

	--领取
	if #infos.day>=MAX_DAY and isChargeToday and infos.nowDay==MAX_DAY then
		self.getRewardIds = {}
		for i, _ in ipairs( self.mMacks ) do
			if not hasgetId[i] then
				local conf = self.rewardConf[i]
				table.insert( self.getRewardIds, conf.ID )
			end
		end
	else
		self.getRewardIds = nil
	end
	self.mGold:setVisible( not self.getRewardIds )
	self.mCost:setVisible( not self.getRewardIds )
	self.btnOk:setTitleText( self.getRewardIds and self:getTextWord(1111) or self:getTextWord(230370) )
end