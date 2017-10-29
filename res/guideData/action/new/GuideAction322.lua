local GuideAction322 = class("GuideAction322", AreaClickAction)

function GuideAction322:ctor()
    GuideAction322.super.ctor(self)
    
    self.info = "免费加速，立即完成"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "quickBtn"
    self.isShowArrow = false
end

function GuideAction322:onEnter(guide)
    GuideAction322.super.onEnter(self, guide)
    
end

return GuideAction322