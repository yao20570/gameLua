-- /**
--  * @Author:	 fwx
--  * @DateTime: 2016.12.08
--  * @Description:  金鸡砸蛋
--  */
SmashEggPanel = class("SmashEggPanel", BasicPanel)
SmashEggPanel.NAME = "SmashEggPanel"

function SmashEggPanel:ctor(view, panelName)
	SmashEggPanel.super.ctor(self, view, panelName, true)
end

local MAX_BOX = 9  --九个蛋
local DELAY = 0.1  --连续砸蛋间隔
local DELAY_ITEM = 2 --item动画展示时间

function SmashEggPanel:finalize()
	for i,eff in ipairs(self.mEffs or {}) do
		eff:finalize()
	end
	self.mEffs = {}
	SmashEggPanel.super.finalize(self)
end

function SmashEggPanel:initPanel()
	SmashEggPanel.super.initPanel(self)

	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true,"smashEgg",true)
	
	self.proxy = self:getProxy( GameProxys.Activity )

	self.mImgBg = self:getChildByName("Img_bg")
	TextureManager:updateImageViewFile( self.mImgBg,"bg/smashEgg/smashEgg.pvr.ccz")

	self.mPanel 	= self:getChildByName("Panel_1")
	self.mTopPanel 	= self:getChildByName("Panel_224")
	self.mDownPanel = self:getChildByName("Panel_148")
	self.mText2 	= self.mTopPanel:getChildByName("text_2")
	self.mText3 	= self.mDownPanel:getChildByName("text_3")
	self.mText4 	= self.mDownPanel:getChildByName("text_4")
	self.mMackBg 	= self:getChildByName("Panel_53")
	self.mMack 		= self:getChildByName("Panel_36")
	self.mKeepText 	= self:getChildByName("text")
	self.mPanel:setVisible(true)

	local conf = ConfigDataManager:getConfigData( ConfigData.SmashEggConfig ) or {}
	conf = conf[1] or {}
	self.mText4:setString( "/"..conf.numberMax )

	local des1 = self.mTopPanel:getChildByName("desc1")
	local des2 = self.mTopPanel:getChildByName("desc2")
	local des3 = self.mTopPanel:getChildByName("desc3")
	des1:setString( self:getTextWord(230401) )
	des2:setString( self:getTextWord(230402) )
	des3:setString( self:getTextWord(230403) )
	-- des3:setString( self:getTextWord(260007) )

	--蛋
	self.num1 = 0
	self.num2 = 0
	self.nCurPoint = nil
	self.mBoxs = {}
	self.mEffs = {}
	for i=1, MAX_BOX do
		local box = self.mPanel:getChildByName( "icon01_"..i )
		local nSacle = box:getScaleX()
		box:setTouchEnabled( true )
		box:addTouchEventListener( function( _, evenType )
			if evenType~=ccui.TouchEventType.ended or self.btnEnabled~=true or box.flag then return end
			self:randomEggAction(i)
			self:onTouchSmash(i)
		end )
		self.mBoxs[i] = box
	end

	self.nNumberSmash = 1
	--砸蛋按钮
	self.btnEnabled = true
	self.btnMashBtn = self.mDownPanel:getChildByName("Button_23")
	self:addTouchEventListener( self.btnMashBtn, function()
		self:onTouchSmash()
	end )
	self:addTouchEventListener( self.mMack, self.onTouchMack)
end
function SmashEggPanel:doLayout()
	NodeUtils:adaptivePanelBg( self.mImgBg, GlobalConfig.downHeight-5, self.mTopPanel)
	NodeUtils:adaptivePanelBg( self.mPanel, GlobalConfig.downHeight-5, self.mTopPanel)
end

function SmashEggPanel:registerEvents()
	SmashEggPanel.super.registerEvents(self)
end

--====================================================
--事件-----
function SmashEggPanel:onClosePanelHandler()
	self.mTopPanel:stopAllActions()
	self.view:dispatchEvent( SmashEggEvent.HIDE_SELF_EVENT )
