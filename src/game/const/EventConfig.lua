--------------
--事件配置表

EventConfig = {}

EventConfig.ReqRoleInfo = 101  --请求角色信息
EventConfig.PreLoadRoleInfoModule = 102 -- 预加载角色信息模块
EventConfig.PreLoadToolbarModule = 103 -- 预加载 工具栏模块
EventConfig.PreLoadMainSceneModule = 104 -- 预加载主场景模块
EventConfig.EnterScene = 105 --进入场景

EventConfig[ModuleName.RoleInfoModule] =  EventConfig.PreLoadRoleInfoModule
EventConfig[ModuleName.ToolbarModule] =  EventConfig.PreLoadToolbarModule
EventConfig[ModuleName.MainSceneModule] =  EventConfig.PreLoadMainSceneModule

function EventConfig:getPreLoadModuleId(moduleName)
    return EventConfig[moduleName]
end