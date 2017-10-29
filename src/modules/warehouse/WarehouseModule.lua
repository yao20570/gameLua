-- 仓库储备模块
WarehouseModule = class("WarehouseModule", BasicModule)

function WarehouseModule:ctor()
    WarehouseModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function WarehouseModule:initRequire()
    require("modules.warehouse.event.WarehouseEvent")
    require("modules.warehouse.view.WarehouseView")
end

function WarehouseModule:finalize()
    WarehouseModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function WarehouseModule:initModule()
    WarehouseModule.super.initModule(self)
    self._view = WarehouseView.new(self.parent)

    self:addEventHandler()
end

function WarehouseModule:addEventHandler()
    self._view:addEventListener(WarehouseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(WarehouseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(WarehouseEvent.Item_Use_Req, self, self.onItemUseReq)
    
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
    self:addProxyEventListener(GameProxys.ItemBuff, AppEvent.ITEM_BUFF_UPDATE, self, self.onItemBufferUpdate)
    -- self:addProxyEventListener(GameProxys.Role, AppEvent.GAIN_INFO_UPDATE, self, self.onItemBufferResp)    
    
    -- self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90003, self, self.onItemBufferResp)
    self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)

end

function WarehouseModule:removeEventHander()
    self._view:removeEventListener(WarehouseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(WarehouseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(WarehouseEvent.Item_Use_Req, self, self.onItemUseReq)
    
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)
    self:removeProxyEventListener(GameProxys.ItemBuff, AppEvent.ITEM_BUFF_UPDATE, self, self.onItemBufferUpdate)
    -- self:removeProxyEventListener(GameProxys.Role, AppEvent.GAIN_INFO_UPDATE, self, self.onItemBufferResp)    
    
    -- self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90003, self, self.onItemBufferResp)
    self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)

end

function WarehouseModule:onItemUseReq(data)
    -- body

    local sendData = {}
    if data.type == 0 then
        sendData.typeId = data.itemID
        sendData.num = data.num
        self:sendServerMessage(AppEvent.NET_M9, AppEvent.NET_M9_C90001, sendData)--item use
        elseif data.type == 1 then
            sendData.id = data.id
            self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100007, sendData)--item buy
        end

    logger:info("onItemUse Req")
end


-- buff信息更新
function WarehouseModule:onItemBufferUpdate()
    -- body
    -- print("buff信息更新···WarehouseModule:onItemBufferUpdate()")
    self._view:onItemBufferUpdate()
end

function WarehouseModule:onItemUseResp(data)
    -- body
    logger:info("onItemUseResp rs="..data.rs)
    if data.rs == 0 then
        local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",data.typeId)
        if info.tipShow == 1 then 
            self:showSysMessage(info.useTips)
        else
            self:showSysMessage(self:getTextWord(1011)) --使用物品成功飘字
        end
    end
end

function WarehouseModule:onItemBuyResp(data)
    -- body
    logger:info("onItemBuyResp rs="..data.rs)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(1012)) --购买使用物品成功飘字
    end
end

function WarehouseModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function WarehouseModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

-- 每次从onShowOtherHandler过来都走这条
function WarehouseModule:onOpenModule()
    WarehouseModule.super.onOpenModule(self)
    self:onItemBufferUpdate()
end

function WarehouseModule:updateRoleInfoHandler(data)
    -- body
    self._view:onWarehouseListInfo()
end