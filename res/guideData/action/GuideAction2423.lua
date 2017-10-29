local GuideAction2423 = class( "GuideAction101", AreaClickAction)
function GuideAction2423:ctor()
    GuideAction2423.super.ctor(self)

    self.info = "点击军械仓库"
  	self.moduleName = ModuleName.PartsModule
  	self.panelName = "PartsMainPanel"
  	self.widgetName = "warehouseBtn"



end

function GuideAction2423:onEnter(guide)
    GuideAction2423.super.onEnter(self, guide)
end

return GuideAction2423