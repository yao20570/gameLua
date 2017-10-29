local GuideAction336 = class("GuideAction336", AreaClickAction)

function GuideAction336:ctor()
    GuideAction336.super.ctor(self)
    
    self.info = "挑战关卡"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city1"

    self.callbackArg = true
end

function GuideAction336:onEnter(guide)
    GuideAction336.super.onEnter(self, guide)
end

return GuideAction336