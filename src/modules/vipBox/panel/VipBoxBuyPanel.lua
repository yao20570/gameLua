
VipBoxBuyPanel = class("VipBoxBuyPanel", BasicPanel)
VipBoxBuyPanel.NAME = "VipBoxBuyPanel"

function VipBoxBuyPanel:ctor(view, panelName)
    VipBoxBuyPanel.super.ctor(self, view, panelName, 460)

end
--Panel显示时调用
function VipBoxBuyPanel:onShowHandler(data)
    self:updatePanel(data)
end 
function VipBoxBuyPanel:finalize()
    VipBoxBuyPanel.super.finalize(self)
end

function VipBoxBuyPanel:initPanel()
    VipBoxBuyPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1606))


    -- local panel = self:getChildByName("mainPanel")
    -- panel:setVisible(false)  --测试

    --设置panel的Z-order
    -- self:setLocalZOrder (PanelLayer.UI_Z_ORDER_1)
    self:initPanelItems()
    self._allCost = 0
end
function VipBoxBuyPanel:initPanelItems()
    local items = {}
    -- local labelTitle = self:getChildByName("mainPanel/Panel_title/Label_titleName")
    -- labelTitle:setString(self:getTextWord(1606))
    
    items.imgIcon = self:getChildByName("mainPanel/Panel_goods/Image_icon")
    items.labelName = self:getChildByName("mainPanel/Panel_goods/Label_name")
    items.labelDesc = self:getChildByName("mainPanel/Panel_goods/Label_desc")
    
    local conBar = self:getChildByName("mainPanel/Panel_control")

    items.labelPrice = self:getChildByName("mainPanel/Panel_num/Label_num1")
    items.labelBuyNum = self:getChildByName("mainPanel/Panel_num/Label_num2")
    items.labelCost = self:getChildByName("mainPanel/Panel_num/Label_num3")
    items.labelHave = self:getChildByName("mainPanel/Panel_num/Label_num4")
    
    
    -- local closeBtn = self:getChildByName("mainPanel/Panel_title/Button_close")
    local buyBtn = self:getChildByName("mainPanel/Button_buy")
    -- self:addTouchEventListener(closeBtn,self.onCloseBtnClicked)
    self:addTouchEventListener(buyBtn,self.onBuyBtnClicked)
    
    self._items = items
    
    local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self.onMoveBtnCallback
    args["count"] = 1
    if self._uiMoveBtn == nil then
        self._uiMoveBtn = UIMoveBtn.new(conBar, args)
    end 
    -- self._uiMoveBtn:setEnterCount(5,true)
    
end
--更新购买数量
function VipBoxBuyPanel:updateBuyNum(num)
    local num = num or 1
    self._buyNum = num
    local price = 1
    if self._data ~= nil then
        price = self._data.shopData.goldprice
    end 
    local allCost = price*num
    self._items.labelBuyNum:setString(num)
    self._items.labelCost:setString(allCost)
    self._allCost = allCost
end 
--更新
function VipBoxBuyPanel:updatePanel(data)
    self._data = data
    if self._uiMoveBtn ~= nil then
        self._uiMoveBtn:setEnterCount(data.maxNum,true)
    end 
    local shopData = data.shopData
    local itemData = data.itemData
    local power = data.power
    local items = self._items
    --商品
    local imgIcon = items.imgIcon
    local data = {}
    data.num = 1
    data.power = power
    data.typeid = shopData.itemID
    if self._uiIcon == nil then
        self._uiIcon = UIIcon.new(imgIcon,data,false)
        self._uiIcon:setPosition(imgIcon:getContentSize().width/2,imgIcon:getContentSize().height/2)
    else
        self._uiIcon:updateData(data)
    end 
    items.labelName:setString(itemData.name)
    items.labelDesc:setString(itemData.info)
    --数量
    items.labelPrice:setString(shopData.goldprice)
    local roleProxy = self:getProxy(GameProxys.Role)
    local have = roleProxy:getRolePowerValue(GamePowerConfig.Resource,206)
    items.labelHave:setString(have)
    self:updateBuyNum(1)
end
----回调函数定义---------
-- --购买
-- function VipBoxBuyPanel:onBuyBtnClicked(sender)
--     --发送购买消息
--     local data = {}
--     data.id = self._data.shopData.ID
--     data.num = self._buyNum
--     print("send data ===",data.id,data.num)
--     self.view:dispatchEvent(ShopEvent.SEND_MESSAGE_BUY_GOODS,data)
    
--     self:onClosePanelHandler()
-- end

--购买
function VipBoxBuyPanel:onBuyBtnClicked(sender)


    local function callFunc()
        --发送购买消息
        local data = {}
        local vipBoxProxy = self:getProxy(GameProxys.VIPBox)
        data.activityId = vipBoxProxy:getActivityId()
        data.type = self._data.type
        data.num = self._buyNum
        vipBoxProxy:onTriggerNet230014Req(data) 
    end
    sender.callFunc = callFunc
    sender.money = self._allCost
    self:isShowRechargeUI(sender)
    
    self:onClosePanelHandler()
end


-- 是否弹窗元宝不足
function VipBoxBuyPanel:isShowRechargeUI(sender)
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


--改变bar
function VipBoxBuyPanel:onMoveBtnCallback(count)
    -- print("count ====",count)
    local count = count
    self:updateBuyNum(count)
end 
--关闭界面
function VipBoxBuyPanel:onCloseBtnClicked(sender)
    self:onClosePanelHandler()
end
function VipBoxBuyPanel:onClosePanelHandler()
    VipBoxBuyPanel.super.onClosePanelHandler(self)
    self:hide()
    self.view:updatePanelResp()
end