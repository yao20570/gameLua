--模块跳转管理器
ModuleJumpManager = {}

function ModuleJumpManager:init(gameState)
    self._gameState = gameState
end

function ModuleJumpManager:finalize()

end

------
-- 跳转管理函数
-- @param  moduleName [string] 目标模块名
-- @param  panelName [string] 目标层级名
-- @param  isPerLoad [bool] 是否预加载
function ModuleJumpManager:jump(moduleName, panelName, isPerLoad)

    if table.indexOf(LegionModuleList, moduleName) >= 0 then --
        local roleProxy = self:getProxy(GameProxys.Role)
        if not roleProxy:hasLegion() then --没有军团，提示不能跳转
            self:showSysMessage(TextWords:getTextWord(915))
            return
        end
    end

    --TODO这样处理跳转世界来关闭其他模块
    if moduleName == ModuleName.MapModule then
        ModuleJumpManager:openMapModule()
        -- if type(self._gameState._showModuleMap) == "table" then
        --     for k,v in pairs(self._gameState._showModuleMap) do
        --         if k ~= ModuleName.MainSceneModule and k ~= ModuleName.ToolbarModule and k ~= ModuleName.RoleInfoModule and k ~= ModuleName.MapModule then
        --             if type(v.sendNotification) == "function" then
        --                 v:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = k})
        --             end
        --         end
        --     end
        -- end
    end

    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingConfigInfo, name = buildingProxy:getBuildConfigByModuleName(moduleName)
    if buildingConfigInfo == nil and  name == nil then

         --//null 单号 7544 策划说这个是个特例  所以写死 以后改动不适用
        if  moduleName == "MainSceneModule2"  and panelName == "BuildingUpPanel"  then      
        local info = {}
        info.type = 1
        info.canbulid = "[2]"
        info.openlv = 3 
        info.ID = 1
        local data = {}
        data.moduleName = "MainSceneModule"
        data.extraMsg = {}
        data.extraMsg.panelName = panelName
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)   
        local panel = self._gameState:getModule("MainSceneModule"):getPanel("BuildingCreatePanel")
        panel:show(info)
        else    
        self:showSysMessage(TextWords:getTextWord(356))
        end
        return 
    end

    if buildingConfigInfo ~= nil then       
        if buildingProxy:isFieldBuilding(buildingConfigInfo.type) then
            -- 野外建筑
            buildingProxy:setBuildingPos(buildingConfigInfo.type, buildingConfigInfo.ID)
            moduleName = name        
        elseif buildingProxy:isBuildingOpen(buildingConfigInfo.type, buildingConfigInfo.ID, false) then        
            buildingProxy:setBuildingPos(buildingConfigInfo.type, buildingConfigInfo.ID)
            moduleName = name
        end
    end
    
    if panelName == "ArenaMainPanel" then
        local soldier = self:getProxy(GameProxys.Arena)
        if not soldier:onGetIsSquire() then
            panelName = "ArenaSqurePanel"
        end
    end

    if moduleName == ModuleName.RankModule then
        local roleProxy = self:getProxy(GameProxys.Role)
        local isOpen = roleProxy:isFunctionUnLock(48)
        if not isOpen then
            return
        end
    end

    if moduleName == ModuleName.PartsModule then
        local roleProxy = self:getProxy(GameProxys.Role)
        local isOpen = roleProxy:isFunctionUnLock(12)
        if not isOpen then
            return
        end
    end

    if moduleName == ModuleName.ConsigliereModule then
        local roleProxy = self:getProxy(GameProxys.Role)
        local isOpen = roleProxy:isFunctionUnLock(45)
        if not isOpen then
            return
        end
    end

    local data = {}
    data.moduleName = moduleName
    data.extraMsg = {}
    data.extraMsg.panelName = panelName
    if isPerLoad ~= nil then
        data.isPerLoad = isPerLoad
    end
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
    
    if moduleName == ModuleName.MainSceneModule then
        self._gameState:openModulePanel(moduleName, panelName)
    end
    return true
end

function ModuleJumpManager:sendNotification(mainevent, subevent, data)
    self._gameState:sendNotification(mainevent, subevent, data)
end

function ModuleJumpManager:getProxy(name)
    return self._gameState:getProxy(name)
end

function ModuleJumpManager:showSysMessage(content, color, font)
    self._gameState:showSysMessage(content, color, font)
end

function ModuleJumpManager:openMapModule()
    if type(self._gameState._showModuleMap) == "table" then
        for k,v in pairs(self._gameState._showModuleMap) do
            if k ~= ModuleName.MainSceneModule and k ~= ModuleName.ToolbarModule and k ~= ModuleName.RoleInfoModule and k ~= ModuleName.MapModule then
                if type(v.sendNotification) == "function" then
                    logger:error("关闭了模块名==%s",k)
                    v:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = k})
                end
            end
        end
    end
end