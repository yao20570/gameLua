-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description:
--  */
ActivityShopSpecialPanel = class("ActivityShopSpecialPanel", BasicPanel)
ActivityShopSpecialPanel.NAME = "ActivityShopSpecialPanel"

function ActivityShopSpecialPanel:ctor(view, panelName)
    ActivityShopSpecialPanel.super.ctor(self, view, panelName)

end

function ActivityShopSpecialPanel:finalize()
    ActivityShopSpecialPanel.super.finalize(self)
end

function ActivityShopSpecialPanel:initPanel()
    ActivityShopSpecialPanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.ActivityShop)

    -- info面板
    self._panelTop = self:getChildByName("panelTop")
    local btnTip = self._panelTop:getChildByName("btnTip")
    self:addTouchEventListener(btnTip, self.onTip)

    local labinfo =  self:getChildByName("panelTop/labInfo")
    labinfo:setColor(cc.c3b(244,244,244))
    local labinfo_0 = self:getChildByName("panelTop/labInfo_0")
    labinfo_0:setColor(cc.c3b(244,244,244))

    -- 商品列表
    self._svShop = self:getChildByName("svShop")
    self._panelSpecial = self._svShop:getChildByName("panelSpecial")
    --self._panelBgFrameLeft = self._panelSpecial:getChildByName("panelBgFrameLeft")
    --self._panelBgFrameRight = self._panelSpecial:getChildByName("panelBgFrameRight")
    self._labSpecialRemainTime = self._panelSpecial:getChildByName("labRemainTime")



    --self._rowUIList = { }
    --self._rowUIList[1] = self._panelSpecial:getChildByName("panelRowBg1")
    self._fristRowUIPos = { }
    self._fristRowUIPos.x, self._fristRowUIPos.y = self._panelSpecial:getChildByName("panelItem1"):getPosition()

    self._cloneItem = self._panelSpecial:getChildByName("panelItem1")
    self._cloneItem:setVisible(false)
    self._itemUIList = { }
    self._fristItemUIPos = { }
    self._fristItemUIPos.x, self._fristItemUIPos.y = self._cloneItem:getPosition()

    self._distanceX = 182
    self._distanceY = 250

    self._innerHeight = 0

    self._remainTimeSpecial = 0
end

function ActivityShopSpecialPanel:registerEvents()
    ActivityShopSpecialPanel.super.registerEvents(self)
end


function ActivityShopSpecialPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._panelTop, nil, GlobalConfig.downHeight, tabsPanel, 3)
    NodeUtils:adaptiveListView(self._svShop, GlobalConfig.downHeight, self._panelTop, 3)

    self._panelSpecial:setPositionY(self._svShop:getContentSize().height - 8);

    if self._innerHeight < self._svShop:getContentSize().height then
        self._innerHeight = self._svShop:getContentSize().height
    end
    --self._panelBgFrameLeft:setContentSize(self._panelBgFrameLeft:getContentSize().width, self._innerHeight)
    --self._panelBgFrameRight:setContentSize(self._panelBgFrameRight:getContentSize().width, self._innerHeight)
end

function ActivityShopSpecialPanel:update()
    local oldRemainTime = self._remainTimeSpecial

    local lynsCfg = self._proxy:getLYNSCfg()        
    self._remainTimeSpecial = self._proxy:getSellerStateRemainTime(ActivityShopProxy.SellerSpecial, lynsCfg.saleMarketID) or 0
    local strTimeSpecial = TimeUtils:getStandardFormatTimeString6(self._remainTimeSpecial)
    self._labSpecialRemainTime:setString(strTimeSpecial)

    if oldRemainTime ~= 0 and self._remainTimeSpecial == 0 then
        self._proxy:onTriggerNet230039Req({ })
    end
end

function ActivityShopSpecialPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityShopEvent.HIDE_SELF_EVENT)
end

function ActivityShopSpecialPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end

    self._svShop:jumpToTop()

    self._proxy:onTriggerNet230039Req( { })
end

function ActivityShopSpecialPanel:updateUI()
    self:updateInfoPanel()
    self:updateShopScrollView()
end


function ActivityShopSpecialPanel:updateInfoPanel()
    local timeStr = self._proxy:getLYNSActivityTimeStr()
    local labTime = self._panelTop:getChildByName("labTime")
    labTime:setString(timeStr)
end


