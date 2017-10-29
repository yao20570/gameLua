local GuideAction2101 = class( "GuideAction101", AreaClickAction)
function GuideAction2101:ctor()
   GuideAction2101.super.ctor(self)

  self.info = "打关卡掉落统率书，提升等级"
  self.moduleName = ModuleName.RoleInfoModule
  self.panelName = "RoleInfoPanel"
  self.widgetName = "headBtn"
end

function GuideAction2101:onEnter(guide)
   GuideAction2101.super.onEnter(self, guide)
end

return GuideAction2101
