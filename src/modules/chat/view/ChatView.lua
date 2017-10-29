
ChatView = class("ChatView", BasicView)

local TAB_WORLD = 1
local TAB_LEGION = 2
local TAB_PRIVATE = 3

function ChatView:ctor(parent)
    ChatView.super.ctor(self, parent)
end

function ChatView:finalize()
    ChatView.super.finalize(self)
    if self._uiRedPacket then
        self._uiRedPacket:removeFromParent()
        self._uiRedPacket = nil
    end

    if self._uiRedPacketNew then
        self._uiRedPacketNew:removeFromParent()
        self._uiRedPacketNew = nil
    end 

    if self._uiAdviserInfo ~= nil then
        self._uiAdviserInfo:finalize()
        self._uiAdviserInfo = nil
    end

    if self._uiSoldierInfo ~= nil then
        self._uiSoldierInfo:finalize()
        self._uiSoldierInfo = nil
    end
end

function ChatView:registerPanels()
    ChatView.super.registerPanels(self)

    require("modules.chat.panel.ChatPanel")
    self:registerPanel(ChatPanel.NAME, ChatPanel)
    
    require("modules.chat.panel.EmotionPanel")
    self:registerPanel(EmotionPanel.NAME, EmotionPanel)

    require("modules.chat.panel.WorldChatPanel")
    self:registerPanel(WorldChatPanel.NAME,WorldChatPanel)
   
    require("modules.chat.panel.ShieldChatPanel")
    self:registerPanel(ShieldChatPanel.NAME,ShieldChatPanel)

    require("modules.chat.panel.ChatPrivatePanel")
    self:registerPanel(ChatPrivatePanel.NAME,ChatPrivatePanel)
    
    require("modules.chat.panel.LegionChatPanel")
    self:registerPanel(LegionChatPanel.NAME,LegionChatPanel)
    
    require("modules.chat.panel.ChatFriendPanel")
    self:registerPanel(ChatFriendPanel.NAME,ChatFriendPanel)
end

function ChatView:initView()
    -- 没加载的聊天数量
    self._noRenderCount = { [0] = 0, [1] = 0, [2] = 0 }

    -- 没加载的聊天
    self._noRenderChats = { [0] = {}, [1] = {}, [2] = {}}

    local mainPanel = self:getPanel(ChatPanel.NAME)
    mainPanel:show()
    mainPanel:showPanel(WorldChatPanel.NAME)
    mainPanel:showPanel(LegionChatPanel.NAME)
    mainPanel:showPanel(ChatPrivatePanel.NAME)

    
end

function ChatView:onClearCmd()
    local worldChatPanel = self:getPanel(WorldChatPanel.NAME)
    worldChatPanel:onClearCmd()
    local legionChatPanel = self:getPanel(LegionChatPanel.NAME)
    legionChatPanel:onClearCmd()
    local privateChatPanel = self:getPanel(ChatPrivatePanel.NAME)
    privateChatPanel:onClearCmd()
end

--更新其余面板的小红点,决定显示哪个面板
function ChatView:onShowView(extraMsg,isInit)
    ChatView.super.onShowView(self,extraMsg, false)
    local proxy = self:getProxy(GameProxys.Chat)
--    local num_world = proxy:getNotRenderWorldChatNum()  --世界未读
--    local num_private = proxy:getNotRenderPrivateChatNum()  --私聊未读总和
--    local num_legion = proxy:getNotRenderLegionChatNum()   --军团未读

    local mainPanel = self:getPanel(ChatPanel.NAME)
    mainPanel:show()
    mainPanel:hideWatchPanel()
    if extraMsg and extraMsg["type"] == "privateChat" then
        local data = extraMsg["data"]
        mainPanel:showPanel(ChatPrivatePanel.NAME, data)
        self:updateRedCount(TAB_PRIVATE)
        return
    end
    if extraMsg and extraMsg["type"] == "legionChat" then
        mainPanel:showPanel(LegionChatPanel.NAME)
        self:updateRedCount(TAB_LEGION)
        return
    end

    local lastChat = proxy:getLastChatInfo()
    if lastChat == nil or lastChat.type == ChatProxy.ChatType_World then
        mainPanel:showPanel(WorldChatPanel.NAME)
        self:updateRedCount(TAB_WORLD)

    elseif lastChat.type == ChatProxy.ChatType_Legion then
        mainPanel:showPanel(LegionChatPanel.NAME)
        self:updateRedCount(TAB_LEGION)

    elseif lastChat.type == ChatProxy.ChatType_Private then
        mainPanel:showPanel(ChatPrivatePanel.NAME)
        self:updateRedCount(TAB_PRIVATE)
    end

