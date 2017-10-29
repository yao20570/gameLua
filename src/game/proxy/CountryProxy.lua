-- 国家系统数据代理

CountryProxy = class("CountryProxy", BasicProxy)

-- self:sendNotification(AppEvent.PROXY_EMPEROR_CITY_MAP_CLICK, {})
function CountryProxy:ctor()
    CountryProxy.super.ctor(self)

    self.proxyName = GameProxys.Country


    self._royalInfoMap = {}
    self._prisonInfoMap = {}

    self._prisonInfoList = {}
end

function CountryProxy:initSyncData(data)
	CountryProxy.super.initSyncData(self, data)
end

------
-- 主界面上的雕像信息
function CountryProxy:onTriggerNet560000Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C560000, data)
end

------
-- 皇族界面信息
function CountryProxy:onTriggerNet560001Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C560001, data)
end

------
-- 监狱界面信息
function CountryProxy:onTriggerNet560002Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C560002, data)
end


------
-- 获取同盟所有成员的简要信息
function CountryProxy:onTriggerNet560003Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C560003, data)
end

------
-- 获取玩家单个技能信息数据
function CountryProxy:onTriggerNet560005Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C560005, data)
end

------
-- 使用技能
function CountryProxy:onTriggerNet563004Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C563004, data)
end

-- 使用流放技能
function CountryProxy:onTriggerNet563005Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C563005, data)
end

------
-- 国家信息修改
function CountryProxy:onTriggerNet561000Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C561000, data)
end

------
-- 任命官职
function CountryProxy:onTriggerNet562001Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C562001, data)
end

------
-- 通缉玩家
function CountryProxy:onTriggerNet563001Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C563001, data)
end

------
-- 撤销通缉
function CountryProxy:onTriggerNet563002Req(data)
    self._removePositionId = data.positionId -- 职位ID	
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C563002, data)
end

------
-- 卸任官职
function CountryProxy:onTriggerNet563003Req(data)
    self:syncNetReq(AppEvent.NET_M56, AppEvent.NET_M56_C563003, data)
end


------
-- 皇族界面信息resp
function CountryProxy:onTriggerNet560001Resp(data)
    if data.rs ~= 0 then
        return
    end


    self._royalInfoList = data.royalInfos or {}
    -- 转化为map
    self._royalInfoMap = {}
    for i, infos in pairs(self._royalInfoList) do
        for j, member in pairs(infos.members) do
            local id = member.positionId
            self._royalInfoMap[id] = member
        end
    end

    self:sendNotification(AppEvent.PROXY_COUNTRY_ALL_ROYAL, {})
end

-- 所有皇族、王族信息
function CountryProxy:getRoyalInfoList()
    return self._royalInfoList
end

-- 获取职位列表id2map
function CountryProxy:getRoyalInfoMap()
    return self._royalInfoMap
end

function CountryProxy:getPosInfoById(id)
    return self._royalInfoMap[id]
end



------
-- 监狱界面信息resp
function CountryProxy:onTriggerNet560002Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._prisonInfoList = nil
    --self._prisonInfoList = {}

    self._prisonInfoList = clone(data.prisoners) -- 所有通缉犯的信息
    
    self._prisonInfoMap = nil
    self._prisonInfoMap = {}
    
    -- 转化为map
    for i, prisoner in pairs(self._prisonInfoList) do
        local memberInfo = prisoner.info -- 通缉犯个人信息
        local id = memberInfo.positionId
        self._prisonInfoMap[id] = prisoner

        logger:info("通缉犯名称:"..memberInfo.playerName)
    end

    -- 剩余通缉次数
    self._remainWantedTimes = data.remainWantedTimes

    self:sendNotification(AppEvent.PROXY_COUNTRY_ALL_PRISON, {})
end

-- 所有通缉犯的信息
function CountryProxy:getPrisnerInfoList()
    return self._prisonInfoList
end


-- 获取监狱列表id2map
function CountryProxy:getPrisonInfoMap()
    return self._prisonInfoMap
end

function CountryProxy:getPosPrisonInfoById(id)
    return self._prisonInfoMap[id]
end

-- 剩余通缉次数
function CountryProxy:getRemainWantedTimes()
    return self._remainWantedTimes or 0
end

