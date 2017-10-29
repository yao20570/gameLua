local GuideAction2202 = class( "GuideAction101", AreaClickAction)
function GuideAction2202:ctor()
   GuideAction2202.super.ctor(self)

  self.info = "点击搜索按钮"
  self.moduleName = ModuleName.MapModule
  self.panelName = "MapInfoPanel"
  self.widgetName = "searchBtn"
end

function GuideAction2202:onEnter(guide)
   GuideAction2202.super.onEnter(self, guide)
end

return GuideAction2202
