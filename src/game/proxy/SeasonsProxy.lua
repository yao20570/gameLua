-- 四季系统数据代理
SeasonsProxy = class("SeasonsProxy", BasicProxy)

SeasonsProxy.Season_Sate_Close = 0
SeasonsProxy.Season_Sate_Open = 1

SeasonsProxy.World_Sate_Close = 0
SeasonsProxy.World_Sate_Open = 1

local _________isTest_________ = false


--1-春 2-夏 3-秋 4-冬
SeasonsProxy.SeasonEnum = {}
SeasonsProxy.SeasonEnum.Spring = 1
SeasonsProxy.SeasonEnum.Summer = 2
SeasonsProxy.SeasonEnum.Autumn = 3
SeasonsProxy.SeasonEnum.Winter = 4


function SeasonsProxy:ctor()
    SeasonsProxy.super.ctor(self)
    self.proxyName = GameProxys.Seasons

    self._remainTimeOfCurSeasonKey = self.proxyName .. "_remainTimeOfCurSeasonKey"

    self._remainTimeOfOpenNextWorldKey = self.proxyName .. "_remainTimeOfOpenNextWorldKey"

    -- 因为有时toolbar在init()后才收到20000协议
    self._worldGlobalInfo = { }
end

function SeasonsProxy:beforeInitSyncData()
    SeasonsProxy.super.beforeInitSyncData(self)
end

function SeasonsProxy:initSyncData(data)
    SeasonsProxy.super.initSyncData(self, data)

    local tempData = nil
    if _________isTest_________ then
        tempData = self:getTestData()
    else
        tempData = data.worldGlobalInfo
    end

    self._worldGlobalInfo.worldSeasonOpen = tempData.worldSeasonOpen or SeasonsProxy.Season_Sate_Close
    self:updateSeasonInfo(tempData)

    self._worldGlobalInfo.worldLevelOpen = tempData.worldLevelOpen or SeasonsProxy.World_Sate_Close
    self:updateWorldLevelInfo(tempData)
end

function SeasonsProxy:resetAttr()
    SeasonsProxy.super.resetAttr(self)
end

-- 季节变更倒计时
function SeasonsProxy:updateSeasonInfo(data)
    self._worldGlobalInfo.season = data.season
    self._worldGlobalInfo.remainTimeOfCurSeason = data.remainTimeOfCurSeason
    if self._worldGlobalInfo.worldSeasonOpen == SeasonsProxy.Season_Sate_Open and self._worldGlobalInfo.remainTimeOfCurSeason > 0 then
        self:pushRemainTime(self._remainTimeOfCurSeasonKey, self._worldGlobalInfo.remainTimeOfCurSeason, AppEvent.NET_M48_C480002, nil, self.onTriggerNet480002Req)
    end
    self:sendNotification(AppEvent.PROXY_SEASONS_UPDATE)
end

-- 下次开放等级上限倒计时
function SeasonsProxy:updateWorldLevelInfo(data)
    self._worldGlobalInfo.worldLevel = data.worldLevel
    self._worldGlobalInfo.playerLevelLimit = data.playerLevelLimit
    self._worldGlobalInfo.nextPlayerLevelLimit = data.nextPlayerLevelLimit
    self._worldGlobalInfo.remainTimeOfOpenNextWorld = data.remainTimeOfOpenNextWorld
    if self._worldGlobalInfo.worldLevelOpen == SeasonsProxy.World_Sate_Open and self._worldGlobalInfo.remainTimeOfOpenNextWorld > 0 then
        self:pushRemainTime(self._remainTimeOfOpenNextWorldKey, self._worldGlobalInfo.remainTimeOfOpenNextWorld, AppEvent.NET_M48_C480000, nil, self.onTriggerNet480000Req)
    end
    self:sendNotification(AppEvent.PROXY_SEASONS_UPDATE_WORLDLEVEL)
    self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, { })
end

-- 获得下一个季节的id
function SeasonsProxy:getNextSeason()
    return self:getCurSeason() % 4 + 1
end

-- 获得下当前季节的id
function SeasonsProxy:getCurSeason()
    return self._worldGlobalInfo.season or 0
end

-- 获得当前季节剩余时间
function SeasonsProxy:getRemainTimeOfCurSeason()
    local time = self:getRemainTime(self._remainTimeOfCurSeasonKey)
    return time
end

-- 获取世界等级
function SeasonsProxy:getWorldLevel()
    return self._worldGlobalInfo.worldLevel or 0
end

