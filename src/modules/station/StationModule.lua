--驻军模块
StationModule = class("StationModule", BasicModule)

function StationModule:ctor()
    StationModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self:initRequire()
end

function StationModule:initRequire()
    require("modules.station.event.StationEvent")
    require("modules.station.view.StationView")
end

function StationModule:finalize()
    StationModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function StationModule:initModule()
    StationModule.super.initModule(self)
    self._view = StationView.new(self.parent)
    self:addEventHandler()
    -- local proxy = self:getProxy(GameProxys.Soldier)
    -- proxy:setMapFightAddEquip()
end

function StationModule:addEventHandler()
    self._view:addEventListener(StationEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(StationEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(StationEvent.OPENPARTMODULE_EVENT, self, self.onOpenPartsHandler)
    self._view:addEventListener(StationEvent.OPEN_EQUIPMODULE, self, self.onOpenEquipModule)
    self._view:addEventListener(StationEvent.STATION_REQ, self, self.onStationReq)
    self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80012, self, self.onGetGoSationTime)
    self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80013, self, self.onStationResp)
end

function StationModule:removeEventHander()
    self._view:removeEventListener(StationEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(StationEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(StationEvent.OPENPARTMODULE_EVENT, self, self.onOpenPartsHandler)
    self._view:removeEventListener(StationEvent.OPEN_EQUIPMODULE, self, self.onOpenEquipModule)
    self._view:removeEventListener(StationEvent.STATION_REQ, self, self.onStationReq)
    self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80012, self, self.onGetGoSationTime)
    self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80013, self, self.onStationResp)
end

function StationModule:onOpenModule(extraMsg)
    StationModule.super.onOpenModule(self)
    local proxy = self:getProxy(GameProxys.Soldier)
    proxy:setMaxFighAndWeight() --设置最大战力
    
    local data = {}
    data.x = extraMsg.tileX
    data.y = extraMsg.tileY
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80012, data)
end

function StationModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function StationModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function StationModule:onOpenPartsHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.DungeonModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.PartsModule})
end

function StationModule:onOpenEquipModule()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.DungeonModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.PartsModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.EquipModule})
end

function StationModule:onGetGoSationTime(data)
    self._view:setSolidertime(data)
end

function StationModule:onStationReq(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80013, data)
end

function StationModule:onStationResp(data)
    print("收到驻军啊啊啊")
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(4023))
        self:onHideSelfHandler()
    end
end