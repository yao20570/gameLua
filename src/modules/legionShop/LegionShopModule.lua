
LegionShopModule = class("LegionShopModule", BasicModule)

function LegionShopModule:ctor()
    LegionShopModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER  
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionShopModule:initRequire()
    require("modules.legionShop.event.LegionShopEvent")
    require("modules.legionShop.view.LegionShopView")
end

function LegionShopModule:finalize()
    LegionShopModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionShopModule:initModule()
    LegionShopModule.super.initModule(self)
    self._view = LegionShopView.new(self.parent)

    self:addEventHandler()
end

function LegionShopModule:addEventHandler()
    self._view:addEventListener(LegionShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(LegionShopEvent.SHOW_SHOP_INFO_EVENT_REQ, self, self.onUpdateShopInfoReq)
    self:addProxyEventListener(GameProxys.Legion,AppEvent.PROXY_LEGION_SHOP_INFO_UPDATE, self, self.onUpdateShopInfoResp)
end

function LegionShopModule:removeEventHander()
    self._view:removeEventListener(LegionShopEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionShopEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(LegionShopEvent.SHOW_SHOP_INFO_EVENT_REQ , self, self.onUpdateShopInfoReq)
    self:removeProxyEventListener(GameProxys.Legion,AppEvent.PROXY_LEGION_SHOP_INFO_UPDATE, self, self.onUpdateShopInfoResp)
end

function LegionShopModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionShopModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function LegionShopModule:onOpenModule(extraMsg)
    LegionShopModule.super.onOpenModule(self, extraMsg)
    self._view:setFirstPanelShow()

    local tmpData = {id=0, opt=0, type = 0}
    -- local tmpData2 = {id=0,opt=0, type = 1}   

    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220002Req(tmpData)
    -- TimerManager:addOnce(200, self.onUpdateShopInfoReq, self, tmpData2)
end

function LegionShopModule:onUpdateShopInfoReq(data)
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220002Req(data)
end

function LegionShopModule:onUpdateShopInfoResp(data)
    -- local info = ConfigDataManager:getConfigData(ConfigData.LegionFixShopConfig)
    self._view:onUpdateShopInfoResp()
end