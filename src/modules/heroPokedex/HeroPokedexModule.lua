
------英雄图鉴模块
-----对应示意图：图鉴.jpg
HeroPokedexModule = class("HeroPokedexModule", BasicModule)

function HeroPokedexModule:ctor()
    HeroPokedexModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroPokedexModule:initRequire()
    require("modules.heroPokedex.event.HeroPokedexEvent")
    require("modules.heroPokedex.view.HeroPokedexView")
end

function HeroPokedexModule:finalize()
    HeroPokedexModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroPokedexModule:initModule()
    HeroPokedexModule.super.initModule(self)
    self._view = HeroPokedexView.new(self.parent)

    self:addEventHandler()
end

function HeroPokedexModule:addEventHandler()
    self._view:addEventListener(HeroPokedexEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroPokedexEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function HeroPokedexModule:removeEventHander()
    self._view:removeEventListener(HeroPokedexEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroPokedexEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function HeroPokedexModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroPokedexModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function HeroPokedexModule:onOpenModule(extraMsg, isPerLoad)
    HeroPokedexModule.super.onOpenModule(self, extraMsg, isPerLoad)
    local taskProxy = self:getProxy(GameProxys.Task)
    local flag = taskProxy:getHeroMissionFlag()
    if not flag then
        local heroProxy = self:getProxy(GameProxys.Hero)
        heroProxy:onTriggerNet300007Req()
    end
end