local GuideAction2092 = class( "GuideAction101", AreaClickAction)
function GuideAction2092:ctor()
   GuideAction2092.super.ctor(self)

  self.info = "招兵分页"
  self.moduleName = ModuleName.BarrackModule
  self.panelName = "BarrackPanel"
  self.widgetName = "tabBtn2"
end

function GuideAction2092:onEnter(guide)
   GuideAction2092.super.onEnter(self, guide)
end

return GuideAction2092
