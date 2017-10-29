-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-12-1 16:14
--  * @Description: 活动商人数据代理（洛阳闹市只是其中的数据之一）
--  */



ActivityShopProxy = class("ActivityShopProxy", BasicProxy)

ActivityShopProxy.SellerDiscount = 1            -- 热卖商人
ActivityShopProxy.SellerBlackMarket = 2         -- 黑市商人
ActivityShopProxy.SellerSpecial = 3             -- 特卖商人

ActivityShopProxy.SellerStateReady = 1          -- 准备状态(抢卷)
ActivityShopProxy.SellerStateBuy = 2            -- 购买状态
ActivityShopProxy.SellerStateClose = 3          -- 关闭状态


function ActivityShopProxy:ctor()
    ActivityShopProxy.super.ctor(self)
    self.proxyName = GameProxys.ActivityShop

    self:resetData()

    -- 商人状态倒时计
    self._keyList = { }
    self._keyList[ActivityShopProxy.SellerDiscount] = "keyDiscount"
    self._keyList[ActivityShopProxy.SellerBlackMarket] = "keyBlackMarket"
    self._keyList[ActivityShopProxy.SellerSpecial] = "keySpecial"

    -- 优惠券
    self._tempCoupons = 0

end


function ActivityShopProxy:resetData()
    self._sellerList = { }
    self._sellerList[ActivityShopProxy.SellerDiscount] = { }
    self._sellerList[ActivityShopProxy.SellerBlackMarket] = { }
    self._sellerList[ActivityShopProxy.SellerSpecial] = { }

    self._coupons = { }

    self._limitActivitys = { }

    self._lynsCfgData = nil
end

-- 初始化活动数据 M20000
function ActivityShopProxy:initSyncData(data)
    RebelsProxy.super.initSyncData(self, data)

    -- 重置数据
    self:resetAttr()


    -- self:testData()
    -- self:onTriggerNet310000Resp(activityInfo)

end

-- 当前礼贤活动ID
function ActivityShopProxy:getCurActivityId()
    return self:getCurActivityData().activityId
end


-- 当前礼贤活动数据
function ActivityShopProxy:getCurActivityData()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local consortActivityData = activityProxy:getCurActivityData()

    return consortActivityData
end

-- 获取洛阳闹市时间字符串
function ActivityShopProxy:getLYNSActivityTimeStr()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData = activityProxy:getLimitActivityDataByUitype(ActivityDefine.LIMIT_ACTIVITY_SHOP_ID)
    -- 洛阳闹市在活动配置表的id = 113
    local t1 = TimeUtils:setTimestampToString4(activityData.startTime)
    local t2 = TimeUtils:setTimestampToString4(activityData.endTime)
    -- return t1 .. " - " .. t2
    return TimeUtils.getLimitActFormatTimeString(activityData.startTime,activityData.endTime,true)
end

-- 获取洛阳闹市活动单个商人配置信息
function ActivityShopProxy:getLYNSSellerCfg(sellerType)
    local lynsCfgData = self:getLYNSCfg()
    return self:getSellerCfgData(sellerType, lynsCfgData)
end

-- 获取洛阳闹市活动的商人配置信息
function ActivityShopProxy:getLYNSCfg()
    --if self._lynsCfgData == nil then
--        local activityProxy = self:getProxy(GameProxys.Activity)
--        local activityData = activityProxy:getLimitActivityDataByUitype(ActivityDefine.LIMIT_ACTIVITY_SHOP_ID)
        local activityData = self:getCurActivityData()
        self._lynsCfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopLimiteActiveConfig, "effectID", activityData.effectId)
    --end

    return self._lynsCfgData
end

-- 获取洛阳闹市的商人配置表信息(通过ShopLimiteActive配置表来取值) 
function ActivityShopProxy:getSellerCfgData(sellerType, shopLimiteActiveCfgData)

    local sellerId = self:getSellerId(sellerType, shopLimiteActiveCfgData)

    if sellerType == ActivityShopProxy.SellerDiscount then
        return ConfigDataManager:getInfoFindByOneKey(ConfigData.PopularMarketConfig, "ID", sellerId)
    elseif sellerType == ActivityShopProxy.SellerBlackMarket then
        return ConfigDataManager:getInfoFindByOneKey(ConfigData.BlackMarketConfig, "ID", sellerId)
    elseif sellerType == ActivityShopProxy.SellerSpecial then
        return ConfigDataManager:getInfoFindByOneKey(ConfigData.SaleMarketConfig, "ID", sellerId)
    end

    return nil
end

-- 通过活动配置数据和商人类型获取 商人ID
function ActivityShopProxy:getSellerId(sellerType, shopLimiteActiveCfgData)
    local sellerId = nil
    if sellerType == ActivityShopProxy.SellerDiscount then
        sellerId = shopLimiteActiveCfgData.popularShopID
    elseif sellerType == ActivityShopProxy.SellerBlackMarket then
        sellerId = shopLimiteActiveCfgData.blackMarketID
    elseif sellerType == ActivityShopProxy.SellerSpecial then
        sellerId = shopLimiteActiveCfgData.saleMarketID
    end

    return sellerId or 0
