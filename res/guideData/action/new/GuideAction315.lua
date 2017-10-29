local GuideAction315 = class("GuideAction315", AreaClickAction)

function GuideAction315:ctor()
    GuideAction315.super.ctor(self)
    
    self.info = "点击"
    self.moduleName = ModuleName.MapModule
    self.panelName = "BanditPanel"
    self.widgetName = "maxFightBtn"
    
end

function GuideAction315:onEnter(guide)
    GuideAction315.super.onEnter(self, guide)
end

return GuideAction315