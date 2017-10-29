local GuideAction443 = class("GuideAction443", AreaClickAction)

function GuideAction443:ctor()
    GuideAction443.super.ctor(self)
    
    self.info = "进入兵营"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel9_2"
    self.isShowArrow = false
end

function GuideAction443:onEnter(guide)
    GuideAction443.super.onEnter(self, guide)
end

return GuideAction443