function ActivityShopSpecialPanel:updateShopScrollView()
    -- 特卖商品列表
    local specialInfo = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerSpecial)
    local itemDataList = specialInfo.itemInfos or { }

    local rowCount = math.ceil(#itemDataList / 3)

    self._innerHeight = rowCount * self._distanceY + 100
    if self._innerHeight < self._svShop:getContentSize().height then
        self._innerHeight = self._svShop:getContentSize().height
    end
    local innerSize = cc.size(self._svShop:getContentSize().width, self._innerHeight)
    self._svShop:setInnerContainerSize(innerSize)
    --self._panelBgFrameLeft:setContentSize(self._panelBgFrameLeft:getContentSize().width, self._innerHeight)
    --self._panelBgFrameRight:setContentSize(self._panelBgFrameRight:getContentSize().width, self._innerHeight)
    self._panelSpecial:setPositionY(self._innerHeight)

    --for k, v in pairs(self._rowUIList) do
    --    v:setVisible(false)
    --end
    for k, v in pairs(self._itemUIList) do
        v:setVisible(false)
    end

    
    table.sort(itemDataList, function(a, b) return a.shopItemCfgId < b.shopItemCfgId end)
    local index = 0
    for k, v in pairs(itemDataList) do

        local colIndex = index % 3
        local rowIndex = math.floor(index / 3)

        --local rowUI = self._rowUIList[rowIndex + 1]
        --if rowUI == nil then
        --    rowUI = self._rowUIList[1]:clone()
        --    rowUI:setPositionY(self._fristRowUIPos.y - self._distanceY * rowIndex)
        --    self._rowUIList[rowIndex + 1] = rowUI
        --    self._panelSpecial:addChild(rowUI)
        --end

        local itemUI = self._itemUIList[index + 1]
        if itemUI == nil then
            itemUI = self._cloneItem:clone()
            itemUI:setPositionX(self._fristItemUIPos.x + self._distanceX * colIndex)
            itemUI:setPositionY(self._fristItemUIPos.y - self._distanceY * rowIndex)
            self._itemUIList[index + 1] = itemUI
            self._panelSpecial:addChild(itemUI)
        end

        --rowUI:setVisible(true)
        itemUI:setVisible(true)

        self:renderListViewItem(itemUI, v, specialInfo, ActivityShopProxy.SellerSpecial)

        index = index + 1
    end
end


function ActivityShopSpecialPanel:renderListViewItem(itemUI, data, specialInfo, sellerType)
    local shopItemCfgData = ConfigDataManager:getConfigById(ConfigData.ShopRewardConfig, data.shopItemCfgId)
    local itemData = StringUtils:jsonDecode(shopItemCfgData.commodity)

    local imgDiscount = itemUI:getChildByName("img1")
    imgDiscount:setVisible(false)

    local imgIcon = itemUI:getChildByName("imgIcon")
    local iconData = { }
    iconData.typeid = itemData[2]
    iconData.num = itemData[3]
    iconData.power = itemData[1]
    if imgIcon.uiIcon == nil then
        imgIcon.uiIcon = UIIcon.new(imgIcon, iconData, true)
        imgIcon.uiIcon:setTouchEnabled(false)
    else
        imgIcon.uiIcon:updateData(iconData)
    end

    local labNum = itemUI:getChildByName("labNum")
    labNum:setString(data.num)

    --[[
    local strOldPrice = string.format(self:getTextWord(410003), shopItemCfgData.cost)
    local labOldPrice = itemUI:getChildByName("labOldPrice")
    labOldPrice:setString(strOldPrice)
    --]]

    local labNewPrice = itemUI:getChildByName("labNewPrice")
    labNewPrice:setString(shopItemCfgData.saleCost)

    local buyData = { }
    buyData.sellerType = sellerType
    buyData.sellerServerData = specialInfo
    buyData.shopItemServerData = data

    itemUI.data = buyData
    ComponentUtils:addTouchEventListener(itemUI, self.onBuy, nil, self)

end


function ActivityShopSpecialPanel:onTip(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = { }
    for i = 0, 1 do
        lines[i] = { { content = TextWords:getTextWord(410041 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } }
    end
    uiTip:setAllTipLine(lines)
end

function ActivityShopSpecialPanel:onBuy(sender)

    local buyData = sender.data

    if buyData.shopItemServerData.num == 0 then
        self:showSysMessage(TextWords:getTextWord(410012))
        return
    end

    local activityId = buyData.sellerServerData.activityId
    local shopItemCfgId = buyData.shopItemServerData.shopItemCfgId

    local function callback( buyNum )
        local reqData = { }
        reqData.activityId = activityId
        reqData.goodsId = shopItemCfgId
        reqData.num = buyNum
        self._proxy:onTriggerNet230040Req(reqData)
    end

    local data = { }
    data.sellerType = buyData.sellerType
    data.coupons = nil
    data.isCanBuyMany = true
    data.shopItemCfgId = shopItemCfgId
    data.num = buyData.shopItemServerData.num
    data.callBack = callback

    local panel = self:getPanel(ActivityShopBuyPanel.NAME)
    panel:show(data)
end