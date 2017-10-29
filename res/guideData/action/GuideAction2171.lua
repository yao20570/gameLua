local GuideAction2171 = class( "GuideAction101", AreaClickAction)
function GuideAction2171:ctor()
   GuideAction2171.super.ctor(self)

  self.info = "设置头像"
  self.moduleName = ModuleName.SettingModule
  self.panelName = "SettingPanel"
  self.widgetName = "headBtn"
end

function GuideAction2171:onEnter(guide)
   GuideAction2171.super.onEnter(self, guide)
end

return GuideAction2171