-- 获取折扣
function SeasonsProxy:getResCoupon()
    local roleProxy = self:getProxy(GameProxys.Role)
    if roleProxy:isFunctionUnLock(52,false) ~= true then
        return 1
    end

    local resCoupon = 0
    local worldLevel = self:getWorldLevel()
    
    local configs = ConfigDataManager:getConfigData(ConfigData.WorldLevelConfig)
    for k,v in pairs(configs) do
        local levels = StringUtils:jsonDecode(v.worldLevel)
        if worldLevel >= levels[1] and worldLevel <= levels[2] then
            resCoupon = v.resCoupon / 10000.0
            return resCoupon
        end
    end
    return resCoupon
end

function SeasonsProxy:getWorldLevelConfigData()
    local worldLevel = self:getWorldLevel()
    local worldLevelConfigData = ConfigDataManager:getInfoFindByFunc(ConfigData.WorldLevelConfig, function(cfgData)
        local ary = StringUtils:jsonDecode(cfgData.worldLevel)
        return ary[1] <= worldLevel and worldLevel <= ary[2]
    end )
    return worldLevelConfigData
end

-- 获得世界玩家等级上限
function SeasonsProxy:getWorldPlayerLevelLimit()
    if self._worldGlobalInfo.playerLevelLimit == nil then
        local cfg = ConfigDataManager:getConfigById(ConfigData.PlayerLvControlConfig, 1)
        return cfg.playerLvMax
    end

    return self._worldGlobalInfo.playerLevelLimit
end

-- 获得世界玩家等级上限
function SeasonsProxy:getNextWorldPlayerLevelLimit()
    if self._worldGlobalInfo.nextPlayerLevelLimit == nil then
        local cfg = ConfigDataManager:getConfigById(ConfigData.PlayerLvControlConfig, 1)
        return cfg.playerLvMax
    end

    return self._worldGlobalInfo.nextPlayerLevelLimit
end

-- 获得下一个开放世界等级的剩余时间
function SeasonsProxy:getRemainTimeOfOpenNextWorld()
    local time = self:getRemainTime(self._remainTimeOfOpenNextWorldKey)
    return time
end

-- 四季系统是否开放
function SeasonsProxy:isWorldSeasonOpen()
    return self._worldGlobalInfo.worldSeasonOpen == SeasonsProxy.Season_Sate_Open
end

-- 世界等级是否开放
function SeasonsProxy:isWorldLevelOpen()
    return self._worldGlobalInfo.worldLevelOpen == SeasonsProxy.World_Sate_Open
end

-- 请求当前世界等级(第一次开放世界等级会推送)
function SeasonsProxy:onTriggerNet480000Req()
    if _________isTest_________ then
        self:onTriggerNet480000Resp( {
            worldLevel = self._worldGlobalInfo.worldLevel + 1,
            playerLevelLimit = self._worldGlobalInfo.playerLevelLimit + 2,
            remainTimeOfOpenNextWorld = 10
        } )
    else
        self:syncNetReq(AppEvent.NET_M48, AppEvent.NET_M48_C480000, { })
    end
end
function SeasonsProxy:onTriggerNet480000Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._worldGlobalInfo.worldLevelOpen = SeasonsProxy.World_Sate_Open
    self:updateWorldLevelInfo(data)

end

-- 请求季节信息(第一次开放季节信息会推送)
function SeasonsProxy:onTriggerNet480002Req()
    if _________isTest_________ then
        self:onTriggerNet480002Resp( {
            season = self:getNextSeason();-- 当前季节 1-春 2-夏 3-秋 4-冬
            remainTimeOfCurSeason = 3;-- 当前季节开始时间
        } )
    else
        self:syncNetReq(AppEvent.NET_M48, AppEvent.NET_M48_C480002, { })
    end
end
function SeasonsProxy:onTriggerNet480002Resp(data)
    self._worldGlobalInfo.worldSeasonOpen = SeasonsProxy.Season_Sate_Open
    self:updateSeasonInfo(data)
end



--------------------------------------------测试数据-----------------------------------------
function SeasonsProxy:getTestData()
    if _________isTest_________ then
        return {
            -- 测试内容 如果服务器有数据过来,就把这段删掉
            worldLevelOpen = 0;-- 世界等级是否开启 0-不开启 1-开启
            worldLevel = 2;-- //当前世界等级
            worldSeasonOpen = 1;-- 世界四季是否开启 0-不开启 1-开启
            season = 1;-- //当前季节 1-春 2-夏 3-秋 4-冬
            remainTimeOfCurSeason = 5;-- //当前季节开始时间
            playerLevelLimit = 5;-- //世界玩家等级上限
            remainTimeOfOpenNextWorld = 50;-- //下一个世界等级开放时间
        }
    else
        return { }
    end
end