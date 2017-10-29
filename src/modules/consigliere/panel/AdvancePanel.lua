

-- 军师进阶
-- edited by fwx 2016.10.28

AdvancePanel = class("AdvancePanel", BasicPanel)
AdvancePanel.NAME = "AdvancePanel"

local ITEM_MAX = 6  --六个item
local LV_TEXTWORD = {270067, 270068, 270069, 270070}

function AdvancePanel:ctor(view, panelName)
    AdvancePanel.super.ctor(self, view, panelName, true)

    --六个item 的 谋士id
    --数据结构 { Common.AdviserInfo.id, Common.AdviserInfo.id, ...  }
    self.tVisiIds = {}

    self.isLevelUping = nil   --0 可以任何操作，，1 正在进阶 不可操作

    self:setUseNewPanelBg(true)
end
function AdvancePanel:finalize()
    if self._uiPayPanel then
    	self._uiPayPanel:finalize()
    	self._uiPayPanel = nil
    end
    if self.effHuo then
    	self.effHuo:finalize()
    	self.effHuo = nil
    end
    self.tVisiIds = {}
    self.isLevelUping = nil
    AdvancePanel.super.finalize(self)
end

--======================================================
--初始化
--======================================================
function AdvancePanel:initPanel()
	AdvancePanel.super.initPanel(self)
    self:setTitle(true,"advanced", true)
    -- self:setBgType(ModulePanelBgType.NONE)

	local panel = self:getChildByName("panel_middle")
	local paneld = self:getChildByName("panel_bottom")
	-- local Img_bg = panel:getChildByName("Img_bg")
	-- TextureManager:updateImageViewFile(Img_bg,"bg/consigliere/bg.jpg")
	-- Img_bg:setScale(0.6)
	self:setBgType(ModulePanelBgType.GOSSIP)

	self.proxy = self:getProxy(GameProxys.Consigliere)

	self.mTit = panel:getChildByName("lab_tit")
	self.mPay = paneld:getChildByName("lab_pay")
    self.topPanel = self:getChildByName("Panel_all")
    self.mPoint = self:getChildByName("img_point")
	self.mIcon=self.mPoint:getChildByName("Panel_icon")
	self.mIcon:setVisible(false)
	self.topPanel:setVisible(false)
	self.tOldPos = {}  --六个item原坐标
	self.m_icons = {}  --六个item图标
	self.m_items = {}  --六个item
	self.m_checks ={}  --复选

	for i=1, ITEM_MAX do
		local item = panel:getChildByName("Panel_"..i )
		self.tOldPos[i] = {x=item:getPositionX(), y=item:getPositionY()}
		self.m_items[i] = item
		self.m_icons[i] = item:getChildByName("_Img_icon")
		self:addTouchEventListener( item, function()
			self:onChilkItem( i )
		end )
		--check
		local check = paneld:getChildByName("CheckBox_"..i)
		if check then
			self.m_checks[i] = check
			check:addEventListener(function()
				check:setSelectedState( true )
				self:setSelect( i )
			end )
		end
	end
	local nextIndex = math.floor( 1+ITEM_MAX*0.5 )
	self.ox = (self.tOldPos[1].x + self.tOldPos[nextIndex].x)*0.5+50  --中心点
	self.oy = (self.tOldPos[1].y + self.tOldPos[nextIndex].y)*0.5+50

	--火特效
	self.effPanel = panel:getChildByName("Panel_eff")
	self.effPanel:setBackGroundColorType(0)
	self.effHuo = UICCBLayer.new("rgb-jsf-jinjiejihuo", self.effPanel)
	self.effHuo:setPosition(-5,-45)
end

function AdvancePanel:registerEvents()
	ConsiglierePanel.super.registerEvents(self)
	local paneld = self:getChildByName("panel_bottom")

	self:addTouchEventListener( self.topPanel, function()
		if self.isLevelUping then return end
		self:ainmInitPosition()
	end)

	local mBtnAuto = paneld:getChildByName("btn_auto")  --自动选择
	local mBtnSure = paneld:getChildByName("btn_sure")  --进阶
	local mBtnOnekey = paneld:getChildByName("btn_onekey") --一键进阶

	self:addTouchEventListener( mBtnAuto, self.onAuto)
	self:addTouchEventListener( mBtnSure, self.onSure)
	self:addTouchEventListener( mBtnOnekey, self.onOneKey)
end

--======================================================
-- 事件
--======================================================
--点击 自动选择
function AdvancePanel:onAuto()
	if self.isLevelUping then return end
	local index = self:getSelect()
	local tData = self.proxy:getQuiltyById( index, true )  --index星的所有闲置的谋士
	self.tVisiIds = {}
	local len = 0
	for i=1, ITEM_MAX do
		if tData[i] then
			len = len + 1
			self.tVisiIds[i] = tData[i].id
		end
		self:renderItemIcon( self.m_icons[i], tData[i], i )
	end
	self.effHuo:setVisible( len==ITEM_MAX )
	local _, payStr = self:getPayList( 1, index )
	self.mPay:setString( payStr )
