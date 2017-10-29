-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownRankModule = class("TownRankModule", BasicModule)

function TownRankModule:ctor()
    TownRankModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function TownRankModule:initRequire()
    require("modules.townRank.event.TownRankEvent")
    require("modules.townRank.view.TownRankView")
end

function TownRankModule:finalize()
    TownRankModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function TownRankModule:initModule()
    TownRankModule.super.initModule(self)
    self._view = TownRankView.new(self.parent)

    self:addEventHandler()
end

function TownRankModule:addEventHandler()
    self._view:addEventListener(TownRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TownRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function TownRankModule:removeEventHander()
    self._view:removeEventListener(TownRankEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TownRankEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function TownRankModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function TownRankModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end