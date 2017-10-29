ChatProxy = class("ChatProxy", BasicProxy)

ChatProxy.Max_Chat_Count = 30
ChatProxy.Max_PrivateChat_Count = 15

ChatProxy.ChatType_Private  = 0
ChatProxy.ChatType_World    = 1
ChatProxy.ChatType_Legion   = 2

require "modules.chat.panel.ChatCommon"

local maxChatLen = ChatProxy.Max_Chat_Count
local chatTypePrivate = ChatProxy.ChatType_Private
local chatTypeWorld = ChatProxy.ChatType_World
local chatTypeLegion = ChatProxy.ChatType_Legion

function ChatProxy:ctor()
    ChatProxy.super.ctor(self)
    self.proxyName = GameProxys.Chat

    self.MAX_CHAT_LINE = 9
    self._worldChatList = {}
    self._legionChatList = {}  --军团聊天信息
    self._privateChatList = {}  --总的私聊信息
    self._privateChatMap = {}

    self._noReadCount = {[chatTypePrivate] = 0, [chatTypeWorld] = 0, [chatTypeLegion] = 0}

    self.myType = 0
    self.oldTime = 0
    self.isComeFromShare = false
end

function ChatProxy:resetAttr()
    self._worldChatList = {}
    self._legionChatList = {}
    self._privateChatList = {}  --私聊信息
    self._privateChatMap = {}

    self._noReadCount = {[chatTypePrivate] = 0, [chatTypeWorld] = 0, [chatTypeLegion] = 0}
end

function ChatProxy:initSyncData(data)
    ChatProxy.super.initSyncData(self, data)

    -- local chatProxy = self:getProxy(GameProxys.Chat)
    self:setReset(true, "isClearWorldChatView")
    self:setReset(true, "isClearLegionChatView")
    self:setReset(true, "isClearPrivateChatView")
    self:sendNotification(AppEvent.CLEAR_TOOLBAR_CMD)

    self._worldChatList = {}
    self._legionChatList = {}
    self._privateChatList = {}  --总的私聊信息
    self._privateChatMap = {}

    self._noReadCount = {[chatTypePrivate] = 0, [chatTypeWorld] = 0, [chatTypeLegion] = 0}
end

function ChatProxy:setReset(isreset, key)
    self._isReset = self._isReset or {}
    self._isReset[key] = isreset
end

function ChatProxy:getReset(key)
    self._isReset = self._isReset or {}
    return self._isReset[key]
end

ChatProxy.LegUpdate = false

function ChatProxy:onTriggerNet140000Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140000, data)
end

function ChatProxy:onTriggerNet140100Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140100, data)
end

function ChatProxy:onTriggerNet140001Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140001, data)
end

function ChatProxy:onTriggerNet140002Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140002, data)
end

function ChatProxy:onTriggerNet140003Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140003, data)
end

function ChatProxy:onTriggerNet140004Req(data, isChat)
    self._isChat = isChat
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140004, data)
end

function ChatProxy:onTriggerNet140005Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140005, data)
end

function ChatProxy:onTriggerNet140006Req(data)
    self.checkShieldType = data.type
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140006, data)
end

function ChatProxy:onTriggerNet140007Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140007, data)
end

function ChatProxy:onTriggerNet140009Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140009, data)
end

function ChatProxy:onTriggerNet140200Req()
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140200, {})
end

function ChatProxy:onTriggerNet140201Req()
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140201, {})
end

---------------
function ChatProxy:onTriggerNet140000Resp(data)

    if data.rs ~= nil and data.rs < 0 then
        return  --发送的聊天不符合
    end

    local chats = data.chats
    local worldChatList = {}
    local legionChatList = {}

    local lastChat = self:getLastChatInfo()
    for _, chat in pairs(chats) do
        
        if lastChat == nil or chat.time > lastChat.time then 
            lastChat = chat
        end
        
        if chat.type == 1 then
            self:addWorldChatInfo(chat)  --添加世界聊天
            table.insert(worldChatList, chat)

            --TODO:性能测试                                                                                                                                                                                                                                 