end
function SmashEggPanel:onShowHandler()
	self:rednerTouchEnabled( true )
	self.mPanel:stopAllActions()
	self.mMack:setVisible( false )
	self.mMackBg:setOpacity(0)
	self.mKeepText:setOpacity(0)
	self.mKeepText:stopAllActions()
	self.mTopPanel:stopAllActions()
	self.mTopPanel:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.DelayTime:create(math.random()*3+1.5),
		cc.CallFunc:create(function()
			self:randomEggAction()
		end)
	)))
	--蛋
	for i=1, #self.mBoxs do
		local box = self.mBoxs[i]
		if box.eff then
			box.eff:setVisible(false)
		end
		self:renderBoxIcon( box )
		--特效
		self:delayCallBack( math.random()*7, function() --((i-1)%3+math.ceil(i/3))
			self.mEffs[i] = self.mEffs[i] or UICCBLayer.new("rpg-jindan", box )
			self.mEffs[i]:setPosition( box:getContentSize().width*0.5, box:getContentSize().height*0.5 )
		end)
	end
	--今日消耗
	self:updateValue()
end
--20007变化回来
function SmashEggPanel:updateValue()

	local roleProxy = self:getProxy(GameProxys.Role)
	local nowSpend = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin)
	local mText1 = self.mTopPanel:getChildByName("text_1")
	mText1:setString( nowSpend )

	self.num1, self.num2 = self.proxy:getSmashEggNumber()
	self.mText2:setString( self.num1 )
	self.mText3:setString( self.num2 )
	self.mText2:setColor( self.num1>0 and ColorUtils.wordGreenColor or ColorUtils.wordWhiteColor )
	self.mText3:setColor( self.num2>0 and ColorUtils.wordGreenColor or ColorUtils.wordWhiteColor )
	self.mText4:setPositionX( self.mText3:getPositionX() + self.mText3:getContentSize().width )
end
--点继续
function SmashEggPanel:onTouchMack()
	if not self.btnEnabled then return end
	local eggs = self:getSmashEggs()
	for i,box in ipairs( self.mBoxs ) do
		if box.eff and box.eff:isVisible() then
			self:eggToBagAction( box )
		end
		self:renderBoxIcon( box, false )
	end
	self.mMack:setVisible( false )
	self.mMackBg:runAction(cc.FadeTo:create(0.1, 0))
	self.mKeepText:stopAllActions()
	self.mKeepText:setOpacity(0)
	self:rednerTouchEnabled( true )
end

--====================================================
--点蛋
function SmashEggPanel:onTouchSmash( point )
	if not self.btnEnabled then return end
	local numberSmash = point and 1 or MAX_BOX  --准备砸蛋个数
	numberSmash = math.min( self.num1, numberSmash )
	numberSmash = math.min( self.num2, numberSmash )
	numberSmash = math.max( 1, numberSmash )

	local action1 = cc.EaseBackOut:create(cc.ScaleTo:create(0.1,2))
	local action2 = cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1))

	if self.num2 and self.num2<numberSmash then   
		self:showSysMessage( self:getTextWord(230404) )  --已上限
		self.mText3:runAction( cc.Sequence:create(action1, action2))
	elseif self.num1 and (self.num1-numberSmash)<0 then
		self:showSysMessage( self:getTextWord(230405) )  --次数不足
		self.mText2:runAction( cc.Sequence:create(action1, action2))
	else
		self.nCurPoint = point
		if numberSmash>1 then
			self:showMessageBox( self:getTextWord(230406), function()
				self:onSmashEggTrigger230030( numberSmash )
			end)
		else
			self:onSmashEggTrigger230030( numberSmash )
		end
	end
end
--请求砸蛋
function SmashEggPanel:onSmashEggTrigger230030( numberSmash )
	self:rednerTouchEnabled( false )  --灰
	self.nNumberSmash = numberSmash
	self.proxy:setNumberSmash( numberSmash )
	--请求
	local activityData = self.proxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_SMASHEGG_ID )
	if activityData then
		self.proxy:onTriggerNet230030Req( { activityId=activityData.activityId, times=numberSmash} )
	end
end
--23030砸蛋回来
function SmashEggPanel:onSmashEggResp( rewardList )
	--开蛋
	for index = 1, self.nNumberSmash do
		self:delayCallBack( DELAY*index, function()
			local point = self.nCurPoint or index
			self:renderBoxIcon( self.mBoxs[point], true, rewardList[index] or {} )
		end)
	end
	--背景效果
	self.mMackBg:runAction(cc.Sequence:create(
		cc.DelayTime:create( DELAY_ITEM*0.2 ),
		cc.FadeTo:create(0.2, 120)
	))
	self:delayCallBack( DELAY_ITEM*0.8, function()
		self.mKeepText:runAction( cc.RepeatForever:create(cc.Sequence:create(
			cc.FadeTo:create(0.7,255),
			cc.FadeTo:create(0.7,0)
		)))
	end)
	self.mMack:setVisible( true )
	self:delayCallBack( DELAY*self.nNumberSmash + DELAY_ITEM, function()
		self.btnEnabled = 1
	end )
