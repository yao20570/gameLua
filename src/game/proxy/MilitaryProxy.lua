--
MilitaryProxy = class("MilitaryProxy", BasicProxy)

function MilitaryProxy:ctor()
    MilitaryProxy.super.ctor(self)
    self.proxyName = GameProxys.Military


end

function MilitaryProxy:initSyncData(data)
	MilitaryProxy.super.initSyncData(self, data)
    
    self._militaryInfos = data.militaryInfo -- 1�����2������3ǹ����4����

    table.sort(self._militaryInfos, 
        function(item01, item02) 
            return item01.type < item02.type
        end
    )

end

------
-- ����
function MilitaryProxy:onTriggerNet510000Req(data)
    self:syncNetReq(AppEvent.NET_M51, AppEvent.NET_M51_C510000, data)
end

------
-- ����
function MilitaryProxy:onTriggerNet510001Req(data)
    self:syncNetReq(AppEvent.NET_M51, AppEvent.NET_M51_C510001, data)
end

------
-- �����󿪷Ź���ʱ����
function MilitaryProxy:onTriggerNet510002Req(data)
    self:syncNetReq(AppEvent.NET_M51, AppEvent.NET_M51_C510002, data)
end

--���ߺϳ�
function MilitaryProxy:onTriggerNet90010Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90010, data)
end

------
-- ���η���
function MilitaryProxy:onTriggerNet510000Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._militaryInfos[data.info.type] = data.info
    
    self:sendNotification(AppEvent.PROXY_MILITARY_UPDATE, {})
end

------
-- ���׷���
function MilitaryProxy:onTriggerNet510001Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._militaryInfos[data.info.type] = data.info

    self:sendNotification(AppEvent.PROXY_MILITARY_UPDATE, {})
end


------
-- �����󿪷Ź���ʱ���ͷ���
function MilitaryProxy:onTriggerNet510002Resp(data)
    self._militaryInfos = data.info --  ��������Ϣ

    table.sort(self._militaryInfos, 
        function(item01, item02) 
            return item01.type < item02.type
        end
    )

end

--�ϳɵ��߷���
function MilitaryProxy:onTriggerNet90010Resp(data)
    self._synthesisRs = data.rs 
end

------
-- ���ݱ��ֵ�type���ͻ�ȡ����
function MilitaryProxy:getMilitaryInfoByType(soldType)
    return self._militaryInfos[soldType]
end

------
-- ���ݱ��ֵ�type���ͻ�ȡ����
function MilitaryProxy:getMilitaryInfos()
    return self._militaryInfos
end

------
-- ���ص�ǰ�׼�
function MilitaryProxy:getSoldierRank(soldierType)
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    return militaryInfo.rank
end

-------
-- ��ȡ����ĵ�ǰ����
function MilitaryProxy:getCurAttriTable(soldierType)
    local textShow = {}
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local segment = militaryInfo.segment -- ���� 
    local level   = militaryInfo.level   -- �ȼ�
    local rank    = militaryInfo.rank    -- ����
    
    local configInfo
    if rank == 1 and level == 0 then
        logger:info("��ǰû�����Լӳ�")
    else
        if level == 0 then
            local maxLevel = self:getMaxLevelByType(soldierType, rank - 1)
            configInfo = self:getLevelConfigInfo(soldierType, maxLevel, rank - 1) -- ȡ��һ����߼�
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
        local attriType = value[3]  -- ��������
        local attriValue = value[4] -- ����ֵ
        if textShow[attriType] == nil then
            textShow[attriType] = attriValue
        else
            textShow[attriType] = textShow[attriType] + attriValue
        end
    end
    return textShow 
end


------
-- ��ȡ��һ�����Բ�ֵ��
function MilitaryProxy:getDiffAttriTable(soldierType)
    local curAttriTable = self:getCurAttriTable(soldierType) -- ��ǰ���Ա�

    local diffShow = {} -- ���Բ����
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local level   = militaryInfo.level   -- �ȼ�
    local rank    = militaryInfo.rank    -- ����
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
-- ��ȡ������ֵ
function MilitaryProxy:getAllLastCtrlNum()
    local lastCtrl = 0
    local militaryInfos = self:getMilitaryInfos() 
    
    for soldierType, info in pairs(militaryInfos) do
        local rank    = info.rank    -- ����
        local configInfo = self:getRankConfiInfo(soldierType, rank) -- ��ǰrank
        local property = StringUtils:jsonDecode(configInfo.property) 
        for k, v in pairs(property) do
            if v[3] == 46 then -- ���� 
                lastCtrl = lastCtrl + v[4]
            end
        end
    end
    return lastCtrl
end


-------
-- ��һ�׼ӳɵĺ��ã�����ֵ
function MilitaryProxy:getNextLastCtrlByType(soldierType)
    local curLastCtrl = self:getAddingLastCtrlByType(soldierType) -- ��ǰ���ͼӳ�

    local nextLastCtrl = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local rank = militaryInfo.rank + 1
    local configInfo = self:getRankConfiInfo(soldierType, rank)

    if configInfo == nil then
        nextLastCtrl = curLastCtrl
    else
        local property = StringUtils:jsonDecode(configInfo.property) 
        for k, v in pairs(property) do
            if v[3] == 46 then -- ���� 
                nextLastCtrl = nextLastCtrl + v[4]
            end
        end
    end

    nextLastCtrl = nextLastCtrl - curLastCtrl
    return nextLastCtrl
end

------
-- ��ǰ���ͼӳɵĺ���
function MilitaryProxy:getAddingLastCtrlByType(soldierType)
    local typeLastCtrl = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)

    local rank = militaryInfo.rank -- ��ǰ�Ľ׼�

    local configInfo = self:getRankConfiInfo(soldierType, rank)
    local property = StringUtils:jsonDecode(configInfo.property) 
    for k, v in pairs(property) do
        if v[3] == 46 then -- ���� 
            typeLastCtrl = typeLastCtrl + v[4]
        end
    end

    return typeLastCtrl
end


------
-- ��ǰ�׼��Ķ�Ӧ��������
function MilitaryProxy:getMaxStagePosByType(soldierType)
    local maxStagePos = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local rank = militaryInfo.rank -- ��ǰ�Ľ׼�
    local configInfo = ConfigDataManager:getConfigById(ConfigData.MilitaryInstituteConfig, rank)
    return configInfo.segment
end

------
-- ��ǰ�׼��Ķ�Ӧ�ȼ�����
function MilitaryProxy:getMaxLevelByType(soldierType, rankNum)
    local maxStagePos = 0
    local militaryInfo = self:getMilitaryInfoByType(soldierType)
    local rank = militaryInfo.rank -- ��ǰ�Ľ׼�
    if rankNum ~= nil then
        rank = rankNum
    end
    local configInfo = ConfigDataManager:getConfigById(ConfigData.MilitaryInstituteConfig, rank)
    return configInfo.levelMax
end


------
-- ��ȡͼƬ��id
-- ���� + �׼� + ��ʾ 
-- ���� + 46 + ��0/��1 + ��ʾ
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
-- ����1�� ����2�� ����3�����ж�
function MilitaryProxy:getActionStateByType(soldierType)
    local actionType 
    local militaryInfo = self:getMilitaryInfoByType(soldierType)

    local maxStagePos = self:getMaxStagePosByType(soldierType) -- ������

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




















