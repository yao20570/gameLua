local GuideAction132 = class("GuideAction132", AreaClickAction)

function GuideAction132:ctor()
    GuideAction132.super.ctor(self)
    
    self.info = "空地可建造铁、石、木三种资源建筑"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPos8"
    self.isShowArrow = false
end

function GuideAction132:onEnter(guide)
    GuideAction132.super.onEnter(self, guide)
end

return GuideAction132