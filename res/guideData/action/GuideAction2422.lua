local GuideAction2422 = class( "GuideAction101", AreaClickAction)
function GuideAction2422:ctor()
    GuideAction2422.super.ctor(self)

    self.info = "点击军械坊"
  	self.moduleName = ModuleName.MainSceneModule
  	self.panelName = "MainScenePanel"
  	self.widgetName = "buildingPanel14_7"


end

function GuideAction2422:onEnter(guide)
    GuideAction2422.super.onEnter(self, guide)
end

return GuideAction2422