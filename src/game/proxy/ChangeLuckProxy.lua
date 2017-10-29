-- /**
--  * @Author:      wzy
--  * @DateTime:    2017-7-16 17:43
--  * @Description: 招财转运活动数据代理
--  */

ChangeLuckProxy = class("ChangeLuckProxy", BasicProxy)


function ChangeLuckProxy:ctor()
    ChangeLuckProxy.super.ctor(self)
    self.proxyName = GameProxys.ChangeLuck

    self:resetAttr()
end

-- 初始化活动数据 M20000
function ChangeLuckProxy:initSyncData(data)
    ChangeLuckProxy.super.initSyncData(self, data)

    logger:info("init ChangeLuckProxy================>招财转运") 
    -- 重置数据
    self:resetAttr()

    self._fortuneInfos = data.fortuneInfos
end

-- 活动开启
function ChangeLuckProxy:onTriggerNet230011Resp(data)     
    self:initSyncData(data)
end

function ChangeLuckProxy:resetAttr()
    ChangeLuckProxy.super.resetAttr(self)

    self._fortuneInfos = { }
end

-- 12点活动数据重置
function ChangeLuckProxy:resetCountSyncData(data)
    for k, v in pairs(self._fortuneInfos) do
        local activityProxy =  self:getProxy(GameProxys.Activity)
        local activityData = activityProxy:getLimitActivityInfoById(v.id)
        local ChangeLuckActivityCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.FortuneConfig, "effectID", activityData.effectId)
        v.freeTimes1 = ChangeLuckActivityCfg.freeTimes1
        v.freeTimes2 = ChangeLuckActivityCfg.freeTimes2
    end

    self:setRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })

    self:sendNotification(AppEvent.PROXY_UPDATE_CHANGE_LUCK_INFO)
end

-- 获取招财转运时间字符串
function ChangeLuckProxy:getActivityTimeStr()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData = activityProxy:getLimitActivityDataByUitype(ActivityDefine.LIMIT_CHANGELUCK_ID)

    local t1 = TimeUtils:setTimestampToString4(activityData.startTime)
    local t2 = TimeUtils:setTimestampToString4(activityData.endTime)

    return TimeUtils.getLimitActFormatTimeString(activityData.startTime, activityData.endTime, true)
end

-- 剩余次数(不包含了免费次数)
function ChangeLuckProxy:getRemainTimes(activityId)
    local activityInfo = self:getActivityInfo(activityId)
    if activityInfo == nil then
        return 0, 0
    end

    return activityInfo.times1, activityInfo.times2
end

-- 免费次数
function ChangeLuckProxy:getFreeRemainTimes(activityId)
    local activityInfo = self:getActivityInfo(activityId)
    if activityInfo == nil then
        return 0, 0
    end

    return activityInfo.freeTimes1, activityInfo.freeTimes2
end

-- 次数和级
function ChangeLuckProxy:getTimes(activityId)
    local activityInfo = self:getActivityInfo(activityId)
    if activityInfo == nil then
        return 0, 0
    end

    return activityInfo.freeTimes1 + activityInfo.times1, activityInfo.freeTimes2 + activityInfo.times2
end

-- 获取对应的转运轮盘
function ChangeLuckProxy:getActivityInfo(activityId)
    -- 更新对应的好运轮盘信息
    for k, v in pairs(self._fortuneInfos) do
        if v.id == activityId then
            return v
        end
    end

    return nil
end

-- 推送红点
function ChangeLuckProxy:setRedPoint()
    local redPoint = self:getProxy(GameProxys.RedPoint)
    for k, v in pairs(self._fortuneInfos) do
        redPoint:setRedPoint(v.id, v.times1 + v.freeTimes1 + v.times2 + v.freeTimes2)
    end
end

------------------------------------------------------------------协议----------------------------------------------------------------------------------

-- 招财转运
function ChangeLuckProxy:onTriggerNet230059Req(data)

    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230059, data)

end
function ChangeLuckProxy:onTriggerNet230059Resp(data)
    if data.rs ~= 0 then
        return
    end

    -- 更新对应的好运轮盘信息
    for k, v in pairs(self._fortuneInfos) do
        if v.id == data.fortuneInfo.id then
            self._fortuneInfos[k] = data.fortuneInfo
        end
    end

    self:setRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })

    self:sendNotification(AppEvent.PROXY_UPDATE_CHANGE_LUCK_INFO, data.rewardId)

end

-- 充值后推送好运轮盘信息
function ChangeLuckProxy:onTriggerNet230060Resp(data)


    self._fortuneInfos = data.fortuneInfos

    self:setRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })

    self:sendNotification(AppEvent.PROXY_UPDATE_CHANGE_LUCK_INFO)

end