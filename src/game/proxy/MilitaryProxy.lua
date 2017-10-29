--
MilitaryProxy = class("MilitaryProxy", BasicProxy)

function MilitaryProxy:ctor()
    MilitaryProxy.super.ctor(self)
    self.proxyName = GameProxys.Military


end

function MilitaryProxy:initSyncData(data)
	MilitaryProxy.super.initSyncData(self, data)
    
    self._militaryInfos = data.militaryInfo -- 1骑兵，2刀兵，3枪兵，4弓兵

    table.sort(self._militaryInfos, 
        function(item01, item02) 
            return item01.type < item02.type
        end
    )

end

------
-- 升段
function MilitaryProxy:onTriggerNet510000Req(data)
    self:syncNetReq(AppEvent.NET_M51, AppEvent.NET_M51_C510000, data)
end

------
-- 升阶
function MilitaryProxy:onTriggerNet510001Req(data)
    self:syncNetReq(AppEvent.NET_M51, AppEvent.NET_M51_C510001, data)
end

------
-- 升级后开放功能时推送
function MilitaryProxy:onTriggerNet510002Req(data)
    self:syncNetReq(AppEvent.NET_M51, AppEvent.NET_M51_C510002, data)
end

--道具合成
function MilitaryProxy:onTriggerNet90010Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90010, data)
end

------
-- 升段返回
function MilitaryProxy:onTriggerNet510000Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._militaryInfos[data.info.type] = data.info
    
    self:sendNotification(AppEvent.PROXY_MILITARY_UPDATE, {})
end

------
-- 升阶返回
function MilitaryProxy:onTriggerNet510001Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._militaryInfos[data.info.type] = data.info

    self:sendNotification(AppEvent.PROXY_MILITARY_UPDATE, {})
end


------
-- 升级后开放功能时推送返回
function MilitaryProxy:onTriggerNet510002Resp(data)
    self._militaryInfos = data.info --  军工所信息

    table.sort(self._militaryInfos, 
        function(item01, item02) 
            return item01.type < item02.type
        end
    )

end

--合成道具返回
function MilitaryProxy:onTriggerNet90010Resp(data)
    self._synthesisRs = data.rs 
end

------
-- 根据兵种的type类型获取数据
function MilitaryProxy:getMilitaryInfoByType(soldType)
    return self._militaryInfos[soldType]
end

------
-- 根据兵种的type类型获取数据
function MilitaryProxy:getMilitaryInfos()
    return self._militaryInfos
end

------
-- 返回当前阶级
function MilitaryProxy:getSoldierRank(soldierType)
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    return militaryInfo.rank
end

-------
-- 获取该项的当前属性
function MilitaryProxy:getCurAttriTable(soldierType)
    local textShow = {}
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local segment = militaryInfo.segment -- 段数 
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数
    
    local configInfo
    if rank == 1 and level == 0 then
        logger:info("当前没有属性加成")
    else
        if level == 0 then
            local maxLevel = self:getMaxLevelByType(soldierType, rank - 1)
            configInfo = self:getLevelConfigInfo(soldierType, maxLevel, rank - 1) -- 取上一阶最高级
        else        
            configInfo = self:getLevelConfigInfo(soldierType, level, rank)
        end
        textShow = self:getAttriTableByConfigInfo(configInfo)
    end
    
    return textShow
end

function MilitaryProxy:getAttriTableByConfigInfo(configInfo)
    local property = StringUtils:jsonDecode(configInfo.property)
    local textShow = {}
    for index, value in pairs(property) do
        local attriType = value[3]  -- 属性类型
        local attriValue = value[4] -- 属性值
        if textShow[attriType] == nil then
            textShow[attriType] = attriValue
        else
            textShow[attriType] = textShow[attriType] + attriValue
        end
    end
    return textShow 
end


------
-- 获取下一级属性差值表
function MilitaryProxy:getDiffAttriTable(soldierType)
    local curAttriTable = self:getCurAttriTable(soldierType) -- 当前属性表

    local diffShow = {} -- 属性差异表
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数
    local configInfo = self:getLevelConfigInfo(soldierType, level + 1, rank)
    if configInfo ~= nil then
        local nextShow = self:getAttriTableByConfigInfo(configInfo)
        for attriType, value in pairs(nextShow) do
            local curValue = curAttriTable[attriType] and curAttriTable[attriType] or 0
            diffShow[attriType] = value - curValue
        end
    end

    return diffShow
end


function MilitaryProxy:getRankConfiInfo(soldierType, rank)
    return ConfigDataManager:getInfoFindByTwoKey(ConfigData.MilitaryInstituteConfig, "type", soldierType, "rank", rank)
end

