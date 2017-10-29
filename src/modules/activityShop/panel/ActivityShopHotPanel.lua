-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description:
--  */
ActivityShopHotPanel = class("ActivityShopHotPanel", BasicPanel)
ActivityShopHotPanel.NAME = "ActivityShopHotPanel"

function ActivityShopHotPanel:ctor(view, panelName)
    ActivityShopHotPanel.super.ctor(self, view, panelName)

end

function ActivityShopHotPanel:finalize()
    ActivityShopHotPanel.super.finalize(self)

    if self._renderTexture then
        self._renderTexture:removeFromParent()
        self._renderTexture = nil
    end

    if self._earse then
        self._earse:release()
        self._earse = nil
    end
end

function ActivityShopHotPanel:initPanel()
    ActivityShopHotPanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.ActivityShop)


    -- top面板
    self._panelTop = self:getChildByName("panelTop")
    local btnTip = self._panelTop:getChildByName("btnTip")
    self:addTouchEventListener(btnTip, self.onTip)

    local labinfo =  self:getChildByName("panelTop/labInfo")
    labinfo:setColor(cc.c3b(244,244,244))
    local labinfo_0 = self:getChildByName("panelTop/labInfo_0")
    labinfo_0:setColor(cc.c3b(244,244,244))


    -- 商品列表
    self._svShop = self:getChildByName("svShop")
    local panelSV = self._svShop:getChildByName("panelSV")

    -- 打折面板
    self._panelDiscount = panelSV:getChildByName("panelDiscount")
    self._labDiscountRemainTime = self._panelDiscount:getChildByName("labDiscountRemainTime")

    -- 黑市面板
    self._panelBlackMarket = panelSV:getChildByName("panelBlackMarket")
    self._labBlackMarketRemainTime = self._panelBlackMarket:getChildByName("labBlackMarketRemainTime")
    self._labBlackMarketRemainTimeTxt = self._panelBlackMarket:getChildByName("labBlackMarketRemainTimeTxt")

    -- 抢卷面板
    self._panelCoupon = self._panelBlackMarket:getChildByName("panelCoupon")
    self._labCouponRemainTime = self._panelCoupon:getChildByName("labCouponRemainTime")
    self._panelScraping = self._panelCoupon:getChildByName("panelScraping")
    self._labCoupon = self._panelScraping:getChildByName("labCoupon")

    -- 黑市结束面板
    self._panelOver = self._panelBlackMarket:getChildByName("panelOver")
    self._labOverRemainTime = self._panelOver:getChildByName("labOverRemainTime")

    -- 滚动截断层(在self._panelScraping上touch move时不会拖动滑动列表)
    local scrapingSize = self._panelScraping:getContentSize()
    local x, y = self._panelScraping:getPosition()
    self._panelScraping:removeFromParent();
    self._panelScraping:setPosition(0, 0)
    local layerTouchMask = cc.Layer:create()
    layerTouchMask:setContentSize(scrapingSize)
    layerTouchMask:setPosition(x, y)
    layerTouchMask:addChild(self._panelScraping)
    self._panelCoupon:addChild(layerTouchMask)


    self._delayCreateIconFuncList = FrameQueue.new(0.05)

    self._isReqCoupon = false
    self._blackMarketState = ActivityShopProxy.SellerStateClose
end

function ActivityShopHotPanel:registerEvents()
    ActivityShopHotPanel.super.registerEvents(self)
end

function ActivityShopHotPanel:doLayout()
    local tabsPanel = self:getTabsPanel()

    NodeUtils:adaptiveTopPanelAndListView(self._panelTop, nil, GlobalConfig.downHeight, tabsPanel, 3)
    NodeUtils:adaptiveListView(self._svShop, GlobalConfig.downHeight, self._panelTop, 3)

end

function ActivityShopHotPanel:update()
    self:updateUIDiscountTime()
    self:updateUIBlackMarketTime()

end

function ActivityShopHotPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityShopEvent.HIDE_SELF_EVENT)
end

function ActivityShopHotPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end

    self:updateUIPanelInfo()

    self._svShop:jumpToTop()

    local lynsCfg = self._proxy:getLYNSCfg()

    self:hideAllItems()

    self._proxy:onTriggerNet410000Req( { typeId = lynsCfg.popularShopID })
    self._proxy:onTriggerNet410001Req( { typeId = lynsCfg.blackMarketID })
end


function ActivityShopHotPanel:updateUIPanelInfo()
    local timeStr = self._proxy:getLYNSActivityTimeStr()
    local labTime = self._panelTop:getChildByName("labTime")
    labTime:setString(timeStr)
end

function ActivityShopHotPanel:hideAllItems()
    for i = 1, 6 do
        local itemUI = self._panelDiscount:getChildByName("panelItem" .. i)
        itemUI:setVisible(false)
    end

    for i = 1, 6 do
        local itemUI = self._panelBlackMarket:getChildByName("panelItem" .. i)
        itemUI:setVisible(false)
    end
end

function ActivityShopHotPanel:updateUIPanelDiscount()
    -- 打折商品列表
    local discountInfo, lynsCfgData = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerDiscount)
    if discountInfo == nil then
        return
    end
    
    local itemInfoList = discountInfo.itemInfoList or {}
    table.sort(itemInfoList, function(a, b) return a.shopItemCfgId < b.shopItemCfgId end)
    for i = 1, 6 do
        local itemUI = self._panelDiscount:getChildByName("panelItem" .. i)
        if itemInfoList == nil or itemInfoList[i] == nil then
            itemUI:setVisible(false)
        else
            itemUI:setVisible(true)
            self:renderListViewItem(itemUI, itemInfoList[i], discountInfo, ActivityShopProxy.SellerDiscount)
        end
    end


    -- 状态倒计时
    self:updateUIDiscountTime()

end

function ActivityShopHotPanel:updateUIPanelBlackMarket()
    local blackMarketInfo = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerBlackMarket)
    if blackMarketInfo == nil then
        return
    end

    local couponsNum = self._proxy:getCouponsNum(blackMarketInfo.typeId)
    -- 记录黑市状态在UI里的改变,
    if blackMarketInfo.state == ActivityShopProxy.SellerStateReady then                       
        if couponsNum == nil then
            self._proxy:onTriggerNet410001Req( { typeId = blackMarketInfo.typeId })
            return
        elseif couponsNum < 0 then
            self:createScrapingUI(self._panelScraping)
        elseif couponsNum >= 0 then
            self:updateCouponNumUI();
        end
    end    

    -- 黑市商品列表
    local itemInfoList = blackMarketInfo.itemInfoList or {}
    table.sort(itemInfoList, function(a, b) return a.shopItemCfgId < b.shopItemCfgId end)
    for i = 1, 6 do
        local itemUI = self._panelBlackMarket:getChildByName("panelItem" .. i)
        if blackMarketInfo == nil or itemInfoList == nil or itemInfoList[i] == nil then
            itemUI:setVisible(false)
        else
            itemUI:setVisible(true)

            self:renderListViewItem(itemUI, itemInfoList[i], blackMarketInfo, ActivityShopProxy.SellerBlackMarket)
        end
    end

    -- 状态倒计时
    self:updateUIBlackMarketTime()

end


function ActivityShopHotPanel:updateUIDiscountTime()
    local lynsCfg = self._proxy:getLYNSCfg()

    local remainTimeDiscount = self._proxy:getSellerStateRemainTime(ActivityShopProxy.SellerDiscount, lynsCfg.popularShopID)
    local strTimeDiscount = TimeUtils:getStandardFormatTimeString6(remainTimeDiscount or 0)
    self._labDiscountRemainTime:setString(strTimeDiscount)
end

