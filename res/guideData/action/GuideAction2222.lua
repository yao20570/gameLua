local GuideAction2222 = class( "GuideAction101", AreaClickAction)
function GuideAction2222:ctor()
   GuideAction2222.super.ctor(self)

  self.info = "选择战功"
  self.moduleName = ModuleName.TaskModule
  self.panelName = "TaskPanel"
  self.widgetName = "tabBtn2"
end

function GuideAction2222:onEnter(guide)
   GuideAction2222.super.onEnter(self, guide)
end

return GuideAction2222
