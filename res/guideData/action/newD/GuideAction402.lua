local GuideAction402 = class("GuideAction402", AreaClickAction)

function GuideAction402:ctor()
    GuideAction402.super.ctor(self)
    
    self.info = "点击进城"  --世界地图玩家的据点，点击直接跳转到主城  

    self.moduleName = ModuleName.MapModule
    self.panelName = "MapPanel"
    self.widgetName = "selfBuilding"

    self.callbackArg = true
end

function GuideAction402:callback(value)
    GuideAction402.super.callback(self, value)

    ModuleJumpManager:jump(ModuleName.MainSceneModule, "MainScenePanel")
end

return GuideAction402


