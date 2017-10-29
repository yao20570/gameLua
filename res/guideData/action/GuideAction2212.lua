local GuideAction2212 = class( "GuideAction101", AreaClickAction)
function GuideAction2212:ctor()
   GuideAction2212.super.ctor(self)

  self.info = "点击搜索按钮"
  self.moduleName = ModuleName.MapModule
  self.panelName = "MapInfoPanel"
  self.widgetName = "searchBtn"
end

function GuideAction2212:onEnter(guide)
   GuideAction2212.super.onEnter(self, guide)
end

return GuideAction2212
