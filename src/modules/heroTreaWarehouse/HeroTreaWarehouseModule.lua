-- /**
--  * @DateTime:    2016-10-09 
--  * @Description: 宝具模块(宝具仓库)
--  * @Author: lizhuojian
--  */
HeroTreaWarehouseModule = class("HeroTreaWarehouseModule", BasicModule)

function HeroTreaWarehouseModule:ctor()
    HeroTreaWarehouseModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.Animation
    
    self:initRequire()
end

function HeroTreaWarehouseModule:initRequire()
    require("modules.heroTreaWarehouse.event.HeroTreaWarehouseEvent")
    require("modules.heroTreaWarehouse.view.HeroTreaWarehouseView")
end

function HeroTreaWarehouseModule:finalize()
    HeroTreaWarehouseModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroTreaWarehouseModule:initModule()
    HeroTreaWarehouseModule.super.initModule(self)
    self._view = HeroTreaWarehouseView.new(self.parent)

    self:addEventHandler()
end

function HeroTreaWarehouseModule:addEventHandler()
    self._view:addEventListener(HeroTreaWarehouseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroTreaWarehouseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --20007推送刷新 宝具信息变更
   self:addProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_UPDATE_INFO, self, self.treasureInfoChange)
   --20007推送刷新 宝具碎片信息变更
   self:addProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_PIECE_UPDATE_INFO, self, self.treasurePieceInfoChange)
   
end

function HeroTreaWarehouseModule:removeEventHander()
    self._view:removeEventListener(HeroTreaWarehouseEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroTreaWarehouseEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_UPDATE_INFO, self, self.treasureInfoChange)
    self:removeProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_PIECE_UPDATE_INFO, self, self.treasurePieceInfoChange)
end

function HeroTreaWarehouseModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroTreaWarehouseModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
--宝具信息刷新
function HeroTreaWarehouseModule:treasureInfoChange()
    self._view:treasureInfoChange()
end
--宝具碎片信息刷新
function HeroTreaWarehouseModule:treasurePieceInfoChange()
    self._view:treasurePieceInfoChange()
end

