
-- 通用 元宝兑换物品显示 界面。  
-- by fwx 2016.11.13

UIPayPanel = class("UIPayPanel", BasicComponent)

--panel        父级table
--okCallback  回调逻辑--->> 如果元宝足够，点击右下按钮后立即回调。默认空事件

--_title     标题。默认“提示”
--_btnTexts  左右两个按钮标题 默认{ "取消","确定" }
function UIPayPanel:ctor(panel, okCallback, _title, _btnTexts)
    UIPayPanel.super.ctor(self)

	self._uiSkin = UISkin.new("UIPayPanel")
    self._uiSkin:setParent(panel)
    self._uiSkin:setLocalZOrder( PanelLayer.UI_Z_ORDER_3 )
    self.secLvBg = UISecLvPanelBg.new( self._uiSkin:getRootNode(), self)
    self.secLvBg:setContentHeight(320)
    self.secLvBg:setBackGroundColorOpacity(120)
    self._panel = panel
    self.isFullGold = true  --默认元宝足够

    self.mainPanel = self._uiSkin:getChildByName("bgPanel")
    self.mainPanel:setTouchEnabled(false)
    self.mainPanel:setLocalZOrder(101)
    self.listView = self.mainPanel:getChildByName( "ListView_311" )
	self.textTitle = self.mainPanel:getChildByName( "text_title" )

    if okCallback then
    	self:setOkCallback( okCallback )
    end
    if _itemDatas then
    	self:show( _itemDatas )
    end
    self:setTitle( _title )

    local btn_center=self.mainPanel:getChildByName( "btn_center" )
    local btn_pay = self.mainPanel:getChildByName( "btn_pay" )
    _btnTexts = _btnTexts or {TextWords:getTextWord(101), TextWords:getTextWord(100)}
    if _btnTexts then
    	btn_center:setTitleText( _btnTexts[1] )
    	btn_pay:setTitleText( _btnTexts[2] )
    end
    ComponentUtils:addTouchEventListener( btn_center, function()
		self._uiSkin:setVisible(false)
    end)
	ComponentUtils:addTouchEventListener( btn_pay, function()
		if self.okCallback and self.isFullGold then
			self.okCallback( self._panel )
		elseif self._panel.showSysMessage then
			self:showRechargeUI()
			--self._panel:showSysMessage( TextWords:getTextWord(337) )
		end
		self._uiSkin:setVisible( false )
	end )
end
function UIPayPanel:finalize()
    UIPayPanel.super.ctor(self)
	self._uiSkin:finalize()
	self._uiSkin = nil
end

--==============================================
--接口
--==============================================
--_itemDatas  需要购买的物品列表  { {power, typeid, num}, {power, typeid, num}, ... }    ---- *num是需要购买数量
--   **请注意，是否需要重新 setOkCallback
function UIPayPanel:show( itemDatas )
	self._uiSkin:setVisible(true)

	--计算消耗元宝
	local nPayCoin = 0
	for i, itemData in ipairs(itemDatas) do
		local shopData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", itemData.typeid ) or {}
		local price = shopData.goldprice or 0
		nPayCoin = nPayCoin + price*itemData.num
	end
	self.isFullGold = true
	if self._panel and self._panel.getProxy then
		local roleProxy = self._panel:getProxy(GameProxys.Role)
    	local gold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    	self.isFullGold = nPayCoin<=gold
    end

	local strTit = string.format( TextWords:getTextWord(270030), nPayCoin )
	strTit = StringUtils:getStringAddBackEnter(strTit ,20)
	self.textTitle:setString( strTit )

	--刷新listView
	self._nWidth = self.listView:getContentSize().width/#itemDatas
	self:renderListView( self.listView, itemDatas, self, self.renderItemPanel )
end
function UIPayPanel:renderItemPanel( item, iconData )
	item:setContentSize( self._nWidth, item:getContentSize().height )
	if not item.icon then
		item.icon = UIIcon.new(item, iconData, true, self._panel, nil, true)
		item:setBackGroundColorType(0)
	else
		item.icon:updateData(iconData)
	end
	local size = item:getContentSize()
	item.icon:setPosition(size.width/2, size.height/2)
end

function UIPayPanel:setOkCallback( okCallback )
	self.okCallback = okCallback
end
function UIPayPanel:setTitle( title )
	self.secLvBg:setTitle( title or TextWords:getTextWord(128) )
end

function UIPayPanel:hide()
    self._uiSkin:setVisible(false)
end

function UIPayPanel:showRechargeUI()
	local parent = self._panel:getParent()
	if parent.panel == nil then
	    local _panel = UIRecharge.new(parent, self._panel)
	    parent.panel = _panel
	else
	    parent.panel:show()
	end
end