------
-- 获取同盟所有成员的简要信息resp
function CountryProxy:onTriggerNet560003Resp(data)
    if data.rs ~= 0 then
        return
    end
    self._memberInfoList = data.infos

    self:sendNotification(AppEvent.PROXY_CHOOSE_LEGION_MEMBERS, {})
end

-- 同盟所有成员信息
function CountryProxy:getMemberInfoList()
    return self._memberInfoList or {}
end



------
-- 获取玩家单个技能信息数据Resp
function CountryProxy:onTriggerNet560005Resp(data)
    if data.rs ~= 0 then
        return
    end 

    self._curUseSkillInfo = data.skillInfo
    self:sendNotification(AppEvent.PROXY_COUNTRY_GET_SKILLINFO, {})
end

-- 获取将要使用的技能信息
function CountryProxy:getCurUseSkillInfo()
    return self._curUseSkillInfo
end

------
-- 使用技能Resp
function CountryProxy:onTriggerNet563004Resp(data)
    if data.rs ~= 0 then
        return
    end     

    local positionId = data.positionId   -- 	// 职位ID

    self:getPosPrisonInfoById(positionId).buffInfos = data.buffInfos

--    for i , info in pairs (data.buffInfos) do
--        local skillId    = info.skillId   
--        local remainTime = info.remainTime
--    end

    self:sendNotification(AppEvent.PROXY_COUNTRY_USED_SKILL, {}) 
end



-- 使用流放技能回调
function CountryProxy:onTriggerNet563005Resp(data)
    self:onTriggerNet563004Resp(data)
end

------
-- 国家信息修改resp
function CountryProxy:onTriggerNet561000Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._dynastyName = data.dynastyName -- 朝代名
    self._emperorName = data.emperorName -- 皇帝名

    -- 新状态，有无皇帝
    self._hadEmperor = data.hadEmperor -- 0无,1有

    -- 是否开启
    self._isOpen = data.isOpen -- 国家系统是否开启：0为未开启，1为开启

    -- 回调
    self:sendNotification(AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY, {})
end


-- 获得朝代名
function CountryProxy:getDynastyName()
    return self._dynastyName or ""
end

-- 获得皇帝名
function CountryProxy:getEmperorName()
    return self._emperorName or ""
end

-- 皇帝状态0无,1有
function CountryProxy:getHadEmperor()
    return self._hadEmperor or 0
end

-- 是否开启
function CountryProxy:getIsOpen()
    return self._isOpen or 0
end


-- 皇位战开启，进行重置
function CountryProxy:resetDynastyEmperorName()
    self._dynastyName = ""
    self._emperorName = ""
    self._hadEmperor  = 0 -- 无皇帝
    -- 回调
    self:sendNotification(AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY, {})
end

------
-- 任命官职resp
function CountryProxy:onTriggerNet562001Resp(data)
    if data.rs ~= 0 then
        return
    end
    if data.cdTime == 0 then
        -- 任命成功,刷新数据
        self:showSysMessage( TextWords:getTextWord(560015))
        self._curAppointInfo = data.memberInfo -- 任职成功信息数据

        -- 回调
        self:sendNotification(AppEvent.PROXY_COUNTRY_APPOINT_SUCCEED, {})
    else
        -- 有cd限制
        self:showSysMessage( string.format(TextWords:getTextWord(560014), TimeUtils:getStandardFormatTimeString8(data.cdTime)))
    end
    
end

-- 任职成功返回的数据
function CountryProxy:getCurAppointInfo()
    return self._curAppointInfo 
end 

function CountryProxy:setCurAppointInfo(info)
    self._curAppointInfo = info
end 

------
-- 卸任官职resp
function CountryProxy:onTriggerNet563003Resp(data)
    if data.rs ~= 0 then
        return
    end

    self:showSysMessage( TextWords:getTextWord(560022)) -- "卸任成功"

    -- 本地清空checkPanel信息
    self:setCurAppointInfo(nil)

    self:sendNotification(AppEvent.PROXY_COUNTRY_REMOVE_SUCCEED, {})
end

