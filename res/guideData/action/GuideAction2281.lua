local GuideAction2281 = class( "GuideAction101", DialogueAction)
function GuideAction2281:ctor()
    GuideAction2281.super.ctor(self)

    self.info = "升级或者建造资源点，增加产量"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPos12"
end

function GuideAction2281:onEnter(guide)
    GuideAction2281.super.onEnter(self, guide)
end

return GuideAction2281