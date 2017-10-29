-- 盟战数据代理
CityWarProxy = class("CityWarProxy", BasicProxy)

function CityWarProxy:ctor()
    CityWarProxy.super.ctor(self)
    self.proxyName = GameProxys.CityWar


    self._cityWarInfoMap = {} -- 所有的州城配置数据 


    self._battleReportMap = {} -- 州城全服战报表
    self._spareTeamMap = {} -- 州城空闲队伍表


    self._configMap = {} -- 以"x_y"为key的配置表
    self._configNameMap = {} -- 以"stateName"为key的配置表

    self:setConfigMap()
    self:setConfigNameMap()
end

function CityWarProxy:initSyncData(data)
	CityWarProxy.super.initSyncData(self, data)

    
end

------
-- 查看州城
function CityWarProxy:onTriggerNet470000Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470000, data)
end

------
-- 盟城宣战
function CityWarProxy:onTriggerNet470100Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470100, data)
end




------
-- 请求该州的全服战报 上次的战斗结果
function CityWarProxy:onTriggerNet470002Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470002, data)
end

------
-- 请求空闲队伍
function CityWarProxy:onTriggerNet470003Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470003, data)
end

------
-- 请求州排名
function CityWarProxy:onTriggerNet470005Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470005, data)
end

------
-- 请求州城信息
function CityWarProxy:onTriggerNet470006Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470006, data)
end

------
-- 请求州的贸易信息
function CityWarProxy:onTriggerNet470007Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470007, data)
end

------
-- 请求兑换
function CityWarProxy:onTriggerNet470009Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470009, data)
end

------
-- 请求天下大势信息
function CityWarProxy:onTriggerNet470201Req(data)
    self:syncNetReq(AppEvent.NET_M47, AppEvent.NET_M47_C470201, data)
end


------
-- 查看州城返回
function CityWarProxy:onTriggerNet470000Resp(data)
    if data.rs ~= 0 then
        return
    end
    self._townInfo       = data.townInfo        -- 盟城信息
    
    self:pushRemainTime(self:getKey(self:getTownId()), 0) -- 只保留一个时间

    self._nextStateTime  = data.nextStateTime   -- 下一个状态的剩余时间 目前只有2 4有值
    self._marchTime      = data.marchTime       -- 行军时间
    self._townLegionList = data.townLegionList  -- 宣战军团信息 非归属盟的弹窗   repeated
    self._buffIdList     = data.buffIdList      -- 洲城增益Buff 归属盟弹窗       repeated
    self._debuffId       = data.deBuffId        -- 洲城减益buffoptional
    self._fightBuffIdList= data.fightBuffIdList -- 战斗生效的buff
    self._teamInfo       = data.teamInfo        -- 盟城相关队伍简要信息
    self._minAttackCapacity = data.minAttackCapacity -- 部队出战最低战力
    self._minWarOnCapacity  = data.minWarOnCapacity -- 部队宣战最低战力
    -- 存时间
    if self._nextStateTime >= 0 then
        self:pushRemainTime(self:getKey(self:getTownId()), self._nextStateTime, 470000, nil, self.timeEndCall)
        logger:info("记录时间：".. self._nextStateTime)
    end

    -- 重要参数，设置索引key
    self._townKey = self._townInfo.x.."_"..self._townInfo.y

    self:sendNotification(AppEvent.PROXY_WARCITY_UPDATE, {})
end


-- 盟城信息
--message TownInfo{  //盟城信息
--	required int32 townId = 1;//州城id
--	required string legionName = 2;//军团名字
--	required int32 x = 3; // x坐标
--	required int32 y = 4; // y坐标
--	optional int32 townStatus = 5;//状态 0未开放1可宣战时期2宣战（可派兵）期间3开战期间4保护期间5休战期间
--}
function CityWarProxy:getTownInfo()
    return self._townInfo
end

-- 获取州城id
function CityWarProxy:getTownId()
    local id
    if self._townInfo ~= nil then
        id = self._townInfo.townId
    else
        id = 0
    end
    return id
end

-- 下个状态剩余时间
function CityWarProxy:getNextStateTime()
    return self._nextStateTime
end

-- 行军时间
function CityWarProxy:getMarchTime()
    return self._marchTime
end