end
--点击 进阶
function AdvancePanel:onSure()
	if self.isLevelUping or not self:isVisible() then return end
	local ids = self:getIds()
	if #ids<ITEM_MAX then
		self:showSysMessage( self:getTextWord(270065) )
	else
		local index = self:getSelect()
		local payList = self:getPayList( 1, index )
		if #payList>0 then
			self:onTryPay(payList, self.playAdvanceEft )
		else
			self:playAdvanceEft()
		end
	end
end
--点击 一键进阶
function AdvancePanel:onOneKey()
	local index = self:getSelect()
	local tData = self.proxy:getQuiltyById( index, true )  --index星的所有闲置的谋士
	local num = math.floor( #tData/ITEM_MAX )

	local function okfn()
		self.proxy:onTriggerNet260006Req( { quilty=index } )
	end

	if num>0 then
		local payList, centStr = self:getPayList( num, index )
		local lvStr = self:getTextWord( LV_TEXTWORD[index] ) or ""
		local retStr = string.format( self:getTextWord(270066), num or 1, lvStr,  centStr or "" )
		self:showMessageBox( retStr, function()
			self:onTryPay( payList, okfn )
		end)
	else
		self:showSysMessage( self:getTextWord(270065) )
	end
end
--点击 item
function AdvancePanel:onChilkItem( i )
	local m_icon = self.m_icons[i]

	if m_icon:isVisible() then
		m_icon:setVisible( false )
		self.effHuo:setVisible(false)
		self.tVisiIds[i] = nil
	else
		local callback = function( visiIds )
			self.tVisiIds = visiIds
			self:renderTableView( visiIds )
		end
		local panel = self:getPanel(ChoosePanel.NAME)
		local index = self:getSelect()
		local dataList = self.proxy:getQuiltyById( index, true )  --index星的所有闲置的谋士
		local data = { ids=self.tVisiIds, dataList=dataList, callback=callback }  --打开批量选择
		panel:show( data )
	end
end

--==========================================
--外部刷新
--==========================================
function AdvancePanel:onShowHandler()
	self.isLevelUping = nil

	self.m_checks[1]:setSelectedState( true )
	self:setSelect(1)
	self:setInitPos()
end
function AdvancePanel:onClosePanelHandler()
	self.isLevelUping = nil
	self:hide()
	self.view:updateConsigliereList()
end

function AdvancePanel:playAdvanceEft()
	self.isLevelUping = true

	local ids = self:getIds()
	local index = self:getSelect()
	local data = { ids=ids, quilty=index }
	self.proxy:onTriggerNet260001Req( data )
end

--260001回来更新。播放特效
function AdvancePanel:advanceSuccess( rs, typeid )

	self.effHuo:setVisible(false)

	local function playAnim()
		self.topPanel:setOpacity(255)
		self.mIcon:setVisible( true )
		ComponentUtils:renderConsigliereItem( self.mIcon, typeid )
		self.mPoint:setScale(0)
		self.mPoint:setLocalZOrder(99)
		self.mPoint:runAction( cc.Sequence:create(
			cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1 ) ),
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				self.isLevelUping = nil
			end)
		) )
	end 

	if rs==0 and typeid then
		local function fpause()
			for i, item in ipairs(self.m_items) do
			-- local isFisrt = i==1
						-- local scale = item:getScale()
						-- item:runAction( cc.Sequence:create(
						-- 	cc.Spawn:create(
						-- 		cc.EaseSineOut:create( cc.MoveTo:create( 0, cc.p( self.ox, self.oy ))),
						-- 		cc.ScaleTo:create( 0, 0)
						-- 		),cc.FadeTo:create( 0, 0 )
						-- 	))
						-- item:runAction(cc.FadeTo:create(0.1,0))
						item:getChildByName("_Img_icon"):setOpacity(0)
			end
		end
		local function fpause1()
			playAnim()
		end

		local function fcomplete()
			for _, item in ipairs(self.m_items) do
						item:getChildByName("_Img_icon"):setOpacity(255)
			end
			self.effHC:finalize()
		end

		--特效要填单次播放，否则快速点击进阶，会卡死.
		local cbtb={pause=fpause,pause1=fpause1,complete=fcomplete}
		self.effHC = self:createUICCBLayer("rgb-jsf-jinjie", self:getParent(), cbtb, nil, true)  

		local panel = self:getChildByName("panel_middle")
		local x = panel:getPositionX() + self.effPanel:getPositionX()
		local y = panel:getPositionY() + self.effPanel:getPositionY()-60
		self.effHC:setPosition( x, y )
		self.topPanel:setVisible( true )
		self.topPanel:setOpacity(0)

		-- for i, item in ipairs(self.m_items) do
		-- 	local isFisrt = i==1
		-- 	local scale = item:getScale()
		-- 	item:runAction( cc.Sequence:create(
		-- 		cc.Spawn:create(
		-- 			cc.EaseSineOut:create( cc.MoveTo:create( 0.4, cc.p( self.ox, self.oy ) ) ) ,
		-- 			cc.ScaleTo:create( 0.4, 0)
		-- 		),
		-- 		cc.FadeTo:create( 0, 0 ),
		-- 		cc.DelayTime:create( 0.5 ),
		-- 		cc.CallFunc:create(function()  --还原坐标
		-- 			item:setScale(scale)
		-- 			if not isFisrt then return end
		-- 			playAnim()
		-- 		end)
		-- 	))
		-- end
	else
		self.isLevelUping = nil
		self:ainmInitPosition()
	end