end

--统一刷新小红点
function ChatView:updateRedCount(tab)
    local proxy = self:getProxy(GameProxys.Chat)

    local nums = {}
    nums[ChatProxy.ChatType_World] = proxy:getNotReadChatNum(ChatProxy.ChatType_World)
    nums[ChatProxy.ChatType_Legion] = proxy:getNotReadChatNum(ChatProxy.ChatType_Legion)
    nums[ChatProxy.ChatType_Private] = proxy:getNotReadChatNum(ChatProxy.ChatType_Private)
    
    -- TODO:
    if tab ~= TAB_PRIVATE then
        nums[tab] = 0
    end

    local panel = self:getPanel(ChatPanel.NAME)
    for k,v in pairs(nums) do
        panel:updateRedCount(k, v)
    end
end

-- 更新私聊红点
function ChatView:onUpdateChatPrivateRedPoint()
    local proxy = self:getProxy(GameProxys.Chat)
    local num = proxy:getNotReadChatNum(ChatProxy.ChatType_Private)
    local chatPanel = self:getPanel(ChatPanel.NAME)
    chatPanel:updateRedCount(TAB_PRIVATE, num)
end

--收到140000更新，通过type判断是什么频道。如果对应panel没打开，更新小红点数量
function ChatView:onGetChatInfoResp(data)
    local mainPanel = self:getPanel(ChatPanel.NAME)
    local proxy = self:getProxy(GameProxys.Chat)
    if data.type == 1 then
        local worldPanel = self:getPanel(WorldChatPanel.NAME)
        worldPanel:updateChatInfos(data.chats)
        if not worldPanel:isVisible() then
            local num = proxy:getNotReadChatNum(ChatProxy.ChatType_World)  
            mainPanel:updateRedCount(TAB_WORLD, num)
        end
    else
        local legionPanel = self:getPanel(LegionChatPanel.NAME)
        legionPanel:updateChatInfos(data.chats)
        if not legionPanel:isVisible() then
            local num = proxy:getNotReadChatNum(ChatProxy.ChatType_Legion)  
            mainPanel:updateRedCount(TAB_LEGION, num)
        end
    end


end

--点击头像，请求个人信息返回
function ChatView:onGetPersonInfo(data)
    local panel = self:getPanel(ChatPanel.NAME)
    panel:onShowInfo(data)
end

--搜索协议返回，刷新私聊面板的信息
function ChatView:onGetChatPrivateInfoResp(data)
    local chatPanel = self:getPanel(ChatPanel.NAME)
    chatPanel:show()

    local privatePanel = self:getPanel(ChatPrivatePanel.NAME)  
    local proxy = self:getProxy(GameProxys.Chat)
    local isSend = proxy:getIsChat()
    if isSend then
        privatePanel:sendPrivateData(data)
    else
        chatPanel:showPanel(ChatPrivatePanel.NAME, data)
    end
    
end

--请求屏蔽列表返回
function ChatView:onShieldChatInfoResp( data )
    local ShieldChatPanel = self:getPanel(ShieldChatPanel.NAME)
    ShieldChatPanel:onShieldChatInfoResp(data)
end

--收到私聊信息，panel没show就更新小红点
function ChatView:sendResp(data)   --140003的东西 收到私聊
    local panel = self:getPanel(ChatPrivatePanel.NAME)
    panel:updateUI()
    if not panel:isVisible() then
        local chatPanel = self:getPanel(ChatPanel.NAME)
        local proxy = self:getProxy(GameProxys.Chat)
        --local num = proxy:getNotRenderPrivateChatNum()
        local num = proxy:getNotReadChatNum(ChatProxy.ChatType_Private)  --私聊未读总和
        chatPanel:updateRedCount(TAB_PRIVATE, num)
    end
