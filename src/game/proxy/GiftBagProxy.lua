-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-03-17
--  * @Description: 热卖礼包数据代理
--  */
GiftBagProxy = class("GiftBagProxy", BasicProxy)

local MaxGiftCount = 5

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
    MaxGiftCount = 50  --IOS需要审核，开启所有的礼包，不做限制
end

function GiftBagProxy:ctor()
    GiftBagProxy.super.ctor(self)
    self.proxyName = GameProxys.GiftBag

    self._giftBagInfos = {}
    self._isDataNew = false
end

function GiftBagProxy:initSyncData(data)
    if data.giftBagDataInfo.giftBagInfos and #data.giftBagDataInfo.giftBagInfos > 0 then
	    self:setGiftBagInfos(data.giftBagDataInfo.giftBagInfos)
	end
	self.delayData = data.giftBagDataInfo.nextOpenTime
end
function GiftBagProxy:afterInitSyncData()
	self:checkOpen(self.delayData)
end
--检测下一个活动开启倒计时
function GiftBagProxy:checkOpen(nextOpenTime)
    -- logger:info("checkOpen")
    -- print("-------checkOpen----------nextOpenTime---",nextOpenTime)
    if nextOpenTime and nextOpenTime > 0 then
        self:pushRemainTime("giftNextOpen", nextOpenTime, AppEvent.NET_M43_C430001,nil,self.giftNextOpenComplete)
    else
        self._remainTimeMap["giftNextOpen"] = nil
    end
end
function GiftBagProxy:giftNextOpenComplete()
    self._remainTimeMap["giftNextOpen"] = nil
    -- print("giftNextOpenComplete")
    self:onTriggerNet430001Req()
end
--购买后刷新活动
function GiftBagProxy:onTriggerNet430000Resp(data)
    -- logger:info("onTriggerNet430000Resp")
    self:setOneInfo(data.giftBagInfo)
end
function GiftBagProxy:onTriggerNet430001Resp(data)
    -- logger:info("onTriggerNet430001Resp")
    -- print("-------data.giftBagDataInfo.giftBagInfos-------------",#data.giftBagDataInfo.giftBagInfos)
    self:setGiftBagInfos(data.giftBagDataInfo.giftBagInfos)
    self:checkOpen(data.giftBagDataInfo.nextOpenTime)
end
function GiftBagProxy:onTriggerNet430001Req(data)
    self:syncNetReq(AppEvent.NET_M43, AppEvent.NET_M43_C430001, {})
end

function GiftBagProxy:resetCountSyncData()

end
--20000下来的礼包信息Map
function GiftBagProxy:setGiftBagInfos(giftBagInfos)
	--self.newRedBagInfos = data
    -- print("-----------------GiftBagProxy:setGiftBagInfos giftBagInfos",#giftBagInfos)
	self._giftBagInfos = giftBagInfos
    self:setIsDataNew(true)
    -- print("GiftBagProxy --  new #giftBagInfos",#giftBagInfos)
	for _,v in ipairs(giftBagInfos) do
        -- print("durationTime",v.durationTime)
        if v.durationTime == 0 then
            local name = "oneGiftBag_RemainTime" .. v.activityDbId
            self._remainTimeMap[name] = nil
        elseif v.durationTime >  0 then
            local name = "oneGiftBag_RemainTime" .. v.activityDbId
            local remainTime = v.durationTime
            self:pushRemainTime(name,remainTime,AppEvent.NET_M43_C430001,name,self.oneComplete)
        end
	end
    self:sendNotification(AppEvent.PROXY_GIFTBAGINFOS_UPDATE)
end
--购买后刷新，单个礼包数据处理
function GiftBagProxy:setOneInfo( giftBagInfo )
    -- print("giftBagInfo.buyLimit",giftBagInfo.buyLimit)
    -- print("giftBagInfo.alreadyBuy",giftBagInfo.alreadyBuy)
    if giftBagInfo.buyLimit == giftBagInfo.alreadyBuy then
        --已经买完次数了
        for i,val in ipairs(self._giftBagInfos) do
            if val.activityDbId == giftBagInfo.activityDbId then
                table.remove(self._giftBagInfos,i)
                break
            end
        end
    else
        for i,val in ipairs(self._giftBagInfos) do
            if val.activityDbId == giftBagInfo.activityDbId then
                self._giftBagInfos[i] = giftBagInfo
                break
            end
        end
    end
    self:setIsDataNew(true)
    self:sendNotification(AppEvent.PROXY_GIFTBAGINFOS_UPDATE)

end
function GiftBagProxy:oneComplete(args)
    self._remainTimeMap[args[1]] = nil
    self:onTriggerNet430001Req()
    -- print("oneGiftBag_RemainTime")

end

function GiftBagProxy:getGiftBagAllInfos()
    return self._giftBagInfos or {}
end

function GiftBagProxy:getGiftBagFilterInfos()
	table.sort( self._giftBagInfos, function ( a,b )
        if a.startTime == b.startTime then
            return a.sort < b.sort
        end
		return a.startTime < b.startTime
	end )
        
	local info = {}
	for k, v in pairs(self._giftBagInfos) do
        if k > MaxGiftCount then
            -- 取最新的5个礼包
            break
        end
        --logger:info("==================>giftBagInfo, activityTypeId:%s, startTime:%s, sort:%s", v.activityTypeId, v.startTime, v.sort)    
        table.insert(info, v)
        v.showTag = k
    end
    
	return info
end

--当数据刷新，要重新刷界面
function GiftBagProxy:isDataNew()
    return self._isDataNew
end
function GiftBagProxy:setIsDataNew(bl)
    self._isDataNew = bl
end




--请求是否还能购买热卖礼包
function GiftBagProxy:onTriggerNet430002Req(data)
    -- message C2S{
    --     required int32 giftType = 1; //充值类型
    --     required int32 priceLimit = 2; //充值额度
    -- }
    -- self:syncNetReq(AppEvent.NET_M49, AppEvent.NET_M49_C490000, data)
    self:syncNetReq(AppEvent.NET_M43, AppEvent.NET_M43_C430002, data)
end
--请求是否还能购买热卖礼包返回
function GiftBagProxy:onTriggerNet430002Resp(data)
    if data.rs == 0 then
        self:sendNotification(AppEvent.PROXY_GIFTBAG_CAN_BUY, data)
    elseif data.rs < 0 then
        --TODO  统一弹错误码
    end
end

