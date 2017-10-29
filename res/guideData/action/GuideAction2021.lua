local GuideAction2021 = class( "GuideAction101", AreaClickAction)
function GuideAction2021:ctor()
   GuideAction2021.super.ctor(self)

  self.info = "兵营等级提高可招募高级兵种"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel9_2"
end

function GuideAction2021:onEnter(guide)
   GuideAction2021.super.onEnter(self, guide)
end

return GuideAction2021