end
--开蛋
function SmashEggPanel:renderBoxIcon( box, flag, itemData )
	if not box then return end
	local size = box:getContentSize()
	local x = size.width*0.5
	local y = size.height*0.5+5
	local url = flag and "images/smashEgg/egg_die.png" or "images/smashEgg/egg_idle.png"
	TextureManager:updateImageView( box, url )
	box.flag = flag
	if flag then
		if not box.eff then
			box.eff = UICCBLayer.new("rpg-bxwupin", box, nil, nil, true)
		end

		local data = {
			power = itemData.power,
			typeid = itemData.typeid,
			num = itemData.num or 1,
		}
		if not box.icon then
			box.icon = UIIcon.new( box.eff:getLayer(), data, true, self, nil)
			box.icon:setPosition( 0, 17 )
		else
			box.icon:updateData( data )
		end
		box.eff:stopAllActions()
		box.eff:setVisible(false)
		box.eff:setOpacity(255)
		box.eff:setPosition(x, y)
		box.eff:runAction(cc.Sequence:create(
			cc.DelayTime:create( DELAY_ITEM*0.35 ),
			cc.EaseExponentialOut:create( cc.MoveTo:create(DELAY_ITEM*0.2, cc.p(x, y+50)) )
		))
		box.icon:setVisible(false)
		box.icon:setScale(0)
		box.icon:runAction(cc.Sequence:create(
			cc.DelayTime:create( DELAY_ITEM*0.35 ),
			cc.CallFunc:create(function()
				box.icon:setVisible(true)
				box.eff:setVisible(true)
			end),
			cc.EaseBackOut:create(cc.ScaleTo:create(DELAY_ITEM*0.2, 1))
		))

		local eff = UICCBLayer.new("rgb-zajindan", box, nil, nil , true )
		eff:setPosition( size.width*0.5, size.height*0.5 )
	end
end
--可点击状态
function SmashEggPanel:rednerTouchEnabled( isEnabled )
	self.btnEnabled = isEnabled
	self.btnMashBtn:setVisible( isEnabled )
end

--=============================================================
function SmashEggPanel:getSmashEggs()
	local eggs = {}
	for i,box in ipairs(self.mBoxs) do
		if not box.flag then table.insert( eggs, box ) end
	end
	return eggs
end


--=============================================================
--动画 
function SmashEggPanel:delayCallBack( time, callback, _parent, _fmt )
	local fn = _parent and function()
		callback( _parent, _fmt )
	end or callback
	self.mPanel:runAction( cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create( fn )
	) )
end
--egg随机动一下
function SmashEggPanel:randomEggAction( index )
	local random = math.random()*5 + 2
	local flag = math.random()>0.5 and 1 or -1
	local box
	if index then
		box = self.mBoxs[index]
		random = math.random()*3+1
		flag = -1
	else
		local eggs = self:getSmashEggs()
		local i = math.ceil(math.random()*#eggs)
		box = eggs[i]
	end
	if not box or not self.btnEnabled then return end
	box:runAction( cc.Sequence:create(
		cc.EaseSineOut:create( cc.RotateTo:create( 0.15, random*flag) ),
		cc.EaseSineInOut:create( cc.RotateTo:create( 0.13, -random*0.7*flag )),
		cc.EaseSineInOut:create( cc.RotateTo:create( 0.08, random*0.3*flag )),
		cc.RotateTo:create( 0.05, 0 )
	) )
end
-- MoveTo背包
function SmashEggPanel:eggToBagAction( box )
	local size = self.mPanel:getContentSize()
	local toPosx = (size.width*0.9-box:getPositionX())/box:getScale()
	local toPosy = (40-box:getPositionY()/box:getScale())
	local time = math.abs(toPosy/size.height*0.5)*(math.random()*1.2+0.3)
	AudioManager:playEffect("TouchMarket")
	box.eff:runAction(cc.Sequence:create(
		cc.EaseSineIn:create( cc.MoveTo:create( time, cc.p( toPosx, toPosy )) ),
		cc.CallFunc:create(function()
			local layer = UICCBLayer.new("rgb-huoquwuping-beibao", box, nil, nil, true) 
			layer:setPosition( toPosx, toPosy )
			box.eff:setVisible(false)
		end)
	))
end