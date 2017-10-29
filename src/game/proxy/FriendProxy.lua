
FriendProxy = class("FriendProxy ", BasicProxy)


function FriendProxy:ctor()
    FriendProxy.super.ctor(self)
    self.proxyName = GameProxys.Friend
    
    self._friendInfoMap = {}
    self._blessInfoMap = {}
    self._collectionInfoMap = {}
end

function FriendProxy:resetAttr()
    self._friendInfoMap = {}
    self._blessInfoMap = {}
    self._collectionInfoMap = {}
end

function FriendProxy:initSyncData(data)
    FriendProxy.super.initSyncData(self, data)
    self:onTriggerNet170000Resp(data.friBleInfos) -- 好友列表
end

function FriendProxy:resetCountSyncData()
--以前做的接口 4点刷新的
    local data = {}
    data.blessStateLog = 4
    self:onTriggerNet30103Resp(data)
end

function FriendProxy:onTriggerNet170000Resp(data)
    --if data.rs == 0 then
        for _, friendInfo in pairs(data.friendInfos) do
        	self:_updateFriendList(friendInfo)
        end
        
        for _, blessInfo in pairs(data.blessInfos) do
        	self:_updateBlessInfo(blessInfo)
        end
    --end
    
    self:sendNotification(AppEvent.PROXY_FRIEND_INFO_UPDATE, {})
end

function FriendProxy:onTriggerNet30103Resp(data)
    if data.blessStateLog == 4 then
        for k, v in pairs(self._friendInfoMap) do
            v.blessState = 0
        end
        for k, v in pairs(self._blessInfoMap) do
            if v.getState == 1 then
                self._blessInfoMap[k] = nil
            end
        end
        self:sendNotification(AppEvent.PROXY_FRIEND_INFO_UPDATE, {})
        self:sendNotification(AppEvent.PROXY_FRIEND_BLESS_UPDATE, {})
    end
end

function FriendProxy:onTriggerNet170001Resp(data)
    if data.rs == 0 then
        self:showSysMessage(string.format(TextWords:getTextWord(1115), data.friendInfo.name)) --添加好友成功提示
        self:_updateFriendList(data.friendInfo)
        self:sendNotification(AppEvent.PROXY_FRIEND_INFO_UPDATE, {data.friendInfo})
    end
end

--搜索好友结果
function FriendProxy:onTriggerNet170002Resp(data)
    if data.rs == 0 then
        self:sendNotification(AppEvent.PROXY_FRIEND_SEARCH, data.friendInfo)
    end
end

--删除好友结果
function FriendProxy:onTriggerNet170003Resp(data)
    if data.rs == 0 then
        local friendInfo = self:getFriendInfo(data.playerId)
        self:showSysMessage(string.format(TextWords:getTextWord(1116), friendInfo.name)) --移除好友成功提示
        self._friendInfoMap[data.playerId] = nil
        self:sendNotification(AppEvent.PROXY_FRIEND_INFO_UPDATE, {})
    end
end

--祝福好友返回 改变好友的祝福状态
function FriendProxy:onTriggerNet170004Resp(data)
    if data.rs == 0 then
        for _, playerId in pairs(data.playerIds) do
        	local friendInfo = self:getFriendInfo(playerId)
        	friendInfo.blessState = 1
        end
        
        self:showSysMessage(TextWords:getTextWord(1117))
        self:sendNotification(AppEvent.PROXY_FRIEND_INFO_UPDATE, {})
    end
end

--被祝福通知 
function FriendProxy:onTriggerNet170005Resp(data)
    for _, blessInfo in pairs(data.blessInfos) do
    	self:_updateBlessInfo(blessInfo)
    end
    
    self:sendNotification(AppEvent.PROXY_FRIEND_BLESS_UPDATE, {})
    self:updateRedPoint()
end

--领取祝福奖励
function FriendProxy:onTriggerNet170006Resp(data)
    if data.rs == 0 then
        for _, playerId in pairs(data.playerIds) do
            local blessInfo = self:getBlessInfo(playerId)
            blessInfo.getState = 1
        end
        self:showSysMessage(TextWords:getTextWord(1118))
        self:sendNotification(AppEvent.PROXY_FRIEND_BLESS_UPDATE, {})
        self:updateRedPoint()
    end
end
--进行收藏
function FriendProxy:onTriggerNet80008Resp(data)
    if data.rs == 0 then
        self:_updateCollectionInfos(data.infos)
    end 
