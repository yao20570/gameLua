-- /**
--  * @Author:    wzy
--  * @DateTime:    2017-2-6 16:14
--  * @Description: 礼贤下士活动数据代理
--  */

ConsortProxy = class("ConsortProxy", BasicProxy)


function ConsortProxy:ctor()
    ActivityShopProxy.super.ctor(self)
    self.proxyName = GameProxys.Consort

    self:resetData()
end


function ConsortProxy:resetData()
    self._consortInfoDatas = {}
end

-- 初始化活动数据 M20000
function ConsortProxy:initSyncData(data)
    ConsortProxy.super.initSyncData(self, data)

    -- 重置数据
    self:resetAttr()

    logger:info("init ConsortProxy================>礼贤下士")
    self._consortInfoDatas = data.courteousActivityInfos
end

-- 活动开启
function ConsortProxy:onTriggerNet230011Resp(data)        
    self:initSyncData(data)
end

-- 12点活动数据重置
function ConsortProxy:resetCountSyncData()
    for k, v in pairs(self._consortInfoDatas) do
        v.freeTime = 0
    end
end

function ConsortProxy:getConsortInfoDatas()
    return self._consortInfoDatas or {}
end

-- 当前礼贤活动ID
function ConsortProxy:getCurActivityId()
    return self:getCurActivityData().activityId
end


-- 当前礼贤活动数据
function ConsortProxy:getCurActivityData()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local consortActivityData = activityProxy:getCurActivityData()

    return consortActivityData
end

-- 当前配置表数据
function ConsortProxy:getCurConsortCfgData()
    local curActivityId = self:getCurActivityId()
    local curConsortCfgData = self:getConsortCfgData(curActivityId)
    return curConsortCfgData
end

-- 配置表数据
function ConsortProxy:getConsortCfgData(activityId)
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData = activityProxy:getLimitActivityInfoById(activityId)
    if activityData then
        local effectId = activityData.effectId
        local courteousData = ConfigDataManager:getInfoFindByOneKey(ConfigData.CourteousConfig, "effectID", effectId)
        return courteousData
    end

    return nil
end

-- 获取礼贤下士活动的礼贤信息
function ConsortProxy:getConsortInfoData(activityId)
    for k, v in pairs(self._consortInfoDatas) do
        if v.activityId == activityId then
            return v
        end
    end
    return nil
end

-- 礼贤亲密度
function ConsortProxy:getIntimate(activityId)
    local intimacy = 0
    local consortInfoData = self:getConsortInfoData(activityId)
    if consortInfoData then
        intimacy = consortInfoData.intimacy or 0
    end
    return intimacy
end

-- 是否有免费次数
function ConsortProxy:isHasFreeTimes(activityId)
    local freeTime = self:getFreeTimes(activityId)
    return freeTime > 0
end

-- 免费次数
function ConsortProxy:getFreeTimes(activityId)
    --活动结束，未下架
    local actProxy = self:getProxy(GameProxys.Activity)
    local limitActivityInfo = actProxy:getLimitActivityInfoById(activityId)
    if limitActivityInfo == nil then
        return 0
    end
    if GameConfig.serverTime >= limitActivityInfo.endTime then
        return 0
    end
    local consortCfgData = self:getConsortCfgData(activityId)
    if consortCfgData then
        local hasUseTimes = self:getHasUseTimes(activityId)
        local remainFreeTimes = consortCfgData.freeTime - hasUseTimes
        return remainFreeTimes
    end
    return 0
end

-- 当前已用次数
function ConsortProxy:getHasUseTimes(activityId)
    local consortInfoData = self:getConsortInfoData(activityId)
    -- 蛋疼的服务端的freeTime是使用次数
    return consortInfoData.freeTime or 0
end

-- 排行榜信息
function ConsortProxy:getConsortRankServerDatas()
    local activityRankProxy = self:getProxy(GameProxys.Activity)
    local activityId = self:getCurActivityId()
    local rankInfo = activityRankProxy:getRankInfoById(activityId)
    return rankInfo
end

function ConsortProxy:setRedPoint()
    local redPoint = self:getProxy(GameProxys.RedPoint)
    for k,v in pairs(self._consortInfoDatas) do
		local redNum = self:getFreeTimes(v.activityId)
		redPoint:setRedPoint(v.activityId, redNum)
	end	
end

----------------------------------------------------------------协议----------------------------------------------------------------------------------

-- 请求礼贤
function ConsortProxy:onTriggerNet230041Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230041, data)
end
function ConsortProxy:onTriggerNet230041Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._consortInfoDatas = data.courteousActivityInfo

    self:setRedPoint()

	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})

    self:sendNotification(AppEvent.PROXY_UPDATE_CONSORT_INFO)

    self:sendNotification(AppEvent.PROXY_PLAY_CONSORT_ANIMA, data.getids)
end