
EspecialGoodsUseModule = class("EspecialGoodsUseModule", BasicModule)

function EspecialGoodsUseModule:ctor()
    EspecialGoodsUseModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    self:initRequire()
end

function EspecialGoodsUseModule:initRequire()
    require("modules.especialGoodsUse.event.EspecialGoodsUseEvent")
    require("modules.especialGoodsUse.view.EspecialGoodsUseView")
end

function EspecialGoodsUseModule:finalize()
    EspecialGoodsUseModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EspecialGoodsUseModule:initModule()
    EspecialGoodsUseModule.super.initModule(self)
    self._view = EspecialGoodsUseView.new(self.parent)
    self:addEventHandler()
end

function EspecialGoodsUseModule:addEventHandler()
    self._view:addEventListener(EspecialGoodsUseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EspecialGoodsUseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(EspecialGoodsUseEvent.ESPECIALGOODSUSE_REQ, self, self.useEspecialGoodsReq)
    self._view:addEventListener(EspecialGoodsUseEvent.USESENDNOTICE_REQ, self, self.useSendNoticeReq)
    self._view:addEventListener(EspecialGoodsUseEvent.CHECKPLAYERPOINTREQ, self, self.checkPlayerPointReq)

    self._view:addEventListener(EspecialGoodsUseEvent.REDPACKET_ITEMGOODS_USE_REQ,self,self.useRedPacketItemReq) --使用发送红包物品

    self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80006, self, self.checkPlayerPointResp)
    
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onPlayerInfoResp)
    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_ESPECIALUSE, self, self.useEspecialGoodsResp)
    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20400, self, self.onLaterPersonResp) --最近联系人
end

function EspecialGoodsUseModule:removeEventHander()
    self._view:removeEventListener(EspecialGoodsUseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EspecialGoodsUseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(EspecialGoodsUseEvent.ESPECIALGOODSUSE_REQ, self, self.useEspecialGoodsReq)
    self._view:removeEventListener(EspecialGoodsUseEvent.USESENDNOTICE_REQ, self, self.useSendNoticeReq)
    self._view:removeEventListener(EspecialGoodsUseEvent.CHECKPLAYERPOINTREQ, self, self.checkPlayerPointReq)

    self._view:removeEventListener(EspecialGoodsUseEvent.REDPACKET_ITEMGOODS_USE_REQ,self,self.useRedPacketItemReq)

    self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80006, self, self.checkPlayerPointResp)

    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onPlayerInfoResp)
    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_ESPECIALUSE, self, self.useEspecialGoodsResp)
    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20400, self, self.onLaterPersonResp)
end

function EspecialGoodsUseModule:onHideSelfHandler()
    print("jiang **************************")
    local function hideCallback() -- 关闭动作之后，再关闭模块
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
        return ModuleName.EspecialGoodsUseModule
    end
    self:getPanel(EspecialGoodsUsePanel.NAME):hide(hideCallback, self)
    self:getPanel(RedPacketItemUsePanel.NAME):hide(hideCallback, self)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function EspecialGoodsUseModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function EspecialGoodsUseModule:onOpenModule(extraMsg)
    EspecialGoodsUseModule.super.onOpenModule(self)
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20400, {})
    self._view:showExtraMsg(extraMsg)
end

function EspecialGoodsUseModule:useEspecialGoodsReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet90004Req(data)
end

function EspecialGoodsUseModule:useSendNoticeReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet90006Req(data)
end
function EspecialGoodsUseModule:checkPlayerPointReq(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80006, data)
end
function EspecialGoodsUseModule:checkPlayerPointResp(sender)
    if sender.rs == 5 then
        self:showSysMessage(self:getTextWord(4016))
    elseif sender.rs == 0 then
        local data = {}
        data.moduleName = ModuleName.MapModule
        data.extraMsg = {}
        data.extraMsg.tileX = sender.x
        data.extraMsg.tileY = sender.y
        -- self:onShowOtherHandler(data)
        self:sendNotification(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, {tileX = data.extraMsg.tileX,
        tileY = data.extraMsg.tileY})
        self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)
    elseif data.rs == -9 then
        self:showSysMessage(self:getTextWord(4017))
        return
    end
    self:onHideSelfHandler()
end

function EspecialGoodsUseModule:useEspecialGoodsResp(data)
    if data.rs == 0 then
        self:onHideSelfHandler()
    elseif data.rs == -9 then
        self:showSysMessage(self:getTextWord(4017))
    end
end

function EspecialGoodsUseModule:onPlayerInfoResp(data)
     if data.rs == 0 then
        self._view:onPlayerInfoResp(data)
    end
end

function EspecialGoodsUseModule:onLaterPersonResp(data)
    self._view:onLaterPersonResp(data)
end

--function EspecialGoodsUseModule:onHideModule()
--    print("成功关闭特殊物品使用模块")
--end

--发红包
function EspecialGoodsUseModule:useRedPacketItemReq(data)
    local redBagProxy = self:getProxy(GameProxys.RedBag)
    redBagProxy:onTriggerNet540000Req(data)
    self:onHideSelfHandler()
end 