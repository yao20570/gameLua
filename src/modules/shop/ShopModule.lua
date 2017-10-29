
ShopModule = class("ShopModule", BasicModule)

function ShopModule:ctor()
    ShopModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    --
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    --
    
    
    self:initRequire()
end

function ShopModule:initRequire()
    require("modules.shop.event.ShopEvent")
    require("modules.shop.view.ShopView")
end

function ShopModule:finalize()
    ShopModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ShopModule:initModule()
    ShopModule.super.initModule(self)
    self._view = ShopView.new(self.parent)
    --协议消息
    --self._eventCenter = MsgCenter.new()

    self:addEventHandler()
end

function ShopModule:addEventHandler()
    self._view:addEventListener(ShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    -- self:addEventListener(AppEvent.NET_M10, AppEvent.NET_M10_C100008, self, self.onBuyGoodsResp)
    self._view:addEventListener(ShopEvent.SEND_MESSAGE_BUY_GOODS, self, self.onBuyGoodsReq)

    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_BUYGOODS_UPDATE, self, self.onBuyGoodsResp)
end

function ShopModule:removeEventHander()
    self._view:removeEventListener(ShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self:removeEventListener(AppEvent.NET_M10, AppEvent.NET_M10_C100008, self, self.onBuyGoodsResp)
    self._view:removeEventListener(ShopEvent.SEND_MESSAGE_BUY_GOODS, self, self.onBuyGoodsReq)

    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BUYGOODS_UPDATE, self, self.onBuyGoodsResp)
end

function ShopModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ShopModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

--发送购买商品请求
function ShopModule:onBuyGoodsReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet100008Req(data)
    -- local sendData = {}
    -- sendData["moduleId"] = AppEvent.NET_M10 --协议大类
    -- sendData["cmdId"]    = AppEvent.NET_M10_C100008 --子协议
    -- sendData["obj"]      = data --发送的数据
    -- self:sendNotification("net_event", "net_send_data", sendData)
end 
--从服务器接收到数据
function ShopModule:onBuyGoodsResp(data)
    local rs = data.rs
    print("rs ===",rs)
    if rs == 0 then
        self:showSysMessage("购买成功！")
    end 
end 

function ShopModule:onOpenModule(extraMsg)
    ShopModule.super.onOpenModule(self)
    self._view:setFirstPanelShow(extraMsg)
    --self._view:onOpenView()
end