------
-- 通缉玩家resp
function CountryProxy:onTriggerNet563001Resp(data)
    if data.rs ~= 0 then
        return
    end

    if data.cdTime == 0 then
        -- 通缉成功
        self:showSysMessage( TextWords:getTextWord(560024)) -- 通缉成功

        local prisoner = data.prisoner

        self._curWantedInfo = clone(prisoner.info) -- 通缉成功信息数据
        
        -- 新技能数据组合加入 self._prisonInfoMap
        self._prisonInfoMap[self._curWantedInfo.positionId] = prisoner
        
        -- 剩余通缉次数
        self._remainWantedTimes = data.remainWantedTimes

        -- 回调
        self:sendNotification(AppEvent.PROXY_COUNTRY_WANTED_SUCCEED, {})
    else
        -- 有cd限制
        self:showSysMessage( string.format(TextWords:getTextWord(560023), TimeUtils:getStandardFormatTimeString8(data.cdTime)))
    end
end

-- 通缉成功返回的数据
function CountryProxy:getCurWantedInfo()
    return self._curWantedInfo 
end 

function CountryProxy:setCurWantedInfo(info)
    self._curWantedInfo = info
end 

------
-- 撤销通缉resp
function CountryProxy:onTriggerNet563002Resp(data)
    if data.rs ~= 0 then
        return
    end
    self:showSysMessage( TextWords:getTextWord(560025)) -- "撤销成功"

    -- 清除map，用缓存的posId todocountry
    if self._prisonInfoMap[self._removePositionId] ~= nil then 
        self._prisonInfoMap[self._removePositionId] = nil
    end
    
    -- 本地清空checkPanel信息
    self:setCurWantedInfo(nil)

    -- 剩余通缉次数
    self._remainWantedTimes = data.remainWantedTimes

    self:sendNotification(AppEvent.PROXY_COUNTRY_REMOVE_WANTED, {})
end





----------------------------------------------------------静态数据处理

-- 获取listView1数据
function CountryProxy:getListViewData01()
    local listData = {}
    local configData = ConfigDataManager:getConfigData(ConfigData.CountryPositionConfig)
    for i = 1 , #configData do
        local positionType = configData[i].positionType -- 类型
        if positionType >= 2 and positionType <= 6 then
            table.insert(listData, configData[i])
        end
    end

    listData = TableUtils:splitData(listData, 2)
    return listData
end

-- 获取listView02数据
function CountryProxy:getListViewData02()
    local listData = {}
    local configData = ConfigDataManager:getConfigData(ConfigData.CountryPositionConfig)
    for i = 1 , #configData do
        local positionType = configData[i].positionType -- 类型
        if positionType == 8 then
            table.insert(listData, configData[i])
        end
    end

    return listData
end

-- 获取listView02数据
function CountryProxy:getListViewData03()
    local listData = {}
    local configData = ConfigDataManager:getConfigData(ConfigData.CountryPositionConfig)
    for i = 1 , #configData do
        local positionType = configData[i].positionType -- 类型
        if positionType == 10 then
            table.insert(listData, configData[i])
        end
    end

    return listData
end

-- 顶层位置数据，index对应 group组id
function CountryProxy:getEmperorIdList()
    return {15, 10, 1}
end

-- 获取同盟名字
function CountryProxy:getLegionName(posId)
    for i, infos in pairs(self._royalInfoList) do
        for j, member in pairs(infos.members) do
            local id = member.positionId
            if id == posId then
                return infos.legionName
            end
        end
    end
end

-- 获取监狱表数据
function CountryProxy:getPrisonListData()
    local configData = ConfigDataManager:getConfigData(ConfigData.PrisonPositionConfig)

    local listData = TableUtils:splitData(configData, 4)
    
    return listData
end

------
-- 获取自己的对应权限表
function CountryProxy:getMyPowerStateList(roleName, powerKey)
    local powerList = {}
    for i, royalInfo in pairs(self._royalInfoMap) do
        if royalInfo.playerName == roleName then 
            local configInfo = ConfigDataManager:getConfigById(ConfigData.CountryPositionConfig, royalInfo.positionId)
            powerList = StringUtils:jsonDecode(configInfo[powerKey]) 
            break
        end
    end

    return powerList
end

------
-- 根据名字取职位id，0表示没有
function CountryProxy:getMyPositionId(roleName)
    local positionId = 0 
    for i , royalInfo in pairs(self._royalInfoMap) do
        if royalInfo.playerName == roleName then 
            positionId = royalInfo.positionId
            break
        end
    end
    return positionId
end
