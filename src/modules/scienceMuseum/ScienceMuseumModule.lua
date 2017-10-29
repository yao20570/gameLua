
ScienceMuseumModule = class("ScienceMuseumModule", BasicModule)

function ScienceMuseumModule:ctor()
    ScienceMuseumModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function ScienceMuseumModule:initRequire()
    require("modules.scienceMuseum.event.ScienceMuseumEvent")
    require("modules.scienceMuseum.view.ScienceMuseumView")
end

function ScienceMuseumModule:finalize()
    ScienceMuseumModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ScienceMuseumModule:initModule()
    ScienceMuseumModule.super.initModule(self)
    self._view = ScienceMuseumView.new(self.parent)

    self:addEventHandler()
end

function ScienceMuseumModule:addEventHandler()
    self._view:addEventListener(ScienceMuseumEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ScienceMuseumEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)
    
    self:addProxyEventListener(GameProxys.Role,AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onUpdateBuildingInfo)

   
end

function ScienceMuseumModule:removeEventHander()
    self._view:removeEventListener(ScienceMuseumEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ScienceMuseumEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)
    self:removeProxyEventListener(GameProxys.Role,AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onUpdateBuildingInfo)
end

function ScienceMuseumModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ScienceMuseumModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ScienceMuseumModule:onItemUseResp(data)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(1011)) --使用物品成功飘字：使用成功
    end
end

function ScienceMuseumModule:onItemBuyResp(data)
    -- body
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(1012)) --购买使用物品成功飘字：购买使用成功
    end
end

-- 20007 消息号变更，
function ScienceMuseumModule:onUpdateBuildingInfo()
    self._view:onUpdateBuildingInfo()
end
