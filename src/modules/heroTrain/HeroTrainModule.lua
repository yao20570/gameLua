
----英雄模块---武将培养
----对应示意图----武将升级.jpg
HeroTrainModule = class("HeroTrainModule", BasicModule)

function HeroTrainModule:ctor()
    HeroTrainModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroTrainModule:initRequire()
    require("modules.heroTrain.event.HeroTrainEvent")
    require("modules.heroTrain.view.HeroTrainView")
end

function HeroTrainModule:finalize()
    HeroTrainModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroTrainModule:initModule()
    HeroTrainModule.super.initModule(self)
    self._view = HeroTrainView.new(self.parent)

    self:addEventHandler()
end

function HeroTrainModule:addEventHandler()
    self._view:addEventListener(HeroTrainEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroTrainEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROLVUP_UPDATE_VIEW, self, self.chooseHeroOver)
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_INFO, self, self.onLvUpSuccess)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROBF_UPDATE_VIEW, self, self.updateBfView)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_LVUPDATE, self, self.updateLv)
end

function HeroTrainModule:removeEventHander()
    self._view:removeEventListener(HeroTrainEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroTrainEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROLVUP_UPDATE_VIEW, self, self.chooseHeroOver)
    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_INFO, self, self.onLvUpSuccess)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROBF_UPDATE_VIEW, self, self.updateBfView)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_LVUPDATE, self, self.updateLv)

end

function HeroTrainModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroTrainModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function HeroTrainModule:onOpenModule(extraMsg)
    self.super.onOpenModule(self)
    local heroData = extraMsg.heroData
    self._view:saveCurData(heroData)
    self._view:setCurTrainType(extraMsg.TrainType)
end

function HeroTrainModule:chooseHeroOver(data)
    self._view:updateLvUpView(data)
end

function HeroTrainModule:onLvUpSuccess()
    self._view:lvUpSuccess()
end

function HeroTrainModule:updateBfView()
    self._view:updateBfView()
end

function HeroTrainModule:updateLv()
    self._view:updateLv()
end