function ActivityShopHotPanel:updateUIBlackMarketTime()
    local lynsCfg = self._proxy:getLYNSCfg()
    local blackMarketInfo = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerBlackMarket)
    local remainTimeBlackMarket = self._proxy:getSellerStateRemainTime(ActivityShopProxy.SellerBlackMarket, lynsCfg.blackMarketID)
    local strTimeBlackMarket = TimeUtils:getStandardFormatTimeString6(remainTimeBlackMarket or 0)


    self._panelCoupon:setVisible(blackMarketInfo.state == ActivityShopProxy.SellerStateReady)
    self._panelOver:setVisible(blackMarketInfo.state == ActivityShopProxy.SellerStateClose)
    self._labBlackMarketRemainTime:setVisible(blackMarketInfo.state == ActivityShopProxy.SellerStateBuy)
    self._labBlackMarketRemainTimeTxt:setVisible(blackMarketInfo.state == ActivityShopProxy.SellerStateBuy)

    if blackMarketInfo.state == ActivityShopProxy.SellerStateReady then
        self._labCouponRemainTime:setString(strTimeBlackMarket)
    elseif blackMarketInfo.state == ActivityShopProxy.SellerStateBuy then
        self._labBlackMarketRemainTime:setString(strTimeBlackMarket)
    elseif blackMarketInfo.state == ActivityShopProxy.SellerStateClose then
        self._labOverRemainTime:setString(strTimeBlackMarket)
    end
end


function ActivityShopHotPanel:renderListViewItem(itemUI, data, sellerServerData, sellerType)

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
        local function delayCreateIcon()
            imgIcon.uiIcon = UIIcon.new(imgIcon, iconData, true)
            imgIcon.uiIcon:setTouchEnabled(false)
        end

        self._delayCreateIconFuncList:pushParams(delayCreateIcon, self)
    else
        imgIcon.uiIcon:updateData(iconData)
    end

    local labNum = itemUI:getChildByName("labNum")
    labNum:setString(data.num)

    local labNewPrice = itemUI:getChildByName("labNewPrice")
    labNewPrice:setString(shopItemCfgData.saleCost)

    local buyData = { }
    
--    for v, k in pairs(sellerServerData) do 
--        logger:info("key:%s, value:%d",v , k)
--    end


    buyData.sellerServerData = sellerServerData
    buyData.shopItemServerData = data
    buyData.sellerType = sellerType
    buyData.remainTimes = shopItemCfgData.personBuyLimite - data.buyNum
    buyData.remainTimes = buyData.remainTimes < 0 and 0 or buyData.remainTimes

    itemUI.data = buyData
    ComponentUtils:addTouchEventListener(itemUI, self.onBuy, nil, self)
end

-- 能否请求抢卷
function ActivityShopHotPanel:isCanReqCoupon()
    local blackMarketInfo = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerBlackMarket)
    local couponsNum = self._proxy:getCouponsNum(blackMarketInfo.typeId)
    if couponsNum < 0 and self._isReqCoupon == false then
        return true
    end

    return false
end

-- 请求抢卷信息
function ActivityShopHotPanel:reqCoupon(touchPosInPanelScraping)

    local offset = 20

    local posX, posY = self._labCoupon:getPosition()
    local size = self._labCoupon:getContentSize();
    local minX = posX - offset
    local minY = posY - offset
    local maxX = posX + size.width + offset
    local maxY = posY + size.height + offset
    -- print("===================>" .. minX .. "<" .. touchPosInPanelScraping.x .. "<" .. maxX .. "  "
    -- .. minY .. "<" .. touchPosInPanelScraping.y .. "<" .. maxY .. "  ")
    if minX < touchPosInPanelScraping.x
        and maxX > touchPosInPanelScraping.x
        and minY < touchPosInPanelScraping.y
        and maxY > touchPosInPanelScraping.y
    then
        if self:isCanReqCoupon() then

            -- 0.5秒后如果没收到优惠券可以再申请
            TimerManager:addOnce(500, function() self._isReqCoupon = false end, self)

            -- 请求优惠券
            self._isReqCoupon = true
            local blackMarket = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerBlackMarket)
            self._proxy:onTriggerNet410004Req( { typeId = blackMarket.typeId })
        end
    end

    return false
end

function ActivityShopHotPanel:updateCouponNumUI()
    local blackMarket = self._proxy:getLYNSSellerServerInfo(ActivityShopProxy.SellerBlackMarket)
    local couponsNum = self._proxy:getCouponsNum(blackMarket.typeId)

    if couponsNum <= 0 then
        self._labCoupon:setString(self:getTextWord(410013))
    else
        local str = string.format(self:getTextWord(410014), couponsNum)
        self._labCoupon:setString(str)
    end