end

--别的地方点开进入私聊频道
function ChatView:enterPrivate(data)
    local panel = self:getPanel(ChatPanel.NAME)
    panel:show()
    local privatePanel = self:getPanel(ChatPrivatePanel.NAME)
    privatePanel:show(data)
end

function ChatView:onClickLink(type, id , _index, info, posInfo)
    type = tonumber(type)
    -- local shareProxy = self:getProxy(GameProxys.Share)
    -- --self._shareDataMap[shareType][type][id]
    -- print("~~~~~~~~!!!!",_index, type, id)
    local shareData = info
    if shareData == nil then
        logger:error("----点击的分享链接数据为空！---type:%d-id:%s-", type, id)
        return
    end
    if type == ChatShareType.SOLDIRE_TYPE then
        if self._uiSoldierInfo == nil then
            local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
            self._uiSoldierInfo = UISoldierInfo.new(parent, self)
        end
        self._uiSoldierInfo:updateSoldierInfo(tonumber(id), shareData, true)
    elseif type == ChatShareType.REPORT_TYPE then
        local data = {}
        data.moduleName = ModuleName.MailModule
        data.extraMsg = {type = "shares",info = shareData,index = _index}
        self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
    elseif type == ChatShareType.ARENA_TYPE then
        local data = {}
        data.moduleName = ModuleName.ArenaMailModule
        data.extraMsg = {type = "shares",info = shareData}
        self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
    elseif type == ChatShareType.RECRUIT_TYPE then
        -- local data = {}
        local roleProxy = self:getProxy(GameProxys.Role)
        local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
        local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
        local moduleName
        local panelName
        if legionId < 1 then
            local isOpen = roleProxy:isFunctionUnLock(7)
            if isOpen then
                moduleName = ModuleName.LegionApplyModule
                panelName = "LegionListPanel"
            end
            
        else
            moduleName = ModuleName.LegionSceneModule
            panelName = "LegionSceneHallPanel"
            -- data.moduleName = ModuleName.LegionModule
            -- self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
        end
        if panelName ~= nil and moduleName ~= nil then
            ModuleJumpManager:jump(moduleName, panelName)
        end
    elseif type == ChatShareType.ADVISER_TYPE then
        local showData = {}
        showData.adviserInfo = shareData
        local typeId = shareData.typeId
        if typeId == nil then
            return
        end
        if self._uiAdviserInfo == nil then
            self._uiAdviserInfo = UIAdviserInfo.new(self, showData)
        else
            self._uiAdviserInfo:show(showData)
        end
    elseif type == ChatShareType.GMNOTIFIER_TYPE then
        if info == 0 then
            return
        end

        --2016年12月19日19:28:40
        --公告跳转模块，很多特殊处理，待优化

        local config = ConfigDataManager:getConfigById(ConfigData.NoticeConfig, info)
        print("config",config, info)
        if config ~= nil then
            if config.functionOpenID ~= nil then
                local proxy = self:getProxy(GameProxys.Role)
                local isOpen = proxy:isFunctionUnLock(config.functionOpenID)
                if not isOpen then
                    return
                end
            end

            local jumpModule = config.jumpModule
            local jumpPannel = config.jumpPannel
            if jumpPannel == "" then
                jumpPannel = nil
            end

            if jumpModule ~= nil and jumpModule ~= "" then -- 如果有配置
                if config.uiType ~= nil then
                    local proxy = self:getProxy(GameProxys.Activity)
                    local limitInfo = proxy:getLimitInfoByUitype(config.uiType)
                    if limitInfo ~= nil then
                        --限时活动同盟致富需要判断是否入盟与主公等级
                        if config.uiType == ActivityDefine.LIMIT_LEGIONRICH_ID then
                            local roleProxy = self:getProxy(GameProxys.Role)
                            local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
                            local canGo = roleProxy:isFunctionUnLock(7,true)

                            if canGo == false and legionId < 1 then

                            elseif canGo == true and legionId < 1 then
                                self:showSysMessage(self:getTextWord(394013))
                            elseif canGo == true and legionId >= 1 then
                                ModuleJumpManager:jump(jumpModule, jumpPannel)
                            end
                        else
                            ModuleJumpManager:jump(jumpModule, jumpPannel)
                        end
                    else
                        self:showSysMessage("活动已经结束")
                    end
                else
                    local battle = self:getProxy(GameProxys.BattleActivity)
                    if jumpModule == ModuleName.WarlordsModule then
                        battle:onTriggerNet330000Req({activityId = 2})
                    elseif jumpModule == ModuleName.WorldBossModule then
                        local battleInfo = battle:getActivityInfoByUitype(ActivityDefine.SERVER_ACTION_WORLD_BOSS)
                        if battleInfo == nil then
                            self:showSysMessage("活动已经结束")
                            return
                        end
                        ModuleJumpManager:jump(jumpModule, jumpPannel)
                    elseif jumpModule == ModuleName.LordCityModule then
                        logger:info("城主战公告 ^^^^^^")
                        local sendData = {}
                        sendData.moduleName = jumpModule
                        data.srcExtraMsg = {panelName = jumpPannel}
                        self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, sendData)
                    else
                        ModuleJumpManager:jump(jumpModule, jumpPannel)
                    end
                    
                end
                if jumpModule == ModuleName.MapModule then
                    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
                end
            elseif jumpModule == nil then
                -- 都为空
                logger:info("前往坐标")
                if posInfo ~= nil then
                    local data = {}
                    local proxy = self:getProxy(GameProxys.Chat)
                    data.moduleName = ModuleName.MapModule
                    if proxy:isModuleShow(ModuleName.MapModule) then
                        proxy:sendNotification(AppEvent.PROXY_UPDATE_CUR_POS, {tileX = posInfo.x, tileY = posInfo.y})
                    else
                        data.extraMsg = {}
                        data.extraMsg.tileX = posInfo.x
                        data.extraMsg.tileY = posInfo.y
                        self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
                    end
                    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
                end
            end
        end
    elseif type == ChatShareType.HERO_TYPE then
        --UIHeroInfoPanel属于关掉立即释放的面板
        local uiHeroInfoPanel = UIHeroInfoPanel.new(self, info, true)
    elseif type == ChatShareType.PROP_TYPE then
        local itemData = ConfigDataManager:getConfigByPowerAndID(GamePowerConfig.Item, info.typeid)
        --额外拼接字段
        rawset(itemData, "num", info.num or 1)
        rawset(itemData, "power", info.power)
        rawset(itemData, "typeid", info.typeid)
        rawset(itemData, "dec", itemData.info or "")
        local iconTip = UIIconTip.new(self:getParent(), itemData, true, self)
    elseif type == ChatShareType.ORDNANCE_TYPE then
        local data = {}
        data.parts = shareData
        data.power = GamePowerConfig.Ordnance
        data.typeid = shareData.typeid
        data.num = 1
        local watchOrdnance = UIWatchOrdnance.new(self, data, true)
    elseif type == ChatShareType.RESOURCE_TYPE then
        local data = {}
        local proxy = self:getProxy(GameProxys.Chat)
        data.moduleName = ModuleName.MapModule
        if proxy:isModuleShow(ModuleName.MapModule) then
            proxy:sendNotification(AppEvent.PROXY_UPDATE_CUR_POS, {tileX = shareData.x, tileY = shareData.y})
        else
            data.extraMsg = {}
            data.extraMsg.tileX = shareData.x
            data.extraMsg.tileY = shareData.y
            self:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
        end
        self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
    end
