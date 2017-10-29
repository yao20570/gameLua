local GuideAction343 = class("GuideAction343", AreaClickAction)

function GuideAction343:ctor()
    GuideAction343.super.ctor(self)
    
    self.info = "进入兵营"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel9_2"
    self.isShowArrow = false
end

function GuideAction343:onEnter(guide)
    GuideAction343.super.onEnter(self, guide)
end

return GuideAction343