end

-- 获取商人物品的配置数据
function ActivityShopProxy:getShopItemCfgDataByID(shopItemCfgId)

    local shopItemCfgData = ConfigDataManager:getConfigById(ConfigData.ShopRewardConfig, shopItemCfgId)

    return shopItemCfgData
end 


-- 获取洛阳闹市活动单个商人服务端信息
function ActivityShopProxy:getLYNSSellerServerInfo(sellerType)
    local lynsCfgData = self:getLYNSCfg()
    local sellerId = self:getSellerId(sellerType, lynsCfgData)

    return self:getSellerServerInfo(sellerType, sellerId), lynsCfgData
end

-- 获取洛阳闹市活动单个商人服务端信息
function ActivityShopProxy:getLYNSSellerStateRemainTime(sellerType)
    local lynsCfgData = self:getLYNSCfg()
    local sellerId = nil
    if sellerType == ActivityShopProxy.SellerDiscount then
        sellerId = lynsCfgData.popularShopID
    elseif sellerType == ActivityShopProxy.SellerBlackMarket then
        sellerId = lynsCfgData.blackMarketID
    elseif sellerType == ActivityShopProxy.SellerSpecial then
        sellerId = lynsCfgData.saleMarketID
    end

    if sellerId ~= nil then
        return self:getSellerStateRemainTime(sellerType, sellerId)
    end

    return 0
end


-- 获取商人服务端信息
function ActivityShopProxy:getSellerServerInfo(sellerType, sellerId)
    assert(sellerId ~= nil)

    if self._sellerList and self._sellerList[sellerType] and self._sellerList[sellerType][sellerId] then
        return self._sellerList[sellerType][sellerId]
    end

    return { }
end
function ActivityShopProxy:getSellerServerInfoByShoperId(sellerType, ShoperId)
    if self._sellerList[sellerType] then
        for k, v in pairs(self._sellerList[sellerType]) do
            if v.shoperID == ShoperId then
                return v
            end
        end
    end

    return { }
end

-- 设置商人服务端信息
function ActivityShopProxy:setSellerServerData(sellerType, typeId, data)
    -- 商人
    self._sellerList[sellerType][typeId] = data
end

-- 设置商人状态倒时计
function ActivityShopProxy:setSellerStateRemainTime(sellerType, sellerId, remainTime)
    assert(sellerId ~= nil)
    local key = self._keyList[sellerType] .. "_" .. sellerId
    self:pushRemainTime(key, remainTime)
end

-- 获取商人状态倒时计
function ActivityShopProxy:getSellerStateRemainTime(sellerType, sellerId)
    assert(sellerId ~= nil)
    return self:getRemainTime(self._keyList[sellerType] .. "_" .. sellerId)
end

-- 获取当前优惠券(只有黑市类型才有抢卷)
function ActivityShopProxy:getCouponsNum(sellerId)
    --[[
    local sellerInfo = self:getSellerServerInfo(ActivityShopProxy.SellerBlackMarket, sellerId)
    if sellerInfo ~= nil then
        return sellerInfo.coupons
    end
    --]]
    return self._coupons[sellerId] or -1
end

-- 设置当前优惠券(只有黑市类型才有抢卷)
function ActivityShopProxy:setCouponsNum(sellerId, num)
    --[[
    local sellerInfo = self:getSellerServerInfo(ActivityShopProxy.SellerBlackMarket, sellerId)
    if sellerInfo ~= nil then
        sellerInfo.coupons = num
    end
    --]]
    self._coupons[sellerId] = num
end

function ActivityShopProxy:setShopItemInfo(selelrType, sellerInfo, itemCfgId, num)
    if selelrType == ActivityShopProxy.SellerDiscount or selelrType == ActivityShopProxy.SellerBlackMarket then
        for k, v in pairs(sellerInfo.itemInfoList) do
            if v.shopItemCfgId == itemCfgId then
                v.num = num
            end
        end
    elseif selelrType == ActivityShopProxy.SellerSpecial then
        for k, v in pairs(sellerInfo.itemInfos) do
            if v.shopItemCfgId == itemCfgId then
                v.num = num
            end
        end
    end
end

-------------------------------------------------------->协议-----------------------------------------------------------

function ActivityShopProxy:onTriggerNet230000Resp(data)
    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_SELLER_INFO_REQ, { })
end

-- 热卖商人信息列表
function ActivityShopProxy:onTriggerNet410000Req(data)
    self:syncNetReq(AppEvent.NET_M41, AppEvent.NET_M41_C410000, data)