end

--获取聊天唯一ID
function ChatView:getChatId()
    --玩家唯一ID + 当前时间戳
    return StringUtils:fixed64ToNormalStr(GameConfig.actorid) .. os.time()
end

--开始录音
function ChatView:startRecorder(onRecorderComplete)
    if self._lastRecorder ~= nil and os.time() - self._lastRecorder <= 2 then --2秒一次录音
        return
    end

    AudioManager:setRecorderEndCallback(onRecorderComplete)
    SDKManager:showASRDigitalDialog()
    self._lastRecorder = os.time()

    AudioManager:pauseMusic()
end

-----获取录音时间
function ChatView:getRecorderTime()
    if self._lastRecorder == nil then
        return 1
    end
    local time = os.time() - self._lastRecorder
    if time <= 0 then
        time = 1
    end
    return time
end

--完成录音
function ChatView:completeRecorder()
    SDKManager:hideASRDigitalDialog()

    AudioManager:resumeMusic()
end

--取消录音
function ChatView:cancelRecorder()
    SDKManager:cancelASRDigitalDialog()

    AudioManager:resumeMusic()
end

function ChatView:removeChateItem(list, index)
    local item = list:getItem(0)

    ComponentUtils:pushListViewItemPool(list, item)

    local children = item:getChildren()
    for _, child in pairs(children) do
        if child:getName() == "RichLabel" and child.dispose ~= nil then
            --child:dispose()
        elseif child:getName() == "Image_7" or child:getName() == "Image_8" then
            local richText = child:getChildByName("RichLabel")
            if richText ~= nil and richText.dispose ~= nil then
                richText:dispose()
            end
        elseif child.effect ~= nil then
           --child.effect:finalize()
           ComponentUtils:pushCCBLayerPool(child.effect)
           child.effect = nil 
        end
    end

    list:removeItem(0)

