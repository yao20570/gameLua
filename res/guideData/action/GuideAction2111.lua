local GuideAction2111 = class( "GuideAction101", AreaClickAction)
function GuideAction2111:ctor()
   GuideAction2111.super.ctor(self)

  self.info = "打关卡掉落战法秘籍，提升战法"
  self.moduleName = ModuleName.RoleInfoModule
  self.panelName = "RoleInfoPanel"
  self.widgetName = "headBtn"
end

function GuideAction2111:onEnter(guide)
   GuideAction2111.super.onEnter(self, guide)
end

return GuideAction2111
