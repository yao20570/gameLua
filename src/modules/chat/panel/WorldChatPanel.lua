
WorldChatPanel = class("WorldChatPanel", BasicPanel)
WorldChatPanel.NAME = "WorldChatPanel"

function WorldChatPanel:ctor(view, panelName)
    WorldChatPanel.super.ctor(self, view, panelName)
    self.isEmotion = 0
    self.lastTime = 5
    self.maxSend = 5
    --self.allChatNoSeeNum = 0 -- 所有聊天频道未查看数量
    self.curNotSeeChatNum = 0 --当前还未查看的数量
    self.isCurrentPanel = true
    self._tempContent = nil
    self.firstEnterSelfPanel = true
    self.firstSendInfo = true
    self.myType = 0
    self.oldTime = 0
    
    self.curSelEmotionNum = 0 --当前表情数目
    self.maxSelEmotionNum = 5 --最大表情数目
    self.oldText = ""

    self.showMaxRenderLine = 10 --默认打开第一次显示条数
    self.isCheckFunction = false

    self:setUseNewPanelBg(true)

    self._vipPinCCBMap = {}
end

function WorldChatPanel:pauseCCB()
    WorldChatPanel.super.pauseCCB(self)
    logger:info("WorldChatPanel:pauseCCB() ========== >")
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

function WorldChatPanel:resumeCCB()
    WorldChatPanel.super.resumeCCB(self)
    logger:info("WorldChatPanel:resumeCCB() ========== >")
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

function WorldChatPanel:finalize()
    if self._itemModel ~= nil then
        self._itemModel:release()
    end
    if self._uiWatch ~= nil then
        self._uiWatch:finalize()
    end
    self._uiWatch = nil
    if self._frameQueue ~= nil then
        self._frameQueue:finalize()
    end
    WorldChatPanel.super.finalize(self)
end

