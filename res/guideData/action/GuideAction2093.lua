local GuideAction2093 = class( "GuideAction101", AreaClickAction)
function GuideAction2093:ctor()
   GuideAction2093.super.ctor(self)

  self.info = "点击招募"
  self.moduleName = ModuleName.BarrackModule
  self.panelName = "BarrackRecruitPanel"
  self.widgetName = "itemPanel1"
end

function GuideAction2093:onEnter(guide)
   GuideAction2093.super.onEnter(self, guide)
end

return GuideAction2093
