-- /**
--  * @Author:      wzy
--  * @DateTime:    2017-7-27 17:43
--  * @Description: 军功玩法数据代理
--  */

MapMilitaryProxy = class("MapMilitaryProxy", BasicProxy)

function MapMilitaryProxy:ctor()
    MapMilitaryProxy.super.ctor(self)
    self.proxyName = GameProxys.MapMilitary

    self:resetAttr()
end

-- 初始化活动数据 M20000
function MapMilitaryProxy:initSyncData(data)
    MapMilitaryProxy.super.initSyncData(self, data)

    -- 重置数据
    self:resetAttr()

    self._militaryExploitInfo = data.militaryExploitInfo

    --logger:info("self._militaryExploitInfo.value = %s", self._militaryExploitInfo.value)
    --logger:info("self._militaryExploitInfo.totalReward = %s", self._militaryExploitInfo.totalReward)
    --logger:info("self._militaryExploitInfo.rewardNum = %s", self._militaryExploitInfo.rewardNum)
    --logger:info("self._militaryExploitInfo.usedTimes = %s", self._militaryExploitInfo.usedTimes)
    --logger:info("self._militaryExploitInfo.groupId = %s", self._militaryExploitInfo.groupId)
    
    self:setOldMilitaryValue(self._militaryExploitInfo.value)

    self.plainsChapterInfo = data.plainsInfo --中原目标信息
end

function MapMilitaryProxy:resetAttr()
    MapMilitaryProxy.super.resetAttr(self)

    self._militaryExploitInfo = {}
end

-- 12点活动数据重置
function MapMilitaryProxy:resetCountSyncData(data)
    self._militaryExploitInfo.value = 0
    self._militaryExploitInfo.totalReward = 0
    self._militaryExploitInfo.rewardNum = 0
    self._militaryExploitInfo.usedTimes = 0

    -- 重置奖励组
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) or 0
    local levelData = ConfigDataManager:getInfosFilterByFunc(ConfigData.TaskLevelIntervalConfig, function(cfgData)
        local ary = StringUtils:jsonDecode(cfgData.level)
        if ary[1] <= playerLevel and playerLevel <= ary[2] then
            return true
        end
        return false
    end )
    self._militaryExploitInfo.groupId = levelData.group

    self:setOldMilitaryValue(self._militaryExploitInfo.value)

    self:sendNotification(AppEvent.PROXY_MAP_MILITARY_UPDATE)
end

-- 用来播放获得军功动画的记录
function MapMilitaryProxy:getOldMilitaryValue()
    return self._oldMilitaryValue or 0
end
function MapMilitaryProxy:setOldMilitaryValue(value)
    self._oldMilitaryValue = (value or 0)
end

-- 获取奖励组
function MapMilitaryProxy:getGroupId()    
    return self._militaryExploitInfo.groupId or 1
end

-- 已重置次数
function MapMilitaryProxy:getUsedTimes()
    return self._militaryExploitInfo.usedTimes or 0
end

-- 今日已获得宝箱	
function MapMilitaryProxy:getTotalReward()
    return self._militaryExploitInfo.totalReward or 0
end

-- 当前拥有的宝箱
function MapMilitaryProxy:getRewardNum()
    return self._militaryExploitInfo.rewardNum or 0
end

-- 今日军功
function MapMilitaryProxy:getCurMilitaryValue()
    return self._militaryExploitInfo.value or 0
end

--获取军工箱子列表
function MapMilitaryProxy:getMilitaryAwardGroup()
    local awardGroup = ConfigDataManager:getInfosFilterByOneKey(ConfigData.MilitaryExploitTaskConfig, "group", self:getGroupId())
    table.sort(awardGroup, function(a, b) return a.sort < b.sort end)
    return awardGroup
end

-- 获取当前最大军功
function MapMilitaryProxy:getMaxMilitaryValue()
    local max = 0
    local awardGroup = self:getMilitaryAwardGroup()
    if awardGroup and next(awardGroup) then
        local lastAwardData = awardGroup[#awardGroup]
        max = lastAwardData.activeNeed
    end

    return max
end

-- 当前可重置次数
function MapMilitaryProxy:getRemianResetTimes()
    -- 当前重置次数
    local usedTimes = self:getUsedTimes()

    -- 当前vip可重置次数
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local timesData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MilitaryExploitMissionConfig, "VIP", vipLevel)

    -- 剩余次数
    local remainTimes = timesData.resetTimes - usedTimes

    return remainTimes
end

