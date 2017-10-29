local GuideAction464 = class("GuideAction464", AreaClickAction)

function GuideAction464:ctor()
    GuideAction464.super.ctor(self)
    
    self.info = "离开"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoPanel"
    self.widgetName = "closeBtn"
    
end

function GuideAction464:onEnter(guide)
    GuideAction464.super.onEnter(self, guide)
end

return GuideAction464