end
function ActivityShopProxy:onTriggerNet410000Resp(data)

    if data.rs ~= 0 then
        return
    end

    local sellerType = ActivityShopProxy.SellerDiscount

    for _, v in pairs(data.sellerDiscount) do
        -- 设置热卖商人信息
        self:setSellerServerData(sellerType, v.typeId, v)

        -- 特卖热卖状态倒计时
        self:setSellerStateRemainTime(sellerType, v.typeId, v.remainTime)
    end

    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_DISCOUNT, { })
end

-- 黑市商人信息列表
function ActivityShopProxy:onTriggerNet410001Req(data)
    self:syncNetReq(AppEvent.NET_M41, AppEvent.NET_M41_C410001, data)
end
function ActivityShopProxy:onTriggerNet410001Resp(data)

    if data.rs ~= 0 then
        return
    end

    local sellerType = ActivityShopProxy.SellerBlackMarket

    for _, v in pairs(data.blackMarketInfo) do
        -- 设置黑市商人信息
        self:setSellerServerData(sellerType, v.typeId, v)

        -- 特卖黑市状态倒计时
        self:setSellerStateRemainTime(sellerType, v.typeId, v.remainTime)


        -- 注意:服务端推和玩家请求有差异(服务端推送是不带优惠券信息)
        local coupons = rawget(v, "coupons")
        if v.state == ActivityShopProxy.SellerStateReady then
            if coupons then
                self:setCouponsNum(v.typeId, coupons)
            end
        elseif v.state == ActivityShopProxy.SellerStateBuy then
            if coupons then
                self:setCouponsNum(v.typeId, coupons)
            end
        elseif v.state == ActivityShopProxy.SellerStateClose then
            self:setCouponsNum(v.typeId, nil)
        end

    end
    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_BLACK_MARKET, { })
end

-- 特卖商人信息列表
function ActivityShopProxy:onTriggerNet230039Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230039, data)
end
function ActivityShopProxy:onTriggerNet230039Resp(data)

    if data.rs ~= 0 then
        return
    end

    local sellerType = ActivityShopProxy.SellerSpecial

    local activityProxy = self:getProxy(GameProxys.Activity)

    for _, v in pairs(data.shoperInfos) do
        -- 通过活动ID获取商人ID
        local activityData = activityProxy:getLimitActivityInfoById(v.activityId)
        local activityShopCfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopLimiteActiveConfig, "effectID", activityData.effectId)

        -- 设置特卖商人信息
        self:setSellerServerData(sellerType, activityShopCfgData.saleMarketID, v)

        -- 特卖商人状态倒计时
        self:setSellerStateRemainTime(sellerType, activityShopCfgData.saleMarketID, v.remainTime)
    end
    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_SPECIAL, { })
end

-- 请求购买特卖物品
function ActivityShopProxy:onTriggerNet230040Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230040, data)
end
function ActivityShopProxy:onTriggerNet230040Resp(data)

    local isClosePanel = true
    -- -2：商品被抢购完了
    if data.rs == -2 then
        isClosePanel = false
    elseif data.rs ~= 0 then
        return
    end

    -- 通过活动ID获取商人ID
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData = activityProxy:getLimitActivityInfoById(data.activityId)
    local activityShopCfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopLimiteActiveConfig, "effectID", activityData.effectId)

    -- 更新对应的商品数量
    local specialSellerServerData = self:getSellerServerInfo(ActivityShopProxy.SellerSpecial, activityShopCfgData.saleMarketID)
    for _, v in pairs(specialSellerServerData.itemInfos) do
        if (v.shopItemCfgId == data.goodsId) then
            v.num = data.num
        end
    end

    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_BUY_RESULT, { isClose = isClosePanel })
    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_SPECIAL, { })
end


-- 请求购买热卖，黑市物品
function ActivityShopProxy:onTriggerNet410003Req(data)
    self:syncNetReq(AppEvent.NET_M41, AppEvent.NET_M41_C410003, data)
end
function ActivityShopProxy:onTriggerNet410003Resp(data)

    local isClosePanel = true
    
    if data.rs == 0 then
        -- data.rs == 0 时服务端还会推410000 或 410001
    elseif data.rs == -2 then
        -- -2：商品被抢购完了
        isClosePanel = false
    end
    
    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_BUY_RESULT, { isClose = isClosePanel })

    
end


-- 请求抢优惠券
function ActivityShopProxy:onTriggerNet410004Req(data)
    self:syncNetReq(AppEvent.NET_M41, AppEvent.NET_M41_C410004, data)
end
function ActivityShopProxy:onTriggerNet410004Resp(data)

    if data.rs == 0 then
        -- 设置抢卷数据
        self:setCouponsNum(data.typeId, data.coupons)
    else
        self:setCouponsNum(data.typeId, 0)
    end
    self:sendNotification(AppEvent.PROXY_ACTIVITY_SHOP_COUPONS_UPDATE, { })
    
end