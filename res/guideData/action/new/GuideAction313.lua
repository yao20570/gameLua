local GuideAction313 = class("GuideAction313", AreaClickAction)

function GuideAction313:ctor()
    GuideAction313.super.ctor(self)
    
    self.info = "讨伐黄巾贼"
    self.moduleName = ModuleName.MapModule
    self.panelName = "MapPanel"
    self.widgetName = "banditDungeon"
    
end

function GuideAction313:onEnter(guide)
    GuideAction313.super.onEnter(self, guide)
end

return GuideAction313