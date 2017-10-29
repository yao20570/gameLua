local GuideAction436 = class("GuideAction436", AreaClickAction)

function GuideAction436:ctor()
    GuideAction436.super.ctor(self)
    
    self.info = "挑战关卡"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city1"
    self.delayTime = 0.5 

    self.callbackArg = true
end

function GuideAction436:onEnter(guide)
    GuideAction436.super.onEnter(self, guide)
end

return GuideAction436