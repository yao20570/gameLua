local GuideAction413 = class("GuideAction413", AreaClickAction)

function GuideAction413:ctor()
    GuideAction413.super.ctor(self)
    
    self.info = "讨伐黄巾贼"
    self.moduleName = ModuleName.MapModule
    self.panelName = "MapPanel"
    self.widgetName = "banditDungeon"
    
end

function GuideAction413:onEnter(guide)
    GuideAction413.super.onEnter(self, guide)
end

return GuideAction413