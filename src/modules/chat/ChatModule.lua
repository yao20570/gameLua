
ChatModule = class("ChatModule", BasicModule)

function ChatModule:ctor()
    ChatModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    self.isFullScreen = true
    self.hideRemoveEvent = false
    self:initRequire()
end

function ChatModule:initRequire()
    require("modules.chat.event.ChatEvent")
    require("modules.chat.view.ChatView")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/faceIcon_ui_resouce_big_0.plist")
    require("modules.chat.panel.ChatCommon")
end

function ChatModule:finalize()
    ChatModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ChatModule:initModule()
    ChatModule.super.initModule(self)
    self._view = ChatView.new(self.parent)

    self:addEventHandler()
    -- local proxy = self:getProxy(GameProxys.Chat)
    -- proxy:onTriggerNet140009Req({})
end

function ChatModule:addEventHandler()
    self._view:addEventListener(ChatEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ChatEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.ENTER_PRIVATE, self, self.enterPrivatePanel)--进入私聊
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onChatRespHandle)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_PRIVATECHAT, self, self.onChatPrivateInfoResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_PRIVATECHAT_REDPOINT, self, self.onUpdateChatPrivateRedPoint)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.CLEAR_TOOLBAR_CMD, self, self.onClearCmd)
    
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_SHIELDCHAT_INFO, self, self.onShieldChatInfoResp)
  
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_SHOW_REDPKGVIEW, self, self.showPkgInfoView) --系统红包展示
    self:addProxyEventListener(GameProxys.RedBag,AppEvent.PROXY_SHOW_PERSON_RED_VIEW,self,self.showPersonRedView) --私人红包展示

    self._view:addEventListener(ChatEvent.SEND_CHATSHIELD_INFO_REQ,self, self.onSendShieldChatReq)--5
    
end

function ChatModule:removeEventHander()
    self._view:removeEventListener(ChatEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ChatEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.ENTER_PRIVATE, self, self.enterPrivatePanel)--进入私聊
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_PRIVATECHAT, self, self.onChatPrivateInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_PRIVATECHAT_REDPOINT, self, self.onUpdateChatPrivateRedPoint)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_SHIELDCHAT_INFO, self, self.onShieldChatInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onChatRespHandle)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.CLEAR_TOOLBAR_CMD, self, self.onClearCmd)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_SHOW_REDPKGVIEW, self, self.showPkgInfoView)
    self:removeProxyEventListener(GameProxys.RedBag,AppEvent.PROXY_SHOW_PERSON_RED_VIEW,self,self.showPersonRedView) --私人红包展示
    
    self._view:removeEventListener(ChatEvent.SEND_CHATSHIELD_INFO_REQ,self, self.onSendShieldChatReq)--5
   
end
-------------------------------------------------------
--140000
-------------------------------------------------------
function ChatModule:onGetChatInfoResp(data)
    
--    local chatProxy = self:getProxy(GameProxys.Chat)

--    local condition2 = chatProxy:getCurShowModuleName() == ModuleName.ChatModule
--    local m1 = self:getModule(ModuleName.MapModule)
--    local m2 = self:getModule(ModuleName.MainSceneModule)
--    local isMainShow = false
--    local isMapShow = false
--    --获取map和main两个模块    如果为空，绝对是没打开过的
--    if m1 ~= nil then
--        isMapShow = m1:isVisible()
--    end 
--    if m2 ~= nil then
--        isMainShow = m2:isVisible()
--    end
--    -- local curTime = GameConfig.lastTouchTime
--    self.curTime = self.curTime or GameConfig.lastTouchTime
--    local condition1 = (isMainShow or isMapShow) and os.time() - GameConfig.lastTouchTime >= 5 and os.time() - self.curTime >= 5
--    --如果没打开聊天，在待机情况下刷新，每5秒刷一次
--    if condition1 then
--        logger:error("主城或者野外待机中，5秒过了刷新一次聊天，重置时间，当前时间间隔为%d", os.time() - self.curTime)
--        self.curTime = os.time()
--    end
--    if condition1 or condition2 then
--        if condition1 then
--            local otherData = self._view:getChatData(data.type)
--            local info = {}
--            for k,v in pairs(otherData) do
--                table.insert(info, v)
--            end
--            for k,v in pairs(data.chats) do
--                table.insert(info, v)
--            end
--            data.chats = info
--            self._view:clearChatData(data.type)
--        end
--        --ProfileUtils:PrintTime(2)
--        self._view:onGetChatInfoResp(data)
--        --ProfileUtils:PrintTime(3)
--    else
--        self._view:saveChatData(data)
--    end

        self._view:saveChatData(data)
        self._view:onGetChatInfoResp(data)
