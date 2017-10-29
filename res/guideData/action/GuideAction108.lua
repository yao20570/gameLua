local GuideAction108 = class("GuideAction108", AreaClickAction)

function GuideAction108:ctor()
    GuideAction108.super.ctor(self)
    
    self.info = "升统率、出战更多士兵，战力飙得快"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoDetailsPanel"
    self.widgetName = "btn3"
    
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction108:onEnter(guide)
    GuideAction108.super.onEnter(self, guide)
end

return GuideAction108