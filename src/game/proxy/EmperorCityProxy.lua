-- 皇城战数据代理
EmperorCityProxy = class("EmperorCityProxy", BasicProxy)


function EmperorCityProxy:ctor()
    EmperorCityProxy.super.ctor(self)
    self.proxyName = GameProxys.EmperorCity
    self._configMap = {} -- 以"x_y"为key的配置表

    self:setConfigMap()
end

function EmperorCityProxy:initSyncData(data)
	EmperorCityProxy.super.initSyncData(self, data)
end

function EmperorCityProxy:afterInitSyncData()
--    self:onTriggerNet550001Req({})
--    self:onTriggerNet550003Req({})

    
end



------
-- 点击地图皇城
function EmperorCityProxy:onTriggerNet550000Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550000, data)
end

------
-- 请求同步皇城
function EmperorCityProxy:onTriggerNet551000Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C551000, data)
end


-----
-- 打开皇城界面获取信息
function EmperorCityProxy:onTriggerNet550001Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550001, data)
end

-----
-- 点击领取资源
function EmperorCityProxy:onTriggerNet551001Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C551001, data)
end


------
-- 获取历史战报
function EmperorCityProxy:onTriggerNet550002Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550002, data)
end

------
-- 获取排名
function EmperorCityProxy:onTriggerNet550003Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550003, data)
end

------
-- 领取排名奖励
function EmperorCityProxy:onTriggerNet551003Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C551003, data)
end 


------
-- 获取单独显示用，活动状态和倒计时
function EmperorCityProxy:onTriggerNet550004Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550004, data)
end 

------
-- 购买特惠讨伐令
function EmperorCityProxy:onTriggerNet550005Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550005, data)
end 


------
-- 清除未读战报数量
function EmperorCityProxy:onTriggerNet550007Req(data)
    self:syncNetReq(AppEvent.NET_M55, AppEvent.NET_M55_C550007, data)
end 

------
-- 请求重播
function EmperorCityProxy:onTriggerNet160005Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end

------
-- 点击皇城resp
function EmperorCityProxy:onTriggerNet550000Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._cityInfo      = data.cityInfo         -- 皇城信息{}
    self._nextStateTime = data.nextStateTime    -- 下一个状态的剩余时间
    self._marchTime     = data.marchTime        -- 行军时间
    self._integralSpeed = data.integralSpeed    -- 民忠速度
    self._occupyNum     = data.occupyNum        -- 当前占领值
    self._judgeOccupyNum= data.occupyNum
    self._defLegionName = data.defLegionName    -- 防守同盟名
    self._defTeamList   = data.defTeamList      -- 防守队伍列表
    self._openTime      = data.openTime         -- 下轮战斗的具体时间

    logger:info("####550000的当前占领值###############:"..data.occupyNum)
    logger:info("####550000的当前占领同盟#############:"..data.cityInfo.legionName)
    logger:info("####550000的当前防守同盟#############:"..data.defLegionName)
    
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_MAP_CLICK, {})

end

-- 皇城信息
function EmperorCityProxy:getCityInfo()
    return self._cityInfo
end

function EmperorCityProxy:getCityId()
    return self._cityInfo.cityId or 0
end
-- 1-未开放, 2-休战期(归属期), 3准备期(保护), 4-争夺期 
function EmperorCityProxy:getCityStatus()
    return self._cityInfo.cityStatus
end



-- 下一个状态的剩余时间
function EmperorCityProxy:getNextStateTime()
    return self._nextStateTime
end

-- 行军时间
function EmperorCityProxy:getMarchTime()
    return self._marchTime
end

-- 民忠速度
function EmperorCityProxy:getIntegralSpeed()
    return self._integralSpeed
end

-- 当前占领值
function EmperorCityProxy:getOccupyNum()
    return self._occupyNum
end

-- 当前占领值2, 做状态判断用
function EmperorCityProxy:getJudgeOccupyNum()
    return self._judgeOccupyNum
end

-- 设置当前占领值
function EmperorCityProxy:setOccupyNum(curNum)
    self._occupyNum = curNum
end


-- 防守同盟名
function EmperorCityProxy:getDefLegionName()
    return self._defLegionName