end

--------------------------------------------------------
--140001
function ChatModule:onChatPersonInfoResp( data )
    -- body 1Len
    self._view:onGetPersonInfo(data)
end
---------------------------------------------------------------------------
--140003
function ChatModule:onChatRespHandle(data)
    self._view:saveChatData( { type = ChatProxy.ChatType_Private, chats = { data } })
    self._view:sendResp(data)
end
---------------------------------------------------------------------------
--140004
function ChatModule:onChatPrivateInfoResp(data)
    self._view:onGetChatPrivateInfoResp(data)
end

function ChatModule:onUpdateChatPrivateRedPoint()
    self._view:onUpdateChatPrivateRedPoint(data)
end

--140006
function ChatModule:onShieldChatInfoResp( data )    --收到频闭列表
    -- body
    if data.rs == 0 and data.type == 1 then
        self._view:onShieldChatInfoResp(data)
    end
end

function ChatModule:onClearCmd()
    self._view:onClearCmd()
end

function ChatModule:onSendShieldChatReq(data)   --请求频闭列表
    -- self:sendServerMessage(AppEvent.NET_M14,AppEvent.NET_M14_C140006, data)
    local proxy = self:getProxy(GameProxys.Chat)
    proxy:onShieldPlayerListReq(data)
end 

function ChatModule:onHideSelfHandler()
    local proxy = self:getProxy(GameProxys.Chat)
    --local num = proxy:getNotRenderWorldChatNum() + proxy:getNotRenderPrivateChatNum()
    local num = proxy:getNotReadChatNum(ChatProxy.ChatType_World) + proxy:getNotReadChatNum(ChatProxy.ChatType_Legion) + proxy:getNotReadChatNum(ChatProxy.ChatType_Private)
    self:sendNotification(AppEvent.NET_CHATNOTICE, AppEvent.CHAT_NOSEE_UPDATE, num)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ChatModule:onShowOtherHandler(data)
    if data.moduleName == ModuleName.LordCityModule then
        local targetM = self:getModule(self.name)
        local srcModule = targetM.srcModule
        if srcModule ~= nil then
            logger:info("关闭聊天 ^^^^^^ 000")
            self:onHideSelfHandler()
            return
        end
    end

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function ChatModule:enterPrivatePanel(data)
    --  local ChatPanel = self:getPanel(ChatPanel.NAME)
    -- ChatPanel:show()
    -- self:hide()
    self._view:enterPrivate(data)
end

function ChatModule:onOpenModule(extraMsg)
    self.super.onOpenModule(self)
    if not self.isSend then
        local proxy = self:getProxy(GameProxys.Chat)
        proxy:onTriggerNet140009Req({})
        self.isSend = true
    end
end

function ChatModule:onHideModule()
    self.super.onHideModule(self)
    AudioManager:stopRecorderSound(true)
end

--展示系统红包打开界面
function ChatModule:showPkgInfoView(data)
    self._view:showPkgInfoView(data)
end

--展示私人红包打开界面
function ChatModule:showPersonRedView(data)
    self._view:showPersonRedView(data)
end 