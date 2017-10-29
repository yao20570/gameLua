local GuideAction302 = class("GuideAction302", AreaClickAction)

function GuideAction302:ctor()
    GuideAction302.super.ctor(self)
    
    self.info = "点击进城"  --世界地图玩家的据点，点击直接跳转到主城  

    self.moduleName = ModuleName.MapModule
    self.panelName = "MapPanel"
    self.widgetName = "selfBuilding"

    self.callbackArg = true
end

function GuideAction302:callback(value)
    GuideAction302.super.callback(self, value)

    ModuleJumpManager:jump(ModuleName.MainSceneModule, "MainScenePanel")
end

return GuideAction302


