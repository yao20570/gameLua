local GuideAction2241 = class( "GuideAction101", AreaClickAction)
function GuideAction2241:ctor()
   GuideAction2241.super.ctor(self)

  self.info = "查看你的资源"
  self.moduleName = ModuleName.RoleInfoModule
  self.panelName = "RoleInfoPanel"
  self.widgetName = "warehouseBtn"
end

function GuideAction2241:onEnter(guide)
   GuideAction2241.super.onEnter(self, guide)
end

return GuideAction2241
