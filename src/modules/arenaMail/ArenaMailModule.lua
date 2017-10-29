
ArenaMailModule = class("ArenaMailModule", BasicModule)

function ArenaMailModule:ctor()
    ArenaMailModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    self.isFullScreen = true
    
    self:initRequire()
end

function ArenaMailModule:initRequire()
    require("modules.arenaMail.event.ArenaMailEvent")
    require("modules.arenaMail.view.ArenaMailView")
end

function ArenaMailModule:finalize()
    ArenaMailModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ArenaMailModule:initModule()
    ArenaMailModule.super.initModule(self)
    self._view = ArenaMailView.new(self.parent)

    self:addEventHandler()
end

function ArenaMailModule:addEventHandler()
    self._view:addEventListener(ArenaMailEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ArenaMailEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:addEventListener(ArenaMailEvent.DELETE_MAILS_REQ, self, self.onDeleteAllMailsHandler)

    self._view:addEventListener(ArenaMailEvent.READ_MAIL_REQ, self, self.onReadMailReqHandler)
    self._view:addEventListener(ArenaMailEvent.FIGHT_AGAIN_REQ, self, self.onFightAgainReqHandler)
    
    --self:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200100, self, self.onGetAllInfosResp)
    --self:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200101, self, self.onReadMailResp)
    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_READMAIL, self, self.onReadMailResp)


    --self:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200102, self, self.onDelteMailResp)

    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_PERMAILS_UPDATE, self, self.onPerMailsUpdate)
end

function ArenaMailModule:removeEventHander()
    self._view:removeEventListener(ArenaMailEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ArenaMailEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:removeEventListener(ArenaMailEvent.DELETE_MAILS_REQ, self, self.onDeleteAllMailsHandler)

    self._view:removeEventListener(ArenaMailEvent.READ_MAIL_REQ, self, self.onReadMailReqHandler)
    self._view:removeEventListener(ArenaMailEvent.FIGHT_AGAIN_REQ, self, self.onFightAgainReqHandler)

    --self:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200100, self, self.onGetAllInfosResp)
    --self:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200101, self, self.onReadMailResp)
    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_READMAIL, self, self.onReadMailResp)

    --self:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200102, self, self.onDelteMailResp)

    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_PERMAILS_UPDATE, self, self.onPerMailsUpdate)
end

function ArenaMailModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ArenaMailModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ArenaMailModule:onOpenModule(extraMsg)
    ArenaMailModule.super.onOpenModule(self)
    if extraMsg == nil then
        self._view:setOpenModule()
        local proxy = self:getProxy(GameProxys.Arena)
        -- proxy:onTriggerNet200105Req()
        --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200100, {})
    else
        -- self._view:onShareFun(extraMsg["info"])
        if extraMsg["info"] == nil then
            self._view:setOpenModule()
            local proxy = self:getProxy(GameProxys.Arena)
            -- proxy:onTriggerNet200105Req()
        else
            self._view:onShareFun(extraMsg["info"])
        end
    end
end

function ArenaMailModule:onDeleteAllMailsHandler(data)
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200102Req(data) 
    --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200102, data)
end

-- function ArenaMailModule:onGetAllInfosResp(data)
--     self._view:onGetAllInfosResp(data)
-- end

function ArenaMailModule:onReadMailResp(data)
    self._view:onReadMailResp(data,self._readType)
end

-- function ArenaMailModule:onDelteMailResp(data)
--     if data.rs == 0 then
--         --0self._view:onDelteMailResp(data)
--     end
-- end

function ArenaMailModule:onReadMailReqHandler(data)
    --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200101, data)
    self._readType = data.type
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200101Req(data)
end

function ArenaMailModule:onFightAgainReqHandler(data)
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet160005Req(data)
    --self:sendServerMessage(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end

function ArenaMailModule:onPerMailsUpdate()
    self._view:onPerMailsUpdate()
end

