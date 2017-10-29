local GuideAction473 = class("GuideAction473", AreaClickAction)

function GuideAction473:ctor()
    GuideAction473.super.ctor(self)
    
    self.info = "挑战关卡四"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "exitBtn"
    
end

function GuideAction473:onEnter(guide)
    GuideAction473.super.onEnter(self, guide)

    --
end

return GuideAction473