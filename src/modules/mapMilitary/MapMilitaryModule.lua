-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MapMilitaryModule = class("MapMilitaryModule", BasicModule)

function MapMilitaryModule:ctor()
    MapMilitaryModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER --ÉèÖÃÕâ¸öÄÜÉèÖÃ²ã¼¶
    self.isFullScreen = false --ÉèÖÃÁËÕâ¸ö,¾Í±íÊ¾ÊÇÒ»¸öUI,ÕâÑù¾Í²»»áµ¼ÖÂÄ£¿é¹Ø±ÕµÄÊ±ºò,Ö÷³¡¾°È«²¿Òþ²Ø

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function MapMilitaryModule:initRequire()
    require("modules.mapMilitary.event.MapMilitaryEvent")
    require("modules.mapMilitary.view.MapMilitaryView")
end

function MapMilitaryModule:finalize()
    MapMilitaryModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function MapMilitaryModule:initModule()
    MapMilitaryModule.super.initModule(self)
    self._view = MapMilitaryView.new(self.parent)

    self:addEventHandler()
end

function MapMilitaryModule:addEventHandler()
    self._view:addEventListener(MapMilitaryEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(MapMilitaryEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.MapMilitary, AppEvent.PROXY_MAP_MILITARY_UPDATE, self, self.updateMilitary)
   
    self:addProxyEventListener(GameProxys.MapMilitary, AppEvent.PROXY_MAP_MILITARY_PLAY_ANIM, self, self.onMapMilitaryPlayAnima)

    --中原目标
    self:addProxyEventListener(GameProxys.MapMilitary, AppEvent.PROXY_MAP_MILITARY_PLAINSCHAPTER_UPDATE,self,self.plainschapterUpdate)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.RedPoint, AppEvent.PROXY_REDPOINT_UPDATE, self, self.updateRedPoint) --更新小红�?
 end

function MapMilitaryModule:removeEventHander()
    self._view:removeEventListener(MapMilitaryEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(MapMilitaryEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.MapMilitary, AppEvent.PROXY_MAP_MILITARY_UPDATE, self, self.updateMilitary)  
    
    self:removeProxyEventListener(GameProxys.MapMilitary, AppEvent.PROXY_MAP_MILITARY_PLAY_ANIM, self, self.onMapMilitaryPlayAnima)

    --中原目标
    self:removeProxyEventListener(GameProxys.MapMilitary, AppEvent.PROXY_MAP_MILITARY_PLAINSCHAPTER_UPDATE,self,self.plainschapterUpdate)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.RedPoint, AppEvent.PROXY_REDPOINT_UPDATE, self, self.updateRedPoint)
end

function MapMilitaryModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function MapMilitaryModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function MapMilitaryModule:onOpenModule(extraMsg)
    MapMilitaryModule.super.onOpenModule(self)

    self._view:openView()

    self:updateMilitary()
end


-- Ë¢ÐÂ¾ü¹¦Íæ·¨ºìµã
function MapMilitaryModule:updateMilitary()
    self._view:updateMilitary()
end

-- Ë¢ÐÂ¾ü¹¦Íæ·¨²¥·Å¶¯»­
function MapMilitaryModule:onMapMilitaryPlayAnima(data)
    self._view:onMapMilitaryPlayAnima(data)
end

function MapMilitaryModule:plainschapterUpdate()
    self._view:plainschapterUpdate()
end

--角色信息更新
function MapMilitaryModule:onGetRoleInfo()
    self._view:onGetRoleInfo()
end

function MapMilitaryModule:updateRedPoint()
    self._view:updateRedPoint()
end 