local GuideAction422 = class("GuideAction422", AreaClickAction)

function GuideAction422:ctor()
    GuideAction422.super.ctor(self)
    
    self.info = "免费加速，立即完成"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "quickBtn"
    self.isShowArrow = false
end

function GuideAction422:onEnter(guide)
    GuideAction422.super.onEnter(self, guide)
    
end

return GuideAction422