--            local testChat = {iconId=999, isShare=true, extendValue=0, shareInfo=2201, time=1488946048, level=0, shareId=4, contextType=0, playerId= StringUtils:int32ToFixed64(0), playerType=0, vipLevel=0, shareName="", legionName="", type=1, context="{{txt='恭喜',color='#eed6aa'},{txt='诸立群',color='#30c7ff'},{txt='建立同盟',color='#eed6aa'},{txt='qqq',color='#30c7ff'},{txt=',一方势力由此崛起！欢迎各路诸侯一同加入，共谋大业！',color='#eed6aa'}}", pendantId=0, name="系统公告" }
--            table.insert(worldChatList, testChat)
        elseif chat.type == 2 then
            self:addLegionChatInfo(chat) --添加军团聊天
            table.insert(legionChatList, chat)
        end
    end

    -- 设置最后一条聊天
    if lastChat ~= nil then
        self:setLastChatInfo(lastChat)
    end



    --ProfileUtils:startTotal()

    if #worldChatList > 0 then
        self:sendNotification(AppEvent.PROXY_GET_CHAT_INFO, {type = chatTypeWorld, chats = worldChatList})
    end

    if #legionChatList > 0 then
        self:sendNotification(AppEvent.PROXY_GET_CHAT_INFO, {type = chatTypeLegion, chats = legionChatList})
    end

    --弹幕推送
    --TimerManager:addOnce(1000, self:sendNotification(AppEvent.PROXY_GET_CHAT_INFO_BARRAGE,data.chats), self)
    self:sendNotification(AppEvent.PROXY_GET_CHAT_INFO_BARRAGE,data.chats)
    --ProfileUtils:endTotal()
end 

--获取到
function ChatProxy:onTriggerNet140100Resp(data)
    if data.rs == 0 then --TODO 需要映射到具体的控件列表上
        AudioManager:playRecorderSound(data.chatClientId, data.context, data.audioSec)
    end
end

function ChatProxy:onTriggerNet140001Resp(data)
    if data.rs == 0 then
        local isMail = self:isModuleShow(ModuleName.MailModule) -- 在邮件中显示
        if isMail then
            self:sendNotification(AppEvent.PROXY_GET_PERSON_NOT_MAP, data) -- 回调不是在地图上的
        else
            self:sendNotification(AppEvent.PROXY_GET_CHATPERSON_INFO,data)
        end
    end
end

function ChatProxy:onTriggerNet140002Resp(data)
    self:sendNotification(AppEvent.PROXY_PRIVATECHAT_INFO, data)
end

function ChatProxy:onTriggerNet140003Resp(data)
    local pritvateChat = data.chatInfo

    self:addPrivateChatInfo(pritvateChat)

    local lastChat = self:getLastChatInfo()
    if lastChat == nil or pritvateChat.time > lastChat.time then
        self:setLastChatInfo(pritvateChat)
    end

    self:sendNotification(AppEvent.PROXY_CHAT_RESP, pritvateChat)    
end

function ChatProxy:getIsChat()
    return self._isChat
end

function ChatProxy:onTriggerNet140004Resp(data)    
    if data.rs == 0 then
        -- 区分别处来的还是自己搜索
        local isOpen = self:isModuleShow(ModuleName.ChatModule)
        if isOpen == true then
            self:sendNotification(AppEvent.PROXY_PRIVATECHAT, data.info) 
            --print("区分 私聊")           

        else
            self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ChatModule })
            local isChatShow = self:isModuleShow(ChatModule)
            if isChatShow then return end
            local tmp = { }
            tmp["moduleName"] = ModuleName.ChatModule
            tmp["extraMsg"] = { }
            tmp["extraMsg"]["type"] = "privateChat"
            tmp["extraMsg"]["isCloseModule"] = true
            tmp["extraMsg"]["data"] = data.info
            self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, tmp)
            --print("区分跳转私聊")
        end
    end
end

--添加到屏蔽列表
function ChatProxy:onTriggerNet140005Resp(data)
    if data.rs == 0 then
        -- 添加屏蔽成功
        self:showSysMessage(TextWords:getTextWord(932))
    end
end

function ChatProxy:onTriggerNet140006Resp(data)
    if data.rs == 0 then
        data.type = self.checkShieldType
        self:sendNotification(AppEvent.PROXY_SHIELDCHAT_INFO,data)
    end
end

function ChatProxy:enterPrivate(data)  --进入私聊界面
    local tmpData = {}
    tmpData.type = 0
    tmpData.playerId = data.info.playerId
    self:onTriggerNet140004Req(tmpData)
    -- self:sendServerMessage(AppEvent.NET_M14,AppEvent.NET_M14_C140004, tmpData)