-- 宣战军团信息 repeated
--message WorldTownLegion{//宣战军团信息
--	optional fixed64 legionId = 1;//宣战军团Id
--	optional string legionName = 2;//军团名字
--}
function CityWarProxy:getTownLegionList()
    return self._townLegionList
end

-- 洲城增益Buff repeated
function CityWarProxy:getBuffIdList()
    return self._buffIdList
end

-- 郡城减益buff，
function CityWarProxy:getDebuffId()
    return self._debuffId
end

-- 战斗生效的buff
function CityWarProxy:getFightBuffIdList()
    return self._fightBuffIdList
end

-- 队伍简要信息
function CityWarProxy:getTeamInfo()
    return self._teamInfo
end

-- 部队出战最低战力
function CityWarProxy:getMinAttackCapacity()
    return self._minAttackCapacity
end

-- 部队宣战最低战力
function CityWarProxy:getMinWarOnCapacity()
    return self._minWarOnCapacity

end



------
-- 盟城宣战resp
function CityWarProxy:onTriggerNet470100Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._townInfo.townId     = data.townId   -- id
    self._townInfo.townStatus = data.townStatus -- 成功后，下发的状态
    self._nextStateTime       = data.nextStateTime -- 下一个状态的剩余时间
    self._townLegionList      = data.townLegionList -- 宣战同盟信息列表
    self._teamInfo            = data.teamInfo        -- 盟城相关队伍简要信息

    -- 存时间
    if self._nextStateTime >= 0 then
        self:pushRemainTime(self:getKey(self:getTownId()), self._nextStateTime, 470000,  nil, self.timeEndCall)
        logger:info("记录时间：".. self._nextStateTime)
    end

    self:sendNotification(AppEvent.PROXY_WARCITY_UPDATE, {x = self._townInfo.x, y = self._townInfo.y})
    -- "宣战成功"
    self:showSysMessage(TextWords:getTextWord(471028)) 
end



------
-- 请求该州的全服战报 上次的战斗结果resp
function CityWarProxy:onTriggerNet470002Resp(data)
    if data.rs ~= 0 then
        return
    end
    local reportInfo = {}
    reportInfo.townId  = data.townId -- 州城id
    reportInfo.x       = data.x      --x坐标
    reportInfo.y       = data.y      -- y坐标
    reportInfo.endTime = data.endTime--结束时间
    reportInfo.result  = data.result --战斗结果 1进攻胜利  2防守胜利
    reportInfo.townFightInfoList = data.townFightInfoList -- 同盟的队伍列表，攻击、防守队伍
   
    reportInfo.winLegionName  = data.winLegionName -- 本次胜利的盟，空的话证明打不过npc
    reportInfo.attackTeamNum  = data.attackTeamNum   -- 攻击参战的队伍数
	reportInfo.attackTotalNum = data.attackTotalNum  -- 攻击总队伍数
	reportInfo.defendTeamNum  = data.defendTeamNum   -- 防守参战的队伍数
	reportInfo.defendTotalNum = data.defendTotalNum  -- 防守总队伍数

    reportInfo.defendIsMonster = data.defendIsMonster -- 0否 1是守军是否为怪物，用来iv. 守方是NPC时，按钮灰色不能点击

    -- 攻击和防守队伍
    reportInfo.attackTeamList = data.attackTeamList
    reportInfo.defendTeamList = data.defendTeamList

    -- 
    reportInfo.attackIdleTeamList = data.attackIdleTeamList
    reportInfo.defendIdleTeamList = data.defendIdleTeamList

    -- 倒序
    reportInfo.townFightInfoList = table.reverseList(reportInfo.townFightInfoList)
    reportInfo.attackTeamList    = table.reverseList(reportInfo.attackTeamList)
    reportInfo.defendTeamList    = table.reverseList(reportInfo.defendTeamList)

    local key = data.x.."_"..data.y
    self._battleReportMap[data.townId] = reportInfo -- 将数据存储到战报表里, 已id做key

    -- 刷新战报界面回调
    self:sendNotification(AppEvent.PROXY_WARCITY_BATTLE_REPORT, {}) -- 获取全服战报
end

-- 获取战报数据
function CityWarProxy:getBattleReportInfo(key)
    local info = nil 
    if self._battleReportMap[key] then
        info = self._battleReportMap[key]
    end
    return info 
end



