--
-- Author: zlf
-- Date: 2016年9月10日11:47:25
-- 购买道具，使用道具二级面板

-- goodsId：道具ID
--type： 1:代表购买商品；2:代表使用商品
-- maxNum： 最大购买数量/最大使用使用数量

UIGoodsPanel = class("UIGoodsPanel")

function UIGoodsPanel:ctor(parent, panel, goodsId, type, maxNum)
	local uiSkin = UISkin.new("UIGoodsPanel")
    uiSkin:setParent(parent)
    uiSkin:setLocalZOrder(100)

    
    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    -- self.secLvBg:setContentHeight(480)
    self.secLvBg:setBackGroundColorOpacity(120)
    self:setBgHeightByType(type)
    self.secLvBg:setTouchEnabled(true)

    self._parent = parent
    self._uiSkin = uiSkin
    self._panel = panel
    self:registerProxyEvent()

    self:initPanel()
    self:show(goodsId, type, maxNum)
end

function UIGoodsPanel:registerProxyEvent()
    local proxy = self._panel:getProxy(GameProxys.Item)
    proxy:addEventListener(AppEvent.PROXY_BUYGOODS_UPDATE, self, self.onBuyGoodsCall)
    proxy:addEventListener(AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onUesGoodsCall)
end

function UIGoodsPanel:finalize()
	local proxy = self._panel:getProxy(GameProxys.Item)
    proxy:removeEventListener(AppEvent.PROXY_BUYGOODS_UPDATE, self, self.onBuyGoodsCall)
    proxy:removeEventListener(AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onUesGoodsCall)

    if self._uiMoveBtn ~= nil then
		self._uiMoveBtn:finalize()
		self._uiMoveBtn = nil
	end
	self._uiSkin:finalize()
end

function UIGoodsPanel:onBuyGoodsCall(data)
	if data.rs == 0 then
		self._panel:showSysMessage(TextWords:getTextWord(541))
		self:hide()
	end
end

function UIGoodsPanel:onUesGoodsCall(data)
	-- if data.rs == 0 then
		-- self._panel:showSysMessage(TextWords:getTextWord(1011))
		self:hide()
	-- end
end

-- 弹窗高度
function UIGoodsPanel:setBgHeightByType(type)
	local height,titleNO
	if type == 2 then
		height = 430--410
		titleNO = 5049
	else
		height = 500--480
		titleNO = 1606
	end
	self.secLvBg:setContentHeight(height)
	self.secLvBg:setTitle(TextWords:getTextWord(titleNO))
end

-- 显示批量使用
function UIGoodsPanel:showInfoByType(mainPanel,goodsId, type, maxNum)
	local buyBtn = mainPanel:getChildByName("Button_buy")
	local Panel_goods = mainPanel:getChildByName("Panel_goods")
	local iconImg = Panel_goods:getChildByName("Image_icon")
	local Label_name = Panel_goods:getChildByName("Label_name")
	local Label_desc = Panel_goods:getChildByName("Label_desc")
    local Panel_control = mainPanel:getChildByName("Panel_control")
	
    logger:error("点击使用物品,goodsId= " .. goodsId)

	local roleProxy = self._panel:getProxy(GameProxys.Role)
	local itemData = ConfigDataManager:getConfigById(ConfigData.ItemConfig, goodsId)
	local shopData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", goodsId)

	-- 购买OR使用按钮
	buyBtn.type = type
	buyBtn.id = shopData.ID
	buyBtn.typeId = goodsId
	ComponentUtils:addTouchEventListener(buyBtn, self.btnTouch, nil,self)

	-- 道具信息
	self.price = shopData.goldprice
	local have = roleProxy:getRolePowerValue(GamePowerConfig.Resource,206)
	Label_name:setString(itemData.name)
	Label_desc:setString(itemData.info)

	-- 道具icon
	local uiIcon = iconImg.uiIcon
	local data = {}
	data.typeid = goodsId
	data.power = GamePowerConfig.Item
	data.num = 1
	if uiIcon == nil then
		uiIcon = UIIcon.new(iconImg, data , true)
		iconImg.uiIcon = uiIcon
	else
		uiIcon:updateData(data)
	end

	-- 数量信息
    if type == 1 then
	    local infoPanel = mainPanel:getChildByName("Panel_num")
	    local childs = infoPanel:getChildren()
	    self.allChild = {}
	    for k,v in pairs(childs) do
	    	self.allChild[v:getName()] = v
	    end
	    self.allChild.oneLab:setString(self.price)
	    self.allChild.haveLab:setString(have)
    elseif type == 2 then
	    local usePanel = mainPanel:getChildByName("usePanel")
	    self.useLab = usePanel:getChildByName("useLab")
	    self.useLab:setString("0")
    end

    -- 最大购买OR使用数量限制为100
	if maxNum == nil or maxNum > 100 then
		maxNum = 100
	end

    -- 滑动按钮
	local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self["onMoveBtnCallback"..type]
    args["count"] = 1
    self.curCount = 1
    if self._uiMoveBtn == nil then
        self._uiMoveBtn = UIMoveBtn.new(Panel_control, args)
    end
    self._uiMoveBtn:setEnterCount(maxNum, true)
end

-- 初始化UI
function UIGoodsPanel:initPanel()
	local panel
	for i=1,2 do
		panel = self:getChildByName("mainPanel"..i)
		panel:setVisible(false)
		self["mainPanel"..i] = panel
	end
end

-- 刷新弹窗信息
function UIGoodsPanel:show(goodsId, type, maxNum)
	local mainPanel = self["mainPanel"..type]
	if mainPanel then
		mainPanel:setVisible(true)
		mainPanel:setLocalZOrder(100)
		mainPanel:setTouchEnabled(false)
		self._uiSkin:setVisible(true)
		self:showInfoByType(mainPanel,goodsId,type,maxNum)
	end
end

function UIGoodsPanel:getChildByName(name)
	return self._uiSkin:getChildByName(name)
end

function UIGoodsPanel:onMoveBtnCallback1(count)
	self.allChild.useLab:setString(count)
	self.allChild.numLab:setString(count)
	self.allChild.allLab:setString(count*self.price)
	self.curCount = count
end

function UIGoodsPanel:onMoveBtnCallback2(count)
	self.useLab:setString(count)
	self.curCount = count
end

function UIGoodsPanel:hide()
    self._uiSkin:setVisible(false)
end

function UIGoodsPanel:btnTouch(sender)
	local type = sender.type
	local id = sender.id
	local proxy = self._panel:getProxy(GameProxys.Item)
	if type == 1 then
		proxy:onTriggerNet100008Req({id = id, num = self.curCount})
	else
		proxy:onTriggerNet90001Req({typeId = sender.typeId, num = self.curCount})
	end
end