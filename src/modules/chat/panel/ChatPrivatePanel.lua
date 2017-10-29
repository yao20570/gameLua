ChatPrivatePanel = class("ChatPrivatePanel", BasicPanel)
ChatPrivatePanel.NAME = "ChatPrivatePanel"

ChatPrivatePanel.State_Player = 1
ChatPrivatePanel.State_Chat = 2


function ChatPrivatePanel:ctor(view, panelName)
    ChatPrivatePanel.super.ctor(self, view, panelName)
    self.infomations = 0
    self.isEmotion = 0
    self.lastTime = 5  
    self.maxSend = 5 --聊天间隔时间
    self.curNotSeeChatNum = 0 --当前还未查看的数量
    --self.allChatNoSeeNum = 0  --所有未读取的条数
    self.myType = 0
    self.oldTime = 0
    self.curSelEmotionNum = 0 --当前表情数目
    self.maxSelEmotionNum = 5 --最大表情数目
    --self.isCheckFunction = false
    self.oldText = ""

    self._curPlayerId = 0

    self:setUseNewPanelBg(true)

    self._vipPinCCBMap = {}
end

function ChatPrivatePanel:pauseCCB()
    ChatPrivatePanel.super.pauseCCB(self)
    logger:info("ChatPrivatePanel:pauseCCB() ========== >")
    for k, v in pairs(self._vipPinCCBMap) do
        local myEffect = v._allChild.myActor.effect
        if myEffect~=nil then            
            myEffect:pause()
        end

        local otherEffect = v._allChild.otherActor.effect
        if otherEffect~=nil then            
            otherEffect:pause()
        end
    end
end

function ChatPrivatePanel:resumeCCB()
    ChatPrivatePanel.super.resumeCCB(self)
    logger:info("ChatPrivatePanel:resumeCCB() ========== >")
    for k, v in pairs(self._vipPinCCBMap) do
        local myEffect = v._allChild.myActor.effect
        if myEffect~=nil and myEffect:isVisible() then            
            myEffect:resume()
        end

        local otherEffect = v._allChild.otherActor.effect
        if otherEffect~=nil and otherEffect:isVisible() then            
            otherEffect:resume()
        end
    end
end

function ChatPrivatePanel:finalize()
    if self._itemModel ~= nil then
        self._itemModel:release()
    end

    if self._frameQueue ~= nil then
        self._frameQueue:finalize()
    end

    ChatPrivatePanel.super.finalize(self)
end