function WorldChatPanel:initPanel()
    WorldChatPanel.super.initPanel(self)

    self._chatProxy = self:getProxy(GameProxys.Chat)

    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    self._NAME = roleProxy:getRoleName()
    self._ICONID = roleProxy:getHeadId()
    
    self._frameQueue = FrameQueue.new(0.06, ChatProxy.Max_Chat_Count)

    
    self._emotionBtn = self:getChildByName("sendPanel/emotionBtn")
    self._sendBtn = self:getChildByName("sendPanel/sendBtn")

    -- 语音
    local btn_audio = self:getChildByName("sendPanel/audionBtn")
    self:addTouchEventListener(btn_audio, self.sendAudioReq, self.startAudioTouch, nil)
    btn_audio:setCancelCallback(self.cancelAudio)
    NodeUtils:setEnable(btn_audio, false)
    
    -- 文本
    local inputPanel = self:getChildByName("sendPanel/inputPanel")
    local bgurl = "images/chat/input.png"
    self._chatEditBox = ComponentUtils:addEditeBox(inputPanel, 40, self:getTextWord(901), function()
        local curText = self._chatEditBox:getText()
        local fixText, curSelEmotionNum = self.view:fixChatEmotionNum(curText, self.maxSelEmotionNum)
        self._chatEditBox:setText(fixText)
        self.curSelEmotionNum = curSelEmotionNum
    end , nil, bgurl,cc.c3b(0,0,0))
    self._chatEditBox:setMaxLength(40)
    --self._chatEditBox:setFontName(GlobalConfig.fontName)
    self._chatEditBox:setFontName("system")
    self._chatEditBox:setFontSize(28)

    if GlobalConfig.chatMinLv == 1 then --测试模式，增加输入限制
        self._chatEditBox:setMaxLength(100)
    end

    self._panelCountBg = self:getChildByName("sendPanel/panelCountBg")
    self._pnlKaiGuan = self:getChildByName("sendPanel/panelCountBg/pnlKaiGuan")
    self._imgKai = self:getChildByName("sendPanel/panelCountBg/pnlKaiGuan/imgKai")
    self._imgKai:setVisible(false)
    self._imgGuan = self:getChildByName("sendPanel/panelCountBg/pnlKaiGuan/imgGuan")
    self._imgGuan:setVisible(true)
    self._panelTouch = self:getChildByName("sendPanel/panelCountBg/panelTouch")
    self._panelTouch:setVisible(false)
    self._txtTip = self:getChildByName("sendPanel/panelCountBg/panelTouch/txtTip")
    

    -- 聊天列表
    self._svWorldChat = self:getChildByName("svWorldChat")
    local chatItem = self._svWorldChat:getChildByName("chatItem")
    UIChatScrollviewExpand:expand(self._svWorldChat, chatItem)
    self._svWorldChat:setMaxItemUICount(ChatProxy.Max_Chat_Count)
    self._svWorldChat:addEventListener( function(sender, evenType)
        --logger:info("==============>ScrollviewEventType:%s", evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            local isInBottom = self._svWorldChat:isInBottom()
            if isInBottom then
--                self._panelTouch:setVisible(false)
--                self._imgKai:setVisible(true)
--                self._imgGuan:setVisible(false)
                self._panelCountBg:setVisible(false)
                self:updateChatInfos()

            end
        end
    end )
    
    -- local chats = self._chatProxy:getNotRenderWorldChat(true)
    self:updateChatInfos()
end

function WorldChatPanel:registerEvents()
    self:addTouchEventListener(self._sendBtn, self.onSendBtnTouch)
    self:addTouchEventListener(self._emotionBtn, self.onEmotionBtnTouch)
    self:addTouchEventListener(self._svWorldChat, self.btnClickEvents)
    self:addTouchEventListener(self._panelTouch, self.btnClickEvents)
end

function WorldChatPanel:doLayout( )
    local bottomPanel = self:getChildByName("sendPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._svWorldChat, bottomPanel, tabsPanel)
    self._svWorldChat:resetPos()
    self._svWorldChat:jumpToBottom()
end

-- 清除聊天记录
function WorldChatPanel:onClearCmd()
    self._svWorldChat:delAllItemUI()
end


function WorldChatPanel:onShowHandler()

    -- self:setBgType(ModulePanelBgType.NONE)
    -- if self:isModuleRunAction() then
    --     return
    -- end
    self:setFrameQueueDelay(0.06)
    self.curTime = os.time()
    
    local mainPanel = self:getPanel(ChatPanel.NAME)
    TimerManager:addOnce(100, mainPanel.hideRedPoint, mainPanel, 1)
    ChatCommon.legShow = true
    local _result = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    self.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    self.isCurrentPanel = true
    --self:ShowNoSeeInfoNum(2)
    

    ChatCommon.legionShareInfo = {}

    self.firstEnterSelfPanel = false
    local useSelfChat = 1


    self._svWorldChat:jumpToBottom()
    self:updateChatInfos()
    self._chatProxy:resetNotReadChatNum(ChatProxy.ChatType_World)

    _G["aSRDigitalSuccess"] = function(result)
        self._chatEditBox:setText(result)
    end

end

function WorldChatPanel:onHideHandler()
    self._svWorldChat:jumpToBottom()
    self._chatProxy:resetNotReadChatNum(ChatProxy.ChatType_World)
end

function WorldChatPanel:hideMethod()
    -- WorldChatPanel.super.onHideHandler(self)
    _G["aSRDigitalSuccess"] = nil
    --self:setFrameQueueDelay(5)  --关闭设置变慢
    self._svWorldChat:jumpToBottom()
end

function WorldChatPanel:onRecorderComplete(recorder)
    AudioManager:setRecorderEndCallback(nil)
    self:sendSelfContent(recorder, 1, 2)  --发送语音给服务端
end

--开始语音-->录音
function WorldChatPanel:startAudioTouch(sender)

    local function onRecorderComplete(recorder)
        self:onRecorderComplete(recorder)
    end

    self.view:startRecorder(onRecorderComplete)
end

--结束录音
function WorldChatPanel:sendAudioReq(sender)
    -- self:showSysMessage(TextWords:getTextWord(821))
    self.view:completeRecorder()
end

--取消录音
function WorldChatPanel:cancelAudio()
    self.view:cancelRecorder()
end

--运动完成之后
function WorldChatPanel:onAfterActionHandler()
    -- self:loadAgain(self._worldChatParam)
    -- self._worldChatParam = nil
    -- self:onShowHandler()
end

--打开显示全部信息，利用module打开的动画来缓冲
--index应该是用来标记是不是自己发送的，自己的发送的时候是没有等协议返回 
function WorldChatPanel:updateChatInfos()
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    

    --断线重连，自己的聊天被过滤掉了，用这个reset来验证是不是需要显示自己的
    local tempChat = {}
    local addType = UIChatScrollviewExpand.AddToFront
    local chatType = ChatProxy.ChatType_World 
    local isReset = self._chatProxy:getReset("isClearWorldChatView")
    if isReset then
        self._chatProxy:setReset(nil, "isClearWorldChatView")        
        addType = UIChatScrollviewExpand.AddToBack    

        -- 聊天第一次加载从最后一条加载起(蛋疼的，协议第一次来时，ChatModule还没创建,数据还没保存到view里)
        -- TODO：有空优化将view里的数据和proxy的数据合并处理
        --local chats = self.view:getChatData(chatType)
        local chats = self._chatProxy:getWorldChatList()
        for i = #chats, 1, -1 do
            table.insert(tempChat, chats[i])
        end
        self.view:clearChatData(chatType)
    else
        local isInBottom = self._svWorldChat:isInBottom()
        if isInBottom then
            tempChat = self.view:getChatData(chatType)
            self.view:clearChatData(chatType)
            self._panelTouch:setVisible(false)

        else            
            local count = self.view:getChatCount(chatType)
            if count > 0 then
                local str = string.format(self:getTextWord(927), count)
                self._txtTip:setString(str)
                self._panelTouch:setVisible(true)                
            end

        end

--        self._imgKai:setVisible(isInBottom == true)
--        self._imgGuan:setVisible(isInBottom == false)
        self._panelCountBg:setVisible(isInBottom == false)
    end

    for k, v in pairs(tempChat) do
        --分享的id就是自己的id，要特殊处理   喇叭，也要特殊处理  chats[i].extendValue = 2
        if isReset or v.playerId ~= playerId or v.extendValue ~= 0 or rawget(v, "isShare") == true then            
            self._frameQueue:pushParams(self.updateChatLineInfo, self, v, addType)
        end
    end
end

function WorldChatPanel:setFrameQueueDelay(delay)
    self._frameQueue:setDelay(delay)
end

function WorldChatPanel:updateChatLineInfo(chat, addType)

    self._svWorldChat:addItemUI(chat, addType, self, self.renderChatItem, true)
    self._svWorldChat:jumpToBottom()

end

function WorldChatPanel:delayJumpToBottom(list)
    list:jumpToBottom()
--    self._panelTouch:setVisible(false)
    
--    self._imgKai:setVisible(true)
--    self._imgGuan:setVisible(false)
    self._panelCountBg:setVisible(false)
end

function WorldChatPanel:renderChatItem(chatItem, chat)
    
    --ProfileUtils:startTotal()
    local itemUIHeight = ChatCommon.CommonRender(chatItem, chat, self)
    
    self._vipPinCCBMap[chatItem] = chatItem

    --ProfileUtils:endTotal()

    return itemUIHeight
end

function WorldChatPanel:onClickActor(sender)
    -- body 
    local id = sender.id
    if id == self._ID then
        local data = {}
        data.moduleName = ModuleName.HeadAndPendantModule
        self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
        return
    end

    if self:isSystemChat(id) == true then --这个是系统信息
    else
        self._chatProxy:onTriggerNet140001Req({playerId = id})
    end
    
end

--通过ID来判断是否是系统的信息
function WorldChatPanel:isSystemChat(id)
    local id1 = string.byte(id,1)
    local id2 = string.byte(id,2)
    local id3 = string.byte(id,3)
    local id4 = string.byte(id,4)
    return id1 == 255 and id2 == 255 and id3 == 255 and id4 == 255
end

function WorldChatPanel:onShowInfo(data)
    local parent = self:getParent()
    if self._uiWatch == nil then
        self._uiWatch = UIWatchPlayerInfo.new(parent,self,true)
    end
    self._uiWatch:setMialShield()
    self._uiWatch:showAllInfo(data)
end

function WorldChatPanel:onClickMyActor()
    -- local HeadSculpturePanel = self:getPanel(HeadSculpturePanel.NAME)
    -- HeadSculpturePanel:show()
end

--选择了表情ID
function WorldChatPanel:selectEmotion(id)
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

function WorldChatPanel:onEmotionBtnTouch(sender)
    local emotionPanel = self:getPanel(EmotionPanel.NAME)
    local num = 0
    if self.isEmotion == 0 then
        self.isEmotion = 0
        emotionPanel:show(num)
    else
        self.isEmotion = 0
        emotionPanel:hide()
    end
    
end

--按钮选择
function WorldChatPanel:btnClickEvents( sender )
    if sender == self._svWorldChat then
        local emotionPanel = self:getPanel(EmotionPanel.NAME)
        self.isEmotion = 0
        emotionPanel:hide()

        local isInBottom = self._svWorldChat:isInBottom()
--        self._imgKai:setVisible(isInBottom == true)
--        self._imgGuan:setVisible(isInBottom == false)
        self._panelCountBg:setVisible(isInBottom == false)

    elseif  sender == self._panelTouch then
        self:delayJumpToBottom(self._svWorldChat)
        self:updateChatInfos()
    end
end

function WorldChatPanel:onSendBtnTouch(sender)
    --[[
    local redProxy = self:getProxy(GameProxys.RedBag)
    redProxy:onTriggerNet540001Resp()
    --]]

    local emotionPanel = self:getPanel(EmotionPanel.NAME)
    self.isEmotion = 0
    emotionPanel:hide()

    local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if lv < GlobalConfig.chatMinLv then
        self:showSysMessage(string.format(TextWords:getTextWord(925), GlobalConfig.chatMinLv))
        return
    end

    
    self._chatEditBox:setText(StringUtils:trim(self._chatEditBox:getText()))
    local text = self._chatEditBox:getText()
    if text == "" then
        return
    end

    local beforeFilterText = self._chatEditBox.beforeFilterText
    if beforeFilterText ~= nil then
        local ary = StringUtils:splitString(beforeFilterText, "#")
        if #ary >= 2 and ary[1] == "serverVersion" then
            local systemProxy = self:getProxy(GameProxys.System)
            systemProxy:onTriggerNet30200Req({fileName = ary[2]})
            return
        end
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

    local data = {}
    data.type = 1
    data.context = text
    
    self:sendSelfContent(data.context, data.type)
end
function WorldChatPanel:sendSelfContent(context, type, contextType, preload)
    -- logger:error("~~~~~~~WorldChatPanel:sendSelfContent:%s~~~~~~~:%d~~~~~~", context, contextType)
    if context == "show me the memory" then
        TextureManager:writeCachedTextureInfo()
        return
    end

    contextType = contextType or 1
    local chatProxy = self._chatProxy

    chatProxy:setReset(nil, "isClearWorldChatView")
    
    
    local isCanSendChat = self:isCanSendChat()
    if isCanSendChat ~= true and preload ~= true then
        self:showSysMessage(self:getTextWord(914))
        return
    end

    if self.oldText ~= context then
        self.oldText = context
    else
        self.oldTime = 0
        self:showSysMessage("不可重复发送相同消息！")
        return
    end
    self.curSelEmotionNum = 0
    self.isEmotion = 0
    self._chatEditBox:setText("")
    local data = {}
    data.context = context
    data.type = 1
    data.contextType = contextType
    if contextType == 2 then
        data.chatClientId = self.view:getChatId()
        data.audioSec = self.view:getRecorderTime()
    end

    if preload ~= true then --预加载不请求数据
        chatProxy:onTriggerNet140000Req(data)
    end
    
    -- logger:error("~~~~~~~WorldChatPanel:sendSelfContent:%s~~~~~~~~~~~~~", context)
    --给自己发送信息
    if self._tempContent == context then
        self:showSysMessage(self:getTextWord(906))
        return
    end
    local chatProxy = self._chatProxy
    local roleProxy = self:getProxy(GameProxys.Role)
    local titleProxy = self:getProxy(GameProxys.Title)
    local frameProxy = self:getProxy(GameProxys.Frame)
    self.myType = chatProxy:getMyType()
    self._ID = roleProxy:getPlayerId()
    self._NAME = roleProxy:getRoleName()
    self._ICONID = roleProxy:getHeadId()
    self._pendantId = roleProxy:getPendantId()
    self._tempContent = context
    local chat = {}
    chat.context = context
    chat.type = type
    chat.name = self._NAME
    chat.playerId = self._ID
    if preload then
        chat.playerId = "11111111"
    end
    chat.iconId = self._ICONID
    chat.pendantId = self._pendantId
    chat.extendValue = 0
    chat.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    chat.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    chat.legionName = roleProxy:getLegionName()
    chat.contextType = contextType
    chat.chatClientId = data.chatClientId
    chat.audioSec = data.audioSec
    chat.design = titleProxy:getMyUsingTitle()
    chat.frameId = frameProxy:getMyUsingFremeId()

    local chats = chatProxy:getLegionChatList()
    self:updateChatLineInfo(chat, UIChatScrollviewExpand.AddToFront)
    self:delayJumpToBottom(self._svWorldChat)

    -- test
    --local worldChatList = {}
    --table.insert(worldChatList, chat)
    --chatProxy:sendNotification(AppEvent.PROXY_GET_CHAT_INFO, {type = ChatProxy.ChatType_World, chats = worldChatList})
end

function WorldChatPanel:onClosePanelHandler()
    self.lastTime = 6
    ChatCommon.legShow = false
    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
end

function WorldChatPanel:getlastTime(nowTime) --两次发送的时间差
    local tmpTime = self.oldTime
    if (nowTime - self.oldTime) >= 5 then
        self.oldTime = nowTime
    end
    return nowTime - tmpTime
end

function WorldChatPanel:isCanSendChat()
    local curTime = os.time()
    if  self.oldTime ~= nil and 
        curTime - self.oldTime < self.maxSend then
        return false
    end

    self.oldTime = curTime
    return true
end


function WorldChatPanel:canTouchEmotion()
    self.isEmotion = 0
end

function WorldChatPanel:onTabChangeEvent(tabControl)
    WorldChatPanel.super.onTabChangeEvent(self, tabControl)
    local panel = self:getPanel(EmotionPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end
end