end

function ActivityShopHotPanel:onTip(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = { }
    for i = 0, 8 do
        lines[i] = { { content = TextWords:getTextWord(410021 + i), foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601 } }
    end
    uiTip:setAllTipLine(lines)
end


function ActivityShopHotPanel:onBuy(sender)

    local buyData = sender.data

    if buyData.shopItemServerData.num == 0 then
        self:showSysMessage(TextWords:getTextWord(410012))
        return
    end

    local sellerType = buyData.sellerServerData.type
    local typeId = buyData.sellerServerData.typeId
    local shopItemCfgId = buyData.shopItemServerData.shopItemCfgId
    local shoperId = buyData.sellerServerData.shoperID

    local function callback(buyNum)
        local reqData = { }
        reqData.type = sellerType
        reqData.itemCfgId = shopItemCfgId
        reqData.num = buyNum
        reqData.shoperID = shoperId
        self._proxy:onTriggerNet410003Req(reqData)
    end

    local data = { }
    data.sellerType = buyData.sellerType
    data.remainTimes = buyData.remainTimes
    if buyData.sellerServerData.type == ActivityShopProxy.SellerBlackMarket then
        data.coupons = self._proxy:getCouponsNum(typeId)
    else
        data.coupons = nil
    end
    data.isCanBuyMany =(buyData.sellerServerData.type ~= ActivityShopProxy.SellerDiscount)
    data.shopItemCfgId = shopItemCfgId
    data.num = buyData.shopItemServerData.num
    data.callBack = callback

    local panel = self:getPanel(ActivityShopBuyPanel.NAME)
    panel:show(data)

end

function ActivityShopHotPanel:updateScrapingUI()

    self._labCoupon:setString("")
    self:createScrapingUI(self._panelScraping)
end


function ActivityShopHotPanel:createScrapingUI(uiScrapingParent)

    -- 橡皮檫
    if self._earse == nil then
        self._earse = TextureManager:createSprite("images/activityShop/earse.png")
        self._earse:retain()
    end

    -- 油漆层
    local imgScraping = TextureManager:createSprite("images/activityShop/g.png")
    imgScraping:setAnchorPoint(cc.p(0, 0));
    imgScraping:setPosition(0, 0);

    -- 油漆
    local imgSize = imgScraping:getContentSize()
    if self._renderTexture then
        self._renderTexture:removeFromParent()
        self._renderTexture = nil
    end
    self._renderTexture = cc.RenderTexture:create(imgSize.width, imgSize.height);
    self._renderTexture:setPosition(imgSize.width / 2, imgSize.height / 2);
    self._renderTexture:begin();
    imgScraping:visit();
    self._renderTexture:endToLua();

    local function erasure(sender, eventType)
        self:erasure(sender, eventType)
    end
    uiScrapingParent:addTouchEventListener(erasure)
    uiScrapingParent:addChild(self._renderTexture);

end

function ActivityShopHotPanel:erasure(sender, eventType)

    if eventType == ccui.TouchEventType.began then

    elseif eventType == ccui.TouchEventType.moved then

        local posWorld = sender:getTouchMovePosition()
        local posNode = sender:convertToNodeSpace(cc.p(posWorld.x, posWorld.y))

        local posFix = cc.p(math.floor(posNode.x), math.floor(posNode.y))
        -- print("===================>" .. math.floor(posWorld.x) .. " , " .. math.floor(posWorld.y) .. "    " .. math.floor(posNode.x) .. " , " .. math.floor(posNode.y))
        self._earse:setPosition(posFix)

        -- 设置混合模式
        self._earse:setBlendFunc(gl.ZERO, gl.SRC_ALPHA);

        -- 将橡皮擦的像素渲染到画布上，与原来的像素进行混合
        self._renderTexture:begin();
        self._earse:visit();
        self._renderTexture:endToLua();

        -- 刮开看到数字了
        self:reqCoupon(posNode)
    elseif eventType == ccui.TouchEventType.canceled then

    elseif eventType == ccui.TouchEventType.ended then

    end
end
