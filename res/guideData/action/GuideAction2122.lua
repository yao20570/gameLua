local GuideAction2122 = class( "GuideAction101", AreaClickAction)
function GuideAction2122:ctor()
   GuideAction2122.super.ctor(self)

  self.info = "打开研究队列"
  self.moduleName = ModuleName.ScienceMuseumModule
  self.panelName = "ScienceMuseumPanel"
  self.widgetName = "tabBtn2"
end

function GuideAction2122:onEnter(guide)
   GuideAction2122.super.onEnter(self, guide)
end

return GuideAction2122
