
LegionChatPanel = class("LegionChatPanel", BasicPanel)
LegionChatPanel.NAME = "LegionChatPanel"

function LegionChatPanel:ctor(view, panelName)
    LegionChatPanel.super.ctor(self, view, panelName)
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
    self.isCheckFunction = false

    self:setUseNewPanelBg(true)
    self._vipPinCCBMap = {}
end

function LegionChatPanel:pauseCCB()
    LegionChatPanel.super.pauseCCB(self)
    logger:info("LegionChatPanel:pauseCCB() ========== >")
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

function LegionChatPanel:resumeCCB()
    LegionChatPanel.super.resumeCCB(self)
    logger:info("LegionChatPanel:resumeCCB() ========== >")
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

function LegionChatPanel:finalize()
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
    LegionChatPanel.super.finalize(self)
end

function LegionChatPanel:initPanel()
    LegionChatPanel.super.initPanel(self)

    self._chatProxy = self:getProxy(GameProxys.Chat)

    local roleProxy = self:getProxy(GameProxys.Role)
    self._ID = roleProxy:getPlayerId()
    self._NAME = roleProxy:getRoleName()
    self._ICONID = roleProxy:getHeadId()

    self._frameQueue = FrameQueue.new(0.3)

    local bottomPanel = self:getChildByName("sendPanel")

    self._emotionBtn = self:getChildByName("sendPanel/emotionBtn")
    self._inputPanel = self:getChildByName("sendPanel/inputPanel")
    local btn_audio = self:getChildByName("sendPanel/audionBtn")
    local keyboardBtn = self:getChildByName("sendPanel/keyboardBtn")
    self._keyboardBtn = keyboardBtn
    self._audioBtn = btn_audio

    -- self:addTouchEventListener(btn_audio, self.toAudioModeTouch )
    self:addTouchEventListener(keyboardBtn, self.toKeyboardModeTouch)
    self:addTouchEventListener(btn_audio, self.sendAudioReq, self.startAudioTouch)
    btn_audio:setCancelCallback(self.cancelAudio)
    -- local talkBtn = self:getChildByName("sendPanel/talkBtn")
    -- self:addTouchEventListener(talkBtn, self.sendAudioReq, self.startAudioTouch)
    -- talkBtn:setCancelCallback(self.cancelAudio)
    -- self._talkBtn = talkBtn

    keyboardBtn:setVisible(false)
    -- talkBtn:setVisible(false)
    btn_audio:setVisible(true)

    -- 点这里说话
    local bgurl = "images/chat/input.png"
    self._chatEditBox = ComponentUtils:addEditeBox(self._inputPanel, 40, self:getTextWord(901), function()
        local curText = self._chatEditBox:getText()
        local fixText, curSelEmotionNum = self.view:fixChatEmotionNum(curText, self.maxSelEmotionNum)
        self._chatEditBox:setText(fixText)
        self.curSelEmotionNum = curSelEmotionNum
    end , nil, bgurl, cc.c3b(0, 0, 0))
    self._chatEditBox:setMaxLength(40)
    --self._chatEditBox:setFontName(GlobalConfig.fontName)
    self._chatEditBox:setFontName("system")
    self._chatEditBox:setFontSize(28)


    self._sendBtn = self:getChildByName("sendPanel/sendBtn")

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
    self._svLegionChat = self:getChildByName("svLegionChat")
    local chatItem = self._svLegionChat:getChildByName("chatItem")
    UIChatScrollviewExpand:expand(self._svLegionChat, chatItem)
    self._svLegionChat:setMaxItemUICount(ChatProxy.Max_Chat_Count)
    self._svLegionChat:addEventListener( function(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            local isInBottom = self._svLegionChat:isInBottom()
            if isInBottom then
                --self._panelTouch:setVisible(false)
                --self._imgKai:setVisible(true)
                --self._imgGuan:setVisible(false)
                self._panelCountBg:setVisible(false)
                self:updateChatInfos()
            end
        end
    end )

    self:updateChatInfos()
end

function LegionChatPanel:registerEvents()
    self:addTouchEventListener(self._sendBtn, self.onSendBtnTouch)
    self:addTouchEventListener(self._emotionBtn, self.onEmotionBtnTouch)
    self:addTouchEventListener(self._svLegionChat, self.btnClickEvents)
    --self:addTouchEventListener(self._checkInfoBtn, self.btnClickEvents)
    self:addTouchEventListener( self._panelTouch,self.btnClickEvents)    
end

function LegionChatPanel:doLayout( )
    local bottomPanel = self:getChildByName("sendPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._svLegionChat, bottomPanel, tabsPanel)

    self._svLegionChat:resetPos()
    self._svLegionChat:jumpToBottom()
end

function LegionChatPanel:onClearCmd()
    logger:info("====================================>onClearCmd")
    self._svLegionChat:delAllItemUI()
end

function LegionChatPanel:onShowHandler(sender)

    local mainPanel = self:getPanel(ChatPanel.NAME)
    TimerManager:addOnce(100, mainPanel.hideRedPoint, mainPanel, 2)

    
    ChatCommon.legShow = true
    local _result = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    self.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    self.isCurrentPanel = true
    --self:ShowNoSeeInfoNum(2)
    local chatProxy = self:getProxy(GameProxys.Chat)

    ChatCommon.legionShareInfo = {}
    
    self._svLegionChat:jumpToBottom()
    self:updateChatInfos()
    self._chatProxy:resetNotReadChatNum(ChatProxy.ChatType_Legion)

    _G["aSRDigitalSuccess"] = function(result)
        self._chatEditBox:setText(result)
    end

end

function LegionChatPanel:onHideHandler()
    self._svLegionChat:jumpToBottom()
    self._chatProxy:resetNotReadChatNum(ChatProxy.ChatType_Legion)
end



function LegionChatPanel:hideMethod()
    -- LegionChatPanel.super.onHideHandler(self)
    _G["aSRDigitalSuccess"] = nil

    AudioManager:stopRecorderSound(true)


    
    self._svLegionChat:jumpToBottom()
end



function LegionChatPanel:toAudioModeTouch(sender)
    self._chatEditBox:setVisible(false)
    self._emotionBtn:setVisible(false)
    self._inputPanel:setVisible(false)
    self._sendBtn:setVisible(false)

    self._keyboardBtn:setVisible(true)
    self._audioBtn:setVisible(false)

    -- self._talkBtn:setVisible(true)
end

function LegionChatPanel:toKeyboardModeTouch(sender)
    self._chatEditBox:setVisible(true)
    self._emotionBtn:setVisible(true)
    self._inputPanel:setVisible(true)
    self._sendBtn:setVisible(true)

    self._keyboardBtn:setVisible(false)
    self._audioBtn:setVisible(true)

    -- self._talkBtn:setVisible(false)
end

--播放录音是的图标
function LegionChatPanel:playRecorderAction(node, audioSec)
    local function complete()
        node:stopAllActions()
        node:setOpacity(255)
    end
    node:setOpacity(0)
    node:stopAllActions()
    local action1 = cc.FadeTo:create(0.2, 255)
    local action2 = cc.FadeTo:create(0.2, 0)
    local repeatAction = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
    node:runAction(repeatAction)

    TimerManager:addOnce(audioSec * 1000, complete, self)
end

function LegionChatPanel:onRecorderComplete(recorder)
    AudioManager:setRecorderEndCallback(nil)
    self:sendSelfContent(recorder, 2, 2)  --发送语音给服务端
end

--开始语音-->录音
function LegionChatPanel:startAudioTouch(sender)

    local roleProxy = self:getProxy(GameProxys.Role)
    local isHaveLegion = roleProxy:hasLegion()
    if isHaveLegion == false then
        self:showSysMessage(self:getTextWord(915))
        return
    end  --判断有没有进军团


    local function onRecorderComplete(recorder)
        self:onRecorderComplete(recorder)
    end
    self.view:startRecorder(onRecorderComplete)


    -- 15后自动完成录音
    TimerManager:addOnce(15000, self.autoCompleteRecorder, self)
    self._isRecording = true
end

function LegionChatPanel:autoCompleteRecorder(dt)    
    if self._isRecording then
        self.view:completeRecorder()
        self._isRecording = false
    end        
end

--结束录音
function LegionChatPanel:sendAudioReq(sender)
    -- self:showSysMessage(TextWords:getTextWord(821))
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local isHaveLegion = roleProxy:hasLegion()
    -- if isHaveLegion == false then
    --     self:showSysMessage(self:getTextWord(915))
    --     return
    -- end

    if self._isRecording then
        self.view:completeRecorder()
        self._isRecording = false
    end
    
end

--取消录音
function LegionChatPanel:cancelAudio()
    local roleProxy = self:getProxy(GameProxys.Role)
    local isHaveLegion = roleProxy:hasLegion()
    if isHaveLegion == false then
        -- self:showSysMessage(self:getTextWord(915))
        return
    end

    self.view:cancelRecorder()
    self._isRecording = false
end

function LegionChatPanel:updateChatInfos()
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()


    local tempChat = { }
    local addType = UIChatScrollviewExpand.AddToFront
    local chatType = ChatProxy.ChatType_Legion
    local isReset = self._chatProxy:getReset("isClearLegionChatView")
    if isReset then
        self._chatProxy:setReset(nil, "isClearLegionChatView")
        addType = UIChatScrollviewExpand.AddToBack

        -- 第一次刷聊天从最后一条渲染起
        local chats = self._chatProxy:getLegionChatList()
        for i = #chats, 1, -1 do
            table.insert(tempChat, chats[i])
        end
        self.view:clearChatData(chatType)
    else
        local isInBottom = self._svLegionChat:isInBottom()
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

        --self._imgKai:setVisible(isInBottom == true)
        --self._imgGuan:setVisible(isInBottom == false)
        self._panelCountBg:setVisible(isInBottom == false)
    end

    for k, v in pairs(tempChat) do
        if isReset or v.playerId ~= playerId or v.extendValue ~= 0 or rawget(v, "isShare") == true then
            self._frameQueue:pushParams(self.updateChatLineInfo, self, v, addType)
        end
    end

end


function LegionChatPanel:updateChatLineInfo(chat, addType)

    self._svLegionChat:addItemUI(chat, addType, self, self.renderChatItem, true)
    self:delayJumpToBottom()

end

function LegionChatPanel:delayJumpToBottom()
    self._svLegionChat:jumpToBottom()
    --self._panelTouch:setVisible(false)

    --self._imgKai:setVisible(true)
    --self._imgGuan:setVisible(false)
    self._panelCountBg:setVisible(false)
end

function LegionChatPanel:renderChatItem(chatItem, chat)
    local itemUIHeight = ChatCommon.CommonRender(chatItem, chat, self)

    self._vipPinCCBMap[chatItem] = chatItem

    return itemUIHeight
end

function LegionChatPanel:onClickActor(sender)
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
        self:getProxy(GameProxys.Chat):onTriggerNet140001Req({playerId = id})
    end
    
end

--通过ID来判断是否是系统的信息
function LegionChatPanel:isSystemChat(id)
    local id1 = string.byte(id,1)
    local id2 = string.byte(id,2)
    local id3 = string.byte(id,3)
    local id4 = string.byte(id,4)
    return id1 == 255 and id2 == 255 and id3 == 255 and id4 == 255
end

function LegionChatPanel:onShowInfo(data)
    local parent = self:getParent()
    if self._uiWatch == nil then
        self._uiWatch = UIWatchPlayerInfo.new(parent,self,true)
    end
    self._uiWatch:setMialShield()
    self._uiWatch:showAllInfo(data)
end

function LegionChatPanel:onClickMyActor()
    -- local HeadSculpturePanel = self:getPanel(HeadSculpturePanel.NAME)
    -- HeadSculpturePanel:show()
end

--选择了表情ID
function LegionChatPanel:selectEmotion(id)
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



function LegionChatPanel:onEmotionBtnTouch(sender)
    local emotionPanel = self:getPanel(EmotionPanel.NAME)
    local num = 2
    if self.isEmotion == 0 then
        self.isEmotion = 2
        emotionPanel:show(num)
    else
        self.isEmotion = 0
        emotionPanel:hide()
    end
    
--    SDKManager:showBaiduASRDigitalDialog()
    
end

--按钮选择
function LegionChatPanel:btnClickEvents( sender )
    if sender == self._svLegionChat then
        local emotionPanel = self:getPanel(EmotionPanel.NAME)
        self.isEmotion = 0
        emotionPanel:hide()

        local isInBottom = self._svLegionChat:isInBottom()
--        self._imgKai:setVisible(isInBottom == true)
--        self._imgGuan:setVisible(isInBottom == false)
        self._panelCountBg:setVisible(isInBottom == false)

    elseif sender == self._panelTouch then        
        self:delayJumpToBottom()
        self:updateChatInfos()
    end
end

function LegionChatPanel:onSendBtnTouch(sender)
    local roleProxy = self:getProxy(GameProxys.Role)
    local isHaveLegion = roleProxy:hasLegion()
    if isHaveLegion == false then
        self:showSysMessage(self:getTextWord(915))
        return
    end
    local emotionPanel = self:getPanel(EmotionPanel.NAME)
    self.isEmotion = 0
    emotionPanel:hide()

    
    self._chatEditBox:setText(StringUtils:trim(self._chatEditBox:getText()))
    local text = self._chatEditBox:getText()
    if text == "" then
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

    local data = {}
    data.type = 2
    data.context = text
    self:sendSelfContent(data.context, data.type)
end

function LegionChatPanel:sendSelfContent(context, type, contextType)
    contextType = contextType or 1
    local chatProxy = self:getProxy(GameProxys.Chat)
    
    local isCanSendChat = self:isCanSendChat()
    if isCanSendChat ~= true then
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
    data.type = 2
    data.contextType = contextType
    if contextType == 2 then
        data.chatClientId = self.view:getChatId()
        data.audioSec = self.view:getRecorderTime()
    end
    chatProxy:onTriggerNet140000Req(data)

    -- logger:error("~~~~~~~WorldChatPanel:sendSelfContent:%s~~~~~~~~~~~~~", context)
    --给自己发送信息
    if self._tempContent == context then
        self:showSysMessage(self:getTextWord(906))
        return
    end
    local chatProxy = self:getProxy(GameProxys.Chat)
    -- local isReset = chatProxy:getReset("isClearLegionChatView")
    -- if isReset then
    chatProxy:setReset(nil, "isClearLegionChatView")
        -- self.firstEnterSelfPanel = true
    -- end

    local roleProxy = self:getProxy(GameProxys.Role)
    local titleProxy = self:getProxy(GameProxys.Title)
    local legionProxy = self:getProxy(GameProxys.Legion)
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
    chat.iconId = self._ICONID
    chat.pendantId = self._pendantId
    chat.extendValue = 0
    chat.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    chat.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    chat.legionName = roleProxy:getLegionName()
    chat.contextType = contextType
    chat.chatClientId = data.chatClientId
    chat.audioSec = data.audioSec
    chat.design = titleProxy:getMyUsingTitle()
    chat.frameId = frameProxy:getMyUsingFremeId()
    chat.legionJob = legionProxy:getMineJob()
    
    self:updateChatLineInfo(chat, UIChatScrollviewExpand.AddToFront)
end

function LegionChatPanel:onClosePanelHandler()
    self.lastTime = 6
    ChatCommon.legShow = false
    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
end

--function LegionChatPanel:ShowNoSeeInfoNum(index)
--    if index and index == 2 then
--        local Proxy = self:getProxy(GameProxys.Chat)
--        local num = Proxy:getNotRenderPrivateChatNum()
--        local num2 = Proxy:getNotRenderWorldChatNum()
--        self.allChatNoSeeNum = num + num2
--    else
--            self.allChatNoSeeNum = self.allChatNoSeeNum + 1
--    end
--end

function LegionChatPanel:getlastTime(nowTime) --两次发送的时间差
    local tmpTime = self.oldTime
    if (nowTime - self.oldTime) >= 5 then
        self.oldTime = nowTime
    end
    return nowTime - tmpTime
end

function LegionChatPanel:isCanSendChat()
    local curTime = os.time()
    if  self.oldTime ~= nil and 
        curTime - self.oldTime < self.maxSend then
        return false
    end

    self.oldTime = curTime
    return true
end


function LegionChatPanel:canTouchEmotion()
    self.isEmotion = 0
end

function LegionChatPanel:onTabChangeEvent(tabControl)
    LegionChatPanel.super.onTabChangeEvent(self, tabControl)
    local panel = self:getPanel(EmotionPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end
end