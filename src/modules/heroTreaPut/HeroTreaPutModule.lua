-- /**
--  * @DateTime:    2016-10-09 
--  * @Description: 宝具模块(穿戴更换)
--  * @Author: lizhuojian
--  */
HeroTreaPutModule = class("HeroTreaPutModule", BasicModule)

function HeroTreaPutModule:ctor()
    HeroTreaPutModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.Animation
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroTreaPutModule:initRequire()
    require("modules.heroTreaPut.event.HeroTreaPutEvent")
    require("modules.heroTreaPut.view.HeroTreaPutView")
end

function HeroTreaPutModule:finalize()
    HeroTreaPutModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroTreaPutModule:initModule()
    HeroTreaPutModule.super.initModule(self)
    self._view = HeroTreaPutView.new(self.parent)

    self:addEventHandler()
end

function HeroTreaPutModule:addEventHandler()
    self._view:addEventListener(HeroTreaPutEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroTreaPutEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
     --20007推送刷新 
    self:addProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_PUT, self, self.treasurePutHandler)
end

function HeroTreaPutModule:removeEventHander()
    self._view:removeEventListener(HeroTreaPutEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroTreaPutEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_PUT, self, self.treasurePutHandler)

end

function HeroTreaPutModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroTreaPutModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
--宝具信息刷新
function HeroTreaPutModule:treasureInfoChange()
   -- self._view:treasureInfoChange()
end
--宝具上下装刷新
function HeroTreaPutModule:treasurePutHandler()
    self._view:treasurePutHandler()
end
