--
RealNameProxy = class("RealNameProxy", BasicProxy)

function RealNameProxy:ctor()
    RealNameProxy.super.ctor(self)
    self.proxyName = GameProxys.RealName
end

function RealNameProxy:initSyncData(data)
	RealNameProxy.super.initSyncData(self, data)
    self._realNameInfo = nil
end

-- 申请实名制
function RealNameProxy:onTriggerNet460000Req(data)
    self:syncNetReq(AppEvent.NET_M46, AppEvent.NET_M46_C460000, data)
end

-- 客户端通知服务端后台实名制开关状态
function RealNameProxy:onTriggerNet460001Req(data)
    self:syncNetReq(AppEvent.NET_M46, AppEvent.NET_M46_C460001, data)
end


function RealNameProxy:onTriggerNet460000Resp(data)
    if data.rs ~= 0 then
        return
    end
    logger:info("接收到实名制认证消息返回 460000")
    self._realNameInfo = data.info
    self:showSysMessage( TextWords:getTextWord(461018)) -- 实名认证成功
    self:sendNotification(AppEvent.PROXY_REALNAME_UPDATE,{}) --实名认证信息的刷新

    self._respTime = os.time() -- 存储时间
end

-- 请求实名制消息
function RealNameProxy:onTriggerNet460001Resp(data)
    if data.rs ~= 0 then
        return 
    end
    logger:info("登陆时客户端通知服务端后台实名制开关状态 460001")
    self._realNameInfo = data.info

    if data.info.state == 0 then  -- 如果收到state == 0，则相当于处于等级限制(空包会返回默认)
        GameConfig.isOpenRealNameVerify = false
    else
        GameConfig.isOpenRealNameVerify = true
    end
        
    self:sendNotification(AppEvent.PROXY_REALNAME_UPDATE,{}) --实名认证信息的刷新

    self._respTime = os.time() -- -- 存储时间
end

function RealNameProxy:getRealNameInfo()
    return self._realNameInfo
end

-- 过了零点刷新数据，时间、充值、debuff百分比
function RealNameProxy:resetCountSyncData()
    if self._realNameInfo ~= nil then
        if self._realNameInfo.state ~= 0 then -- 有不发结构的情况
            self._realNameInfo.onlineTime = 0
            self._realNameInfo.recharge   = 0
            self._realNameInfo.debuff     = 0
        end
    end

end
-- 充值金额每日上限：元
function RealNameProxy:getMaxDailyCharge()
    local maxGold = ConfigDataManager:getConfigById(ConfigData.RealNameConfig, 1).nonageRechargeLimit
    return maxGold
end

-- 获取惩罚开关状态
function RealNameProxy:getIsPunish()
    local isPunish = false
    if self._realNameInfo ~= nil then
        if self._realNameInfo.isPunish == 1 then
            isPunish = true
            logger:info("惩罚开关：开")
        end
    end
    return isPunish
end

-- 是否有减益
function RealNameProxy:isShowDebuff()
    local state = false
    
    if GameConfig.isOpenRealNameVerify and self:getIsPunish() then
        state = true
    end

    return state
end 


-- 返回系数
function RealNameProxy:getDebuff()
    local debuff = 0
    if self._realNameInfo == nil then
        return debuff
    end

    local state = self._realNameInfo.state -- （1：未实名，2：实名未成年，3：实名已成年
    if state == 3 then --实名已成年
        return debuff
    end
    
    if state == 0 then -- 还未开放
        return debuff
    end

    local nowTime = os.time()
    local diff = nowTime - self._respTime
    local allOnlineTime = diff + self._realNameInfo.onlineTime
    
    local realNameBuffConfig = ConfigDataManager:getConfigData(ConfigData.RealNameBuffConfig)
    for i, info in pairs(realNameBuffConfig) do
        if state == 1 and info.type1 == 1 then
            local timeRange = StringUtils:jsonDecode(info.param) -- 时间区间
            if #timeRange == 2 then
                if timeRange[1] <= allOnlineTime and timeRange[2] >= allOnlineTime then
                    debuff = info.buffValue/100
                    break
                end
            elseif #timeRange == 1 then
                if timeRange[1] < allOnlineTime then
                    debuff = info.buffValue/100
                    break
                end
            end
        end

        if state == 2 and info.type1 == 2 then
            local timeRange = StringUtils:jsonDecode(info.param) -- 时间区间
            if #timeRange == 2 then
                if timeRange[1] <= allOnlineTime and timeRange[2] >= allOnlineTime then
                    debuff = info.buffValue/100
                    break
                end
            elseif #timeRange == 1 then
                if timeRange[1] < allOnlineTime then
                    debuff = info.buffValue/100
                    break
                end
            end
        end
    end

    return debuff
end