end

function ChatProxy:enterWriteMsg(data)  --写信
    if data["extraMsg"] ~= nil then
        self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_CLOSE_EVENT,{moduleName = ModuleName.ChatModule})
        self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)
    else
        self:sendNotification(AppEvent.PROXY_SELF_WRITEMAIL,data)
    end
end

function ChatProxy:onTriggerNet140007Resp(data)  --移除收到
    local type = self.checkShieldType
    self:onShieldPlayerListReq(type)
end
---------------------
--请求查看玩家数据
function ChatProxy:watchPlayerInfoReq(data)
    self:sendServerMessage(AppEvent.NET_M14,AppEvent.NET_M14_C140001, data)
end
--请求屏蔽玩家
function ChatProxy:onShieldPlayerReq(Type,PlayerId)--{type//0:邮件，1：聊天   &   PlayerId}
    self:onTriggerNet140005Req({type = Type, playerId = PlayerId})
end
--屏蔽列表请求
function ChatProxy:onShieldPlayerListReq( Type ) -- 0:邮件，1：聊天
    local data = {type = Type}
    self:onTriggerNet140006Req(data)
end

--添加世界聊天数据
function ChatProxy:addWorldChatInfo(chat)
    table.insert(self._worldChatList, chat)


    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    if chat.playerId ~= self._ID then
        self._noReadCount[chatTypeWorld] = self._noReadCount[chatTypeWorld] + 1
    end

    while #self._worldChatList > maxChatLen do  
        table.remove(self._worldChatList, 1)
    end
end

function ChatProxy:addLegionChatInfo(chat)
    table.insert(self._legionChatList, chat)

    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    if chat.playerId ~= self._ID then
        self._noReadCount[chatTypeLegion] = self._noReadCount[chatTypeLegion] + 1
    end

    while #self._legionChatList > maxChatLen do  
        table.remove(self._legionChatList, 1)
    end
end

function ChatProxy:addPrivateChatInfo(chat)
--    table.insert(self._privateChatList, chat)

--    logger:info("=================>chat.receivePlayerId:%s", StringUtils.fixed64ToNormalStr(chat.playerId))

    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
--    if chat.playerId ~= self._ID then
--        self._noReadCount[chatTypePrivate] = self._noReadCount[chatTypePrivate] + 1
--    end

--    while #self._privateChatList > maxChatLen do
--        table.remove(self._privateChatList, 1)
--    end

    -- 私聊玩家ID
    local playerId = chat.playerId
    if chat.playerId == self._ID then            
        playerId = chat.receivePlayerId  
    end

    -- 初始化单人私聊频道
    local playerPrivateChatObject = self._privateChatMap[playerId]
    if playerPrivateChatObject == nil then
        if playerId == self._ID then            
            return
        else
            playerPrivateChatObject = {}
            playerPrivateChatObject._playerId = playerId
            playerPrivateChatObject._noReadCount = 0
            playerPrivateChatObject._lastChatTime = 0
            playerPrivateChatObject._name = ""
            playerPrivateChatObject._legionName = ""
            playerPrivateChatObject._iconId = 0
            playerPrivateChatObject._chats = {}
            self._privateChatMap[playerId] = playerPrivateChatObject
        end
    end


    -- 添加聊天信息
    
    if chat.receivePlayerId == self._ID then
        -- 别人发给我的
        playerPrivateChatObject._noReadCount = playerPrivateChatObject._noReadCount + 1
        self._noReadCount[chatTypePrivate] = self._noReadCount[chatTypePrivate] + 1
        playerPrivateChatObject._name = chat.name
        playerPrivateChatObject._legionName = chat.legionName
        playerPrivateChatObject._iconId = chat.iconId
        playerPrivateChatObject._lastChatTime = chat.time

    else
        -- 我发给别人的
        playerPrivateChatObject._name = rawget(chat, "receivePlayerName")
        playerPrivateChatObject._legionName = rawget(chat, "receivePlayerLegion")
        playerPrivateChatObject._iconId = rawget(chat, "receivePlayerIconId")
        playerPrivateChatObject._lastChatTime = GameConfig.serverTime

    end
    table.insert(playerPrivateChatObject._chats, chat)

    -- 删除超出的聊天
    while #playerPrivateChatObject._chats > ChatProxy.Max_PrivateChat_Count do
        table.remove(playerPrivateChatObject._chats, 1)
    end

    self:delaySendNotification(AppEvent.PROXY_PRIVATECHAT_REDPOINT)
end

function ChatProxy:resetPrivateChatNotReadChatNum(playerId)
    local playerPrivateChatObject = self._privateChatMap[playerId]
    self._noReadCount[chatTypePrivate] = self._noReadCount[chatTypePrivate] - playerPrivateChatObject._noReadCount
    playerPrivateChatObject._noReadCount = 0

    self:delaySendNotification(AppEvent.PROXY_PRIVATECHAT_REDPOINT)
end

function ChatProxy:resetNotReadChatNum(chatType)
    self._noReadCount[chatType] = 0
end

function ChatProxy:getNotReadChatNum(chatType)    
    return self._noReadCount[chatType] or 0
end

function ChatProxy:getAllReadChatNum()
    local num = 0 
    for k, v in pairs(self._noReadCount) do
        num = num + v
    end

    return num
end

--获取所有的未读数量
function ChatProxy:getAllNotRenderChatNum()
    return self:getNotRenderWorldChatNum() + self:getNotRenderLegionChatNum() + self:getNotRenderPrivateChatNum()
end



function ChatProxy:getNotRenderPrivateChatNum()   --私聊未读信息总和
    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    local num = 0
    for _, chatInfo in pairs(self._privateChatList) do
        if chatInfo.playerId == self._ID then
            rawset(chatInfo,"isRender",true)
        end
        if rawget(chatInfo,"isRender") ~= true then
            num = num + 1
        end
    end
    
    return num
end

function ChatProxy:getNotRenderWorldChatNum()  --世界里未读的信息
    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    local num = 0
    for _, chatInfo in pairs(self._worldChatList) do
        --chatInfo.playerId == self._ID and chatInfo.extendValue ~= 1  判断是不是红包
        if chatInfo.playerId == self._ID and chatInfo.extendValue == 0 and rawget(chatInfo,"isShare") ~= true then
            rawset(chatInfo,"isRender",true)
        end
        if rawget(chatInfo,"isRender") ~= true then
            num = num + 1
        end
    end
    return num
end
function ChatProxy:getNotRenderLegionChatNum()  --军团里未读的信息
    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    local num = 0
    for _, chatInfo in pairs(self._legionChatList) do
        if chatInfo.playerId == self._ID and rawget(chatInfo,"isShare") ~= true then
            rawset(chatInfo,"isRender",true)
        end
        if rawget(chatInfo,"isRender") ~= true then
            num = num + 1
        end
    end
    return num
end

function ChatProxy:getNotRenderWorldChat(firstEnterSelfPanel) --世界里未读的聊天信息 包括分享
    local chatList = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    local num = 0
    local allChat = {}

    for _, chatInfo in pairs(self._worldChatList) do
        if firstEnterSelfPanel or rawget(chatInfo,"isRender") ~= true then
            table.insert(chatList, chatInfo)
            rawset(chatInfo,"isRender",true)
        end 
    end
    return chatList
end

function ChatProxy:getNotRenderLegionChat(firstEnterSelfPanel) --军团里未读的聊天信息 包括分享
    local chatList = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    local num = 0
    for _, chatInfo in pairs(self._legionChatList) do
        if rawget(chatInfo,"isRender") ~= true or firstEnterSelfPanel == true then
            table.insert(chatList, chatInfo)
        end
    end
    return chatList
end

function ChatProxy:getNotRenderPrivateChat()
    local chatList = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    for _,chatInfo in pairs(self._privateChatList) do
        if chatInfo.playerId == self._ID then
            rawset(chatInfo,"isRender",true)
        end
        if rawget(chatInfo,"isRender") ~= true then
            table.insert(chatList, chatInfo)
            rawset(chatInfo,"isRender",true)
        end
    end
    return chatList
end

function ChatProxy:getNoeRenderSomeBodyChatNum(index) --获取某人未读的信息 index表示第几个人
    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    local num = 0
    for k, list in pairs(self._privateChatList) do
        for _, chatInfo in pairs(list) do
            if chatInfo.playerId == self._ID then
               rawset(chatInfo,"isRender",true)
            end
            if rawget(chatInfo,"isRender") ~= true and index == k then
                num = num + 1
            end
        end
    end
    return num
end

--获取最后一个聊天信息
function ChatProxy:setLastChatInfo(chat)
    self._lastChat = chat
end
function ChatProxy:getLastChatInfo()
    return self._lastChat    
end


-- 私聊
function ChatProxy:getPrivateChatList(index)
    return self._privateChatList
end
function ChatProxy:getPrivateChatObjMap()
    return self._privateChatMap or {}
end
function ChatProxy:getPrivateChatObj(playerId)
    return self._privateChatMap[playerId]
end

-- 同盟聊天
function ChatProxy:getLegionChatList()
    return self._legionChatList
end

-- 世界聊天
function ChatProxy:getWorldChatList()
    return self._worldChatList
end




function ChatProxy:enterLegionChat(data) --从军团大厅进入聊天
    if data["extraMsg"] ~= nil then
        -- self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_CLOSE_EVENT,{moduleName = ModuleName.ChatModule})
        self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)
    else
        -- self:sendNotification(AppEvent.PROXY_SELF_WRITEMAIL,data)
    end
