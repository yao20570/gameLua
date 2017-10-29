-- /**
--  * @Author:      wzy
--  * @DateTime:    2017-7-10 16:43
--  * @Description: 幸运轮盘活动数据代理
--  */

LuckTurntableProxy = class("LuckTurntableProxy", BasicProxy)


function LuckTurntableProxy:ctor()
    LuckTurntableProxy.super.ctor(self)
    self.proxyName = GameProxys.LuckTurntable

    self:resetData()
end


function LuckTurntableProxy:resetData()
    self._luckyCoronaInfos = { }
end

-- 初始化活动数据 M20000
function LuckTurntableProxy:initSyncData(data)
    LuckTurntableProxy.super.initSyncData(self, data)

    -- 重置数据
    self:resetAttr()

    logger:info("init LuckTurntableProxy================>幸运轮盘")
    self._luckyCoronaInfos = data.luckyCoronaInfos
end

-- 活动开启
function LuckTurntableProxy:onTriggerNet230011Resp(data)    
    self:initSyncData(data)
end

-- 12点活动数据重置
function LuckTurntableProxy:resetCountSyncData(data)
    for k, v in pairs(self._luckyCoronaInfos) do
        local activityProxy =  self:getProxy(GameProxys.Activity)
        local freeTimes = 0        
        local activityData = activityProxy:getLimitActivityInfoById(v.id)
        if activityData ~= nil then            
            local luckTurntableActivityCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.LuckyCoronaConfig, "effectID", activityData.effectId)
            freeTimes = luckTurntableActivityCfg.freeTimes
        end
        v.times = v.times - v.freeTimes + freeTimes
    end

    self:setRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })

    self:sendNotification(AppEvent.PROXY_UPDATE_LUCK_TURNTABLE_INFO)
end

-- 获取幸运轮盘时间字符串
function LuckTurntableProxy:getActivityTimeStr()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData = activityProxy:getLimitActivityDataByUitype(ActivityDefine.LIMIT_LUCKTURNTABLE_ID)

    local t1 = TimeUtils:setTimestampToString4(activityData.startTime)
    local t2 = TimeUtils:setTimestampToString4(activityData.endTime)

    return TimeUtils.getLimitActFormatTimeString(activityData.startTime, activityData.endTime, true)
end

function LuckTurntableProxy:getRemainRecharge(activityId)
    local activityInfo = self:getActivityInfo(activityId)
    if activityInfo == nil then
        return 0
    end

    return activityInfo.currentGold
end

-- 剩余次数
function LuckTurntableProxy:getActivityInfo(activityId)
    -- 活动结束，未下架
    for k, v in pairs(self._luckyCoronaInfos) do
        if v.id == activityId then
            return v
        end
    end

    return nil
end

-- 剩余次数(包含了免费次数)
function LuckTurntableProxy:getRemainTimes(activityId)
    local activityInfo = self:getActivityInfo(activityId)
    if activityInfo == nil then
        return 0
    end

    return activityInfo.times
end

-- 免费次数
function LuckTurntableProxy:getFreeRemainTimes(activityId)
    local activityInfo = self:getActivityInfo(activityId)
    if activityInfo == nil then
        return 0
    end

    return activityInfo.freeTimes
end

-- 推送红点
function LuckTurntableProxy:setRedPoint()
    local redPoint = self:getProxy(GameProxys.RedPoint)
    for k, v in pairs(self._luckyCoronaInfos) do
        redPoint:setRedPoint(v.id, v.times)
    end
end

------------------------------------------------------------------协议----------------------------------------------------------------------------------

-- 好运轮盘抽奖
function LuckTurntableProxy:onTriggerNet230057Req(data)

    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230057, data)

end
function LuckTurntableProxy:onTriggerNet230057Resp(data)
    if data.rs ~= 0 then
        return
    end

    -- 更新对应的好运轮盘信息
    for k, v in pairs(self._luckyCoronaInfos) do
        if v.id == data.luckyCoronaInfo.id then
            self._luckyCoronaInfos[k] = data.luckyCoronaInfo
        end
    end

    self._rewardInfos = data.rewards -- 奖励数据


    self:setRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })

    self:sendNotification(AppEvent.PROXY_UPDATE_LUCK_TURNTABLE_INFO, data.rewardId)

end

-- 获取奖励数据
function LuckTurntableProxy:getRewardInfos()
    return self._rewardInfos
end


-- 充值后推送好运轮盘信息
function LuckTurntableProxy:onTriggerNet230058Resp(data)


    self._luckyCoronaInfos = data.luckyCoronaInfos

    self:setRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })

    self:sendNotification(AppEvent.PROXY_UPDATE_LUCK_TURNTABLE_INFO)

end