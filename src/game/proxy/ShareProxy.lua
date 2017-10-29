

ShareProxy = class("ShareProxy", BasicProxy)

function ShareProxy:ctor()
    ShareProxy.super.ctor(self)
    self.proxyName = GameProxys.Share
    
    self._shareDataMap = {}
    
    self._shareDataMap[1] = {}
    self._shareDataMap[2] = {}
end

function ShareProxy:resetAttr()
    self._shareDataMap = {}
end

function ShareProxy:registerNetEvents( )
end

function ShareProxy:unregisterNetEvents()
end

function ShareProxy:onTriggerNet250000Resp(data)
    self:onShareInfoResp(data)
end

function ShareProxy:shareInfoReq(data)
    self:syncNetReq(AppEvent.NET_M25, AppEvent.NET_M25_C250000, data)
end

function ShareProxy:onShareInfoResp(data)
    if data.rs == 0 then
        local shareType = data.shareType
        local type = data.type
        local id = string.format("%s", tostring(data.id))


        if self._shareDataMap[shareType] == nil then
            self._shareDataMap[shareType] = {}
        end
        
        if self._shareDataMap[shareType][type] == nil then
            self._shareDataMap[shareType][type] = {}
        end

        local shareInfo

        if type == ChatShareType.SOLDIRE_TYPE then
            id = tostring(data.typeId)
            self._shareDataMap[shareType][type][id] = data.soldierInfo
            shareInfo = data.soldierInfo
        elseif type == ChatShareType.REPORT_TYPE then
            self._shareDataMap[shareType][type][id] = data.reportInfo
            shareInfo = data.reportInfo
        elseif type == ChatShareType.ARENA_TYPE then
            self._shareDataMap[shareType][type][id] = data.areanInfo
            shareInfo = data.areanInfo
        elseif type == ChatShareType.RECRUIT_TYPE then
            self._shareDataMap[shareType][type][id] = data.chat
            shareInfo = data.chat
        elseif type == ChatShareType.ADVISER_TYPE then
            self._shareDataMap[shareType][type][id] = data.adviserInfo
            shareInfo = data.adviserInfo
        elseif type == ChatShareType.GMNOTIFIER_TYPE then
            self._shareDataMap[shareType][type][id] = rawget(data, "noticeId") or 0
            shareInfo = rawget(data, "noticeId") or 0 -- 系统直接用notice Id
        elseif type == ChatShareType.HERO_TYPE then
            self._shareDataMap[shareType][type][id] = data.heroInfo
            shareInfo = data.heroInfo
        elseif type == ChatShareType.PROP_TYPE then
            self._shareDataMap[shareType][type][id] = data.itemInfo
            shareInfo = data.itemInfo
        elseif type == ChatShareType.ORDNANCE_TYPE then
            self._shareDataMap[shareType][type][id] = data.ordnanceInfo
            shareInfo = data.ordnanceInfo
        elseif type == ChatShareType.RESOURCE_TYPE then
            shareInfo = data.posInfo
        end

        if data.chat ~= nil then
            local roleProxy = self:getProxy(GameProxys.Role)
            local myName = roleProxy:getRoleName()
            local shareName = data.chat.name
            if myName == shareName and type ~= ChatShareType.RECRUIT_TYPE and type ~= ChatShareType.GMNOTIFIER_TYPE then
                self:showSysMessage(TextWords:getTextWord(280174))
            end
        end

        --系统公告，先判断是不是显示活动的，如果是，先判断是不是有这个限时活动，没有这个限时活动但是却发公告，屏蔽这条公告
        if type == ChatShareType.GMNOTIFIER_TYPE then
            local configId = rawget(data, "noticeId") or 0 
            local config = ConfigDataManager:getConfigById(ConfigData.NoticeConfig, configId)
            if config ~= nil and config.uiType ~= nil then
                local proxy = self:getProxy(GameProxys.Activity)
                local limitData = proxy:getLimitActivityDataByUitype(config.uiType)
                if limitData ~= nil then
                    self:sendToChat(data, id, shareInfo)
                end
            end
            if config ~= nil and config.uiType == nil then
                -- 注意：用于跳转的坐标
                local configName = config.configName
                local testNum = config.testNum
                if configName ~= nil and testNum ~= nil then
                    local posTable = self:getPosInfoByContext(data.chat.context, configName, testNum) -- 用于跳转坐标
                    data.chat.posInfo = posTable
                end
                self:sendToChat(data, id, shareInfo)
            end
        else
            self:sendToChat(data, id, shareInfo)
        end
        
        
    end
end

function ShareProxy:sendToChat(shareData, id, shareInfo)
    local data = {}
    data.type = shareData.shareType
    local chats = {}
    local chat = shareData.chat
    
    chat.isShare = true
    chat.shareInfo = shareInfo
    chat.shareId = shareData.type

    chat.shareName = tostring(id)
    table.insert(chats, chat)
    data.chats = chats
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:onTriggerNet140000Resp(data)
end

function ShareProxy:getShareData(shareType, type, id)
    -- self._shareDataMap[shareType][type][id]
    return self._shareDataMap[shareType][type][id]
end



function ShareProxy:getPosInfoByContext(context, configName, textNum)
    local posInfo = {}

    local strTable = loadstring("return "..context)()
    local posName = strTable[textNum].txt -- 坐标名字

    local configInfo = {}
    local keyName = ""
    
    if configName == "TownWarConfig" then 
        keyName = "stateName"
    elseif configName == "EmperorWarConfig" then
        keyName = "cityName"
    end

    configInfo = ConfigDataManager:getInfoFindByOneKey(configName, keyName, posName)
    if configInfo ~= nil then
        posInfo.x = configInfo.dataX
        posInfo.y = configInfo.dataY
    end

    if posInfo.x == nil then
        posInfo = nil
    end
    return posInfo
end