end

function ChatProxy:onTriggerNet140009Resp(data)
    self.myType = data.type
end



function ChatProxy:onTriggerNet140012Resp(data)
    -- 初始化单人私聊频道
    for k, v in pairs(data.privatePlayers) do
        local privatePlayerInfo = v
        local playerPrivateChatObject = self._privateChatMap[privatePlayerInfo.playerId]
        if playerPrivateChatObject == nil then
            playerPrivateChatObject = { }
            self._privateChatMap[privatePlayerInfo.playerId] = playerPrivateChatObject
        end

        playerPrivateChatObject._playerId = privatePlayerInfo.playerId
        playerPrivateChatObject._noReadCount = 0
        playerPrivateChatObject._lastChatTime = privatePlayerInfo.time
        playerPrivateChatObject._name = privatePlayerInfo.name
        playerPrivateChatObject._legionName = privatePlayerInfo.legionName
        playerPrivateChatObject._iconId = privatePlayerInfo.iconId
        playerPrivateChatObject._chats = { }
    end
    self._noReadCount[chatTypePrivate] = 0
    self:delaySendNotification(AppEvent.PROXY_PRIVATECHAT_REDPOINT)
end

function ChatProxy:getMyType()
    local type = self.myType
    return type
end

function ChatProxy:getlastTime(nowTime) --两次发送的时间差
    local tmpTime = self.oldTime
    if (nowTime - self.oldTime) >= 5 then
        self.oldTime = nowTime
    end
    return nowTime - tmpTime
