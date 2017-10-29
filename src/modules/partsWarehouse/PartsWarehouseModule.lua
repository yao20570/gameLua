
PartsWarehouseModule = class("PartsWarehouseModule", BasicModule)

function PartsWarehouseModule:ctor()
    PartsWarehouseModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self:initRequire()
end

function PartsWarehouseModule:initRequire()
    require("modules.partsWarehouse.event.PartsWarehouseEvent")
    require("modules.partsWarehouse.view.PartsWarehouseView")
end

function PartsWarehouseModule:finalize()
    PartsWarehouseModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PartsWarehouseModule:initModule()
    PartsWarehouseModule.super.initModule(self)
    self._view = PartsWarehouseView.new(self.parent)
--    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_2)
    self:addEventHandler()
end

function PartsWarehouseModule:addEventHandler()
    self._view:addEventListener(PartsWarehouseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PartsWarehouseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Parts,PartsWarehouseEvent.PARTS_EVENT_UPDATE_WHPARTS, self, self.onUpdateWarehouseParts)
    self:addProxyEventListener(GameProxys.Parts,PartsWarehouseEvent.PARTS_EVENT_UPDATE_WHPIECE, self, self.onUpdateWarehousePiece)
    self:addProxyEventListener(GameProxys.Parts,PartsWarehouseEvent.PARTS_EVENT_UPDATE_WHMATERIAL, self, self.onUpdateWarehouseMaterial)
    --130110晶石数量变化
    self:addProxyEventListener(GameProxys.Parts,AppEvent.PARTS_SPAR_CHANGE_INFO, self, self.onUpdateSparExchange)
    --20007晶石数量变化
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onBagNumChang)

end

function PartsWarehouseModule:removeEventHander()
    self._view:removeEventListener(PartsWarehouseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PartsWarehouseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Parts,PartsWarehouseEvent.PARTS_EVENT_UPDATE_WHPARTS, self, self.onUpdateWarehouseParts)
    self:removeProxyEventListener(GameProxys.Parts,PartsWarehouseEvent.PARTS_EVENT_UPDATE_WHPIECE, self, self.onUpdateWarehousePiece)
    self:removeProxyEventListener(GameProxys.Parts,PartsWarehouseEvent.PARTS_EVENT_UPDATE_WHMATERIAL, self, self.onUpdateWarehouseMaterial)
    self:removeProxyEventListener(GameProxys.Parts,AppEvent.PARTS_SPAR_CHANGE_INFO, self, self.onUpdateSparExchange)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onBagNumChang)
end

function PartsWarehouseModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PartsWarehouseModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT,data)
end


--更新军械变更
function PartsWarehouseModule:onUpdateWarehouseParts(data)
    self._view:updatePartsListView(data)
end 

function PartsWarehouseModule:onUpdateWarehousePiece(data)
    self._view:updatePieceListView(data)
end 
function PartsWarehouseModule:onUpdateWarehouseMaterial(data)
    self._view:updateMaterialListView(data)
end
function PartsWarehouseModule:onUpdateSparExchange(data)
    self._view:onUpdateSparExchange(data)
end
function PartsWarehouseModule:onBagNumChang(data)
    self._view:onUpdateSparExchange(data)
end

