

RegionModule = class("RegionModule", BasicModule)



function RegionModule:ctor()

    RegionModule .super.ctor(self)

    

    self._view = nil

    self._loginData = nil

    self.showActionType = ModuleShowType.Animation

    self.moduleLevel = ModuleLevel.FREE_LEVEL

    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self:initRequire()

end



function RegionModule:initRequire()

    require("modules.region.event.RegionEvent")

    require("modules.region.view.RegionView")

end



function RegionModule:finalize()

    RegionModule.super.finalize(self)

    self:removeEventHander()

    self._view:finalize()

    self._view = nil

end



function RegionModule:initModule()

    RegionModule.super.initModule(self)

    self._view = RegionView.new(self.parent)



    self:addEventHandler()

end



function RegionModule:addEventHandler()

    self._view:addEventListener(RegionEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)

    self._view:addEventListener(RegionEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)



    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_LIST_INFO_UPDATE, self, self.onDungeonInfoListResp)

    self:addProxyEventListener(GameProxys.LimitExp, AppEvent.PROXY_LIMIT_INFO_UPDATE, self, self.updateInfoResp)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_INFOS, self, self.ondungeonInfoResp) -- 刷新次数



end



function RegionModule:removeEventHander()

    self._view:removeEventListener(RegionEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)

    self._view:removeEventListener(RegionEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)



    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_LIST_INFO_UPDATE, self, self.onDungeonInfoListResp)

    self:removeProxyEventListener(GameProxys.LimitExp, AppEvent.PROXY_LIMIT_INFO_UPDATE, self, self.updateInfoResp)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_INFOS, self, self.ondungeonInfoResp) -- 刷新次数

end



function RegionModule:onHideSelfHandler()

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})

end



function RegionModule:onShowOtherHandler(data)

    if data.id == nil then

        local moduleMap = {}

        moduleMap.moduleName = data.name

        -- moduleMap.srcModule = ModuleName.RegionModule

        -- moduleMap.srcExtraMsg = {panelName = "RegionPanel"}

        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT,moduleMap)

        

    elseif data.id ~= 4 then

        local moduleName = data.name

        local forxy = self:getProxy(GameProxys.Dungeon)

        forxy:setCurrType(data.id,data.type)

        if data.type == 2 then

            forxy:setExploreIndex(data.index)

        end

        local moduleMap = {}

        moduleMap.moduleName = moduleName

        moduleMap.extraMsg = {info = data.info}

        -- moduleMap.srcModule = ModuleName.RegionModule

        if data.type == 2 then

            -- moduleMap.srcExtraMsg = {panelName = "RegionPanel"}

        end

        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, moduleMap)

    else

        local moduleMap = {}

        moduleMap.moduleName = ModuleName.LimitExpModule

        -- moduleMap.srcModule = ModuleName.RegionModule

        -- moduleMap.srcExtraMsg = {panelName = "RegionPanel"}

        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT,moduleMap)

    end

end



function RegionModule:onOpenModule()

    RegionModule.super.onOpenModule(self)

    self:onDungeonInfoListResp()

    

    if self:isModuleShow(ModuleName.TaskModule) == true then --从战功任务跳转过来的，要关闭任务模块

        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.TaskModule})

    end

end



function RegionModule:onDungeonInfoListResp()



    local dungeonProxy = self:getProxy(GameProxys.Dungeon)

    local data = dungeonProxy:getDungeonListInfo()

    local cloneData = clone(data) 

    self._view:updateDungeonInfoList(cloneData.dungeoInfos)



end



function RegionModule:updateRoleInfoHandler()

    self._view:updateRoleInfoHandler()

    local proxy = self:getProxy(GameProxys.RedPoint)

    proxy:checkDungeonRedPoint()

end



function RegionModule:updateInfoResp()

    self._view:updateInfoResp()

end





function RegionModule:ondungeonInfoResp()

    self._view:updateInfoResp()

end

