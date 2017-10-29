local GuideAction136 = class("GuideAction136", AreaClickAction)

function GuideAction136:ctor()
    GuideAction136.super.ctor(self)
    
    self.info = "升级建筑，领取任务奖励！"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem3"
    self.isShowArrow = false
end

function GuideAction136:onEnter(guide)
    GuideAction136.super.onEnter(self, guide)
    
    guide:hidePanel(ModuleName.MainSceneModule, "BuildingUpPanel")
end

return GuideAction136