--游戏更新状态
UpdateState = class("UpdateState",GameBaseState)
function UpdateState:ctor()
    UpdateState.super.ctor(self)
end

function UpdateState:initialize()
    UpdateState.super.initialize(self)
    
    self:openLoginModule()
end

function UpdateState:registerModules()
    self:addModuleConfig(ModuleName.LoaderModule, "modules.loader.LoaderModule")
end

function UpdateState:openLoginModule()
    local data = {}
    data["moduleName"] = ModuleName.LoaderModule
    data["isPerLoad"] = true
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
    
    AppUtils:loadGameComplete()
end