-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
SeasonsModule = class("SeasonsModule", BasicModule)

function SeasonsModule:ctor()
    SeasonsModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER --设置这个能设置层级
    self.isFullScreen = false --设置了这个,就表示是一个UI,这样就不会导致模块关闭的时候,主场景全部隐藏

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function SeasonsModule:initRequire()
    require("modules.seasons.event.SeasonsEvent")
    require("modules.seasons.view.SeasonsView")
end

function SeasonsModule:finalize()
    SeasonsModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function SeasonsModule:initModule()
    SeasonsModule.super.initModule(self)
    self._view = SeasonsView.new(self.parent)

    self:addEventHandler()
end
--关闭之后的模块,重新打开都需要这个函数
function SeasonsModule:onOpenModule()
    self._view:openView()
end

function SeasonsModule:addEventHandler()
    self._view:addEventListener(SeasonsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(SeasonsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE, self, self.updateSeasonView)
    self:addProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE_WORLDLEVEL, self, self.updateWorldLevelView)
end


function SeasonsModule:removeEventHander()
    self._view:removeEventListener(SeasonsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(SeasonsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE, self, self.updateSeasonView)
    self:removeProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE_WORLDLEVEL, self, self.updateWorldLevelView)
end

function SeasonsModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function SeasonsModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function SeasonsModule:updateSeasonView()
    self._view:updateSeasonView()
end

function SeasonsModule:updateWorldLevelView()
    self._view:updateWorldLevelView()
end
