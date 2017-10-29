
PartsStrengthenModule = class("PartsStrengthenModule", BasicModule)

function PartsStrengthenModule:ctor()
    PartsStrengthenModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    --
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self:initRequire()
end

function PartsStrengthenModule:initRequire()
    require("modules.partsStrengthen.event.PartsStrengthenEvent")
    require("modules.partsStrengthen.view.PartsStrengthenView")
end

function PartsStrengthenModule:finalize()
    PartsStrengthenModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end
--当打开模块的时候要传入数据则重写openModule方法
function PartsStrengthenModule:onOpenModule(extraMsg)
    PartsStrengthenModule.super.onOpenModule(self,extraMsg)
    self._view:onOpenView(extraMsg)
end 

function PartsStrengthenModule:initModule()
    PartsStrengthenModule.super.initModule(self)
    self._view = PartsStrengthenView.new(self.parent)
--    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_3)
    
    self:addEventHandler()
end


function PartsStrengthenModule:addEventHandler()
    self._view:addEventListener(PartsStrengthenEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PartsStrengthenEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:addProxyEventListener(GameProxys.Parts,PartsStrengthenEvent.PARTS_EVENT_EQUIP_PARTS, self, self.onUpdateInfo)
    self:addProxyEventListener(GameProxys.Parts,PartsStrengthenEvent.PARTS_EVENT_STREN_FAILED, self, self.onUpdateInfo)
    self:addProxyEventListener(GameProxys.Parts,AppEvent.PARTS_PIECE_CHANGE_INFO, self, self.onUpdatePieceInfo) -- 军械碎片变更

    self:addProxyEventListener(GameProxys.Parts,AppEvent.PROXY_PARTS_CHANGE, self, self.partsChange)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:addProxyEventListener(GameProxys.Parts, AppEvent.PROXY_PARTS_STRENG, self, self.updateStrengState)

end

function PartsStrengthenModule:removeEventHander()
    self._view:removeEventListener(PartsStrengthenEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PartsStrengthenEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:removeProxyEventListener(GameProxys.Parts,PartsStrengthenEvent.PARTS_EVENT_EQUIP_PARTS, self, self.onUpdateInfo)
    self:removeProxyEventListener(GameProxys.Parts,PartsStrengthenEvent.PARTS_EVENT_STREN_FAILED, self, self.onUpdateInfo)
    self:removeProxyEventListener(GameProxys.Parts,AppEvent.PARTS_PIECE_CHANGE_INFO, self, self.onUpdatePieceInfo) -- 军械碎片变更
    self:removeProxyEventListener(GameProxys.Parts,AppEvent.PROXY_PARTS_CHANGE, self, self.partsChange)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:removeProxyEventListener(GameProxys.Parts, AppEvent.PROXY_PARTS_STRENG, self, self.updateStrengState)

end

function PartsStrengthenModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PartsStrengthenModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


--从服务端接受到数据
function PartsStrengthenModule:onUpdateInfo(data)
    local data = data
    self._view:onUpdateInfo(data)
end
-- 更新碎片信息
function PartsStrengthenModule:onUpdatePieceInfo()
    self._view:onUpdatePieceInfo()
end


-- 更新银币
function PartsStrengthenModule:updateRoleInfoHandler(data)
    -- body
    self._view:updateRoleInfoHandler()
end

function PartsStrengthenModule:updateStrengState(rs)
    self._view:updateStrengState(rs)
end

function PartsStrengthenModule:partsChange()
    self._view:partsChange()
end