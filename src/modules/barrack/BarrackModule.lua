
BarrackModule = class("BarrackModule", BasicModule)

function BarrackModule:ctor()
    BarrackModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = true
    
    self.showActionType = ModuleShowType.LEFT
    
    self:initRequire()
end

function BarrackModule:initRequire()
    require("modules.barrack.event.BarrackEvent")
    require("modules.barrack.view.BarrackView")
end

function BarrackModule:finalize()
    BarrackModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function BarrackModule:initModule()
    BarrackModule.super.initModule(self)
    self._view = BarrackView.new(self.parent)

    self:addEventHandler()
end

function BarrackModule:addEventHandler()
    self._view:addEventListener(BarrackEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(BarrackEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:addEventListener(BarrackEvent.PRODUCTION_REQ, self, self.onProductionReq)
    self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)
    
    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_PROD_UPDATE, self, self.buildingProdHandler)
end

function BarrackModule:removeEventHander()
    self._view:removeEventListener(BarrackEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(BarrackEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:removeEventListener(BarrackEvent.PRODUCTION_REQ, self, self.onProductionReq)
    self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)

    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_PROD_UPDATE, self, self.buildingProdHandler)
end

--打开建筑功能面板，
function BarrackModule:onOpenModule(extraMsg)
    BarrackModule.super.onOpenModule(self, extraMsg)
    AudioManager:playEffect("yx01")
    self._view:reconnectHandler()
end

--
--请求生产
function BarrackModule:onProductionReq(data)
    local buildingProxy = self:getProxy(GameProxys.Building)
    -- buildingProxy:buildingProductionInfoReq(data)
    buildingProxy:onTriggerNet280006Req(data)
end

----------------

function BarrackModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function BarrackModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function BarrackModule:onItemUseResp(data)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(1011)) --使用物品成功飘字
    end
end

function BarrackModule:onItemBuyResp(data)
    -- body
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(1012)) --购买使用物品成功飘字
    end
end


-------------------------------------------------------------------------------
function BarrackModule:buildingProdHandler()
    self._view:buildingProdHandler()
end