end

function ChatProxy:onTriggerNet140200Resp(data)
    local rs = data.rs
    if rs == 0 then

        local content = TextWords:getTextWord(142002)
        local okBtnName = TextWords:getTextWord(142004)
        local canelBtnName = TextWords:getTextWord(142003)
        local title = TextWords:getTextWord(142001)

        local function okCallback()
            --手机相册
            CustomHeadManager:showSelectPicUpload(0)
        end

        local function canCelcallback()
            --拍照
            CustomHeadManager:showSelectPicUpload(1)
        end

        local box = self:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
        box:setTitleName(title)
        box:setShowSecLvBgCloseBtn(true)

    end

    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:setCustomHeadCoolTime(data.customCoolTime)
end

function ChatProxy:onTriggerNet140201Resp(data)

    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:setCustomHeadCoolTime(data.customCoolTime)
end

--审核结果推送
function ChatProxy:onTriggerNet140202Resp(data)
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    local status = data.status
    local noPass = false
    if status == CustomHeadStatus.NORMAL then  --删除掉本地自己的资源
        CustomHeadManager:delCustomHead(CustomHeadManager.CUSTOM_HEAD_ID, playerId) --99999
        noPass = true
    elseif status == CustomHeadStatus.ONCE_OWN then --曾经拥有，重新下载
       noPass = true
    end

    roleProxy:setCustomHeadStatus(status)

    if noPass then
        self:showSysMessage(TextWords:getTextWord(142007))
    end

end

function ChatProxy:onTriggerNet140203Req()
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140203, {})
end