------
-- 请求空闲队伍resp
function CityWarProxy:onTriggerNet470003Resp(data)
    if data.rs ~= 0 then
        return 
    end
    local spareTeamInfo = {}
    spareTeamInfo.teamInfoList = data.teamInfoList -- 成员列表

    self._spareTeamMap[self._townKey] = spareTeamInfo.teamInfoList

    self:sendNotification(AppEvent.PROXY_WARCITY_SPARE_TEAM, {})
end

-- 获取空闲队伍数据
function CityWarProxy:getSpareTeamInfo(key)
    local info = nil 
    if self._spareTeamMap[key] then
        info = self._spareTeamMap[key]
    end
    return info 
end



------
-- 请求州排名resp
function CityWarProxy:onTriggerNet470005Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._townRankInfoList = {}
    self._townRankInfoList = data.townRankInfoList
--    for i = 1, #self._townRankInfoList do
--        logger:info(self._townRankInfoList[i].rank)
--        logger:info(self._townRankInfoList[i].legionName)
--    end

    -- 网络回调
    self:sendNotification(AppEvent.PROXY_WARCITY_TOWN_RANK, {})
end

-- 获取州排名信息
function CityWarProxy:getTownRankInfoList()
    return self._townRankInfoList
end



------
-- 请求州城信息resp
function CityWarProxy:onTriggerNet470006Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._townInfoList = data.townInfoList

    self._warOnRemainTimes = data.remainTimes -- 当前剩余宣战次数
    self._warOnMaxTimes = data.maxTimes -- 最大宣战次数

    -- 回调
    self:sendNotification(AppEvent.PROXY_WARCITY_TOWN_MINE, {})
end

function CityWarProxy:getTownInfoList()
    return self._townInfoList
end

function CityWarProxy:getWarOnRemainTimes()
    return self._warOnRemainTimes
end

function CityWarProxy:getWarOnMaxTimes()
    return self._warOnMaxTimes
end

------
-- 请求州的贸易信息
function CityWarProxy:onTriggerNet470007Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._exchangeInfoList = data.exchangeInfoList -- 兑换列表信息
    --self._tradeNum = data.tradeNum --  剩余贸易兑换券
    self._curTownTradeNum = data.curTownTradeNum -- 当前盟城的可贸易次数
    self._maxTownTradeNum = data.maxTownTradeNum -- 当前盟城的最大贸易次数

    -- 回调
    self:sendNotification(AppEvent.PROXY_WARCITY_TOWN_TRADE, {})
end

-- 剩余贸易兑换券
function CityWarProxy:getTradeNum()
    -- 改为道具数量获取
    local roleProxy = self:getProxy(GameProxys.Role)
    local tradeNum = roleProxy:getRolePowerValue(GamePowerConfig.Item, 4402)
    return tradeNum
end

function CityWarProxy:getExchangeInfoList()
    return self._exchangeInfoList
end

function CityWarProxy:getCurTownTradeNum()
    return self._curTownTradeNum
end

function CityWarProxy:getMaxTownTradeNum()
    return self._maxTownTradeNum
end


------
-- 请求兑换
function CityWarProxy:onTriggerNet470009Resp(data)
    if data.rs ~= 0 then
        return 
    end
    --self._tradeNum = data.tradeNum -- 兑换列表信息
    self._curTownTradeNum = data.curTownTradeNum -- 当前盟城的可贸易次数
    self._maxTownTradeNum = data.maxTownTradeNum -- 当前盟城的最大贸易次数
    -- 兑换回调
    self:sendNotification(AppEvent.PROXY_WARCITY_TOWN_TRADE_END, {})
end

------
-- 郡城小红点推送
function CityWarProxy:onTriggerNet470200Resp(data)
    self._myTownRedPoint = data.num
    self:sendNotification(AppEvent.PROXY_WARCITY_RED_POINT, {})
end

-- 获取郡城小红点数量
function CityWarProxy:getMyTownRedPoint()
    return self._myTownRedPoint or 0
end

------
-- 请求天下大势信息
function CityWarProxy:onTriggerNet470201Resp(data)
    self._townStateInfoList = data.townStateInfoList
    self:sendNotification(AppEvent.PROXY_WARCITY_MINI_FLAG, {})
end

-- 获取天下大势信息
function CityWarProxy:getTownStateList()
    return self._townStateInfoList
end








function CityWarProxy:getTownKey()
    return self._townKey
