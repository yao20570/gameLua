
LimitExpModule = class("LimitExpModule", BasicModule)

function LimitExpModule:ctor()
    LimitExpModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.Animation
    self._view = nil
    self._loginData = nil
    self:initRequire()
end

function LimitExpModule:initRequire()
    require("modules.limitExp.event.LimitExpEvent")
    require("modules.limitExp.view.LimitExpView")
end

function LimitExpModule:finalize()
    LimitExpModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LimitExpModule:initModule()
    LimitExpModule.super.initModule(self)
    self._view = LimitExpView.new(self.parent)
    
    self._limitExpProxy = self:getProxy(GameProxys.LimitExp)

    self:addEventHandler()
end

function LimitExpModule:addEventHandler()
    self._view:addEventListener(LimitExpEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LimitExpEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    -- self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60100, self, self.onLimitInfosResp)
    self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60102, self, self.onFightingResp)
    self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60103, self, self.onStopRewardResp)

    self._view:addEventListener(LimitExpEvent.AGAINBTN_REQ, self, self.onAgainReqHandler)
    self._view:addEventListener(LimitExpEvent.BACKFIGHT_REQ, self, self.onBackFightReqHandler)
    self._view:addEventListener(LimitExpEvent.BEGIN_FIGHT_REQ, self, self.onBeginFightReqHandler)
    self._view:addEventListener(LimitExpEvent.STOP_FIGHT_REQ, self, self.onStopFightReqHandler)
    self._view:addEventListener(LimitExpEvent.FLUSH_FIGHT_REQ, self, self.onFlushFightReqHandler)

    self._view:addEventListener(LimitExpEvent.OPEN_TEAMMODULE, self, self.onOpenTeamModuleHandler)
    -- self:addProxyEventListener(GameProxys.Chat, AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)
    self:addEventListener(AppEvent.NET_CHATNOTICE,AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)
    self:addProxyEventListener(GameProxys.LimitExp, AppEvent.PROXY_LIMIT_INFO_UPDATE, self, self.updateInfoResp)

end

function LimitExpModule:removeEventHander()
    self._view:removeEventListener(LimitExpEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LimitExpEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    -- self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60100, self, self.onLimitInfosResp)
    self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60102, self, self.onFightingResp)
    self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60103, self, self.onStopRewardResp)

    self._view:removeEventListener(LimitExpEvent.AGAINBTN_REQ, self, self.onAgainReqHandler)
    self._view:removeEventListener(LimitExpEvent.BACKFIGHT_REQ, self, self.onBackFightReqHandler)
    self._view:removeEventListener(LimitExpEvent.BEGIN_FIGHT_REQ, self, self.onBeginFightReqHandler)
    self._view:removeEventListener(LimitExpEvent.STOP_FIGHT_REQ, self, self.onStopFightReqHandler)
    self._view:removeEventListener(LimitExpEvent.OPEN_TEAMMODULE, self, self.onOpenTeamModuleHandler)
    self._view:removeEventListener(LimitExpEvent.FLUSH_FIGHT_REQ, self, self.onFlushFightReqHandler)
    -- self:removeProxyEventListener(GameProxys.Chat, AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)
    self:removeEventListener(AppEvent.NET_CHATNOTICE,AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)
    self:removeProxyEventListener(GameProxys.LimitExp, AppEvent.PROXY_LIMIT_INFO_UPDATE, self, self.updateInfoResp)

end

function LimitExpModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LimitExpModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LimitExpModule:onOpenModule()
    LimitExpModule.super.onOpenModule(self)
    -- self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60100, {})
    self._limitExpProxy:onTriggerNet60100Req({})
end

function LimitExpModule:updateInfoResp()
    self:onLimitInfosResp()
end

function LimitExpModule:onLimitInfosResp(data)
    data = self._limitExpProxy:getExinfos()
    if data.rs == 0 then
        if data.ismop == 0 then
           self._flushFlag = nil
        end

        local flag = nil
        if self._flushFlag ~= nil and self._flushFlag == 1 then
            flag = self._flushFlag
        else
            flag = nil
        end
        self._view:onLimitInfosResp(data, flag)
        self._view:onSetMask()
    end
end

-- 请求重播
function LimitExpModule:onAgainReqHandler(data)
    -- self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
    self._limitExpProxy:onTriggerNet160005Req(data)
end

-- 请求极限重置
function LimitExpModule:onBackFightReqHandler(data)
    -- self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60101, data)
    self._limitExpProxy:onTriggerNet60101Req(data)
end

-- 请求开始极限扫荡
function LimitExpModule:onBeginFightReqHandler()
    -- self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60102, {})
    self._limitExpProxy:onTriggerNet60102Req({})
end

-- 请求停止极限扫荡
function LimitExpModule:onStopFightReqHandler()
    -- self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60103, {})
    self._limitExpProxy:onTriggerNet60103Req({})
end

-- 请求刷新扫荡
function LimitExpModule:onFlushFightReqHandler(data)
    self._flushFlag = data
    -- self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60100, {})
    self._limitExpProxy:onTriggerNet60100Req({})
end


-- 极限扫荡奖励
function LimitExpModule:onStopRewardResp(data)
    if data.rs == 0 then
        self._flushFlag = nil
        self._view:onStopRewardResp(data.rewards)
    end
end

-- 开始扫荡返回
function LimitExpModule:onFightingResp(data)
    if data.rs == 0 then
        self._view:onFightingResp()
    end
end

-- 小红点未读消息
function LimitExpModule:updateNoSeeChatNum(num)
    self._view:updateNoSeeChatNum(num)
end

function LimitExpModule:onOpenTeamModuleHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.TeamModule})
    data["extraMsg"] = "limitExp"
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end