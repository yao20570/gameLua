--UI控件功能：仓库资源道具、建筑资源道具的使用/购买
--Time:2015/12/04
--Author:FZW
--How to use ? 参考module：warehouse

UIResourceBuy = class("UIResourceBuy", BasicComponent)

function UIResourceBuy:ctor(parent, panel,isShow)
    UIResourceBuy.super.ctor(self)
    local uiSkin = UISkin.new("UIResourceBuy")
    -- local parent = panel:getLayer(ModuleLayer.UI_TOP_LAYER)
    uiSkin:setParent(parent)
    uiSkin:setVisible(isShow)
    
    local secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    secLvBg:setContentHeight(700)
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(321))
    
    self._parent = parent
    self._uiSkin = uiSkin
    self._panel = panel
    self:registerEventHandler()
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_10)
end

function UIResourceBuy:finalize()
    local proxy = self._panel:getProxy(GameProxys.Role)
    proxy:removeEventListener(AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateBuffNum)
    if self._uiGoodsPanel ~= nil then
        self._uiGoodsPanel:finalize()
        self._uiGoodsPanel = nil
    end
    self._uiSkin:finalize()
    UIResourceBuy.super.finalize(self)
end

function UIResourceBuy:updateBuffNum()
    if self._uiSkin:isVisible() ~= true or self._typeRes == nil then
        return
    end

    --世界buff折扣
    local seasonsProxy = self._panel:getProxy(GameProxys.Seasons)
    self._resCoupon = seasonsProxy:getResCoupon()

    local info = self:setUIData(self._typeRes)
    local listView = self:getChildByName("mainPanel/ListView_1")
    self._listView = listView
    self:renderListView(listView, info, self, self.renderItemPanel)
end

-- 读取道具数量
function UIResourceBuy:getItemCurNumber(info, typeRes)
    -- body
    local itemProxy = self._panel:getProxy(GameProxys.Item)
    info.curNum = itemProxy:getItemNumByType(typeRes) or 0--当前拥有量
    return info
end

-- type:资源补足的类型 FillList
function UIResourceBuy:setUIData(typeRes)
    -- body
    local conf = ConfigDataManager:getConfigDataBySortKey(ConfigData.FillListConfig,"sort")
    local info = {}
    for k,v in pairs(conf) do
        if v.type == typeRes then
            self:getItemCurNumber(v, v.itemID)
            table.insert( info, v )
        end
    end
    return info
end

--show 显示控件内容
function UIResourceBuy:show(typeRes)
    if typeRes == 0 or typeRes == nil then
        logger:info("------typeRes is error!------")
        return
    end
    self._typeRes = typeRes
    self._uiSkin:setVisible(true)

    if self._listView then
        self._listView:jumpToTop()
    end
    
    --世界buff折扣
    local seasonsProxy = self._panel:getProxy(GameProxys.Seasons)
    self._resCoupon = seasonsProxy:getResCoupon()

    local info = self:setUIData(typeRes)
    local listView = self:getChildByName("mainPanel/ListView_1")
    self._listView = listView
    self:renderListView(listView, info, self, self.renderItemPanel)
end

function UIResourceBuy:renderItemPanel(itemPanel, info, index)
    self:renderOneItem(itemPanel, info, index)
end

function UIResourceBuy:renderOneItem(itemPanel, info, index)
    if itemPanel == nil or info == nil then
        return
    end
    itemPanel:setVisible(true)

    local name = itemPanel:getChildByName("nameTxt")
    local infoTxt = itemPanel:getChildByName("infoTxt")
    local Image_36 = itemPanel:getChildByName("Image_36")
    local priceTxt = Image_36:getChildByName("priceTxt")

    local iconInfo = {}
    iconInfo.power,iconInfo.typeid,iconInfo.num = GamePowerConfig.Item,info.itemID,info.curNum
    local icon = itemPanel.icon
    if icon == nil then
        local iconContainer = itemPanel:getChildByName("icon")
        icon = UIIcon.new(iconContainer,iconInfo,true,nil,nil,nil,0)
        itemPanel.icon = icon
    else
        icon:updateData(iconInfo)
    end
    if info.curNum == 0 then
        icon:setNumColor(cc.c3b(255,0,0))
        Image_36:setVisible(true)
    else
        Image_36:setVisible(false)
    end

    local nameStr = icon:getName()
    local infoStr = icon:getDec()
    name:setString(nameStr)
    infoTxt:setString(infoStr)

    -- 价格
    local price = info.price
    local config = ConfigDataManager:getConfigById(ConfigData.ItemConfig, info.itemID)
    if config and config.itemCoupon == 1 then
        price = math.ceil(price * self._resCoupon)
    end
    priceTxt:setString(price)

    local buyBtn = itemPanel:getChildByName("buyBtn")
    local useBtn = itemPanel:getChildByName("useBtn")
    if info.curNum > 0 then
        buyBtn:setVisible(false)
        useBtn:setVisible(true)
        useBtn:setTitleText(TextWords:getTextWord(104))
        useBtn.type = 0
        useBtn.itemID = info.itemID
        useBtn.price = price
        useBtn.curNum = info.curNum
        useBtn.name,useBtn.info = info.name,info.info
        ComponentUtils:addTouchEventListener(useBtn, self.onItemBtnTouch, nil,self)
    else
        useBtn:setVisible(false)
        buyBtn:setVisible(true)
        buyBtn:setTitleText(TextWords:getTextWord(105))
        buyBtn.type = 1
        buyBtn.id = info.ID
        buyBtn.price = price
        ComponentUtils:addTouchEventListener(buyBtn, self.onItemBtnTouch, nil,self)
    end
end

function UIResourceBuy:registerEventHandler()
    local roleProxy = self._panel:getProxy(GameProxys.Role)
    roleProxy:addEventListener(AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateBuffNum)
end

--  购买对话框
function UIResourceBuy:MessageBox(data,sender)
    -- body
    local function okCallBack()
        local function callFunc()
            self:onItemReq(data)
            self:onCloseBtnTouch(sender)
        end
        sender.callFunc = callFunc
        sender.money = data.price
        self:isShowRechargeUI(sender)
    end

    local content = string.format(TextWords:getTextWord(106),data.price)
    self._panel:showMessageBox(content,okCallBack)
end

-- 是否弹窗元宝不足
function UIResourceBuy:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self._parent
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self._panel)
            parent.panel = panel
        else
            panel:show()
        end

    else
        sender.callFunc()
    end

end

function UIResourceBuy:onItemBtnTouch(sender)
    local data = {}
    if sender.type == 0 then -- 使用
        if sender.curNum == 1 then
            data.type,data.itemID,data.num = sender.type,sender.itemID,1
            self:onItemReq(data)
            self:onCloseBtnTouch(sender) 
            return
        end
        if self._uiGoodsPanel == nil then
            self._uiGoodsPanel = UIGoodsPanel.new(self._panel, self._panel, sender.itemID, 2, sender.curNum)
        else
            self._uiGoodsPanel:show(sender.itemID, 2, sender.curNum)
        end
        self:hide()
        
    elseif sender.type == 1 then -- 购买使用
        data.type,data.id,data.price = sender.type,sender.id,sender.price
        self:MessageBox(data,sender)
    end
end

function UIResourceBuy:onItemReq(data)
    -- body
    self._panel:onItemReq(data)
end

function UIResourceBuy:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIResourceBuy:onCloseBtnTouch(sender)
    self._uiSkin:setVisible(false)
end

function UIResourceBuy:hide()
    self._uiSkin:setVisible(false)
end