end 
--删除收藏
function FriendProxy:onTriggerNet80009Resp(data)
    if data.rs == 0 then
        self:_updateCollectionInfos(data.infos)
    end 
end 
--收藏的数据
function FriendProxy:onTriggerNet80010Resp(data)
    if data.rs == 0 then
        self:_updateCollectionInfos(data.infos)
    end 
end 
------------------
-- 请求好友最新列表
function FriendProxy:onTriggerNet170000Req()
    self:syncNetReq(AppEvent.NET_M17, AppEvent.NET_M17_C170000, {})
end

--请求添加好友
function FriendProxy:addFriendReq(playerId)
    self:sendServerMessage(AppEvent.NET_M17, AppEvent.NET_M17_C170001, {playerId = playerId})
end

--请求删除好友
function FriendProxy:removeFriendReq(playerId)
    self:sendServerMessage(AppEvent.NET_M17, AppEvent.NET_M17_C170003, {playerId = playerId})
end

function FriendProxy:blessFriendReq(playerIds)
    self:sendServerMessage(AppEvent.NET_M17, AppEvent.NET_M17_C170004, {playerIds = playerIds})
end

function FriendProxy:getBlessReq(playerIds)
    self:sendServerMessage(AppEvent.NET_M17, AppEvent.NET_M17_C170006, {playerIds = playerIds})
end

--收藏物品请求
function FriendProxy:addCollectionReq(colinfo)
    local data = {}
    data.colinfo = colinfo
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80008,data)
end 
--删除收藏请求
function FriendProxy:deleteCollectionReq(id)
    local data = {}
    data.id = id
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80009,data)
end
--请求收藏的物品
function FriendProxy:getCollectionInfosReq()
    local data = {}
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80010,data)
end
--------------------
function FriendProxy:getFriendInfos()
    local list = TableUtils:map2list(self._friendInfoMap,true)
    return list
end

--判断是否为好友
function FriendProxy:isFriend(playerId)
    return self._friendInfoMap[playerId] ~= nil
end

--获取当前好友数
function FriendProxy:getFriendNum()
    local size = table.size(self._friendInfoMap)
    return size
end

function FriendProxy:getFriendInfo(playerId)
    return self._friendInfoMap[playerId]
end

--获取可以祝福的所有玩家ID列表
--TODO需要做上限判断
function FriendProxy:getCanBlessPlayerIdList()
    local idList = {}
    for _, friendInfo in pairs(self._friendInfoMap) do
    	if friendInfo.blessState == 0 then
            table.insert(idList, friendInfo.playerId)
    	end
    end
    
    return idList
end

function FriendProxy:getBlessInfo(playerId)
    return self._blessInfoMap[playerId]
end
-- 获取祝福列表
function FriendProxy:getBlessInfos()
    local list = TableUtils:map2list(self._blessInfoMap)
    return list
end

-- 获取社交祝福领取红点
function FriendProxy:getBlessRedPointCount()
    local getNum = 0 -- 未领取
    local gotNum = 0 -- 已领取
    local blessInfos = self:getBlessInfos()
    for index, info in pairs(blessInfos) do
        if info.getState == 0 then
            getNum = getNum + 1
        elseif info.getState == 1 then
            gotNum = gotNum + 1
        end
    end
    -- 剩余可领取
    local restGetNum = GlobalConfig.BlessEnergyMaxCount - gotNum
    
    local redCount = 0 -- 红点个数
    if getNum > restGetNum then
        redCount = restGetNum
    else
        redCount = getNum
    end
    return redCount
end

function FriendProxy:getGetBlessNum()
    local num = 0
    for _, blessInfo in pairs(self._blessInfoMap) do
    	if blessInfo.getState == 1 then
    	    num = num + 1
    	end
    end
    return num
end

--获取可以领取祝福的所有玩家ID列表
--TODO需要做上限判断
function FriendProxy:getCanGetBlessPlayerIdList()
    local idList = {}
    for _, blessInfo in pairs(self._blessInfoMap) do
        if blessInfo.getState == 0 then
            table.insert(idList, blessInfo.playerId)
        end
    end

    return idList
end

--
--更新好友信息
function FriendProxy:_updateFriendList(friendInfo)
    self._friendInfoMap[friendInfo.playerId] = friendInfo
end

function FriendProxy:_updateBlessInfo(blessInfo)
    self._blessInfoMap[blessInfo.playerId] = blessInfo
end

--更新收藏信息
function FriendProxy:_updateCollectionInfos(infos)
    self._collectionInfos = infos
end 
--获取收藏信息
function FriendProxy:getCollectionInfos()
    return self._collectionInfos or {}
