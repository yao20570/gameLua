local GuideAction133 = class("GuideAction133", AreaClickAction)

function GuideAction133:ctor()
    GuideAction133.super.ctor(self)
    
    self.info = "下达建造铁矿场的命令"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingCreatePanel"
    self.widgetName = "createBtn1"
    self.isShowArrow = false
end

function GuideAction133:onEnter(guide)
    GuideAction133.super.onEnter(self, guide)
end

return GuideAction133