-- 是否已达当天重置上限
function MapMilitaryProxy:isMaxResetTimes()
    -- 当前重置次数
    local usedTimes = self:getUsedTimes()

    -- 最大可重置次数
    local timesCfg = ConfigDataManager:getConfigData(ConfigData.MilitaryExploitMissionConfig)
    local maxTimes = timesCfg[#timesCfg].resetTimes

    -- 剩余次数
    local remainTimes = maxTimes - usedTimes

    return remainTimes <= 0 
end

-- 是否需要升级vip来提升重置次数
function MapMilitaryProxy:isNeedUpgradeVip()
    -- 当前重置次数
    local usedTimes = self:getUsedTimes()

    -- 当前vip可重置次数
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local timesData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MilitaryExploitMissionConfig, "VIP", vipLevel)

    return usedTimes >= timesData.resetTimes
end

-- 钱是否足够重置去重置
function MapMilitaryProxy:isGoldEnoughToReset()
    local usedTimes = self:getUsedTimes()
    local roleProxy = self:getProxy(GameProxys.Role)
    local curPlayerGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    local priceData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MilitaryExploitPriceConfig, "resetTimes", usedTimes + 1)
    if priceData then
        return curPlayerGold >= priceData.price
    end

    return false
end

function MapMilitaryProxy:getResetGlod()
    local usedTimes = self:getUsedTimes()
    local priceData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MilitaryExploitPriceConfig, "resetTimes", usedTimes + 1)
    if priceData then
        return priceData.price
    end

    priceData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MilitaryExploitPriceConfig, "resetTimes", usedTimes)
    return priceData.price
end


------------------------------------------------------------------协议----------------------------------------------------------------------------------

-- 打开宝箱
function MapMilitaryProxy:onTriggerNet530000Req(data)
    self:syncNetReq(AppEvent.NET_M53, AppEvent.NET_M53_C530000, data)
end
function MapMilitaryProxy:onTriggerNet530000Resp(data)
    --printProto(data)
    if data.rs ~= 0 then
        return
    end

    self._militaryExploitInfo = data.info

    self:sendNotification(AppEvent.PROXY_MAP_MILITARY_PLAY_ANIM, data)

    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkMapMilitrayRedPoint()
    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, data)
end

-- 手动重置
function MapMilitaryProxy:onTriggerNet530001Req()
    self:syncNetReq(AppEvent.NET_M53, AppEvent.NET_M53_C530001, { })
end
function MapMilitaryProxy:onTriggerNet530001Resp(data)
    --printProto(data)
    if data.rs ~= 0 then
        return
    end

    self._militaryExploitInfo = data.info

    self:setOldMilitaryValue(self._militaryExploitInfo.value)

    self:sendNotification(AppEvent.PROXY_MAP_MILITARY_UPDATE)
end

-- 军功变动时推送
function MapMilitaryProxy:onTriggerNet530002Resp(data)
    --printProto(data)
    self._militaryExploitInfo = data.info

    self:sendNotification(AppEvent.PROXY_MAP_MILITARY_UPDATE)

    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkMapMilitrayRedPoint()
    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, data)
end

---[[中原目标
--更新中原任务信息
function MapMilitaryProxy:updatePlainsChapterInfo(data)
    self.plainsChapterInfo = data

    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkMapMilitrayRedPoint()
    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE,{})
    self:sendNotification(AppEvent.PROXY_MAP_MILITARY_PLAINSCHAPTER_UPDATE)
end

function MapMilitaryProxy:getPlainsChapterRewardNum()
    local num = 0
    if self.plainsChapterInfo then
        if self.plainsChapterInfo.state == 1 then--表示可领取
            num = num + 1
        end
        for k,v in pairs(self.plainsChapterInfo.taskInfo) do
            if v.state == 1 then --表示可领取
                num = num + 1
            end
        end 
    end
    print("==============getPlainsChapterRewardNum==============",num)
    
    return num
end 

--获取中原任务信息
function MapMilitaryProxy:getPlainsChapterInfo()
    return self.plainsChapterInfo
end 

--领取任务奖励
function MapMilitaryProxy:onTriggerNet580000Req(data)
    self:syncNetReq(AppEvent.NET_M58, AppEvent.NET_M54_C580000,data)
end

function MapMilitaryProxy:onTriggerNet580000Resp(data)
    if data.rs == 0 then
        self:updatePlainsChapterInfo(data.chapterInfo)
    end 
end

--领取章节奖励
function MapMilitaryProxy:onTriggerNet580001Req(data)
    self:syncNetReq(AppEvent.NET_M58, AppEvent.NET_M54_C580001,data)
end

function MapMilitaryProxy:onTriggerNet580001Resp(data)
   if data.rs == 0 then
        self:updatePlainsChapterInfo(data.chapterInfo)
   end 
end

--章节信息推送
function MapMilitaryProxy:onTriggerNet580002Resp(data)
   -- if data.rs == 0 then
    self:updatePlainsChapterInfo(data.chapterInfo) 
   -- end 
end
--]]