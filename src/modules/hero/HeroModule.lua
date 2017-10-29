
----------------英雄武将基础模块
--对应示意图  武将01.jpg
--(PS：通用界面--武将选择--)
HeroModule = class("HeroModule", BasicModule)

function HeroModule:ctor()
    HeroModule .super.ctor(self)
        
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
        
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroModule:initRequire()
    require("modules.hero.event.HeroEvent")
    require("modules.hero.view.HeroView")
end

function HeroModule:finalize()
    HeroModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroModule:initModule()
    HeroModule.super.initModule(self)
    self._view = HeroView.new(self.parent)

    self:addEventHandler()
end

function HeroModule:addEventHandler()
    self._view:addEventListener(HeroEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --20002推送刷新
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updatePosView)
    --20007推送刷新
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_INFO, self, self.heroInfoChange)
    --宝具信息刷新
    self:addProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_UPDATE_INFO, self, self.heroInfoChange)
    --上阵成功刷新
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROSZ_UPDATE_VIEW, self, self.onClosePanel)
    --布阵换位刷新
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_POS_CHANGE, self, self.onPosChangeUpdate)
    --20007刷新（进阶槽位）
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE, self, self.heroInfoChange)

    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_IMG, self, self.updateHeroImg)
end

function HeroModule:removeEventHander()
    self._view:removeEventListener(HeroEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updatePosView)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_INFO, self, self.heroInfoChange)

    self:removeProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_UPDATE_INFO, self, self.heroInfoChange)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HEROSZ_UPDATE_VIEW, self, self.onClosePanel)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_POS_CHANGE, self, self.onPosChangeUpdate)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE, self, self.heroInfoChange)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_HERO_UPDATE_IMG, self, self.updateHeroImg)
end

function HeroModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function HeroModule:onOpenModule(extraMsg)
    HeroModule.super.onOpenModule(self, extraMsg)
    local heroPanel = self._view:getPanel(HeroPanel.NAME)
    if heroPanel:isVisible() then
        heroPanel:onClosePanel()
    end
end

function HeroModule:updatePosView()
    self._view:updatePosView()
end

function HeroModule:heroInfoChange()
    self._view:heroInfoChange()
end

function HeroModule:onClosePanel()
    self._view:onClosePanel()
end

function HeroModule:onPosChangeUpdate(data)
    self._view:onPosChangeUpdate(data)
end

function HeroModule:updateHeroImg()
    self._view:updateHeroImg()
end