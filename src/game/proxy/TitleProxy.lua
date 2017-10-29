TitleProxy = class("TitleProxy", BasicProxy)

--message TitleInfo{   //��ҳƺ�
--  optional int32 id =1;      //�ƺ�id
--	optional int32 time =2;   //����ʱ���
--	optional int32 use =3;//δʹ�ã�1ʹ��
--}

function TitleProxy:ctor()
    TitleProxy.super.ctor(self)
    self.proxyName = GameProxys.Title
    self._titleInfos = {}
    self._titleConfig = {}
    self._titleConfig = self:getTitleConfigData() -- ���ñ�
end


function TitleProxy:initSyncData(data) --2��Э��
    local titleInfos = data.titleInfos -- //�ƺ���Ϣ

    self._titleInfos = self:setDataWithConfig(titleInfos)
end


------
-- M20802 �ƺ�ѡ��
function TitleProxy:onTriggerNet20802Req(changeId)
    -- ѡ���id
    local data = {}
--    data.useIds = {}
--    table.insert(data.useIds, changeId)
    data.id = changeId
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20802, data)
end

------
-- M20802 �ƺ�ѡ��
-- �ͻ����Լ������ݸ��´���
function TitleProxy:onTriggerNet20802Resp(data)
    self._titleInfos[data.id].use = data.use
    -- �ص���������ˢ��
    self:sendNotification(AppEvent.PROXY_TITLE_CHANGE, {})
end

------
-- M20800{  //������������ͣ��ƺŸ���
-- ֻ�гƺŻ��ʱ���·�, ȫ���ĳƺ��б�
function TitleProxy:onTriggerNet20800Resp(data)
    local titleInfos = data.titleInfos -- //�ƺ���Ϣ

    self._titleInfos = self:setDataWithConfig(titleInfos)
    -- �ص���������ˢ��
    self:sendNotification(AppEvent.PROXY_TITLE_ADD_GOT, {})
end



--------------------------------------------------------------------------
-- ��ȡ�ƺ���Ϣ
function TitleProxy:getTitleInfos()
    
    return self._titleInfos 

end


-- ��ȡ�ƺ����ñ�,��IDΪkey
function TitleProxy:getTitleConfigData()
    local titleTable = {}
    local configData = ConfigDataManager:getConfigData( ConfigData.TitleConfig)
    for key, info in pairs( configData) do
        local t = {}
        t.id      = info.id     
        t.type    = info.type   
        t.title   = info.title  
        t.titleLv = info.titleLv

        titleTable[info.ID] = t
    end

    return titleTable
end

-- �������ñ�����ܱ�
function TitleProxy:setDataWithConfig(titleInfos)
    local allTable = {}
    for ID, configInfo in pairs(self._titleConfig) do
        local t = {}
        t.id   = ID
        t.time = 0
        t.use  = 0
        allTable[ID] = t
    end
         
    for k, v in pairs(titleInfos) do
        local t = {}
        t.id   = v.id  
        t.time = v.time -- - os.time()  -- ��Ϊ��ʣ�൹��ʱ
        t.use  = v.use
        allTable[v.id] = t
        local key = self:getKey(v.id)
        self:pushRemainTime(key, t.time, 390000, v.id, self.timeEndCall);
    end

    return allTable
end

-- ��ȡ��ǰʹ�óƺ��б�
function TitleProxy:getMyUsingTitle()
    local temp = {}
    for k, v in pairs(self._titleInfos) do
        if v.use == 1 then
            table.insert(temp, v.id)
        end
    end
    return temp
end

function TitleProxy:getKey(id)
    return "title_proxy_"..id
end

function TitleProxy:timeEndCall(params)
    local key = self:getKey(params[1])
    self._remainTimeMap[key] = nil
    local id = params[1] -- �����id
    self._titleInfos[id].time = 0
    self._titleInfos[id].use  = 0
    -- �ص���������ˢ��
    self:sendNotification(AppEvent.PROXY_TITLE_CHANGE, {})
end