function MilitaryProxy:getLevelConfigInfo(soldierType, level, rank)
    return ConfigDataManager:getInfoFindByThreeKey(ConfigData.MilitaryLevelConfig , "type", soldierType, "level", level, "rank", rank)
end


------
-- 获取后置总值
function MilitaryProxy:getAllLastCtrlNum()
    local lastCtrl = 0
    local militaryInfos = self:getMilitaryInfos() 
    
    for soldierType, info in pairs(militaryInfos) do
        local rank    = info.rank    -- 阶数
        local configInfo = self:getRankConfiInfo(soldierType, rank) -- 当前rank
        local property = StringUtils:jsonDecode(configInfo.property) 
        for k, v in pairs(property) do
            if v[3] == 46 then -- 后制 
                lastCtrl = lastCtrl + v[4]
            end
        end
    end
    return lastCtrl
end


-------
-- 下一阶加成的后置，差异值
function MilitaryProxy:getNextLastCtrlByType(soldierType)
    local curLastCtrl = self:getAddingLastCtrlByType(soldierType) -- 当前类型加成

    local nextLastCtrl = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local rank = militaryInfo.rank + 1
    local configInfo = self:getRankConfiInfo(soldierType, rank)

    if configInfo == nil then
        nextLastCtrl = curLastCtrl
    else
        local property = StringUtils:jsonDecode(configInfo.property) 
        for k, v in pairs(property) do
            if v[3] == 46 then -- 后制 
                nextLastCtrl = nextLastCtrl + v[4]
            end
        end
    end

    nextLastCtrl = nextLastCtrl - curLastCtrl
    return nextLastCtrl
end

------
-- 当前类型加成的后置
function MilitaryProxy:getAddingLastCtrlByType(soldierType)
    local typeLastCtrl = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)

    local rank = militaryInfo.rank -- 当前的阶级

    local configInfo = self:getRankConfiInfo(soldierType, rank)
    local property = StringUtils:jsonDecode(configInfo.property) 
    for k, v in pairs(property) do
        if v[3] == 46 then -- 后制 
            typeLastCtrl = typeLastCtrl + v[4]
        end
    end

    return typeLastCtrl
end


------
-- 当前阶级的对应段数上限
function MilitaryProxy:getMaxStagePosByType(soldierType)
    local maxStagePos = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local rank = militaryInfo.rank -- 当前的阶级
    local configInfo = ConfigDataManager:getConfigById(ConfigData.MilitaryInstituteConfig, rank)
    return configInfo.segment
end

------
-- 当前阶级的对应等级上限
function MilitaryProxy:getMaxLevelByType(soldierType, rankNum)
    local maxStagePos = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local rank = militaryInfo.rank -- 当前的阶级
    if rankNum ~= nil then
        rank = rankNum
    end
    local configInfo = ConfigDataManager:getConfigById(ConfigData.MilitaryInstituteConfig, rank)
    return configInfo.levelMax
end


------
-- 获取图片的id
-- 类型 + 阶级 + 显示 
-- 类型 + 46 + 尖0/方1 + 显示
function MilitaryProxy:getStagePosImgId(type, rank, lightState, i)
    local id 
    if rank ~= 4 and rank ~= 6 then
        id = type..rank..lightState 
    end
    if rank == 4 then
        if i < 5 then
            id = type.. 46 .. 1 .. lightState
        else
            id = type.. 46 .. 0 .. lightState
        end
    end
    if rank == 6 then
        if i < 6 then
            id = type.. 46 .. 1 .. lightState
        else
            id = type.. 46 .. 0 .. lightState
        end
    end
    return id
end


------
-- 升段1， 升级2， 升阶3操作判断
function MilitaryProxy:getActionStateByType(soldierType)
    local actionType 
    local militaryInfo = self:getMilitaryInfoByType(soldierType)

    local maxStagePos = self:getMaxStagePosByType(soldierType) -- 最大段数

    local maxLevel = self:getMaxLevelByType(soldierType)
    if militaryInfo.level == maxLevel then
        actionType = 3
    end

    if militaryInfo.level ~= maxLevel  and militaryInfo.segment + 1 == maxStagePos then 
        actionType = 2
    end

    if militaryInfo.level ~= maxLevel  and militaryInfo.segment + 1 ~= maxStagePos then
        actionType = 1
    end

    return actionType
end


function MilitaryProxy:getAllMilitaryAttri()
    local allMilitaryAttri = {}
    for i = 1, 4 do
        local thisTypeAttri = self:getCurAttriTable(i)
        for key, value in pairs(thisTypeAttri) do
            if allMilitaryAttri[key] == nil then
                allMilitaryAttri[key] = value
            else
                allMilitaryAttri[key] = allMilitaryAttri[key] + value
            end
        end
    end
    return allMilitaryAttri
end




