end 
----------------处理收藏的逻辑--------------------------------
function FriendProxy:getColkey(info)
    local key = info.name.."_"..info.tileX.."_"..info.tileY
    return key
end

function FriendProxy:initWorldCollectionInfos(data)
    self._collectionInfoMap = {}
    for _, info in pairs(data.infos) do
    	self._collectionInfoMap[self:getColkey(info)] = info
    end
end

function FriendProxy:getWorldCollectionInfoList()
    return TableUtils:map2list(self._collectionInfoMap)
end

function FriendProxy:getWorldCollectionInfoByType(type)
    local list = {}
    if type == 0 then
        list = TableUtils:map2list(self._collectionInfoMap)
    else
        for _, info in pairs(self._collectionInfoMap) do
        	local tags = info.tags
        	if table.indexOf(tags, type) >= 0 then
                table.insert(list, info)
        	end
        end    
    end
    return list

   

end


------
-- 根据一个list筛选
-- @param  selectList [list] 选择列表
-- @return nil
function FriendProxy:getWorldCollectBySelect(selectList)
    -- 判断是否是空表，表示要显示全部
    local count = 0
    for i = 1, selectList:size() do
        count = count + selectList:at(i)
    end
    if count == 0 then
        local list = {}
        list = TableUtils:map2list(self._collectionInfoMap)
        return list 
    end


    local isHave = function (tags, value )
        if table.indexOf(tags, value) == -1 then -- 坑，最好不要用关键词
            return false
        else
            return true
        end
    end

    local list = {}
    for _, info in pairs(self._collectionInfoMap) do
        local canPutIn = true
        local tags = info.tags
        for i = 1, selectList:size() do
            if selectList:at(i) ~= 0 then
                if isHave(tags, selectList:at(i)) == false then
                    canPutIn = false
                end
            end
        end
        if canPutIn == true then
            table.insert(list, info)
        end
    end
    return list
end

function FriendProxy:getWorldCollectionsByIsPerson(type)  --0玩家 1资源 2叛军
    local list = {}
    for _, info in pairs(self._collectionInfoMap) do
        if info.isPerson == type then
            table.insert(list, info)
        end
    end    
    return list
end

function FriendProxy:updateWorldCollectionInfo(info, isSyn)
    -- 邮件收藏规范化输入
    local newInfo = {}
    newInfo.buildingType = info.buildingType
    newInfo.isPerson     = info.isPerson
    newInfo.level        = info.level
    newInfo.tileY        = info.tileY
    newInfo.tags         = info.tags
    newInfo.tileX        = info.tileX
    newInfo.name         = info.name
    newInfo.iconId       = info.iconId
    newInfo.power        = info.power
    newInfo.legionName   = info.legionName
    newInfo.playerId     = info.playerId

    self._collectionInfoMap[self:getColkey(newInfo)] = newInfo
    if isSyn == true then
        self:synWorldCollectionInfo()
    end
end

function FriendProxy:delWorldCollectionInfo(info)
    self._collectionInfoMap[self:getColkey(info)] = nil
end

function FriendProxy:synWorldCollectionInfo()
    local list = TableUtils:map2list(self._collectionInfoMap)
    -- 规范主城收藏字段
    self:removeUnusedKey(list, "isSelect", "isUpdate") -- 在EspecialSelectPanel中不规范使用，难以分离
    local data = {}
    data.infos = list
    local systemProxy = self:getProxy(GameProxys.System)
    systemProxy:updateProtoGeneratedMessage(ClientCacheType.WORLD_COLLECTION, data)
end

--小红点更新
function FriendProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkFriendRedPoint() 
end

function FriendProxy:setIsShowCollectSysMsg(isShow)
    local systemProxy = self:getProxy(GameProxys.System)
    systemProxy:setIsShowCollectSysMsg(isShow)
end

-- 过滤字段并规范化输入
function FriendProxy:removeUnusedKey(list, unusedKey01, unusedKey02)
    for key, info in pairs(list) do
        if info.isPerson == 0 then
            if rawget(info, unusedKey01) ~= nil or rawget(info, unusedKey02) ~= nil then
                local newInfo = {}
                newInfo.isPerson     = info.isPerson
                newInfo.level        = info.level
                newInfo.tileY        = info.tileY
                newInfo.tags         = info.tags
                newInfo.tileX        = info.tileX
                newInfo.name         = info.name
                newInfo.iconId       = info.iconId
                list[key] = newInfo
            end
        end
    end
end