end

-- 防守队伍列表
function EmperorCityProxy:getDefTeamList()
    return self._defTeamList or {}
end

-- 下轮战斗的具体时间
function EmperorCityProxy:getOpenTime()
    return self._openTime
end



------
-- 请求同步皇城推送
function EmperorCityProxy:onTriggerNet551000Resp(data)
    if data.rs ~= 0 then
        return
    end
    -- 地图刷新：先判断这个点有没有在地图上生成，有的话直接刷新当前的界面
    self:updateWorldNode(data.cityId)

    -- 主界面刷新：根据id拿取info，将info替换
    self:updateCityStateInfoList(data)

    -- 弹窗刷新：直接替换数据
    self:updateCityMapClickInfo(data)
end


-- 主界面推送数据刷新
function EmperorCityProxy:updateCityStateInfoList(data)
    if #self:getCityStateInfoList() == 0 then
        return 
    end
    local cityId = data.cityId

    for i, info in pairs(self:getCityStateInfoList()) do
        if info.cityInfo.cityId == cityId then
            info.cityInfo.legionName = data.legionName
            info.cityInfo.cityStatus = data.cityStatus
        end
    end
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_INFO_UPDATE, {})  -- 刷新info界面
end


-- 弹窗刷新：直接替换数据
function EmperorCityProxy:updateCityMapClickInfo(data)
    local cityId = data.cityId
    if self:getCityInfo() ~= nil then
        if cityId ~= self:getCityId() then -- 只刷当前
            return
        end
    else
        return
    end

    self._cityInfo.legionName = data.legionName
    self._cityInfo.cityStatus = data.cityStatus
    -------------------------------------------
    self._nextStateTime = data.nextStateTime    -- 下一个状态的剩余时间
    self._integralSpeed = data.integralSpeed    -- 民忠速度
    self._occupyNum     = data.occupyNum        -- 当前占领值
    self._judgeOccupyNum= data.occupyNum
    self._defLegionName = data.defLegionName    -- 防守同盟名
    self._defTeamList   = data.defTeamList      -- 防守队伍列表

    logger:info("下一个状态的剩余时间: "..data.nextStateTime) 
    logger:info("民忠速度           : "..data.integralSpeed) 
    logger:info("当前占领值         : "..data.occupyNum    ) 
    logger:info("防守同盟名         : "..data.defLegionName) 
    logger:info("占领同盟名         : "..data.legionName) 

    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_WARON_UPDATE, {})
end

-- 地图刷新：先判断这个点有没有在地图上生成，有的话直接刷新当前的地图信息
function EmperorCityProxy:updateWorldNode(cityId)
    -- 在地图界面才执行
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarConfig, cityId)
    local posData = {x = configInfo.dataX, y = configInfo.dataY}
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_UPDATE_WORLD, posData)
end

------
-- 打开皇城界面获取信息resp
function EmperorCityProxy:onTriggerNet550001Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._cityStateInfoList = data.cityStateInfoList -- 皇城界面信息

    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_INFO_UPDATE, {})  -- 刷新info界面
end

function EmperorCityProxy:getCityStateInfoList()
    return self._cityStateInfoList or {}
end


------
-- 点击领取资源
function EmperorCityProxy:onTriggerNet551001Resp(data)
    if data.rs ~= 0 then
        return
    end
    local rewardState = 2 -- 领取状态刷新
    local cityId = data.cityId -- 皇城id

    for k, info in pairs (self:getCityStateInfoList()) do
        if info.cityInfo.cityId == cityId then
            info.rewardState = rewardState
        end
    end

    -- 更新红点
    self:getAllRedPoint()
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_INFO_UPDATE, {})  -- 刷新info界面
end



------
-- 获取历史战报
function EmperorCityProxy:onTriggerNet550002Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._cityFightInfoList = data.cityFightInfoList -- 战报

    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_GET_REPORT, {})
end

-- 获取战报列表
function EmperorCityProxy:getCityFightInfoList()
    return self._cityFightInfoList

end


