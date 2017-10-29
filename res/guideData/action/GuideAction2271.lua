local GuideAction2271 = class( "GuideAction101", DialogueAction)
function GuideAction2271:ctor()
    GuideAction2271.super.ctor(self)

    self.info = "升级或者建造资源点，增加产量"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPos1"
end

function GuideAction2271:onEnter(guide)
    GuideAction2271.super.onEnter(self, guide)
end

return GuideAction2271