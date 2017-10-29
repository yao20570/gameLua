
FightingCapModule = class("FightingCapModule", BasicModule)

function FightingCapModule:ctor()
    FightingCapModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    --
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self:initRequire()
end

function FightingCapModule:initRequire()
    require("modules.fightingCap.event.FightingCapEvent")
    require("modules.fightingCap.view.FightingCapView")
end

function FightingCapModule:finalize()
    FightingCapModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function FightingCapModule:initModule()
    FightingCapModule.super.initModule(self)
    self._view = FightingCapView.new(self.parent)

    self:addEventHandler()
end
--显示Module时调用
function FightingCapModule:showModule(extraMsg)
    FightingCapModule.super.showModule(self)
    print("FightingCapModule Open !!!")
    local rankProxy = self:getProxy(GameProxys.Rank)
    rankProxy:onTriggerNet210000Req({typeId = 1}) --请求玩家战力信息

end

function FightingCapModule:addEventHandler()
    self._view:addEventListener(FightingCapEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(FightingCapEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Rank, AppEvent.PROXY_RANK_INFO_UPDATE, self, self.updateRankHandler)
end

function FightingCapModule:removeEventHander()
    self._view:removeEventListener(FightingCapEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(FightingCapEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Rank, AppEvent.PROXY_RANK_INFO_UPDATE, self, self.updateRankHandler)
end

function FightingCapModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function FightingCapModule:onShowOtherHandler(data)
    data.srcModule = self.name
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT,data)
end

--获取服务器数据：玩家战力排名
function FightingCapModule:updateRankHandler()
    self._view:updateRankHandler()
end 