end

--系统红包详情
function ChatView:showPkgInfoView(data)
    if not self._uiRedPacket then
        self._uiRedPacket = UIRetPacket.new(self, self)
    end
    local info = data.rbrInfo
    local num = data.showNum
    self._uiRedPacket:show(info, data.name, num)
end

--私人红包详情
function ChatView:showPersonRedView(data)
    if not self._uiRedPacketNew then
        self._uiRedPacketNew = UIRetPacketNew.new(self,self)
    end
    -- local info = data.rbrInfo
    -- local num = data.showNum
    self._uiRedPacketNew:show(data)
end 

function ChatView:saveChatData(data)

    local maxCount = ChatProxy.Max_Chat_Count
    local curCount = #self._noRenderChats[data.type]

    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()

    for k, v in pairs(data.chats) do
        if curCount >= maxCount then
            table.remove(self._noRenderChats[data.type], 1)
            curCount = curCount - 1
        end

        table.insert(self._noRenderChats[data.type], v)
        curCount = curCount + 1

        if v.playerId ~= playerId or v.extendValue ~= 0 or rawget(v, "isShare") == true then
            self._noRenderCount[data.type] = self._noRenderCount[data.type] + 1 
        end
    end
    -- print("缓存聊天===",#self._noRenderChats[data.type])
end

function ChatView:getChatData(chatType)
    return self._noRenderChats[chatType] 
end

function ChatView:getChatCount(chatType)
    return self._noRenderCount[chatType]
end

function ChatView:clearChatData(chatType)
    self._noRenderChats[chatType] = {}
    self._noRenderCount[chatType] = 0
end


function ChatView:fixChatEmotionNum(chatContent, maxEmotionNum)

    local texts = ComponentUtils:getChatItem(chatContent)
    local curEmotionNum = 0

    -- 需要删除的表情
    local delEmotionTabel = { }
    for k, v in pairs(texts) do
        if rawget(v, "img") ~= nil then
            if curEmotionNum > maxEmotionNum then
                table.insert(delEmotionTabel, k)
            else
                curEmotionNum = curEmotionNum + 1
            end
        end
    end
    for i = #delEmotionTabel, 1, -1 do
        table.remove(texts, delEmotionTabel[i])
    end
    if #delEmotionTabel > 0 then
        local newStrTable = { }
        for k, v in pairs(texts) do
            table.insert(newStrTable, v.str)
        end
        chatContent = table.concat(newStrTable)
    end

    --返回修正的聊天文本, 表情数量
    return chatContent, curEmotionNum
end