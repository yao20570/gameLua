local GuideAction2424 = class( "GuideAction101", AreaClickAction)
function GuideAction2424:ctor()
    GuideAction2424.super.ctor(self)

    self.info = "点击军械"
  	self.moduleName = ModuleName.PartsWarehouseModule
  	self.panelName = "PWPartsPanel"
  	self.widgetName = "item1"




end

function GuideAction2424:onEnter(guide)
    GuideAction2424.super.onEnter(self, guide)
end

return GuideAction2424