end

------
-- 根据id获取configInfo
function CityWarProxy:getTownConfigInfoById(id)
    local configInfo = ConfigDataManager:getConfigById(ConfigData.TownWarConfig, id)
    return configInfo
end

-----
-- 根据字段获取configValue
function CityWarProxy:getTownConfigValue(id, key)
    return self:getTownConfigInfoById(id).key
end


------
-- 请求重播
function CityWarProxy:onTriggerNet160005Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end



function CityWarProxy:getToGoalTime( cityPosX, cityPosY)
    local rolePrxoy = self:getProxy(GameProxys.Role)
    local beginX, beginY = rolePrxoy:getWorldTilePos()
    local time = rolePrxoy:calcNeedTime(RoleProxy.MarchingType_Town, beginX, beginY, cityPosX, cityPosY)
    return time
end

-- 设置获取的州城配置数据表
function CityWarProxy:setCityWarInfo(key, value)
    self._cityWarInfoMap[key] = value
end

-- 以获取的州城配置数据表
function CityWarProxy:getCityWarInfo(key)
    return self._cityWarInfoMap[key]
end

function CityWarProxy:getKey(id)
    return "cityWarProxy"..id
end

-- 状态时间回调的函数
function CityWarProxy:timeEndCall()
    local data = {}
    data.x = self._townInfo.x
    data.y = self._townInfo.y

    -- 刷新郡城打开界面
    local function delayReq()
       self:onTriggerNet470000Req(data)  
    end

    TimerManager:addOnce(500, delayReq, self)

    -- 清空定时器
    self:pushRemainTime(self:getKey(self:getTownId()), 0)
end

function CityWarProxy:setConfigMap()
    local config = ConfigDataManager:getConfigData(ConfigData.TownWarConfig)
    for key, info in pairs(config) do
        self._configMap[info.dataX.."_"..info.dataY] = info
    end
end

function CityWarProxy:getConfigByMapKey(mapKey)
    return self._configMap[mapKey]
end

function CityWarProxy:setConfigNameMap()
    local config = ConfigDataManager:getConfigData(ConfigData.TownWarConfig)
    for key, info in pairs(config) do
        self._configNameMap[info.stateName] = info
    end
end


function CityWarProxy:getPosInfoByContext(context)
    local posInfo = {}

    local strTable = loadstring("return "..context)()
    local configInfo = self._configNameMap[strTable[1].txt]
    if configInfo ~= nil then
        posInfo.x = configInfo.dataX
        posInfo.y = configInfo.dataY
    end

    if posInfo.x == nil then
        posInfo = nil
    end
    return posInfo
end


-------
-- 组合战斗buff数据表
function CityWarProxy:getFightBuffStringList(fightBuffListConfig)
    -- self._fightBuffIdList

    local configData = ConfigDataManager:getConfigData(ConfigData.TownWarFightBuffConfig)
    
    local buffStringList = {}
    for i = 1, #fightBuffListConfig do
        local fightBuffId = fightBuffListConfig[i]
        local buffInfoTable = StringUtils:jsonDecode(configData[fightBuffId].buffInfo)
        
        local withStr = buffInfoTable[1]..buffInfoTable[2]
        


        for index, str in pairs (buffInfoTable) do
            local buffStr = {}
            buffStr.str = str
            buffStr.fightBuffId = fightBuffId
            table.insert(buffStringList, buffStr)
        end
        -- 添加空白行
        if i ~= #fightBuffListConfig then
            for count = 1, 2 do
                local buffStr = {}
                buffStr.str = ""
                buffStr.fightBuffId = fightBuffId
                table.insert(buffStringList, buffStr)
            end
        end
    end
    return buffStringList
end



-------
-- 组合战斗buff数据表
function CityWarProxy:getFightBuffStringList2(fightBuffListConfig)
    -- self._fightBuffIdList

    local configData = ConfigDataManager:getConfigData(ConfigData.TownWarFightBuffConfig)
    
    local buffStringList = {}
    for i = 1, #fightBuffListConfig do
        local fightBuffId = fightBuffListConfig[i]
        local buffContext = configData[fightBuffId].buffInfo


        local buffStr = {}
        buffStr.str = buffContext
        buffStr.fightBuffId = fightBuffId
        table.insert(buffStringList, buffStr)
    end
    return buffStringList
end