end




--==========================================
--
--==========================================
function AdvancePanel:setSelect( index )
	for i, _check in ipairs(self.m_checks) do
		if index~=i then
			_check:setSelectedState( false )
		end
	end
	local lvStr = self:getTextWord( LV_TEXTWORD[index] ) or ""
	lvStr = string.format( self:getTextWord(270032), lvStr )
	self.mTit:setString( lvStr )

	self:onAuto()
end
function AdvancePanel:getSelect()
	for i, _check in ipairs(self.m_checks) do
		if _check:getSelectedState() then
			return i
		end
	end
end
--单个刷新item
function AdvancePanel:renderItemIcon( icon, data, i )
	data = data or {}
	local conf = self.proxy:getDataById( data.typeId ) or {}
	self:renderIcon( icon, conf.head, i )
end
--多个刷新item
function AdvancePanel:renderTableView( visiIds )
	local len = 0
	for i=1, ITEM_MAX do
		local id = visiIds[i]
		local conf = self.proxy:getConfById( id )
		if conf then
			len = len + 1
			self:renderIcon( self.m_icons[i], conf.head, i )
		else
			self:renderIcon( self.m_icons[i], nil, i )
		end
	end
	self.effHuo:setVisible( len==ITEM_MAX )
end

function AdvancePanel:renderIcon( micon, head, i )
	micon:setVisible( false )
	if head then
		micon:stopAllActions()
		micon:runAction( cc.Sequence:create(
			cc.DelayTime:create(0.03*i),
			cc.CallFunc:create(function()
				micon:setVisible( true )
				local str = string.format("images/counsellorIcon/%d.png", head or 1)
				TextureManager:updateImageView( micon, str )
			end)
		) )
	end
end

function AdvancePanel:getPayList( num, index )
	local itemProxy = self:getProxy(GameProxys.Item)

	local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.CounsellorAdcostConfig, "ID", index ) or {}
	local needDatas = StringUtils:jsonDecode( config.need )

	local centStr = ""
	local tNeedDataList = {}
	for i, data in ipairs( needDatas ) do
		local typeid = data[2]
		local nNeedNum = data[3]*num or 0
		local nMyNumber = itemProxy:getItemNumByType( typeid )

		if nMyNumber<nNeedNum then
			local coinData = {}
			coinData.num = nNeedNum-nMyNumber
			coinData.typeid = typeid
			coinData.power = data[1]
			table.insert( tNeedDataList, coinData )
		end
		local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",typeid) or {}
		local dhStr = i<#needDatas and "," or ""
		centStr = centStr..info.name.."*"..nNeedNum..dhStr
	end
	return tNeedDataList, centStr
end

function AdvancePanel:onTryPay( tNeedDataList, okfn )
	if #tNeedDataList>0 then
		if not self._uiPayPanel then
			self._uiPayPanel = UIPayPanel.new( self, okfn)
		end
		self._uiPayPanel:show( tNeedDataList )
		self._uiPayPanel:setOkCallback( okfn )
	else
		okfn()
	end
end

--动画结束回到原始状态
function AdvancePanel:ainmInitPosition()
	self.topPanel:setVisible( false )
	self.mIcon:setVisible( false )
	self:setInitPos()
	self:onAuto()
end
function AdvancePanel:setInitPos()
	if self.isLevelUping then return end
	for i,item in ipairs(self.m_items) do
		self.tOldPos[i] = self.tOldPos[i] or {}
		item:setPosition( self.tOldPos[i].x or 0, self.tOldPos[i].y or 0 )
		item:setOpacity(255)
	end
end
function AdvancePanel:getIds()
	local ids = {}
	for _,id in pairs(self.tVisiIds) do
		table.insert( ids, id )
	end
	return ids
end