function ChatPrivatePanel:initPanel()
    ChatPrivatePanel.super.initPanel(self)
    -- self:setBgType(ModulePanelBgType.BACK)

    -- 渲染队列
    self._frameQueue = FrameQueue.new(0.06, 50)

    -- 面板当前状态
    self._curPanelState = ChatPrivatePanel.State_Player

    -- 代理数据
    self._chatProxy = self:getProxy(GameProxys.Chat)
    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    self._NAME = roleProxy:getRoleName()
    self._ICONID = roleProxy:getHeadId()

    -- UI
    self._panelSend = self:getChildByName("panelSend")
    self._panelSend:setVisible(false)
    self._btnReturn = self:getChildByName("panelSend/btnReturn")
    self._panelCountBg = self:getChildByName("panelSend/panelCountBg")
    self._pnlKaiGuan = self:getChildByName("panelSend/panelCountBg/pnlKaiGuan")
    self._imgKai = self:getChildByName("panelSend/panelCountBg/pnlKaiGuan/imgKai")
    self._imgKai:setVisible(false)
    self._imgGuan = self:getChildByName("panelSend/panelCountBg/pnlKaiGuan/imgGuan")
    self._imgGuan:setVisible(true)
    self._panelTouch = self:getChildByName("panelSend/panelCountBg/panelTouch")
    self._panelTouch:setVisible(false)
    self._txtTip = self:getChildByName("panelSend/panelCountBg/panelTouch/txtTip")

    local btn_audio = self:getChildByName("panelSend/audionBtn")
    self:addTouchEventListener(btn_audio, self.sendAudioReq, self.startAudioTouch, nil)
    btn_audio:setCancelCallback(self.cancelAudio)
    NodeUtils:setEnable(btn_audio, false)

    self._panelFind = self:getChildByName("panelFind")
    self._panelFind:setVisible(true)
    self._btnFind = self:getChildByName("panelFind/btnFind")
    self._btnFriend = self:getChildByName("panelFind/btnFriend")

    self:addTouchEventListener(self._btnFind, self.onFind)
    

    -- 点这里说话  
    local urlBg = "images/chat/input.png"

    local panelInput = self:getChildByName("panelSend/panelInput")  
    self._chatEditBox = ComponentUtils:addEditeBox(panelInput, 40, self:getTextWord(901), function()
        local curText = self._chatEditBox:getText()
        local fixText, curSelEmotionNum = self.view:fixChatEmotionNum(curText, self.maxSelEmotionNum)
        self._chatEditBox:setText(fixText)
        self.curSelEmotionNum = curSelEmotionNum
    end , nil, urlBg, cc.c3b(0, 0, 0))
    self._chatEditBox:setMaxLength(40)
    --self._chatEditBox:setFontName(GlobalConfig.fontName)
    self._chatEditBox:setFontName("system")
    self._chatEditBox:setFontSize(28)

    local panelName = self:getChildByName("panelFind/panelName")
    self._nameEditBox = ComponentUtils:addEditeBox(panelName, 38, self:getTextWord(926), nil, nil, urlBg, cc.c3b(0, 0, 0))
    self._nameEditBox:setMaxLength(38)
    --self._nameEditBox:setFontName(GlobalConfig.fontName)
    self._nameEditBox:setFontName("system")
    self._nameEditBox:setFontSize(28)

    -- 最近聊天对象
    self._svLast = self:getChildByName("svLast")
    self._svLast:setVisible(true)

    -- 聊天列表
    self._svPrivateChat = self:getChildByName("svPrivateChat")
    self._svPrivateChat:setVisible(false)
    local chatItem = self._svPrivateChat:getChildByName("chatItem")
    UIChatScrollviewExpand:expand(self._svPrivateChat, chatItem)
    self._svPrivateChat:setMaxItemUICount(ChatProxy.Max_PrivateChat_Count)
    self._svPrivateChat:addEventListener( function(sender, evenType)
        -- logger:info("==============>ScrollviewEventType:%s", evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            local isInBottom = self._svPrivateChat:isInBottom()
            if isInBottom then
                --self._panelTouch:setVisible(false)
                --self._imgKai:setVisible(true)
                --self._imgGuan:setVisible(false)
                self._panelCountBg:setVisible(false)
                self:updateChatInfos()
            end
        end
    end )
    
    
end

function ChatPrivatePanel:doLayout( )
    local tabsPanel = self:getTabsPanel()
    --NodeUtils:adaptiveListView(self._worldListView, bottomPanel, tabsPanel)   
    NodeUtils:adaptiveListView(self._svLast, self._panelSend, tabsPanel)
    self:createScrollViewItemUIForDoLayout(self._svLast)

    NodeUtils:adaptiveListView(self._svPrivateChat, self._panelSend, tabsPanel) 
    self._svPrivateChat:resetPos()
    self._svPrivateChat:jumpToBottom()
end

function ChatPrivatePanel:registerEvents()
    local sendBtn = self:getChildByName("panelSend/sendBtn")
    
    local emotionBtn = self:getChildByName("panelSend/emotionBtn")
    
    self:addTouchEventListener(sendBtn, self.onSendBtnTouch)
    self:addTouchEventListener(emotionBtn, self.onEmotionBtnTouch)

    self:addTouchEventListener( self._svPrivateChat, self.btnClickEvents)
    self:addTouchEventListener( self._panelTouch, self.btnClickEvents)
    self:addTouchEventListener( self._btnReturn, self.onReturn)

    self:addTouchEventListener(self._btnFind, self.onFind)
    self:addTouchEventListener(self._btnFriend, self.onOpenFriend)

end

function ChatPrivatePanel:onRecorderComplete(recorder)
    AudioManager:setRecorderEndCallback(nil)
    self:sendSelfContent(recorder, 2)  --发送语音给服务端
end

--开始语音-->录音
function ChatPrivatePanel:startAudioTouch(sender)

    local function onRecorderComplete(recorder)
        self:onRecorderComplete(recorder)
    end

    self.view:startRecorder(onRecorderComplete)
end

--结束录音
function ChatPrivatePanel:sendAudioReq(sender)
    -- self:showSysMessage(TextWords:getTextWord(821))
    self.view:completeRecorder()
end

--取消录音
function ChatPrivatePanel:cancelAudio()
    self.view:cancelRecorder()
end

function ChatPrivatePanel:onClickMyActor()
    -- local HeadSculpturePanel = self:getPanel(HeadSculpturePanel.NAME)
    -- HeadSculpturePanel:show()
end

function ChatPrivatePanel:onClearCmd()
    self._svPrivateChat:delAllItemUI()
end

function ChatPrivatePanel:getCurPanelState()
    return self._curPanelState
end

--开始就会掉用
function ChatPrivatePanel:onShowHandler(data)  

    self:delayJumpToBottom()  

    if data~= nil then
        self:updatePanel(data.name, data.playerId)
    else
        self:onReturn()
    end

    
    self:updateUI()
    --self:onReturn()
end

function ChatPrivatePanel:updateUI()
    if self._curPanelState == ChatPrivatePanel.State_Player then
        self:updateLastPanel()
    elseif self._curPanelState == ChatPrivatePanel.State_Chat then
        

        self:updateChatInfos()

--    self._chatProxy:resetNotReadChatNum(ChatProxy.ChatType_Private)    

--    if data ~= nil then
--         self._nameEditBox.playerId = data.info.playerId
--         self._nameEditBox:setText(data.info.name)
--    end

--    local mainPanel = self:getPanel(ChatPanel.NAME)
--    TimerManager:addOnce(100, mainPanel.hideRedPoint, mainPanel, 3)
    end
end

function ChatPrivatePanel:onHideHandler()
    self:delayJumpToBottom()  
--    self._chatProxy:resetNotReadChatNum(ChatProxy.ChatType_Private)
end

function ChatPrivatePanel:hideMethod()
    self:delayJumpToBottom()  
end

function ChatPrivatePanel:updatePanel(name, playerId)
    self._nameEditBox:setText(name)

    if self._curPlayerId ~= playerId then
        -- 切换了聊天对象后，移除所有ItemUI
        self._svPrivateChat:delAllItemUI()

        self._curPlayerId = playerId

        self._chatProxy:setReset(true, "isClearPrivateChatView")
    end
    self:switchState(ChatPrivatePanel.State_Chat)
end

function ChatPrivatePanel:updateLastPanel()
    local playerList = self:getPlayerList()
    self:renderScrollView(self._svLast, "panelItem", playerList, self, self.renderPlayerItemUI, 1, GlobalConfig.scrollViewRowSpace) 
end

function ChatPrivatePanel:renderPlayerItemUI(itemUI, data, index)
    
    local playerPrivateChatObject = data
    
    -- 头像
    local headInfo = { }
    headInfo.icon = playerPrivateChatObject._iconId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    headInfo.playerId = playerPrivateChatObject._playerId

    local imgHead = itemUI:getChildByName("imgHead")
    local head = imgHead.head
    if head == nil then
        head = UIHeadImg.new(imgHead, headInfo, self)
        imgHead.head = head
    else
        head:updateData(headInfo)
    end

    -- 名称
    local txtName = itemUI:getChildByName("txtName")
    txtName:setString(playerPrivateChatObject._name)

    -- 同盟名称
    local txtLegionName = itemUI:getChildByName("txtLegionName")
    txtLegionName:setString(playerPrivateChatObject._legionName)

    NodeUtils:alignNodeL2R(txtName, txtLegionName, 5)

    -- 新消息
    local str = string.format(self:getTextWord(928), playerPrivateChatObject._noReadCount)
    local txtNewCount = itemUI:getChildByName("txtNewCount")
    txtNewCount:setString(str)

    
    local btnChat = itemUI:getChildByName("btnChat")
    btnChat.data = playerPrivateChatObject
    self:addTouchEventListener(btnChat, self.onSelectPlayer)

end

function ChatPrivatePanel:getPlayerList()
    local chatMap = self._chatProxy:getPrivateChatObjMap()
    local tempList = TableUtils:map2list(chatMap, true)
    table.sort(tempList, function(a, b) return a._lastChatTime > b._lastChatTime end)
--    local playerList = { }
--    for k, v in pairs(tempList) do
--        if k > 5 then
--            break
--        end
--        table.insert(playerList, v)
--    end
--    return playerList
    return tempList
end

function ChatPrivatePanel:updateChatInfos()

    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    
    local isInBottom = true

    --断线重连，自己的聊天被过滤掉了，用这个reset来验证是不是需要显示自己的    
    local addType = UIChatScrollviewExpand.AddToFront
    local chatType = ChatProxy.ChatType_Private 
    local tempChat = {}
    local playerPrivateChatObject = self._chatProxy:getPrivateChatObj(self._curPlayerId)

    -- 没有聊天对象
    if playerPrivateChatObject == nil then
        return
    end

    local chats = playerPrivateChatObject._chats

    local isReset = self._chatProxy:getReset("isClearPrivateChatView")
    if isReset then
        self._chatProxy:setReset(nil, "isClearPrivateChatView")        
        --addType = UIChatScrollviewExpand.AddToBack    

--        local chats = self._chatProxy:getPrivateChatList()
--        for i = #chats, 1, -1 do
--            rawset(chats[i], "isRender", false)
--            table.insert(tempChat, chats[i])
--        end
        for k, v in pairs(chats) do    
            rawset(v, "isRender", false)
            table.insert(tempChat, v)
        end
--        self.view:clearChatData(chatType)
        self._chatProxy:resetPrivateChatNotReadChatNum(self._curPlayerId)
    else
        isInBottom = self._svPrivateChat:isInBottom()
        if isInBottom then

            --tempChat = self.view:getChatData(chatType)
            tempChat = chats

            --self.view:clearChatData(chatType)
            self._chatProxy:resetPrivateChatNotReadChatNum(self._curPlayerId)
            self._panelTouch:setVisible(false)

        else            
            --local count = self.view:getChatCount(chatType)
            local count = playerPrivateChatObject._noReadCount
            if count > 0 then
                -- "您有%s条新消息"
                local str = string.format(self:getTextWord(927), count)
                self._txtTip:setString(str)
                self._panelTouch:setVisible(true)    
            end

        end
                
    end


    for k, v in pairs(tempChat) do
        --分享的id就是自己的id，要特殊处理   喇叭，也要特殊处理  chats[i].extendValue = 2
        --if isReset or v.playerId ~= playerId or v.extendValue ~= 0 or rawget(v, "isShare") == true then  
        
            --self._frameQueue:pushParams(self.updateChatLineInfo, self, v, addType) 
            self:updateChatLineInfo(v, addType)           
        --end
    end

    self._svPrivateChat:resetPos()

    if isInBottom then
        self:delayJumpToBottom()  
    end
end


function ChatPrivatePanel:updateChatLineInfo(chat, addType)
    if rawget(chat, "isRender") ~= true then
        rawset(chat, "isRender", true)
        --logger:info("==>function ChatPrivatePanel:updateChatLineInfo(chat, addType):%s", chat.context)
        self._svPrivateChat:addItemUI(chat, addType, self, self.renderChatItem, false)
        --self._svPrivateChat:jumpToBottom()
    end
end

function ChatPrivatePanel:delayJumpToBottom()
    self._svPrivateChat:jumpToBottom()
    --logger:info("==========================>ChatPrivatePanel:delayJumpToBottom()")
    self._panelTouch:setVisible(false)

    --self._imgKai:setVisible(true)
    --self._imgGuan:setVisible(false)
    self._panelCountBg:setVisible(false)
end

function ChatPrivatePanel:renderChatItem(chatItem, chat)
    --处理信息
    local itemUIHeight = ChatCommon.CommonRender(chatItem, chat, self)
    --logger:info("=================>ChatPrivatePanel:renderChatItem : %s", chat.context)

    self._vipPinCCBMap[chatItem] = chatItem

    return itemUIHeight
end

function ChatPrivatePanel:onClickActor(sender)
    local id = sender.id
    if id == self._ID then
        local data = {}
        data.moduleName = ModuleName.HeadAndPendantModule
        self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
        return
    end
    self:getProxy(GameProxys.Chat):onTriggerNet140001Req({playerId = id})
end

--选择了表情ID
function ChatPrivatePanel:selectEmotion(id)
    local faceInfo = ConfigDataManager:getConfigById(ConfigData.ChatFaceConfig,id)
    local faceinstead = faceInfo.faceinstead
    
    if self.curSelEmotionNum > self.maxSelEmotionNum then
        return --超过最大选择的聊天表情数目
    end
    self.curSelEmotionNum = self.curSelEmotionNum + 1
    
    -- self:sendSelfContent(faceinstead, 1)
    local  text = self._chatEditBox:getText()
    self._chatEditBox:setText(text .. faceinstead)
end




function ChatPrivatePanel:onEmotionBtnTouch(sender)
    --logger:info("============onEmotionBtnTouch=================%s", self.isEmotion)
    local emotionPanel = self:getPanel(EmotionPanel.NAME)
    local num = 1
    if self.isEmotion == 0 then
        self.isEmotion = 1
        emotionPanel:show(num)
    else
        self.isEmotion = 0
        emotionPanel:hide()
    end 
end

--按钮选择
function ChatPrivatePanel:btnClickEvents( sender )
    --if sender == self._worldListView then
    if sender == self._svPrivateChat then
        local emotionPanel = self:getPanel(EmotionPanel.NAME)
        self.isEmotion = 0
        emotionPanel:hide()

        local isInBottom = self._svPrivateChat:isInBottom()
        --self._imgKai:setVisible(isInBottom == true)
        --self._imgGuan:setVisible(isInBottom == false)
        self._panelCountBg:setVisible(isInBottom == false)
    elseif  sender == self._panelTouch then
        --TimerManager:addOnce(2 * 30, self.delayJumpToBottom, self, self._worldListView)

        self:delayJumpToBottom()  
        self:updateChatInfos()
    end
end

function ChatPrivatePanel:onSendBtnTouch(sender)
    local emotionPanel = self:getPanel(EmotionPanel.NAME)
    self.isEmotion = 0
    emotionPanel:hide()

    local text = self._chatEditBox:getText()
    if text == "" then
        self:showSysMessage("不可发送空消息！")
        return
    end

    local SensitiveWords = {"'", "\"", "“", "‘", "’", "”", "%(<", ">)", "/", "\\"}
    local isHaveSensitiveWords = false
    for k,v in pairs(SensitiveWords) do
        if string.find(text, v) then
            isHaveSensitiveWords = true
            break
        end
    end
    if isHaveSensitiveWords then
        self:showSysMessage("聊天信息中有敏感字符")
        return
    end
    
    self:sendSelfContent()
end

function ChatPrivatePanel:sendSelfContent(context, contextType)
    self._contextType = contextType or 1
    
    self._chatEditBox:setText(StringUtils:trim(self._chatEditBox:getText()))
    self._context = context or self._chatEditBox:getText()
    self._audioSec = self.view:getRecorderTime()
    local context = self._context
    

    local name = self._nameEditBox:getText()
    if name == nil or name == "" then
        self:showSysMessage(self:getTextWord(929))
        return
    end

    local isCanSendChat = self:isCanSendChat()
    if isCanSendChat ~= true then
        self:showSysMessage(self:getTextWord(914))
        return
    end
    
    if self.oldText ~= context then
        self.oldText = context
    elseif name == self.oldName then
        self.oldTime = 0
        self:showSysMessage(self:getTextWord(931))
        return
    end
    self.oldName = name    

    if name == self._NAME then
        self:showSysMessage(self:getTextWord(930))
        return
    end

    self.curSelEmotionNum = 0
    self.isEmotion = 0

    self._chatProxy:onTriggerNet140004Req({type = 1, name = name}, true)    

end

function ChatPrivatePanel:onClosePanelHandler()
    self.lastTime = 6
    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
end

function ChatPrivatePanel:getlastTime(nowTime) --两次发送的时间差
    local tmpTime = self.oldTime
    if (nowTime - self.oldTime) >= 5 then
        self.oldTime = nowTime
    end
    return nowTime - tmpTime
end

function ChatPrivatePanel:isCanSendChat()
    local curTime = os.time()
    if  self.oldTime ~= nil and 
        curTime - self.oldTime < self.maxSend then
        return false
    end

    self.oldTime = curTime
    return true
end

function ChatPrivatePanel:canTouchEmotion()
    self.isEmotion = 0
end

function ChatPrivatePanel:sendPrivateData(simplePlayerInfo)
    
    local context = self._context --self._chatEditBox:getText()
    if context == nil or context == "" then
        return
    end
    local chatProxy = self._chatProxy
    local titleProxy = self:getProxy(GameProxys.Title)
    local frameProxy = self:getProxy(GameProxys.Frame)
    local sendData = {}
    sendData.context = context
    sendData.playerId = simplePlayerInfo.playerId
    sendData.contextType = self._contextType
    if self._contextType == 2 then --语音
        sendData.chatClientId = self.view:getChatId()
        sendData.audioSec = self._audioSec
    end
    chatProxy:onTriggerNet140002Req(sendData)

    local roleProxy = self:getProxy(GameProxys.Role)
    self.myType = chatProxy:getMyType()
    self._ID = roleProxy:getPlayerId()
    self._NAME = roleProxy:getRoleName()
    self._ICONID = roleProxy:getHeadId()
    self._pendantId = roleProxy:getPendantId()
    local data = {}
    data.context = context
    data.playerId = self._ID
    data.iconId = self._ICONID
    data.name = self._NAME
    data.pendantId = self._pendantId
    data.type = 0
    data.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    data.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    data.extendValue = 0
    data.legionName = roleProxy:getLegionName()
    data.contextType = sendData.contextType
    data.chatClientId = sendData.chatClientId
    data.audioSec = sendData.audioSec
    data.design = titleProxy:getMyUsingTitle()
    data.frameId = frameProxy:getMyUsingFremeId()
    data.receivePlayerId = self._curPlayerId
    rawset(data, "receivePlayerName", simplePlayerInfo.name)
    rawset(data, "receivePlayerLegion", simplePlayerInfo.legion)
    rawset(data, "receivePlayerIconId", simplePlayerInfo.iconId)
               
    self._chatProxy:addPrivateChatInfo(data)
    self:delayJumpToBottom()
    self:updateChatInfos()
    --self:updateChatLineInfo(data, UIChatScrollviewExpand.AddToFront)
    self._chatEditBox:setText("")
end

function ChatPrivatePanel:onTabChangeEvent(tabControl)
    ChatPrivatePanel.super.onTabChangeEvent(self, tabControl)
    local panel = self:getPanel(EmotionPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end
end


function ChatPrivatePanel:switchState(state)
    self._curPanelState = state
    self._panelFind:setVisible(state == ChatPrivatePanel.State_Player)
    self._svLast:setVisible(state == ChatPrivatePanel.State_Player)
    self._panelSend:setVisible(state == ChatPrivatePanel.State_Chat)
    self._svPrivateChat:setVisible(state == ChatPrivatePanel.State_Chat)
end

function ChatPrivatePanel:reqPrivateChat(playerName)
    if playerName == "" then
        -- 找不到对应的玩家
        self:showSysMessage(self:getTextWord(929))
        return
    end

    if name == self._NAME then
        -- 不能与自己私聊
        self:showSysMessage(self:getTextWord(930))
        return
    end

    self._chatProxy:onTriggerNet140004Req( { type = 1, name = playerName } )
end

function ChatPrivatePanel:onSelectPlayer(sender)
    local playerPrivateChatObject = sender.data
    -- self:reqPrivateChat(playerPrivateChatObject._name)
    self:delayJumpToBottom()  
    self:updatePanel(playerPrivateChatObject._name, playerPrivateChatObject._playerId)
    self:switchState(ChatPrivatePanel.State_Chat)
    self:updateUI()
end

function ChatPrivatePanel:onFind(sender)          
    local name = self._nameEditBox:getText()
    self:reqPrivateChat(name)
end

function ChatPrivatePanel:onReturn(sender)          
    self:switchState(ChatPrivatePanel.State_Player)
    self:updateLastPanel()
end

function ChatPrivatePanel:onOpenFriend(sender)          
    local panel = self:getPanel(ChatFriendPanel.NAME)
    panel:show()
end
