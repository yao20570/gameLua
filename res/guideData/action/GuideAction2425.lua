local GuideAction2425 = class( "GuideAction101", AreaClickAction)
function GuideAction2425:ctor()
    GuideAction2425.super.ctor(self)

    self.info = "点击装备"
  	self.moduleName = ModuleName.PartsWarehouseModule
  	self.panelName = "PWPartsPanel"
  	self.widgetName = "equipBtn"



end

function GuideAction2425:onEnter(guide)
    GuideAction2425.super.onEnter(self, guide)
end

return GuideAction2425