
BuyPanel = class("BuyPanel", BasicPanel)
BuyPanel.NAME = "BuyPanel"

function BuyPanel:ctor(view, panelName)
    BuyPanel.super.ctor(self, view, panelName, 500)
    
    self:setUseNewPanelBg(true)
end
--Panel显示时调用
function BuyPanel:onShowHandler(data)
    self:updatePanel(data)
end 
function BuyPanel:finalize()
    BuyPanel.super.finalize(self)
end

function BuyPanel:initPanel()
    BuyPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1606))


    -- local panel = self:getChildByName("mainPanel")
    -- panel:setVisible(false)  --测试

    --设置panel的Z-order
    self:setLocalZOrder (PanelLayer.UI_Z_ORDER_1)
    self:initPanelItems()
    self._allCost = 0
end
function BuyPanel:initPanelItems()
    local items = {}
    
    items.imgIcon = self:getChildByName("mainPanel/Panel_goods/Image_icon")
    items.labelName = self:getChildByName("mainPanel/Panel_goods/Label_name")
    items.labelDesc = self:getChildByName("mainPanel/Panel_goods/Label_desc")
    
    local conBar = self:getChildByName("mainPanel/Panel_control")

    items.labelPrice = self:getChildByName("mainPanel/Panel_num/Label_num1")
    items.labelBuyNum = self:getChildByName("mainPanel/Panel_num/Label_num2")
    items.labelCost = self:getChildByName("mainPanel/Panel_num/Label_num3")
    items.labelHave = self:getChildByName("mainPanel/Panel_num/Label_num4")
    
    
    local buyBtn = self:getChildByName("mainPanel/Button_buy")
    self:addTouchEventListener(buyBtn,self.onBuyBtnClicked)
    
    self._items = items
    
    local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self.onMoveBtnCallback
    args["count"] = 1
    if self._uiMoveBtn == nil then
        self._uiMoveBtn = UIMoveBtn.new(conBar, args)
    end 
    self._uiMoveBtn:setEnterCount(100,true)
    
end
--更新购买数量
function BuyPanel:updateBuyNum(num)

	if self._data == nil then
		return
	end
    local num = num or 1
    self._buyNum = num
    local price = 1

	if self._data ~= nil then
		if self._data.itemCostData then
			price = self._data.itemCostData.num
		end
	end
    local allCost = price*num
    self._items.labelBuyNum:setString(num)
    self._items.labelCost:setString(allCost)
    self._allCost = allCost
end 
--更新
function BuyPanel:updatePanel(data)
    self._data = data

    if self._uiMoveBtn ~= nil then
	    if data.isTimeLimit then
	        self._uiMoveBtn:setEnterCount(data.maxBuyNum,true)
	    else
	        self._uiMoveBtn:setEnterCount(100,true)
	    end
    end 
    local itemData = data.itemData
    local costItemData = data.itemCostData
    local items = self._items
    --商品
    local imgIcon = items.imgIcon
    local data = {}
    data.num = 1
    data.power = itemData.power
    data.typeid = itemData.typeid
    if self._uiIcon == nil then
        self._uiIcon = UIIcon.new(imgIcon,data,false)
        self._uiIcon:setPosition(imgIcon:getContentSize().width/2,imgIcon:getContentSize().height/2)
    else
        self._uiIcon:updateData(data)
    end 

    local conf = ConfigDataManager:getConfigByPowerAndID(itemData.power, itemData.typeid)
    items.labelName:setString(conf.name)

    items.labelDesc:setString(conf.info)
    
    -- 单价
    local price = costItemData.num  --原价
    items.labelPrice:setString(price)

    --数量
    items.labelHave:setString(self._data.iHaveNum)

    self:updateBuyNum(1)
end
----回调函数定义---------
--购买
function BuyPanel:onBuyBtnClicked(sender)

    if self._data.iHaveNum > self._allCost then
		self._data.btnBuyCallback(self._buyNum)
    else
    	--显示彩豆不足
	    local conf = ConfigDataManager:getConfigByPowerAndID(self._data.itemCostData.power, self._data.itemCostData.typeid)
		self:showSysMessage(string.format(TextWords:getTextWord(540056),conf.name))
    end
    
    self:onClosePanelHandler()
end




--改变bar
function BuyPanel:onMoveBtnCallback(count)
    --print("count ====",count)
    local count = count
    self:updateBuyNum(count)
end 
--关闭界面
function BuyPanel:onCloseBtnClicked(sender)
    self:onClosePanelHandler()
end
function BuyPanel:onClosePanelHandler()
    BuyPanel.super.onClosePanelHandler(self)
    self:hide()
end