
----------英雄---将军府模块
----对应示意图---将军府.jpg\阵法.jpg
HeroHallModule = class("HeroHallModule", BasicModule)

function HeroHallModule:ctor()
    HeroHallModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT 

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroHallModule:initRequire()
    require("modules.heroHall.event.HeroHallEvent")
    require("modules.heroHall.view.HeroHallView")
end

function HeroHallModule:finalize()
    HeroHallModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroHallModule:initModule()
    HeroHallModule.super.initModule(self)
    self._view = HeroHallView.new(self.parent)

    self:addEventHandler()
end

function HeroHallModule:addEventHandler()
    self._view:addEventListener(HeroHallEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroHallEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    --20007推送刷新
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_INFO, self, self.onUpdateView)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onUpdatePropNum)

    --阵法升级
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROZF_UPDATE_VIEW, self, self.onZfLvUpdateSuccess)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_SHOW_RESOLVE, self, self.onShowResolveView)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_POS_RESOLVE, self, self.onResolveResp)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROPIECE_UPDATE_INFO, self, self.updatePieceData)
end

function HeroHallModule:removeEventHander()
    self._view:removeEventListener(HeroHallEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroHallEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onUpdatePropNum)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_INFO, self, self.onUpdateView)
    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROZF_UPDATE_VIEW, self, self.onZfLvUpdateSuccess)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_SHOW_RESOLVE, self, self.onShowResolveView)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_POS_RESOLVE, self, self.onResolveResp)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROPIECE_UPDATE_INFO, self, self.updatePieceData)
end

function HeroHallModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroHallModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function HeroHallModule:onUpdateView(data)
    if self._view == nil then
        return
    end
    self._view:onUpdateView(data)
end

function HeroHallModule:onZfLvUpdateSuccess()
    if self._view == nil then
        return
    end
    self._view:onZfLvUpdateSuccess()
end

function HeroHallModule:onUpdatePropNum()
    if self._view == nil then
        return
    end
    self._view:onUpdatePropNum()
end

function HeroHallModule:onShowResolveView(data)
    if self._view == nil then
        return
    end
    self._view:onShowResolveView(data)
end

function HeroHallModule:onResolveResp()
    if self._view == nil then
        return
    end
    self._view:onResolveResp()
end

function HeroHallModule:updatePieceData()
    if self._view == nil then
        return
    end
    self._view:updatePieceData()
end