------
-- 获取排名
function EmperorCityProxy:onTriggerNet550003Resp(data)
    if data.rs ~= 0 then
        return
    end
    self._legionRankList = data.legionRankList -- 同盟
    self._personRankList = data.personRankList -- 个人
    self._rewardState    = data.rewardState    -- 领取状态，0不可领取，1可领取，2已领取

    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_RANK_UPDATE, {})

    -- 更新红点
    self:getAllRedPoint()
end
-- 获取同盟排名
function EmperorCityProxy:getLegionRankList()
    return self._legionRankList or {}
end
-- 获取个人排名
function EmperorCityProxy:getPersonRankList()
    return self._personRankList or {}
end

function EmperorCityProxy:getRewardState()
    return self._rewardState or 0                      
end


------
-- 领取排名奖励Resp
function EmperorCityProxy:onTriggerNet551003Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._rewardState = 2 -- 已领取

    -- 更新红点
    self:getAllRedPoint()
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_RANK_REWARD, {})
end 



------
-- 获取单独显示用，活动状态和倒计时Resp
function EmperorCityProxy:onTriggerNet550004Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._showCityStatus = data.cityStatus
    self._showNextStateTime = data.nextStateTime
    self._boughtTimes = data.boughtTimes -- 皇城活动的特惠讨伐令已购买次数
    -- 时间push
    self:pushRemainTime(AppEvent.NET_M55_C550004, self._showNextStateTime, AppEvent.NET_M55_C550004, self._showCityStatus, self.timeEndCall)
    -- 回调
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_SHOW_STATE, {})
end

-- 状态
function EmperorCityProxy:getShowCityStatus()
    return self._showCityStatus or 0
end

function EmperorCityProxy:getBoughtTimes()
    return self._boughtTimes or 0
    -- return 12
end

function EmperorCityProxy:setBoughtTimes(count)
    self._boughtTimes = count
end

------
-- 购买特惠讨伐令Resp
function EmperorCityProxy:onTriggerNet550005Resp(data)
    if data.rs ~= 0 then
        return
    end
    self:setBoughtTimes(data.boughtTimes)
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_BOUGHT_FIGHT, {})
end


-- 时间结束，重新请求
function EmperorCityProxy:timeEndCall()
    self:onTriggerNet550004Req({})
end

------
-- 推送未读的个人战报数量
function EmperorCityProxy:onTriggerNet550006Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._unreadReportNum = data.unread -- 未读的数量
    -- 更新红点
    self:getAllRedPoint()
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT, {})
end

-- 个人战报未读数量
function EmperorCityProxy:getUnreadReportNum()
    return self._unreadReportNum or 0
end

function EmperorCityProxy:setUnreadReportNum(count)
    self._unreadReportNum = count

    -- 更新红点
    self:getAllRedPoint()
    -- 清除红点回调
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_READ_REPORT, {})
    self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT, {})
end


------
-- 清除未读战报数量
function EmperorCityProxy:onTriggerNet550007Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self:setUnreadReportNum(0) -- 清零
end

-- 静态表
function EmperorCityProxy:setConfigMap()
    local config = ConfigDataManager:getConfigData(ConfigData.EmperorWarConfig)
    for key, info in pairs(config) do
        if info.dataX ~= nil then
            self._configMap[info.dataX.."_"..info.dataY] = info
        end
    end

    local aa = self._configMap
end

function EmperorCityProxy:getConfigByMapKey(mapKey)
    return self._configMap[mapKey]
end


------
-- 获得领取奖励数
function EmperorCityProxy:getCityInfosRedCount()
    local count = 0
    for i, info in pairs(self:getCityStateInfoList()) do
        if info.rewardState == 1 then
            count = count + 1
        end
    end
    count = 0
    -- 未读战报红点
    local unreadCount = self:getUnreadReportNum()
    return count + unreadCount
    
end


------
-- 获取皇城活动红点总数
function EmperorCityProxy:getAllRedPoint()
    local infoPanelNum = self:getCityInfosRedCount()

    local rankNum = 0
    if self:getRewardState() == 1 then
        rankNum = rankNum + 1
    end
    local unreadReportNum = self:getUnreadReportNum()

    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:updateEmperorCityRedNum(infoPanelNum + rankNum)
end